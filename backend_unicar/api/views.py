from django.db import transaction

from rest_framework import generics, permissions, status
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response
from rest_framework.views import APIView
from django.db.models import Sum
from rest_framework_simplejwt.views import TokenObtainPairView


from .models import (
    Utilisateur,
    Vehicule,
    Trajet,
    Reservation,
    Notification,
)

from .permissions import( EstConducteur, EstAdministrateur,)

from .serializers import (
    ConnexionTokenSerializer,
    InscriptionSerializer,
    ProfilUtilisateurSerializer,
    VehiculeSerializer,
    TrajetSerializer,
    ReservationSerializer,
    ChangerEtatTrajetSerializer,
    NotificationSerializer,
    AdminUtilisateurSerializer,
    ChangerMotDePasseSerializer,
    
)



# AUTHENTIFICATION ET PROFIL
class ConnexionView(TokenObtainPairView):
    serializer_class = ConnexionTokenSerializer

class InscriptionView(generics.CreateAPIView):
    queryset = Utilisateur.objects.all()
    serializer_class = InscriptionSerializer
    permission_classes = [permissions.AllowAny]


class ProfilUtilisateurView(
    generics.RetrieveUpdateAPIView
):
    serializer_class = ProfilUtilisateurSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user
# CHANGEMENT DE MOT DE PASSE

class ChangerMotDePasseView(APIView):
    permission_classes = [
        permissions.IsAuthenticated,
    ]

    def patch(self, request):
        serializer = ChangerMotDePasseSerializer(
            data=request.data,
            context={"request": request},
        )

        serializer.is_valid(
            raise_exception=True
        )

        utilisateur = request.user

        utilisateur.set_password(
            serializer.validated_data[
                "nouveau_mot_de_passe"
            ]
        )

        utilisateur.save(
            update_fields=["password"]
        )

        return Response(
            {
                "message": (
                    "Votre mot de passe a été modifié "
                    "avec succès. Veuillez vous reconnecter."
                )
            },
            status=status.HTTP_200_OK,
        )



# VEHICULES

class ListeCreationVehiculeView(
    generics.ListCreateAPIView
):
    serializer_class = VehiculeSerializer
    permission_classes = [
        permissions.IsAuthenticated,
        EstConducteur,
    ]

    def get_queryset(self):
        return Vehicule.objects.filter(
            proprietaire=self.request.user
        )

    def perform_create(self, serializer):
        serializer.save(
            proprietaire=self.request.user
        )


class DetailVehiculeView(
    generics.RetrieveUpdateDestroyAPIView
):
    serializer_class = VehiculeSerializer
    permission_classes = [
        permissions.IsAuthenticated,
        EstConducteur,
    ]

    def get_queryset(self):
        return Vehicule.objects.filter(
            proprietaire=self.request.user
        )



# TRAJETS
class TrajetListCreateView(
    generics.ListCreateAPIView
):
    serializer_class = TrajetSerializer

    def get_permissions(self):
        if self.request.method == "POST":
            return [
                permissions.IsAuthenticated(),
                EstConducteur(),
            ]

        return [
            permissions.IsAuthenticated()
        ]

    def get_queryset(self):
        queryset = (
            Trajet.objects
            .select_related(
                "conducteur",
                "vehicule",
            )
            .filter(
                statut=Trajet.Statut.PUBLIE,
            )
        )

        lieu_depart = self.request.query_params.get(
            "lieu_depart"
        )

        lieu_arrivee = self.request.query_params.get(
            "lieu_arrivee"
        )

        date_depart = self.request.query_params.get(
            "date_depart"
        )

        nombre_places = self.request.query_params.get(
            "nombre_places"
        )

        if lieu_depart:
            queryset = queryset.filter(
                lieu_depart__icontains=lieu_depart.strip()
            )

        if lieu_arrivee:
            queryset = queryset.filter(
                lieu_arrivee__icontains=lieu_arrivee.strip()
            )

        if date_depart:
            queryset = queryset.filter(
                date_depart=date_depart
            )

        if nombre_places:
            try:
                nombre_places = int(nombre_places)

                if nombre_places < 1:
                    raise ValueError

            except ValueError:
                raise ValidationError(
                    {
                        "nombre_places": (
                            "Le nombre de places doit être "
                            "un nombre entier supérieur à zéro."
                        )
                    }
                )

            queryset = queryset.filter(
                nombre_places_disponibles__gte=nombre_places
            )

        return queryset.order_by(
            "date_depart",
            "heure_depart",
        )

    def perform_create(self, serializer):
        serializer.save(
            conducteur=self.request.user
        )


