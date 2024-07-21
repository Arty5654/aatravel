from .models import Account
from rest_framework import viewsets, generics, status
from rest_framework import permissions
from rest_framework.response import Response
from .serializer import AccountSerializer

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