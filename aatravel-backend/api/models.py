from django.db import models
from django.contrib.auth.models import User
from django.conf import settings
import uuid

# Create your models here.
class Account(models.Model):
  uuid = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
  email = models.EmailField(max_length=100, null=True, blank=True)
  password = models.CharField(max_length=100, null=True, blank=True)
  created_at = models.DateTimeField(auto_now_add=True)
  def __str__(self):
    return self.email if self.email else "No Email"

# Photo Upload
class Photo(models.Model):
    #user = models.ForeignKey(User, on_delete=models.CASCADE)
    #TODO: Make sure photos link to the user
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, null=True, blank=True)
    image = models.ImageField(upload_to='photos/')
    uploaded_at = models.DateTimeField(auto_now_add=True)
    
    # def __str__(self):
    #     return f"Photo by {self.user.email}"
    def __str__(self):
        return f"Photo {self.id} - {self.image.name}"

# Create Post
class Post(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, null=True, blank=True)
    image = models.ImageField(upload_to='posts/')
    caption = models.TextField(blank=True)
    location = models.CharField(max_length=255, blank=True, null=True)
    date_taken = models.CharField(max_length=255, blank=True, null=True)  # Storing date as a string for simplicity
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Post by {self.user.email if self.user else 'Unknown'} at {self.created_at}"
