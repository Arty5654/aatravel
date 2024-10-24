from rest_framework import serializers
from .models import Account, Photo

class AccountSerializer(serializers.ModelSerializer):
  class Meta:
    model = Account
    #fields = ['email', 'password' 'created_at']
    #fields = '__all__'
    fields = ['id', 'email', 'password', 'created_at']

class PhotoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Photo
        fields = ['image', 'uploaded_at']