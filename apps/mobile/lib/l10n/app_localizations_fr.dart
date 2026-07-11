// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Anti-Gaspi DZ';

  @override
  String get welcomeMessage => 'Bienvenue sur Anti-Gaspi DZ';

  @override
  String get loginTitle => 'Se connecter';

  @override
  String get phoneNumberLabel => 'Numéro de téléphone';

  @override
  String get phoneNumberHint => 'Ex: 0551234567';

  @override
  String get sendOtp => 'Envoyer le code';

  @override
  String get otpTitle => 'Code de vérification';

  @override
  String otpMessage(String phoneNumber) {
    return 'Entrez le code envoyé au $phoneNumber';
  }

  @override
  String get verifyOtp => 'Vérifier';

  @override
  String get resendOtp => 'Renvoyer le code';

  @override
  String rateLimitMessage(int minutes) {
    return 'Trop de tentatives. Réessayez dans $minutes min.';
  }

  @override
  String get consentTitle => 'Vos autorisations';

  @override
  String get consentPayment => 'Paiement mobile';

  @override
  String get consentPaymentDesc => 'Autoriser les paiements via BaridiMob/CIB';

  @override
  String get consentGeolocation => 'Géolocalisation';

  @override
  String get consentGeolocationDesc => 'Trouver les offres près de vous';

  @override
  String get consentNotifications => 'Notifications';

  @override
  String get consentNotificationsDesc =>
      'Rappels de retrait et nouvelles offres';

  @override
  String get continueButton => 'Continuer';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'العربية';

  @override
  String get tabSurpriseBags => 'Sacs Surprise';

  @override
  String get tabFamily => 'Onglet Famille';

  @override
  String get tabInstitutional => 'Dons B2A';

  @override
  String get tabProfile => 'Profil';

  @override
  String get offersNearYou => 'Offres près de vous';

  @override
  String get noOffersAvailable => 'Aucune offre disponible pour le moment';

  @override
  String originalPrice(String price) {
    return 'Valeur initiale : $price DA';
  }

  @override
  String salePrice(String price) {
    return '$price DA';
  }

  @override
  String pickupWindow(String start, String end) {
    return 'Retrait : $start - $end';
  }

  @override
  String get reserveButton => 'Réserver';

  @override
  String get payNow => 'Payer maintenant';

  @override
  String get scanQrCode => 'Scanner le QR Code';

  @override
  String get reservationConfirmed => 'Réservation confirmée !';

  @override
  String get showQrCode => 'Montrer le QR Code au commerçant';

  @override
  String get createOffer => 'Créer une offre';

  @override
  String get offerTitle => 'Titre de l\'offre';

  @override
  String get initialValue => 'Valeur initiale (DA)';

  @override
  String get saleValue => 'Prix de vente (DA)';

  @override
  String get quantity => 'Quantité';

  @override
  String get pickupStart => 'Début du retrait';

  @override
  String get pickupEnd => 'Fin du retrait';

  @override
  String get expiryType => 'Type de date';

  @override
  String get expiryTypeDLC => 'DLC (Date Limite de Consommation)';

  @override
  String get expiryTypeDDM => 'DDM (Date de Durabilité Minimale)';

  @override
  String get expiryDate => 'Date de péremption';

  @override
  String get dlcError => 'La DLC ne peut pas être avant la fin du retrait';

  @override
  String get publishOffer => 'Publier l\'offre';

  @override
  String get donateFood => 'Partager de la nourriture';

  @override
  String get donationTitle => 'Titre du don';

  @override
  String get donationDescription => 'Description';

  @override
  String get selectNeighborhood => 'Choisir le quartier';

  @override
  String get publishDonation => 'Publier le don';

  @override
  String get sendMessage => 'Envoyer un message';

  @override
  String get phoneNumbersHidden =>
      'Les numéros de téléphone sont masqués pour votre protection';

  @override
  String get shareSuccess => 'J\'ai partagé un repas ce mois-ci ! 🤲';

  @override
  String get announceSurplus => 'Signaler un excédent';

  @override
  String get selectAssociation => 'Choisir l\'association';

  @override
  String get estimatedQuantity => 'Quantité estimée';

  @override
  String get acceptDonation => 'Accepter le don';

  @override
  String get generateTransferDeed => 'Générer le bon de cession';

  @override
  String get signTransferDeed => 'Signer le bon de cession';

  @override
  String get rseDashboard => 'Tableau de bord RSE';

  @override
  String get deleteAccount => 'Supprimer mon compte';

  @override
  String get deleteAccountConfirm =>
      'Êtes-vous sûr ? Cette action est irréversible.';

  @override
  String get settings => 'Paramètres';

  @override
  String get logout => 'Déconnexion';

  @override
  String get howItWorksTitle => 'Comment ça marche ?';

  @override
  String get howItWorksBody =>
      'Réservez un panier surprise à prix réduit, payez en ligne, et récupérez-le pendant le créneau indiqué avec votre QR code.';

  @override
  String get comeBackLater =>
      'Revenez un peu plus tard — de nouveaux paniers arrivent régulièrement 🌱';

  @override
  String get dlcVsDdmTitle => 'DLC vs DDM';

  @override
  String get dlcVsDdmBody =>
      'DLC (Date Limite de Consommation) : à consommer avant cette date, pour raisons de sécurité alimentaire.\n\nDDM (Date de Durabilité Minimale) : indicative — le produit reste bon au-delà, avec une qualité qui peut légèrement diminuer.';

  @override
  String get paymentWaitingMessage =>
      'Une fois le paiement confirmé, votre QR code de retrait apparaîtra ici.';

  @override
  String get devModeTitle => 'Mode Développeur / Admin';

  @override
  String get devModeSubtitle => 'Afficher les indicateurs Mock';

  @override
  String get openAdminDashboard => 'Ouvrir le Dashboard Admin';

  @override
  String get cancel => 'Annuler';

  @override
  String get mapTooltip => 'Voir sur la carte';

  @override
  String get retry => 'Réessayer';
}
