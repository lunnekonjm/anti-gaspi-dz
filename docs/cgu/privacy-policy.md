# Politique de Confidentialité — Anti-Gaspi DZ
# سياسة الخصوصية — مضاد للتبذير

*Dernière mise à jour / آخر تحديث: 2024-07-10*

---

## 1. Responsable du traitement / المسؤول عن المعالجة

Anti-Gaspi DZ est exploité par [NOM DE L'ENTREPRISE À COMPLÉTER].
Contact : [EMAIL À COMPLÉTER]

---

## 2. Données collectées / البيانات المجمعة

| Donnée | Base légale | Durée de conservation |
|--------|-------------|----------------------|
| Numéro de téléphone | Exécution du contrat | Durée du compte + 30 jours après suppression |
| Nom affiché | Consentement | Durée du compte |
| Géolocalisation (marchands) | Consentement explicite (`consent_geolocation`) | Réduite à ~1km après expiration de l'offre |
| Historique de réservations | Exécution du contrat | 5 ans (obligations comptables) |
| Adresse IP (journaux d'audit) | Intérêt légitime | 90 jours puis supprimée |
| Messages (dons C2C) | Exécution du contrat | Durée du don |

---

## 3. Flux de données tiers / تدفقات البيانات إلى أطراف ثالثة

| Service | Données partagées | Finalité |
|---------|-------------------|----------|
| Google Maps (via `google_maps_flutter`) | Position GPS de l'appareil | Affichage de la carte des offres |
| Google Fonts (via `google_fonts`) | Adresse IP de l'appareil | Chargement des polices |
| Render.com | Toutes les données API | Hébergement serveur |
| PostgreSQL (Render) | Toutes les données | Base de données |

> **Note** : Aucune donnée de carte bancaire n'est stockée sur la plateforme. Les paiements sont délégués au prestataire de services de paiement (SATIM/BaridiMob).

---

## 4. Droits des utilisateurs / حقوق المستخدمين

Conformément à la Loi 18-07 algérienne :

- **Droit d'accès** : `GET /api/v1/users/me`
- **Droit de rectification** : `PATCH /api/v1/users/me`
- **Droit à l'effacement** : `DELETE /api/v1/users/me` — suppression douce suivie d'une purge complète après 30 jours
- **Droit d'opposition** : Mise à jour des consentements via `PATCH /api/v1/users/me/consent`

---

## 5. Consentements / الموافقات

Trois consentements granulaires sont collectés séparément :

1. **Paiement** (`consent_payment`) — requis avant toute transaction
2. **Géolocalisation** (`consent_geolocation`) — requis avant l'utilisation de la carte
3. **Notifications** (`consent_notifications`) — requis avant l'envoi de notifications push

Chaque consentement est horodaté et peut être retiré à tout moment.

---

## 6. Sécurité / الأمان

- Chiffrement SSL/TLS pour toutes les communications
- Jetons JWT avec secret rotatif
- Codes OTP à usage unique générés cryptographiquement
- Journaux d'audit immuables pour les transactions financières

---

## 7. Contact

Pour toute question relative à vos données personnelles :
[EMAIL DPO À COMPLÉTER]
