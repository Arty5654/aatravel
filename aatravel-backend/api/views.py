from .models import Account, Photo
from rest_framework import viewsets, generics, status
from rest_framework.views import APIView
from rest_framework.response import Response
from .serializer import AccountSerializer, PhotoSerializer
from google.auth.transport import requests
from google.oauth2 import id_token
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
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

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