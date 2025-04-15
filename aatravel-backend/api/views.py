from .models import Account, Photo, Post
from .serializer import AccountSerializer, PhotoSerializer, PostSerializer, ChangePasswordSerializer

from rest_framework import viewsets, generics, status
from rest_framework.views import APIView
from rest_framework.response import Response
from google.auth.transport import requests
from google.oauth2 import id_token
from django.contrib.auth.hashers import check_password, make_password
from django.conf import settings
from rest_framework.parsers import MultiPartParser, FormParser # For Images
from django.contrib.auth import authenticate
from rest_framework.decorators import api_view


class AccountViewSet(viewsets.ModelViewSet):
  queryset = Account.objects.all()
  serializer_class = AccountSerializer
  #permissions_classes = [permissions.IsAuthenticated]

class RegisterView(generics.CreateAPIView):
    queryset = Account.objects.all()
    serializer_class = AccountSerializer

    def post(self, request, *args, **kwargs):
        email = request.data.get('email')
        if Account.objects.filter(email__iexact=email).exists():
            return Response({"error": "An account with this email already exists."},
                            status=status.HTTP_400_BAD_REQUEST)

        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            account = serializer.save()
            return Response(AccountSerializer(account).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    def post(self, request, *args, **kwargs):
        # username or email
        identifier = request.data.get('identifier') 
        password = request.data.get('password')

        user = authenticate(username=identifier, password=password)
        if user:
            serializer = AccountSerializer(user)
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

class GoogleLogin(APIView):
  #queryset = Account.objects.all()
  #serializer_class = AccountSerializer
  def post(self, request, *args, **kwargs):
    token = request.data.get('token')
    try:
      id_info = id_token.verify_oauth2_token(token, requests.Request(), settings.GOOGLE_CLIENT_ID)

      if id_info['iss'] not in ['accounts.google.com', 'https://accounts.google.com']:
        raise ValueError('Wrong issuer.')

      email = id_info['email']
      # Check if the user exists, if not create a new user
      # Return a JWT token or session

      account, created = Account.objects.get_or_create(email=email)
      if created:
        account.password = 'SignedUpWithGoogle'
        account.save()

      return Response({'message': 'User signed in successfully'}, status=status.HTTP_200_OK)
    except ValueError:
      return Response({'error': 'Invalid token'}, status=status.HTTP_400_BAD_REQUEST)

class PhotoUploadView(APIView):
  parser_classes = [MultiPartParser, FormParser]

  def post(self, request, *args, **kwargs):
    serializer = PhotoSerializer(data=request.data)
    if serializer.is_valid():
      #serializer.save(user=request.user)
      serializer.save()
      return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class PostUploadView(APIView):
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request, *args, **kwargs):
        user_uuid = request.data.get('uuid')
        caption = request.data.get('caption')

        try:
            user = Account.objects.get(uuid=user_uuid)
        except Account.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

        # Create the Post
        post = Post.objects.create(user=user, caption=caption)

        index = 0
        while f'image_{index}' in request.FILES:
            image = request.FILES[f'image_{index}']
            location = request.data.get(f'location_{index}', 'Unknown')
            date_taken = request.data.get(f'date_taken_{index}', 'Unknown')

            Photo.objects.create(
                post=post,
                image=image,
                location=location,
                date_taken=date_taken
            )
            index += 1

        return Response({"message": "Post created successfully."}, status=status.HTTP_201_CREATED)


class ProfileView(APIView):
    def get(self, request):
        email = request.query_params.get('email')
        if not email:
            return Response({'error': 'Email required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            account = Account.objects.get(email=email)
        except Account.DoesNotExist:
            return Response({'error': 'Account not found'}, status=status.HTTP_404_NOT_FOUND)

        #serializer = AccountSerializer(account)
        serializer = AccountSerializer(account, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)

class ChangePasswordView(APIView):
    def post(self, request):
        serializer = ChangePasswordSerializer(data=request.data)
        if serializer.is_valid():
            uuid = serializer.validated_data['uuid']
            new_password = serializer.validated_data['new_password']

            try:
                account = Account.objects.get(uuid=uuid)
                account.password = make_password(new_password)
                account.save()
                return Response({"message": "Password updated successfully."}, status=status.HTTP_200_OK)
            except Account.DoesNotExist:
                return Response({"error": "Account not found."}, status=status.HTTP_404_NOT_FOUND)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LogoutView(APIView):
    def post(self, request):
        # Use JWT Tokens later
        return Response({"message": "Logged out successfully."}, status=status.HTTP_200_OK)

class UploadProfilePictureView(APIView):
  def post(self, request):
    uuid = request.data.get('uuid')
    image = request.FILES.get('image')

    if not uuid or not image:
        return Response({'error': 'Missing uuid or image'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        account = Account.objects.get(uuid=uuid)
        account.profile_picture = image
        account.save()
        return Response({'message': 'Profile picture updated'}, status=status.HTTP_200_OK)
    except Account.DoesNotExist:
        return Response({'error': 'Account not found'}, status=status.HTTP_404_NOT_FOUND)
  
class GetProfilePictureView(APIView):
  def post(self, request):
      uuid = request.data.get('uuid')
      try:
          user = Account.objects.get(uuid=uuid)
          return Response({
              "profile_picture_url": user.profile_picture.url if user.profile_picture else ""
          })
      except Account.DoesNotExist:
          return Response({"error": "User not found"}, status=404)


  

