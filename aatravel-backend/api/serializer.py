from rest_framework import serializers
from django.contrib.auth.hashers import make_password
from .models import Account, Photo, Post

class AccountSerializer(serializers.ModelSerializer):
  class Meta:
    model = Account
    fields = ['uuid', 'email', 'password', 'created_at']

    # Password is not in the serialized output
    extra_kwargs = {'password': {'write_only': True}}
  
  def create(self, validData):
    # Hash pass before saving it to DB
    validData['password'] = make_password(validData['password'])
    return super().create(validData)


class PhotoSerializer(serializers.ModelSerializer):
  class Meta:
    model = Photo
    fields = ['image', 'uploaded_at']

# For Posts
class PostSerializer(serializers.ModelSerializer):
  class Meta:
    model = Post
    fields = ['user', 'image', 'caption', 'created_at']