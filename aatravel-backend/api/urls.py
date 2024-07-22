from django.urls import path, include
from . import views
from rest_framework import routers
from .views import AccountViewSet, RegisterView, GoogleLogin

router = routers.DefaultRouter()
router.register(r'accounts', AccountViewSet)

urlpatterns = [
  path('', include(router.urls)),
  path('register/', RegisterView.as_view(), name='register'),
  path('google-login/', GoogleLogin.as_view(), name='google-login'),
  path('api-auth/', include('rest_framework.urls'))
]