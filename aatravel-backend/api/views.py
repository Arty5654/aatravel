from .models import Account, Photo, Post
from .serializer import AccountSerializer, PhotoSerializer, PostSerializer

from rest_framework import viewsets, generics, status
from rest_framework.views import APIView
from rest_framework.response import Response
from google.auth.transport import requests
from google.oauth2 import id_token
from django.contrib.auth.hashers import check_password
from django.conf import settings
from rest_framework.parsers import MultiPartParser, FormParser # For Images


class AccountViewSet(viewsets.ModelViewSet):
  queryset = Account.objects.all()
  serializer_class = AccountSerializer
  #permissions_classes = [permissions.IsAuthenticated]

class RegisterView(generics.CreateAPIView):
  queryset = Account.objects.all()
  serializer_class = AccountSerializer

  def post(self, request, *args, **kwargs):
    # Check if account exists already
    email = request.data.get('email')
    if Account.objects.filter(email=email).exists():
      return Response({"error": "An account with this email already exists."},
        status=status.HTTP_400_BAD_REQUEST)
    # Normal Account Creation
    serializer = self.get_serializer(data=request.data)
    if serializer.is_valid():
      serializer.save()
      return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
  def post(self, request, *args, **kwargs):
    email = request.data.get('email')
    password = request.data.get('password')

    # Check if account exists
    try:
      account = Account.objects.get(email=email)
      if check_password(password, account.password):
        return Response({'email': account.email}, status=status.HTTP_200_OK)
      else:
        return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)
    except Account.DoesNotExist:
      return Response({'error': 'Account not found'}, status=status.HTTP_404_NOT_FOUND)

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
    def post(self, request, *args, **kwargs):
        # Extract email to associate the post with the user
        user_email = request.data.get('email')
        try:
            user = Account.objects.get(email=user_email)
        except Account.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

        # Handle file upload and metadata
        serializer = PostSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=user)  # Associate user with the post
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
  
def post(self, request, *args, **kwargs):
    user_email = request.data.get('email')
    try:
      user = Account.objects.get(email=user_email)
    except Account.DoesNotExist:
      return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

    # Handle file upload and caption
    serializer = PostSerializer(data=request.data)
    if serializer.is_valid():
      serializer.save(user=user)
      return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
