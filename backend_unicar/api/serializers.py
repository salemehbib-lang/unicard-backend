from django.contrib.auth.password_validation import validate_password
from django.utils import timezone
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

from .models import (
    Utilisateur,
    Vehicule,
    Trajet,
    Reservation,
    Notification,
)



# INSCRIPTION

class InscriptionSerializer(serializers.ModelSerializer):
    password = serializers.CharField(
        write_only=True,
        required=True,
        validators=[validate_password],
        style={"input_type": "password"},
    )

    password_confirmation = serializers.CharField(
        write_only=True,
        required=True,
        style={"input_type": "password"},
    )

    class Meta:
        model = Utilisateur
        fields = [
            "id",
            "username",
            "first_name",
            "last_name",
            "email",
            "telephone",
            "role",
            "password",
            "password_confirmation",
        ]

        read_only_fields = [
            "id",
        ]

    def validate_role(self, value):
        roles_autorises = [
            Utilisateur.Role.PASSAGER,
            Utilisateur.Role.CONDUCTEUR,
        ]

        if value not in roles_autorises:
            raise serializers.ValidationError(
                "Le rôle doit être passager ou conducteur."
            )

        return value

    def validate(self, attrs):
        password = attrs.get("password")
        confirmation = attrs.get(
            "password_confirmation"
        )

        if password != confirmation:
            raise serializers.ValidationError(
                {
                    "password_confirmation": (
                        "Les mots de passe ne correspondent pas."
                    )
                }
            )

        return attrs

    def create(self, validated_data):
        validated_data.pop(
            "password_confirmation"
        )

        password = validated_data.pop(
            "password"
        )

        utilisateur = Utilisateur(
            **validated_data
        )

        utilisateur.set_password(password)
        utilisateur.save()

        return utilisateur
    
# PROFIL UTILISATEUR

class ProfilUtilisateurSerializer(serializers.ModelSerializer):

    class Meta:
        model = Utilisateur
        fields = [
            "id",
            "username",
            "first_name",
            "last_name",
            "email",
            "telephone",
            "role",
            "est_bloque",
            "date_joined",
        ]

        read_only_fields = [
            "id",
            "username",
            "role",
            "est_bloque",
            "date_joined",
        ]



    
# CHANGEMENT DE MOT DE PASSE

class ChangerMotDePasseSerializer(serializers.Serializer):
    ancien_mot_de_passe = serializers.CharField(
        write_only=True,
        style={"input_type": "password"},
    )

    nouveau_mot_de_passe = serializers.CharField(
        write_only=True,
        validators=[validate_password],
        style={"input_type": "password"},
    )

    confirmation_mot_de_passe = serializers.CharField(
        write_only=True,
        style={"input_type": "password"},
    )

    def validate_ancien_mot_de_passe(self, value):
        utilisateur = self.context["request"].user

        if not utilisateur.check_password(value):
            raise serializers.ValidationError(
                "L’ancien mot de passe est incorrect."
            )

        return value

    def validate(self, attrs):
        nouveau = attrs["nouveau_mot_de_passe"]
        confirmation = attrs["confirmation_mot_de_passe"]
        ancien = attrs["ancien_mot_de_passe"]

        if nouveau != confirmation:
            raise serializers.ValidationError(
                {
                    "confirmation_mot_de_passe": (
                        "Les deux nouveaux mots de passe "
                        "ne correspondent pas."
                    )
                }
            )

        if ancien == nouveau:
            raise serializers.ValidationError(
                {
                    "nouveau_mot_de_passe": (
                        "Le nouveau mot de passe doit être différent "
                        "de l’ancien."
                    )
                }
            )

        return attrs

    class Meta:
        model = Utilisateur
        fields = [
            "id",
            "username",
            "first_name",
            "last_name",
            "email",
            "telephone",
            "role",
            "password",
            "password_confirmation",
        ]

        read_only_fields = [
            "id",
        ]

    def validate_role(self, value):
        roles_autorises = [
            Utilisateur.Role.PASSAGER,
            Utilisateur.Role.CONDUCTEUR,
        ]

        if value not in roles_autorises:
            raise serializers.ValidationError(
                "Le rôle doit être passager ou conducteur."
            )

        return value

    def validate(self, attrs):
        if attrs["password"] != attrs["password_confirmation"]:
            raise serializers.ValidationError(
            {
                "password_confirmation":
                    "Les mots de passe ne correspondent pas."
            }
        )

        return attrs

    def create(self, validated_data):
        validated_data.pop("password_confirmation")
        password = validated_data.pop("password")

        utilisateur = Utilisateur(**validated_data)
        utilisateur.set_password(password)
        utilisateur.save()

        return utilisateur



