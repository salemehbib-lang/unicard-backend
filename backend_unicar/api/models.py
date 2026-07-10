from django.contrib.auth.models import AbstractUser
from django.db import models


class Utilisateur(AbstractUser):
    class Role(models.TextChoices):
        PASSAGER = "passager", "Passager"
        CONDUCTEUR = "conducteur", "Conducteur"
        ADMINISTRATEUR = "administrateur", "Administrateur"

    email = models.EmailField(unique=True)
    telephone = models.CharField(max_length=20, unique=True)
    role = models.CharField(
        max_length=20,
        choices=Role.choices,
        default=Role.PASSAGER,
    )
    est_bloque = models.BooleanField(default=False)

    REQUIRED_FIELDS = ["email", "telephone"]

    def __str__(self):
        return f"{self.username} - {self.role}"