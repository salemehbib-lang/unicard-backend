from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers

from .models import Utilisateur


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
        read_only_fields = ["id"]

    def validate_role(self, value):
        # Un utilisateur ne doit pas pouvoir s’inscrire lui-même comme administrateur.
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
                    "password_confirmation": (
                        "Les deux mots de passe ne correspondent pas."
                    )
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