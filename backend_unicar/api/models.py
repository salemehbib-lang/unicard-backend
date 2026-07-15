from django.contrib.auth.models import AbstractUser
from django.db import models



# UTILISATEURS

class Utilisateur(AbstractUser):

    class Role(models.TextChoices):
        PASSAGER = "passager", "Passager"
        CONDUCTEUR = "conducteur", "Conducteur"
        ADMINISTRATEUR = "administrateur", "Administrateur"

    email = models.EmailField(
        unique=True
    )

    telephone = models.CharField(
        max_length=20,
        unique=True
    )

    role = models.CharField(
        max_length=20,
        choices=Role.choices,
        default=Role.PASSAGER,
    )

    est_bloque = models.BooleanField(
        default=False
    )

    REQUIRED_FIELDS = [
        "email",
        "telephone",
    ]

    def __str__(self):
        return f"{self.username} - {self.get_role_display()}"



# VEHICULES

class Vehicule(models.Model):

    proprietaire = models.ForeignKey(
        Utilisateur,
        on_delete=models.CASCADE,
        related_name="vehicules",
    )

    marque = models.CharField(
        max_length=100
    )

    modele = models.CharField(
        max_length=100
    )

    immatriculation = models.CharField(
        max_length=30,
        unique=True
    )

    couleur = models.CharField(
        max_length=50
    )

    nombre_places = models.PositiveSmallIntegerField()

    est_actif = models.BooleanField(
        default=True
    )

    date_creation = models.DateTimeField(
        auto_now_add=True
    )

    class Meta:
        ordering = ["-date_creation"]

    def __str__(self):
        return (
            f"{self.marque} {self.modele} "
            f"- {self.immatriculation}"
        )



# TRAJETS

class Trajet(models.Model):

    class Statut(models.TextChoices):
        PUBLIE = "publie", "Publié"
        COMPLET = "complet", "Complet"
        ANNULE = "annule", "Annulé"
        TERMINE = "termine", "Terminé"

    class Etat(models.TextChoices):
        EN_ATTENTE_DEPART = (
            "en_attente_depart",
            "En attente du départ",
        )

        CHAUFFEUR_EN_ROUTE = (
            "chauffeur_en_route",
            "Chauffeur en route",
        )

        CHAUFFEUR_ARRIVE = (
            "chauffeur_arrive",
            "Chauffeur arrivé",
        )

        EN_COURS = (
            "en_cours",
            "Trajet en cours",
        )

        TERMINE = (
            "termine",
            "Trajet terminé",
        )

    conducteur = models.ForeignKey(
        Utilisateur,
        on_delete=models.CASCADE,
        related_name="trajets",
    )

    vehicule = models.ForeignKey(
        Vehicule,
        on_delete=models.PROTECT,
        related_name="trajets",
    )

    lieu_depart = models.CharField(
        max_length=150
    )

    lieu_arrivee = models.CharField(
        max_length=150
    )

    date_depart = models.DateField()

    heure_depart = models.TimeField()

    nombre_places_disponibles = (
        models.PositiveSmallIntegerField()
    )

    prix_par_place = models.DecimalField(
        max_digits=10,
        decimal_places=2,
    )

    description = models.TextField(
        blank=True,
        null=True,
    )

    statut = models.CharField(
        max_length=20,
        choices=Statut.choices,
        default=Statut.PUBLIE,
    )

    etat = models.CharField(
        max_length=30,
        choices=Etat.choices,
        default=Etat.EN_ATTENTE_DEPART,
    )

    date_creation = models.DateTimeField(
        auto_now_add=True
    )

    date_modification = models.DateTimeField(
        auto_now=True
    )

    class Meta:
        ordering = [
            "date_depart",
            "heure_depart",
        ]

    def __str__(self):
        return (
            f"{self.lieu_depart} → "
            f"{self.lieu_arrivee} "
            f"le {self.date_depart}"
        )



# RESERVATIONS

class Reservation(models.Model):

    class Statut(models.TextChoices):
        EN_ATTENTE = (
            "en_attente",
            "En attente",
        )

        ACCEPTEE = (
            "acceptee",
            "Acceptée",
        )

        REFUSEE = (
            "refusee",
            "Refusée",
        )

        ANNULEE = (
            "annulee",
            "Annulée",
        )

    trajet = models.ForeignKey(
        Trajet,
        on_delete=models.CASCADE,
        related_name="reservations",
    )

    passager = models.ForeignKey(
        Utilisateur,
        on_delete=models.CASCADE,
        related_name="reservations",
    )

    nombre_places = models.PositiveSmallIntegerField(
        default=1
    )

    statut = models.CharField(
        max_length=20,
        choices=Statut.choices,
        default=Statut.EN_ATTENTE,
    )

    date_reservation = models.DateTimeField(
        auto_now_add=True
    )

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=[
                    "trajet",
                    "passager",
                ],
                name=(
                    "reservation_unique_par_passager_et_trajet"
                ),
            )
        ]

        ordering = [
            "-date_reservation",
        ]

    def __str__(self):
        return (
            f"{self.passager.username} "
            f"→ trajet {self.trajet.id}"
        )

# NOTIFICATIONS

class Notification(models.Model):

    class Type(models.TextChoices):
        CHAUFFEUR_EN_ROUTE = (
            "chauffeur_en_route",
            "Chauffeur en route",
        )
        CHAUFFEUR_ARRIVE = (
            "chauffeur_arrive",
            "Chauffeur arrivé",
        )
        TRAJET_COMMENCE = (
            "trajet_commence",
            "Trajet commencé",
        )
        TRAJET_TERMINE = (
            "trajet_termine",
            "Trajet terminé",
        )

    utilisateur = models.ForeignKey(
        Utilisateur,
        on_delete=models.CASCADE,
        related_name="notifications",
    )

    trajet = models.ForeignKey(
        Trajet,
        on_delete=models.CASCADE,
        related_name="notifications",
        null=True,
        blank=True,
    )

    type_notification = models.CharField(
        max_length=30,
        choices=Type.choices,
    )

    titre = models.CharField(
        max_length=150,
    )

    message = models.TextField()

    est_lue = models.BooleanField(
        default=False,
    )

    date_creation = models.DateTimeField(
        auto_now_add=True,
    )

    class Meta:
        ordering = [
            "-date_creation",
        ]

    def __str__(self):
        return (
            f"{self.utilisateur.username} - "
            f"{self.titre}"
        )
    TRAJET_ANNULE = (
    "trajet_annule",
    "Trajet annulé",
    )