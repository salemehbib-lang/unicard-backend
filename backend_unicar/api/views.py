from rest_framework import generics, permissions

from .models import Utilisateur
from .serializers import InscriptionSerializer


class InscriptionView(generics.CreateAPIView):
    queryset = Utilisateur.objects.all()
    serializer_class = InscriptionSerializer
    permission_classes = [permissions.AllowAny]