# VEHICULE

class VehiculeSerializer(serializers.ModelSerializer):
    proprietaire = serializers.ReadOnlyField(
        source="proprietaire.username"
    )

    class Meta:
        model = Vehicule
        fields = [
            "id",
            "proprietaire",
            "marque",
            "modele",
            "immatriculation",
            "couleur",
            "nombre_places",
            "est_actif",
            "date_creation",
        ]

        read_only_fields = [
            "id",
            "proprietaire",
            "date_creation",
        ]

    def validate_nombre_places(self, value):
        if value < 2:
            raise serializers.ValidationError(
                "Le véhicule doit avoir au moins deux places."
            )

        if value > 20:
            raise serializers.ValidationError(
                "Le nombre de places ne peut pas dépasser 20."
            )

        return value



# TRAJET

class TrajetSerializer(serializers.ModelSerializer):
    conducteur = serializers.ReadOnlyField(
        source="conducteur.username"
    )

    class Meta:
        model = Trajet
        fields = [
            "id",
            "conducteur",
            "vehicule",
            "lieu_depart",
            "lieu_arrivee",
            "date_depart",
            "heure_depart",
            "nombre_places_disponibles",
            "prix_par_place",
            "description",
            "statut",
            "etat",
            "date_creation",
            "date_modification",
        ]

        read_only_fields = [
            "id",
            "conducteur",
            "statut",
            "etat",
            "date_creation",
            "date_modification",
        ]

    def validate(self, attrs):
        request = self.context.get("request")

        vehicule = attrs.get(
            "vehicule",
            getattr(self.instance, "vehicule", None),
        )

        if request and vehicule:
            if vehicule.proprietaire != request.user:
                raise serializers.ValidationError(
                    {
                        "vehicule": (
                            "Vous ne pouvez utiliser que votre propre véhicule."
                        )
                    }
                )

            if not vehicule.est_actif:
                raise serializers.ValidationError(
                    {
                        "vehicule": "Ce véhicule est désactivé."
                    }
                )

        places = attrs.get(
            "nombre_places_disponibles",
            getattr(
                self.instance,
                "nombre_places_disponibles",
                None,
            ),
        )

        if vehicule and places is not None:
            places_passagers_max = vehicule.nombre_places - 1

            if places < 1:
                raise serializers.ValidationError(
                    {
                        "nombre_places_disponibles": (
                            "Le trajet doit proposer au moins une place."
                        )
                    }
                )

            if places > places_passagers_max:
                raise serializers.ValidationError(
                    {
                        "nombre_places_disponibles": (
                            f"Ce véhicule permet au maximum "
                            f"{places_passagers_max} places passagers."
                        )
                    }
                )

        date_depart = attrs.get(
            "date_depart",
            getattr(self.instance, "date_depart", None),
        )

        if date_depart and date_depart < timezone.localdate():
            raise serializers.ValidationError(
                {
                    "date_depart": (
                        "La date de départ ne peut pas être dans le passé."
                    )
                }
            )

        lieu_depart = attrs.get(
            "lieu_depart",
            getattr(self.instance, "lieu_depart", ""),
        )

        lieu_arrivee = attrs.get(
            "lieu_arrivee",
            getattr(self.instance, "lieu_arrivee", ""),
        )

        if (
            lieu_depart
            and lieu_arrivee
            and lieu_depart.strip().lower()
            == lieu_arrivee.strip().lower()
        ):
            raise serializers.ValidationError(
                {
                    "lieu_arrivee": (
                        "Le lieu d’arrivée doit être différent du départ."
                    )
                }
            )

        return attrs



