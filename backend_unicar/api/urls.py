from django.urls import path

from rest_framework_simplejwt.views import TokenRefreshView

from .views import (
    InscriptionView,
    ConnexionView,
    ProfilUtilisateurView,

    ListeCreationVehiculeView,
    DetailVehiculeView,

    TrajetListCreateView,
    TrajetDetailView,
    ChangerEtatTrajetAPIView,
    ListeCreationReservationView,
    DetailReservationView,
    PointRendezVousReservationView,
    AccepterReservationView,
    RefuserReservationView,
    ListeNotificationsView,
    MarquerNotificationLueView,
    AnnulerReservationView,
    AnnulerTrajetView,
    ListeUtilisateursAdminView,
    DetailUtilisateurAdminView,
    BloquerUtilisateurAdminView,
    DebloquerUtilisateurAdminView,
    StatistiquesAdminView,
    TableauBordConducteurView,
    TableauBordPassagerView,
    ChangerMotDePasseView,
    MesTrajetsView,
    

)

urlpatterns = [

    
    # Authentification
    
    path(
        "auth/inscription/",
        InscriptionView.as_view(),
        name="inscription",
    ),

    path(
    "auth/connexion/",
    ConnexionView.as_view(),
    name="connexion",
),

    path(
        "auth/token/refresh/",
        TokenRefreshView.as_view(),
        name="token_refresh",
    ),

    path(
        "auth/profil/",
        ProfilUtilisateurView.as_view(),
        name="profil_utilisateur",
    ),
    path(
    "auth/changer-mot-de-passe/",
    ChangerMotDePasseView.as_view(),
    name="changer_mot_de_passe",
    ),

    
    # Véhicules
    
    path(
        "vehicules/",
        ListeCreationVehiculeView.as_view(),
        name="liste_creation_vehicules",
    ),

    path(
        "vehicules/<int:pk>/",
        DetailVehiculeView.as_view(),
        name="detail_vehicule",
    ),

    
    # Trajets
    
    path(
        "trajets/",
        TrajetListCreateView.as_view(),
        name="trajets",
    ),
    path(
        "mes-trajets/",
        MesTrajetsView.as_view(),
        name="mes_trajets",
    ),

    path(
        "trajets/<int:pk>/",
        TrajetDetailView.as_view(),
        name="trajet_detail",
    ),

    path(
        "trajets/<int:trajet_id>/etat/",
        ChangerEtatTrajetAPIView.as_view(),
        name="changer_etat_trajet",
    ),
    path(
    "trajets/<int:trajet_id>/annuler/",
    AnnulerTrajetView.as_view(),
    name="annuler_trajet",
    ),
    path(
    "reservations/<int:reservation_id>/point-rendez-vous/",
    PointRendezVousReservationView.as_view(),
    name="reservation-point-rendez-vous",
    ),
    
    # Réservations
    
    path(
    "reservations/",
    ListeCreationReservationView.as_view(),
    name="liste-creation-reservations",
),

path(
    "reservations/<int:pk>/",
    DetailReservationView.as_view(),
    name="detail-reservation",
),

path(
    "reservations/<int:reservation_id>/accepter/",
    AccepterReservationView.as_view(),
    name="accepter-reservation",
),

path(
    "reservations/<int:reservation_id>/refuser/",
    RefuserReservationView.as_view(),
    name="refuser-reservation",
),

path(
    "reservations/<int:reservation_id>/annuler/",
    AnnulerReservationView.as_view(),
    name="annuler-reservation",
),

path(
    "reservations/<int:reservation_id>/point-rendez-vous/",
    PointRendezVousReservationView.as_view(),
    name="reservation-point-rendez-vous",
),


# Notifications

path(
    "notifications/",
    ListeNotificationsView.as_view(),
    name="liste_notifications",
),

path(
    "notifications/<int:pk>/",
    MarquerNotificationLueView.as_view(),
    name="marquer_notification_lue",
),

# ADMINISTRATION

path(
    "admin/utilisateurs/",
    ListeUtilisateursAdminView.as_view(),
    name="admin_liste_utilisateurs",
),

path(
    "admin/utilisateurs/<int:pk>/",
    DetailUtilisateurAdminView.as_view(),
    name="admin_detail_utilisateur",
),

path(
    "admin/utilisateurs/<int:utilisateur_id>/bloquer/",
    BloquerUtilisateurAdminView.as_view(),
    name="admin_bloquer_utilisateur",
),

path(
    "admin/utilisateurs/<int:utilisateur_id>/debloquer/",
    DebloquerUtilisateurAdminView.as_view(),
    name="admin_debloquer_utilisateur",
),
path(
    "admin/statistiques/",
    StatistiquesAdminView.as_view(),
    name="admin_statistiques",
),

# TABLEAU DE BORD CONDUCTEUR

path(
    "conducteur/tableau-de-bord/",
    TableauBordConducteurView.as_view(),
    name="tableau_bord_conducteur",
),

# TABLEAU DE BORD PASSAGER

path(
    "passager/tableau-de-bord/",
    TableauBordPassagerView.as_view(),
    name="tableau_bord_passager",
),
]