from rest_framework import generics, permissions

from .models import Utilisateur
from .serializers import (
    InscriptionSerializer,
    ProfilUtilisateurSerializer,
)


class InscriptionView(generics.CreateAPIView):
    queryset = Utilisateur.objects.all()
    serializer_class = InscriptionSerializer
    permission_classes = [permissions.AllowAny]


class ProfilUtilisateurView(generics.RetrieveUpdateAPIView):
    serializer_class = ProfilUtilisateurSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user