# CHANGEMENT DE L'ETAT DU TRAJET

class ChangerEtatTrajetSerializer(serializers.ModelSerializer):

    class Meta:
        model = Trajet
        fields = [
            "etat",
        ]

    def validate_etat(self, value):
        trajet = self.instance

        if trajet is None:
            raise serializers.ValidationError(
                "Le trajet à modifier est introuvable."
            )

        transitions_autorisees = {
            Trajet.Etat.EN_ATTENTE_DEPART: [
                Trajet.Etat.CHAUFFEUR_EN_ROUTE,
            ],
            Trajet.Etat.CHAUFFEUR_EN_ROUTE: [
                Trajet.Etat.CHAUFFEUR_ARRIVE,
            ],
            Trajet.Etat.CHAUFFEUR_ARRIVE: [
                Trajet.Etat.EN_COURS,
            ],
            Trajet.Etat.EN_COURS: [
                Trajet.Etat.TERMINE,
            ],
            Trajet.Etat.TERMINE: [],
        }

        etats_suivants = transitions_autorisees.get(
            trajet.etat,
            [],
        )

        if value not in etats_suivants:
            etat_actuel = trajet.get_etat_display()
            nouvel_etat = dict(
                Trajet.Etat.choices
            ).get(
                value,
                value,
            )

            raise serializers.ValidationError(
                (
                    f"Le passage de l’état « {etat_actuel} » "
                    f"vers « {nouvel_etat} » "
                    "n’est pas autorisé."
                )
            )

        return value



# RESERVATION

# RESERVATION