class TrajetDetailView(
    generics.RetrieveUpdateDestroyAPIView
):
    serializer_class = TrajetSerializer
    permission_classes = [
        permissions.IsAuthenticated,
        EstConducteur,
    ]

    def get_queryset(self):
        return Trajet.objects.filter(
            conducteur=self.request.user
        ).select_related(
            "conducteur",
            "vehicule",
        )


# ETAT DU TRAJET

class ChangerEtatTrajetAPIView(APIView):
    permission_classes = [
        permissions.IsAuthenticated,
        EstConducteur,
    ]

    @transaction.atomic
    def patch(self, request, trajet_id):
        try:
            trajet = (
                Trajet.objects
                .select_for_update()
                .get(pk=trajet_id)
            )
        except Trajet.DoesNotExist:
            return Response(
                {
                    "detail": "Trajet introuvable."
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        if trajet.conducteur != request.user:
            return Response(
                {
                    "detail": (
                        "Vous n’êtes pas autorisé à modifier "
                        "l’état de ce trajet."
                    )
                },
                status=status.HTTP_403_FORBIDDEN,
            )

        if trajet.statut == Trajet.Statut.ANNULE:
            return Response(
                {
                    "detail": (
                        "Impossible de modifier l’état "
                        "d’un trajet annulé."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        serializer = ChangerEtatTrajetSerializer(
            trajet,
            data=request.data,
            partial=True,
        )
        serializer.is_valid(raise_exception=True)

        ancien_etat = trajet.etat
        trajet = serializer.save()

        if trajet.etat == Trajet.Etat.TERMINE:
            trajet.statut = Trajet.Statut.TERMINE
            trajet.save(
                update_fields=[
                    "statut",
                    "date_modification",
                ]
            )

        notifications_par_etat = {
            Trajet.Etat.CHAUFFEUR_EN_ROUTE: {
                "type": Notification.Type.CHAUFFEUR_EN_ROUTE,
                "titre": "Chauffeur en route",
                "message": (
                    "Votre chauffeur est en route "
                    "vers le point de rendez-vous."
                ),
            },
            Trajet.Etat.CHAUFFEUR_ARRIVE: {
                "type": Notification.Type.CHAUFFEUR_ARRIVE,
                "titre": "Chauffeur arrivé",
                "message": (
                    "Votre chauffeur est arrivé "
                    "au point de rendez-vous."
                ),
            },
            Trajet.Etat.EN_COURS: {
                "type": Notification.Type.TRAJET_COMMENCE,
                "titre": "Trajet commencé",
                "message": (
                    "Votre trajet a commencé. Bon voyage."
                ),
            },
            Trajet.Etat.TERMINE: {
                "type": Notification.Type.TRAJET_TERMINE,
                "titre": "Trajet terminé",
                "message": (
                    "Votre trajet est terminé. "
                    "Merci d’avoir utilisé UniCar."
                ),
            },
        }

        notification_data = notifications_par_etat.get(
            trajet.etat
        )
        nombre_notifications = 0

        if notification_data is not None:
            reservations_acceptees = (
                trajet.reservations
                .filter(
                    statut=Reservation.Statut.ACCEPTEE
                )
                .select_related("passager")
            )

            notifications_a_creer = [
                Notification(
                    utilisateur=reservation.passager,
                    trajet=trajet,
                    type_notification=notification_data["type"],
                    titre=notification_data["titre"],
                    message=notification_data["message"],
                )
                for reservation in reservations_acceptees
            ]

            if notifications_a_creer:
                Notification.objects.bulk_create(
                    notifications_a_creer
                )
                nombre_notifications = len(
                    notifications_a_creer
                )

        return Response(
            {
                "message": (
                    "L’état du trajet a été modifié "
                    "avec succès."
                ),
                "trajet_id": trajet.id,
                "ancien_etat": ancien_etat,
                "nouvel_etat": trajet.etat,
                "statut": trajet.statut,
                "notification": (
                    notification_data["message"]
                    if notification_data
                    else None
                ),
                "nombre_notifications_envoyees": (
                    nombre_notifications
                ),
            },
            status=status.HTTP_200_OK,
        )


class MesTrajetsView(generics.ListAPIView):
    serializer_class = TrajetSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Trajet.objects.filter(
            conducteur=self.request.user
        ).order_by("-date_depart", "-heure_depart")

# ANNULATION D'UN TRAJET

class AnnulerTrajetView(APIView):
    permission_classes = [
        permissions.IsAuthenticated,
        EstConducteur,
    ]

    @transaction.atomic
    def patch(self, request, trajet_id):
        try:
            trajet = (
                Trajet.objects
                .select_for_update()
                .get(pk=trajet_id)
            )

        except Trajet.DoesNotExist:
            return Response(
                {
                    "detail": "Trajet introuvable."
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        if trajet.conducteur != request.user:
            return Response(
                {
                    "detail": (
                        "Vous ne pouvez annuler que "
                        "vos propres trajets."
                    )
                },
                status=status.HTTP_403_FORBIDDEN,
            )

        if trajet.statut == Trajet.Statut.ANNULE:
            return Response(
                {
                    "detail": (
                        "Ce trajet est déjà annulé."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        if trajet.statut == Trajet.Statut.TERMINE:
            return Response(
                {
                    "detail": (
                        "Un trajet terminé ne peut "
                        "pas être annulé."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        reservations_concernees = list(
            trajet.reservations.filter(
                statut__in=[
                    Reservation.Statut.EN_ATTENTE,
                    Reservation.Statut.ACCEPTEE,
                ]
            ).select_related(
                "passager"
            )
        )

        trajet.statut = Trajet.Statut.ANNULE

        trajet.save(
            update_fields=[
                "statut",
                "date_modification",
            ]
        )

        ids_reservations = [
            reservation.pk
            for reservation in reservations_concernees
        ]

        if ids_reservations:
            Reservation.objects.filter(
                pk__in=ids_reservations
            ).update(
                statut=Reservation.Statut.ANNULEE
            )

        notifications = [
            Notification(
                utilisateur=reservation.passager,
                trajet=trajet,
                type_notification=Notification.Type.TRAJET_ANNULE,
                titre="Trajet annulé",
                message=(
                    f"Le trajet de "
                    f"{trajet.lieu_depart} "
                    f"vers "
                    f"{trajet.lieu_arrivee} "
                    f"a été annulé par le conducteur."
                ),
                est_lue=False,
            )
            for reservation in reservations_concernees
        ]

        if notifications:
            Notification.objects.bulk_create(
                notifications
            )

        return Response(
            {
                "message": (
                    "Le trajet a été annulé avec succès "
                    "et les passagers ont été informés."
                ),
                "trajet_id": trajet.id,
                "statut": trajet.statut,
                "reservations_annulees": len(
                    reservations_concernees
                ),
                "notifications_envoyees": len(
                    notifications
                ),
            },
            status=status.HTTP_200_OK,
        )
# RESERVATIONS

class ListeCreationReservationView(
    generics.ListCreateAPIView
):
    serializer_class = ReservationSerializer
    permission_classes = [
        permissions.IsAuthenticated
    ]

    def get_queryset(self):
        utilisateur = self.request.user

        if (
            utilisateur.role
            == Utilisateur.Role.PASSAGER
        ):
            return Reservation.objects.filter(
                passager=utilisateur
            ).select_related(
                "trajet",
                "trajet__conducteur",
                "trajet__vehicule",
            )

        if (
            utilisateur.role
            == Utilisateur.Role.CONDUCTEUR
        ):
            return Reservation.objects.filter(
                trajet__conducteur=utilisateur
            ).select_related(
                "passager",
                "trajet",
                "trajet__vehicule",
            )

        return Reservation.objects.all().select_related(
            "passager",
            "trajet",
        )

    @transaction.atomic
    def perform_create(self, serializer):
        trajet = (
            Trajet.objects
            .select_for_update()
            .get(
                pk=serializer.validated_data[
                    "trajet"
                ].pk
            )
        )

        nombre_places = (
            serializer.validated_data.get(
                "nombre_places",
                1,
            )
        )

        if (
            nombre_places
            > trajet.nombre_places_disponibles
        ):
            raise ValidationError(
                "Il ne reste pas assez de "
                "places disponibles."
            )

        serializer.save(
            passager=self.request.user,
            trajet=trajet,
        )


class DetailReservationView(
    generics.RetrieveAPIView
):
    serializer_class = ReservationSerializer
    permission_classes = [
        permissions.IsAuthenticated
    ]

    def get_queryset(self):
        utilisateur = self.request.user

        if (
            utilisateur.role
            == Utilisateur.Role.PASSAGER
        ):
            return Reservation.objects.filter(
                passager=utilisateur
            )

        if (
            utilisateur.role
            == Utilisateur.Role.CONDUCTEUR
        ):
            return Reservation.objects.filter(
                trajet__conducteur=utilisateur
            )

        return Reservation.objects.all()

# ACCEPTATION ET REFUS DES RESERVATIONS

class AccepterReservationView(APIView):
    permission_classes = [
        permissions.IsAuthenticated,
        EstConducteur,
    ]

    @transaction.atomic
    def patch(self, request, reservation_id):
        try:
            reservation = (
                Reservation.objects
                .select_for_update()
                .select_related(
                    "trajet",
                    "passager",
                )
                .get(pk=reservation_id)
            )
        except Reservation.DoesNotExist:
            return Response(
                {
                    "detail": "Réservation introuvable."
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        trajet = (
            Trajet.objects
                .select_for_update()
                .get(pk=reservation.trajet_id)
        )

        if trajet.conducteur != request.user:
            return Response(
                {
                    "detail": (
                        "Vous ne pouvez gérer que les réservations "
                        "de vos propres trajets."
                    )
                },
                status=status.HTTP_403_FORBIDDEN,
            )

        if reservation.statut == Reservation.Statut.ACCEPTEE:
            return Response(
                {
                    "detail": (
                        "Cette réservation est déjà acceptée."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        if reservation.statut == Reservation.Statut.REFUSEE:
            return Response(
                {
                    "detail": (
                        "Cette réservation a déjà été refusée."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        if reservation.statut == Reservation.Statut.ANNULEE:
            return Response(
                {
                    "detail": (
                        "Une réservation annulée ne peut pas être acceptée."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        if trajet.statut != Trajet.Statut.PUBLIE:
            return Response(
                {
                    "detail": (
                        "Ce trajet n’est plus disponible "
                        "pour les réservations."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        if (
            reservation.nombre_places
            > trajet.nombre_places_disponibles
        ):
            return Response(
                {
                    "detail": (
                        "Il ne reste pas assez de places "
                        "pour accepter cette réservation."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        reservation.statut = Reservation.Statut.ACCEPTEE
        reservation.save(
            update_fields=["statut"]
        )

        trajet.nombre_places_disponibles -= (
            reservation.nombre_places
        )

        if trajet.nombre_places_disponibles == 0:
            trajet.statut = Trajet.Statut.COMPLET

        trajet.save(
            update_fields=[
                "nombre_places_disponibles",
                "statut",
                "date_modification",
            ]
        )

        return Response(
            {
                "message": (
                    "La réservation a été acceptée avec succès."
                ),
                "reservation_id": reservation.id,
                "passager": reservation.passager.username,
                "statut_reservation": reservation.statut,
                "nombre_places_reservees": (
                    reservation.nombre_places
                ),
                "places_restantes": (
                    trajet.nombre_places_disponibles
                ),
                "statut_trajet": trajet.statut,
            },
            status=status.HTTP_200_OK,
        )


class RefuserReservationView(APIView):
    permission_classes = [
        permissions.IsAuthenticated,
        EstConducteur,
    ]

    @transaction.atomic
    def patch(self, request, reservation_id):
        try:
            reservation = (
                Reservation.objects
                .select_for_update()
                .select_related(
                    "trajet",
                    "passager",
                )
                .get(pk=reservation_id)
            )
        except Reservation.DoesNotExist:
            return Response(
                {
                    "detail": "Réservation introuvable."
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        if reservation.trajet.conducteur != request.user:
            return Response(
                {
                    "detail": (
                        "Vous ne pouvez gérer que les réservations "
                        "de vos propres trajets."
                    )
                },
                status=status.HTTP_403_FORBIDDEN,
            )

        if reservation.statut == Reservation.Statut.ACCEPTEE:
            return Response(
                {
                    "detail": (
                        "Une réservation déjà acceptée "
                        "ne peut pas être refusée."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        if reservation.statut == Reservation.Statut.REFUSEE:
            return Response(
                {
                    "detail": (
                        "Cette réservation est déjà refusée."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        if reservation.statut == Reservation.Statut.ANNULEE:
            return Response(
                {
                    "detail": (
                        "Cette réservation est déjà annulée."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        reservation.statut = Reservation.Statut.REFUSEE
        reservation.save(
            update_fields=["statut"]
        )

        return Response(
            {
                "message": (
                    "La réservation a été refusée avec succès."
                ),
                "reservation_id": reservation.id,
                "passager": reservation.passager.username,
                "statut_reservation": reservation.statut,
            },
            status=status.HTTP_200_OK,
        )

# ANNULATION D'UNE RESERVATION

class AnnulerReservationView(APIView):
    permission_classes = [
        permissions.IsAuthenticated,
    ]

    @transaction.atomic
    def patch(self, request, reservation_id):
        try:
            reservation = (
                Reservation.objects
                .select_for_update()
                .select_related(
                    "trajet",
                    "passager",
                )
                .get(pk=reservation_id)
            )
        except Reservation.DoesNotExist:
            return Response(
                {
                    "detail": "Réservation introuvable."
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        if reservation.passager != request.user:
            return Response(
                {
                    "detail": (
                        "Vous ne pouvez annuler que "
                        "vos propres réservations."
                    )
                },
                status=status.HTTP_403_FORBIDDEN,
            )

        if reservation.statut == Reservation.Statut.ANNULEE:
            return Response(
                {
                    "detail": (
                        "Cette réservation est déjà annulée."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        if reservation.statut == Reservation.Statut.REFUSEE:
            return Response(
                {
                    "detail": (
                        "Une réservation refusée "
                        "ne peut pas être annulée."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        trajet = (
            Trajet.objects
            .select_for_update()
            .get(pk=reservation.trajet_id)
        )

        ancien_statut = reservation.statut

        if ancien_statut == Reservation.Statut.ACCEPTEE:
            trajet.nombre_places_disponibles += (
                reservation.nombre_places
            )

            if trajet.statut == Trajet.Statut.COMPLET:
                trajet.statut = Trajet.Statut.PUBLIE

            trajet.save(
                update_fields=[
                    "nombre_places_disponibles",
                    "statut",
                    "date_modification",
                ]
            )

        reservation.statut = Reservation.Statut.ANNULEE
        reservation.save(
            update_fields=[
                "statut",
            ]
        )

        return Response(
            {
                "message": (
                    "La réservation a été annulée avec succès."
                ),
                "reservation_id": reservation.id,
                "ancien_statut": ancien_statut,
                "nouveau_statut": reservation.statut,
                "places_restantes": (
                    trajet.nombre_places_disponibles
                ),
                "statut_trajet": trajet.statut,
            },
            status=status.HTTP_200_OK,
        )

# NOTIFICATIONS


class ListeNotificationsView(
    generics.ListAPIView
):
    serializer_class = NotificationSerializer
    permission_classes = [
        permissions.IsAuthenticated,
    ]

    def get_queryset(self):
        return Notification.objects.filter(
            utilisateur=self.request.user
        ).select_related(
            "utilisateur",
            "trajet",
            "trajet__conducteur",
            "trajet__vehicule",
        )


class MarquerNotificationLueView(generics.UpdateAPIView):
    permission_classes = [
        permissions.IsAuthenticated,
    ]

    http_method_names = [
        "patch",
        "options",
    ]

    def get_queryset(self):
        return Notification.objects.filter(
            utilisateur=self.request.user
        )

    def patch(self, request, *args, **kwargs):
        notification = self.get_object()

        notification.est_lue = True
        notification.save(update_fields=["est_lue"])

        return Response(
            {
                "succes": True,
                "message": "Notification marquée comme lue.",
                "id": notification.id,
                "lue": notification.est_lue,
            },
            status=status.HTTP_200_OK,
        )

# ADMINISTRATION DES UTILISATEURS

class ListeUtilisateursAdminView(
    generics.ListAPIView
):
    serializer_class = AdminUtilisateurSerializer
    permission_classes = [
        permissions.IsAuthenticated,
        EstAdministrateur,
    ]

    def get_queryset(self):
        queryset = Utilisateur.objects.all().order_by(
            "-date_joined"
        )

        role = self.request.query_params.get("role")
        est_bloque = self.request.query_params.get(
            "est_bloque"
        )

        if role:
            queryset = queryset.filter(role=role)

        if est_bloque is not None:
            if est_bloque.lower() == "true":
                queryset = queryset.filter(
                    est_bloque=True
                )

            elif est_bloque.lower() == "false":
                queryset = queryset.filter(
                    est_bloque=False
                )

        return queryset


class DetailUtilisateurAdminView(
    generics.RetrieveAPIView
):
    serializer_class = AdminUtilisateurSerializer
    permission_classes = [
        permissions.IsAuthenticated,
        EstAdministrateur,
    ]

    queryset = Utilisateur.objects.all()


class BloquerUtilisateurAdminView(APIView):
    permission_classes = [
        permissions.IsAuthenticated,
        EstAdministrateur,
    ]

    def patch(self, request, utilisateur_id):
        try:
            utilisateur = Utilisateur.objects.get(
                pk=utilisateur_id
            )

        except Utilisateur.DoesNotExist:
            return Response(
                {
                    "detail": "Utilisateur introuvable."
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        if utilisateur == request.user:
            return Response(
                {
                    "detail": (
                        "Vous ne pouvez pas bloquer "
                        "votre propre compte."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        if utilisateur.is_superuser:
            return Response(
                {
                    "detail": (
                        "Un superutilisateur ne peut pas "
                        "être bloqué."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        if utilisateur.est_bloque:
            return Response(
                {
                    "detail": (
                        "Cet utilisateur est déjà bloqué."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        utilisateur.est_bloque = True
        utilisateur.is_active = False

        utilisateur.save(
            update_fields=[
                "est_bloque",
                "is_active",
            ]
        )

        return Response(
            {
                "message": (
                    "L’utilisateur a été bloqué avec succès."
                ),
                "utilisateur_id": utilisateur.id,
                "username": utilisateur.username,
                "est_bloque": utilisateur.est_bloque,
                "is_active": utilisateur.is_active,
            },
            status=status.HTTP_200_OK,
        )


class DebloquerUtilisateurAdminView(APIView):
    permission_classes = [
        permissions.IsAuthenticated,
        EstAdministrateur,
    ]

    def patch(self, request, utilisateur_id):
        try:
            utilisateur = Utilisateur.objects.get(
                pk=utilisateur_id
            )

        except Utilisateur.DoesNotExist:
            return Response(
                {
                    "detail": "Utilisateur introuvable."
                },
                status=status.HTTP_404_NOT_FOUND,
            )

        if not utilisateur.est_bloque:
            return Response(
                {
                    "detail": (
                        "Cet utilisateur n’est pas bloqué."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        utilisateur.est_bloque = False
        utilisateur.is_active = True

        utilisateur.save(
            update_fields=[
                "est_bloque",
                "is_active",
            ]
        )

        return Response(
            {
                "message": (
                    "L’utilisateur a été débloqué avec succès."
                ),
                "utilisateur_id": utilisateur.id,
                "username": utilisateur.username,
                "est_bloque": utilisateur.est_bloque,
                "is_active": utilisateur.is_active,
            },
            status=status.HTTP_200_OK,
        )

# TABLEAU DE BORD ADMINISTRATEUR

class StatistiquesAdminView(APIView):
    permission_classes = [
        permissions.IsAuthenticated,
        EstAdministrateur,
    ]

    def get(self, request):
        nombre_utilisateurs = Utilisateur.objects.count()

        nombre_passagers = Utilisateur.objects.filter(
            role=Utilisateur.Role.PASSAGER
        ).count()

        nombre_conducteurs = Utilisateur.objects.filter(
            role=Utilisateur.Role.CONDUCTEUR
        ).count()

        nombre_administrateurs = Utilisateur.objects.filter(
            role=Utilisateur.Role.ADMINISTRATEUR
        ).count()

        nombre_utilisateurs_bloques = Utilisateur.objects.filter(
            est_bloque=True
        ).count()

        nombre_vehicules = Vehicule.objects.count()

        nombre_trajets = Trajet.objects.count()

        nombre_trajets_publies = Trajet.objects.filter(
            statut=Trajet.Statut.PUBLIE
        ).count()

        nombre_trajets_complets = Trajet.objects.filter(
            statut=Trajet.Statut.COMPLET
        ).count()

        nombre_trajets_annules = Trajet.objects.filter(
            statut=Trajet.Statut.ANNULE
        ).count()

        nombre_trajets_termines = Trajet.objects.filter(
            statut=Trajet.Statut.TERMINE
        ).count()

        nombre_reservations = Reservation.objects.count()

        nombre_reservations_en_attente = Reservation.objects.filter(
            statut=Reservation.Statut.EN_ATTENTE
        ).count()

        nombre_reservations_acceptees = Reservation.objects.filter(
            statut=Reservation.Statut.ACCEPTEE
        ).count()

        nombre_reservations_refusees = Reservation.objects.filter(
            statut=Reservation.Statut.REFUSEE
        ).count()

        nombre_reservations_annulees = Reservation.objects.filter(
            statut=Reservation.Statut.ANNULEE
        ).count()

        nombre_notifications = Notification.objects.count()

        nombre_notifications_non_lues = Notification.objects.filter(
            est_lue=False
        ).count()

        total_places_reservees = (
            Reservation.objects
            .filter(
                statut=Reservation.Statut.ACCEPTEE
            )
            .aggregate(
                total=Sum("nombre_places")
            )["total"]
            or 0
        )

        return Response(
            {
                "utilisateurs": {
                    "total": nombre_utilisateurs,
                    "passagers": nombre_passagers,
                    "conducteurs": nombre_conducteurs,
                    "administrateurs": nombre_administrateurs,
                    "bloques": nombre_utilisateurs_bloques,
                },
                "vehicules": {
                    "total": nombre_vehicules,
                },
                "trajets": {
                    "total": nombre_trajets,
                    "publies": nombre_trajets_publies,
                    "complets": nombre_trajets_complets,
                    "annules": nombre_trajets_annules,
                    "termines": nombre_trajets_termines,
                },
                "reservations": {
                    "total": nombre_reservations,
                    "en_attente": (
                        nombre_reservations_en_attente
                    ),
                    "acceptees": (
                        nombre_reservations_acceptees
                    ),
                    "refusees": (
                        nombre_reservations_refusees
                    ),
                    "annulees": (
                        nombre_reservations_annulees
                    ),
                    "places_reservees": (
                        total_places_reservees
                    ),
                },
                "notifications": {
                    "total": nombre_notifications,
                    "non_lues": (
                        nombre_notifications_non_lues
                    ),
                },
            },
            status=status.HTTP_200_OK,
        )

# TABLEAU DE BORD CONDUCTEUR

class TableauBordConducteurView(APIView):
    permission_classes = [
        permissions.IsAuthenticated,
        EstConducteur,
    ]

    def get(self, request):
        conducteur = request.user

        vehicules = Vehicule.objects.filter(
            proprietaire=conducteur
        )

        trajets = Trajet.objects.filter(
            conducteur=conducteur
        )

        reservations = Reservation.objects.filter(
            trajet__conducteur=conducteur
        )

        total_places_reservees = (
            reservations
            .filter(
                statut=Reservation.Statut.ACCEPTEE
            )
            .aggregate(
                total=Sum("nombre_places")
            )["total"]
            or 0
        )

        return Response(
            {
                "conducteur": {
                    "id": conducteur.id,
                    "username": conducteur.username,
                    "nom_complet": conducteur.get_full_name(),
                },

                "vehicules": {
                    "total": vehicules.count(),
                    "actifs": vehicules.filter(
                        est_actif=True
                    ).count(),
                    "inactifs": vehicules.filter(
                        est_actif=False
                    ).count(),
                },

                "trajets": {
                    "total": trajets.count(),

                    "publies": trajets.filter(
                        statut=Trajet.Statut.PUBLIE
                    ).count(),

                    "complets": trajets.filter(
                        statut=Trajet.Statut.COMPLET
                    ).count(),

                    "annules": trajets.filter(
                        statut=Trajet.Statut.ANNULE
                    ).count(),

                    "termines": trajets.filter(
                        statut=Trajet.Statut.TERMINE
                    ).count(),

                    "en_cours": trajets.filter(
                        etat=Trajet.Etat.EN_COURS
                    ).count(),
                },

                "reservations_recues": {
                    "total": reservations.count(),

                    "en_attente": reservations.filter(
                        statut=Reservation.Statut.EN_ATTENTE
                    ).count(),

                    "acceptees": reservations.filter(
                        statut=Reservation.Statut.ACCEPTEE
                    ).count(),

                    "refusees": reservations.filter(
                        statut=Reservation.Statut.REFUSEE
                    ).count(),

                    "annulees": reservations.filter(
                        statut=Reservation.Statut.ANNULEE
                    ).count(),

                    "places_reservees": total_places_reservees,
                },
            },
            status=status.HTTP_200_OK,
        )

# TABLEAU DE BORD PASSAGER

class TableauBordPassagerView(APIView):
    permission_classes = [
        permissions.IsAuthenticated,
    ]

    def get(self, request):
        passager = request.user

        if passager.role != Utilisateur.Role.PASSAGER:
            return Response(
                {
                    "detail": (
                        "Cette fonctionnalité est réservée "
                        "aux passagers."
                    )
                },
                status=status.HTTP_403_FORBIDDEN,
            )

        reservations = Reservation.objects.filter(
            passager=passager
        )

        notifications = Notification.objects.filter(
            utilisateur=passager
        )

        trajets_effectues = reservations.filter(
            statut=Reservation.Statut.ACCEPTEE,
            trajet__etat=Trajet.Etat.TERMINE,
        ).count()

        trajets_en_cours = reservations.filter(
            statut=Reservation.Statut.ACCEPTEE,
            trajet__etat=Trajet.Etat.EN_COURS,
        ).count()

        trajets_a_venir = reservations.filter(
            statut=Reservation.Statut.ACCEPTEE,
            trajet__etat__in=[
                Trajet.Etat.EN_ATTENTE_DEPART,
                Trajet.Etat.CHAUFFEUR_EN_ROUTE,
                Trajet.Etat.CHAUFFEUR_ARRIVE,
            ],
        ).count()

        return Response(
            {
                "passager": {
                    "id": passager.id,
                    "username": passager.username,
                    "nom_complet": passager.get_full_name(),
                },

                "reservations": {
                    "total": reservations.count(),

                    "en_attente": reservations.filter(
                        statut=Reservation.Statut.EN_ATTENTE
                    ).count(),

                    "acceptees": reservations.filter(
                        statut=Reservation.Statut.ACCEPTEE
                    ).count(),

                    "refusees": reservations.filter(
                        statut=Reservation.Statut.REFUSEE
                    ).count(),

                    "annulees": reservations.filter(
                        statut=Reservation.Statut.ANNULEE
                    ).count(),
                },

                "trajets": {
                    "a_venir": trajets_a_venir,
                    "en_cours": trajets_en_cours,
                    "effectues": trajets_effectues,
                },

                "notifications": {
                    "total": notifications.count(),

                    "non_lues": notifications.filter(
                        est_lue=False
                    ).count(),

                    "lues": notifications.filter(
                        est_lue=True
                    ).count(),
                },
            },
            status=status.HTTP_200_OK,
        )