import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Anti-Gaspi DZ'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur Anti-Gaspi DZ'**
  String get welcomeMessage;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginTitle;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get phoneNumberLabel;

  /// No description provided for @phoneNumberHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: 0551234567'**
  String get phoneNumberHint;

  /// No description provided for @sendOtp.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le code'**
  String get sendOtp;

  /// No description provided for @otpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Code de vérification'**
  String get otpTitle;

  /// No description provided for @otpMessage.
  ///
  /// In fr, this message translates to:
  /// **'Entrez le code envoyé au {phoneNumber}'**
  String otpMessage(String phoneNumber);

  /// No description provided for @verifyOtp.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier'**
  String get verifyOtp;

  /// No description provided for @resendOtp.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get resendOtp;

  /// No description provided for @rateLimitMessage.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Réessayez dans {minutes} min.'**
  String rateLimitMessage(int minutes);

  /// No description provided for @consentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos autorisations'**
  String get consentTitle;

  /// No description provided for @consentPayment.
  ///
  /// In fr, this message translates to:
  /// **'Paiement mobile'**
  String get consentPayment;

  /// No description provided for @consentPaymentDesc.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser les paiements via BaridiMob/CIB'**
  String get consentPaymentDesc;

  /// No description provided for @consentGeolocation.
  ///
  /// In fr, this message translates to:
  /// **'Géolocalisation'**
  String get consentGeolocation;

  /// No description provided for @consentGeolocationDesc.
  ///
  /// In fr, this message translates to:
  /// **'Trouver les offres près de vous'**
  String get consentGeolocationDesc;

  /// No description provided for @consentNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get consentNotifications;

  /// No description provided for @consentNotificationsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Rappels de retrait et nouvelles offres'**
  String get consentNotificationsDesc;

  /// No description provided for @continueButton.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueButton;

  /// No description provided for @selectLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la langue'**
  String get selectLanguage;

  /// No description provided for @french.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @arabic.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @tabSurpriseBags.
  ///
  /// In fr, this message translates to:
  /// **'Sacs Surprise'**
  String get tabSurpriseBags;

  /// No description provided for @tabFamily.
  ///
  /// In fr, this message translates to:
  /// **'Onglet Famille'**
  String get tabFamily;

  /// No description provided for @tabInstitutional.
  ///
  /// In fr, this message translates to:
  /// **'Dons B2A'**
  String get tabInstitutional;

  /// No description provided for @tabProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @offersNearYou.
  ///
  /// In fr, this message translates to:
  /// **'Offres près de vous'**
  String get offersNearYou;

  /// No description provided for @noOffersAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucune offre disponible pour le moment'**
  String get noOffersAvailable;

  /// No description provided for @originalPrice.
  ///
  /// In fr, this message translates to:
  /// **'Valeur initiale : {price} DA'**
  String originalPrice(String price);

  /// No description provided for @salePrice.
  ///
  /// In fr, this message translates to:
  /// **'{price} DA'**
  String salePrice(String price);

  /// No description provided for @pickupWindow.
  ///
  /// In fr, this message translates to:
  /// **'Retrait : {start} - {end}'**
  String pickupWindow(String start, String end);

  /// No description provided for @reserveButton.
  ///
  /// In fr, this message translates to:
  /// **'Réserver'**
  String get reserveButton;

  /// No description provided for @payNow.
  ///
  /// In fr, this message translates to:
  /// **'Payer maintenant'**
  String get payNow;

  /// No description provided for @scanQrCode.
  ///
  /// In fr, this message translates to:
  /// **'Scanner le QR Code'**
  String get scanQrCode;

  /// No description provided for @reservationConfirmed.
  ///
  /// In fr, this message translates to:
  /// **'Réservation confirmée !'**
  String get reservationConfirmed;

  /// No description provided for @showQrCode.
  ///
  /// In fr, this message translates to:
  /// **'Montrer le QR Code au commerçant'**
  String get showQrCode;

  /// No description provided for @createOffer.
  ///
  /// In fr, this message translates to:
  /// **'Créer une offre'**
  String get createOffer;

  /// No description provided for @offerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre de l\'offre'**
  String get offerTitle;

  /// No description provided for @initialValue.
  ///
  /// In fr, this message translates to:
  /// **'Valeur initiale (DA)'**
  String get initialValue;

  /// No description provided for @saleValue.
  ///
  /// In fr, this message translates to:
  /// **'Prix de vente (DA)'**
  String get saleValue;

  /// No description provided for @quantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get quantity;

  /// No description provided for @pickupStart.
  ///
  /// In fr, this message translates to:
  /// **'Début du retrait'**
  String get pickupStart;

  /// No description provided for @pickupEnd.
  ///
  /// In fr, this message translates to:
  /// **'Fin du retrait'**
  String get pickupEnd;

  /// No description provided for @expiryType.
  ///
  /// In fr, this message translates to:
  /// **'Type de date'**
  String get expiryType;

  /// No description provided for @expiryTypeDLC.
  ///
  /// In fr, this message translates to:
  /// **'DLC (Date Limite de Consommation)'**
  String get expiryTypeDLC;

  /// No description provided for @expiryTypeDDM.
  ///
  /// In fr, this message translates to:
  /// **'DDM (Date de Durabilité Minimale)'**
  String get expiryTypeDDM;

  /// No description provided for @expiryDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de péremption'**
  String get expiryDate;

  /// No description provided for @dlcError.
  ///
  /// In fr, this message translates to:
  /// **'La DLC ne peut pas être avant la fin du retrait'**
  String get dlcError;

  /// No description provided for @publishOffer.
  ///
  /// In fr, this message translates to:
  /// **'Publier l\'offre'**
  String get publishOffer;

  /// No description provided for @donateFood.
  ///
  /// In fr, this message translates to:
  /// **'Partager de la nourriture'**
  String get donateFood;

  /// No description provided for @donationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre du don'**
  String get donationTitle;

  /// No description provided for @donationDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get donationDescription;

  /// No description provided for @selectNeighborhood.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le quartier'**
  String get selectNeighborhood;

  /// No description provided for @publishDonation.
  ///
  /// In fr, this message translates to:
  /// **'Publier le don'**
  String get publishDonation;

  /// No description provided for @sendMessage.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un message'**
  String get sendMessage;

  /// No description provided for @phoneNumbersHidden.
  ///
  /// In fr, this message translates to:
  /// **'Les numéros de téléphone sont masqués pour votre protection'**
  String get phoneNumbersHidden;

  /// No description provided for @shareSuccess.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai partagé un repas ce mois-ci ! 🤲'**
  String get shareSuccess;

  /// No description provided for @announceSurplus.
  ///
  /// In fr, this message translates to:
  /// **'Signaler un excédent'**
  String get announceSurplus;

  /// No description provided for @selectAssociation.
  ///
  /// In fr, this message translates to:
  /// **'Choisir l\'association'**
  String get selectAssociation;

  /// No description provided for @estimatedQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité estimée'**
  String get estimatedQuantity;

  /// No description provided for @acceptDonation.
  ///
  /// In fr, this message translates to:
  /// **'Accepter le don'**
  String get acceptDonation;

  /// No description provided for @generateTransferDeed.
  ///
  /// In fr, this message translates to:
  /// **'Générer le bon de cession'**
  String get generateTransferDeed;

  /// No description provided for @signTransferDeed.
  ///
  /// In fr, this message translates to:
  /// **'Signer le bon de cession'**
  String get signTransferDeed;

  /// No description provided for @rseDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord RSE'**
  String get rseDashboard;

  /// No description provided for @deleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr ? Cette action est irréversible.'**
  String get deleteAccountConfirm;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
