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
    validData['email'] = validData['email'].lower()
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
        fields = ['user', 'image', 'caption', 'location', 'date_taken', 'created_at']

class ChangePasswordSerializer(serializers.Serializer):
    uuid = serializers.UUIDField()
    new_password = serializers.CharField(write_only=True)

    def validate_new_password(self, value):
        if len(value) < 6:
            raise serializers.ValidationError("Password must be at least 6 characters long.")
        return value
