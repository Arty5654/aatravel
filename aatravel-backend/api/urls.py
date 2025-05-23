from django.urls import path, include
from . import views
from rest_framework import routers
from .views import AccountViewSet, RegisterView, GoogleLogin, PhotoUploadView, PostUploadView, LoginView, ProfileView, ChangePasswordView, LogoutView, UploadProfilePictureView, GetProfilePictureView

router = routers.DefaultRouter()
router.register(r'accounts', AccountViewSet)

urlpatterns = [
  path('', include(router.urls)),
  path('register/', RegisterView.as_view(), name='register'),
  path('google-login/', GoogleLogin.as_view(), name='google-login'),
  path('upload/', PhotoUploadView.as_view(), name='upload-photo'),
  path('upload-post/', PostUploadView.as_view(), name='upload-post'),
  path('profile/', ProfileView.as_view(), name='profile'),
  path('change-password/', ChangePasswordView.as_view(), name='change-password'),
  path('login/', LoginView.as_view(), name='login'),
  path('logout/', LogoutView.as_view(), name='logout'),
  path('upload-profile-picture/', UploadProfilePictureView.as_view(), name='upload-profile-picture'),
  path('get-profile-picture/', GetProfilePictureView.as_view(), name='get-profile-picture'),
  path('api-auth/', include('rest_framework.urls'))
]