from rest_framework import serializers
from django.contrib.auth.hashers import make_password
from .models import Account, Photo, Post

class AccountSerializer(serializers.ModelSerializer):
  profile_picture_url = serializers.SerializerMethodField()
  class Meta:
    model = Account
    fields = ['uuid', 'email', 'password', 'created_at', 'profile_picture_url']

    # Password is not in the serialized output
    extra_kwargs = {'password': {'write_only': True}}
  
  def get_profile_picture_url(self, obj):
        request = self.context.get('request')
        if obj.profile_picture and hasattr(obj.profile_picture, 'url'):
            return request.build_absolute_uri(obj.profile_picture.url) if request else obj.profile_picture.url
        return None
  
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
