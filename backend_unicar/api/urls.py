from django.urls import path
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

from .views import InscriptionView


urlpatterns = [
    path(
        "auth/inscription/",
        InscriptionView.as_view(),
        name="inscription",
    ),
    path(
        "auth/connexion/",
        TokenObtainPairView.as_view(),
        name="connexion",
    ),
    path(
        "auth/token/refresh/",
        TokenRefreshView.as_view(),
        name="token_refresh",
    ),
]