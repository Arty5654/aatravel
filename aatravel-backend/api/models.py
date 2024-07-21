from django.db import models

# Create your models here.
class Account(models.Model):
  email = models.EmailField(max_length=100, null=True, blank=True)
  password = models.CharField(max_length=100, null=True, blank=True)
  created_at = models.DateTimeField(auto_now_add=True)
  def __str__(self):
    return self.email if self.email else "No Email"