class ReservationSerializer(serializers.ModelSerializer):
    passager = serializers.ReadOnlyField(
        source="passager.username"
    )

    trajet_details = TrajetSerializer(
        source="trajet",
        read_only=True,
    )

    conducteur_details = serializers.SerializerMethodField()
    passager_details = serializers.SerializerMethodField()

    class Meta:
        model = Reservation
        fields = [
            "id",
            "trajet",
            "trajet_details",
            "passager",
            "passager_details",
            "conducteur_details",
            "nombre_places",
            "statut",
            "date_reservation",
        ]

        read_only_fields = [
            "id",
            "passager",
            "passager_details",
            "conducteur_details",
            "statut",
            "date_reservation",
            "trajet_details",
        ]

    def get_conducteur_details(self, obj):
        request = self.context.get("request")

        # Le passager voit les coordonnées du conducteur
        # seulement après l’acceptation de la réservation.
        if (
            request
            and request.user == obj.passager
            and obj.statut != Reservation.Statut.ACCEPTEE
        ):
            return None

        conducteur = obj.trajet.conducteur
        nom_complet = conducteur.get_full_name().strip()

        return {
            "id": conducteur.id,
            "username": conducteur.username,
            "first_name": conducteur.first_name,
            "last_name": conducteur.last_name,
            "nom_complet": nom_complet or conducteur.username,
            "telephone": conducteur.telephone,
        }

    def get_passager_details(self, obj):
        request = self.context.get("request")

        # Les informations du passager sont destinées
        # au conducteur propriétaire du trajet.
        if (
            request
            and request.user != obj.trajet.conducteur
            and request.user != obj.passager
        ):
            return None

        passager = obj.passager
        nom_complet = passager.get_full_name().strip()

        return {
            "id": passager.id,
            "username": passager.username,
            "first_name": passager.first_name,
            "last_name": passager.last_name,
            "nom_complet": nom_complet or passager.username,
            "telephone": passager.telephone,
        }

    def validate(self, attrs):
        request = self.context.get("request")

        trajet = attrs.get(
            "trajet",
            getattr(self.instance, "trajet", None),
        )

        nombre_places = attrs.get(
            "nombre_places",
            getattr(self.instance, "nombre_places", 1),
        )

        if (
            request
            and request.user.role
            != Utilisateur.Role.PASSAGER
        ):
            raise serializers.ValidationError(
                "Seul un passager peut effectuer une réservation."
            )

        if trajet:
            if trajet.statut != Trajet.Statut.PUBLIE:
                raise serializers.ValidationError(
                    {
                        "trajet": (
                            "Ce trajet n’est plus disponible."
                        )
                    }
                )

            if (
                request
                and trajet.conducteur == request.user
            ):
                raise serializers.ValidationError(
                    {
                        "trajet": (
                            "Vous ne pouvez pas réserver "
                            "votre propre trajet."
                        )
                    }
                )

            if nombre_places < 1:
                raise serializers.ValidationError(
                    {
                        "nombre_places": (
                            "Le nombre de places doit être "
                            "supérieur à zéro."
                        )
                    }
                )

            if (
                nombre_places
                > trajet.nombre_places_disponibles
            ):
                raise serializers.ValidationError(
                    {
                        "nombre_places": (
                            "Le nombre de places demandé dépasse "
                            "les places disponibles."
                        )
                    }
                )

            if request:
                reservation_existante = (
                    Reservation.objects.filter(
                        trajet=trajet,
                        passager=request.user,
                    )
                )

                if self.instance:
                    reservation_existante = (
                        reservation_existante.exclude(
                            pk=self.instance.pk
                        )
                    )

                if reservation_existante.exists():
                    raise serializers.ValidationError(
                        {
                            "trajet": (
                                "Vous avez déjà réservé ce trajet."
                            )
                        }
                    )

        return attrs

# NOTIFICATION

class NotificationSerializer(serializers.ModelSerializer):
    utilisateur = serializers.ReadOnlyField(
        source="utilisateur.username"
    )

    trajet_details = TrajetSerializer(
        source="trajet",
        read_only=True,
    )

    type_affiche = serializers.CharField(
        source="get_type_notification_display",
        read_only=True,
    )

    class Meta:
        model = Notification
        fields = [
            "id",
            "utilisateur",
            "trajet",
            "trajet_details",
            "type_notification",
            "type_affiche",
            "titre",
            "message",
            "est_lue",
            "date_creation",
        ]

        read_only_fields = [
            "id",
            "utilisateur",
            "trajet",
            "trajet_details",
            "type_notification",
            "type_affiche",
            "titre",
            "message",
            "date_creation",
        ]


# ADMINISTRATION DES UTILISATEURS

class AdminUtilisateurSerializer(serializers.ModelSerializer):
    role_affiche = serializers.CharField(
        source="get_role_display",
        read_only=True,
    )

    class Meta:
        model = Utilisateur
        fields = [
            "id",
            "username",
            "first_name",
            "last_name",
            "email",
            "telephone",
            "role",
            "role_affiche",
            "est_bloque",
            "is_active",
            "date_joined",
            "last_login",
        ]

        read_only_fields = [
            "id",
            "username",
            "first_name",
            "last_name",
            "email",
            "telephone",
            "role",
            "role_affiche",
            "est_bloque",
            "is_active",
            "date_joined",
            "last_login",
        ]

class ConnexionTokenSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        donnees = super().validate(attrs)

        utilisateur = self.user

        donnees["utilisateur"] = {
            "id": utilisateur.id,
            "username": utilisateur.username,
            "email": utilisateur.email,
            "telephone": utilisateur.telephone,
            "role": utilisateur.role,
            "est_bloque": utilisateur.est_bloque,
        }

        return donnees
