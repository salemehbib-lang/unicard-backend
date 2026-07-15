from rest_framework.permissions import BasePermission

from .models import Utilisateur


class EstConducteur(BasePermission):
    message = "Cette action est réservée aux conducteurs."

    def has_permission(self, request, view):
        return (
            request.user
            and request.user.is_authenticated
            and request.user.role
            == Utilisateur.Role.CONDUCTEUR
            and not request.user.est_bloque
        )


class EstAdministrateur(BasePermission):
    message = "Cette action est réservée aux administrateurs."

    def has_permission(self, request, view):
        return (
            request.user
            and request.user.is_authenticated
            and (
                request.user.role
                == Utilisateur.Role.ADMINISTRATEUR
                or request.user.is_superuser
            )
            and not request.user.est_bloque
        )