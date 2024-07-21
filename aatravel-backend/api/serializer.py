from .models import Account
from rest_framework import serializers

class AccountSerializer(serializers.ModelSerializer):
  class Meta:
    model = Account
    #fields = ['email', 'password' 'created_at']
    #fields = '__all__'
    fields = ['id', 'email', 'password', 'created_at']