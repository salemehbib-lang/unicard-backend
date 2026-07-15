from django.contrib import admin

from .models import Utilisateur, Vehicule


@admin.register(Utilisateur)
class UtilisateurAdmin(admin.ModelAdmin):
    list_display = (
        "username",
        "email",
        "telephone",
        "role",
        "est_bloque",
    )
    list_filter = ("role", "est_bloque")
    search_fields = ("username", "email", "telephone")


@admin.register(Vehicule)
class VehiculeAdmin(admin.ModelAdmin):
    list_display = (
        "immatriculation",
        "marque",
        "modele",
        "proprietaire",
        "nombre_places",
        "est_actif",
    )
    list_filter = ("est_actif", "marque")
    search_fields = (
        "immatriculation",
        "marque",
        "modele",
        "proprietaire__username",
    )