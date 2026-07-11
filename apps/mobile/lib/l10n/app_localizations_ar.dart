// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مكافحة الهدر DZ';

  @override
  String get welcomeMessage => 'مرحباً بكم في مكافحة الهدر DZ';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get phoneNumberLabel => 'رقم الهاتف';

  @override
  String get phoneNumberHint => 'مثال: 0551234567';

  @override
  String get sendOtp => 'إرسال الرمز';

  @override
  String get otpTitle => 'رمز التحقق';

  @override
  String otpMessage(String phoneNumber) {
    return 'أدخل الرمز المرسل إلى $phoneNumber';
  }

  @override
  String get verifyOtp => 'تحقق';

  @override
  String get resendOtp => 'إعادة إرسال الرمز';

  @override
  String rateLimitMessage(int minutes) {
    return 'محاولات كثيرة. أعد المحاولة بعد $minutes دقيقة.';
  }

  @override
  String get consentTitle => 'الأذونات الخاصة بك';

  @override
  String get consentPayment => 'الدفع عبر الهاتف';

  @override
  String get consentPaymentDesc => 'السماح بالدفع عبر بريدي موب/CIB';

  @override
  String get consentGeolocation => 'تحديد الموقع';

  @override
  String get consentGeolocationDesc => 'العثور على العروض القريبة منك';

  @override
  String get consentNotifications => 'الإشعارات';

  @override
  String get consentNotificationsDesc => 'تذكيرات الاستلام والعروض الجديدة';

  @override
  String get continueButton => 'متابعة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'العربية';

  @override
  String get tabSurpriseBags => 'أكياس مفاجأة';

  @override
  String get tabFamily => 'تبويب العائلة';

  @override
  String get tabInstitutional => 'تبرعات B2A';

  @override
  String get tabProfile => 'الملف الشخصي';

  @override
  String get offersNearYou => 'عروض قريبة منك';

  @override
  String get noOffersAvailable => 'لا توجد عروض متاحة حالياً';

  @override
  String originalPrice(String price) {
    return 'القيمة الأصلية: $price دج';
  }

  @override
  String salePrice(String price) {
    return '$price دج';
  }

  @override
  String pickupWindow(String start, String end) {
    return 'الاستلام: $start - $end';
  }

  @override
  String get reserveButton => 'احجز';

  @override
  String get payNow => 'ادفع الآن';

  @override
  String get scanQrCode => 'مسح رمز QR';

  @override
  String get reservationConfirmed => 'تم تأكيد الحجز!';

  @override
  String get showQrCode => 'أظهر رمز QR للتاجر';

  @override
  String get createOffer => 'إنشاء عرض';

  @override
  String get offerTitle => 'عنوان العرض';

  @override
  String get initialValue => 'القيمة الأصلية (دج)';

  @override
  String get saleValue => 'سعر البيع (دج)';

  @override
  String get quantity => 'الكمية';

  @override
  String get pickupStart => 'بداية الاستلام';

  @override
  String get pickupEnd => 'نهاية الاستلام';

  @override
  String get expiryType => 'نوع التاريخ';

  @override
  String get expiryTypeDLC => 'DLC (تاريخ انتهاء الاستهلاك)';

  @override
  String get expiryTypeDDM => 'DDM (تاريخ الصلاحية المفضل)';

  @override
  String get expiryDate => 'تاريخ انتهاء الصلاحية';

  @override
  String get dlcError => 'لا يمكن أن يكون تاريخ DLC قبل نهاية الاستلام';

  @override
  String get publishOffer => 'نشر العرض';

  @override
  String get donateFood => 'مشاركة طعام';

  @override
  String get donationTitle => 'عنوان التبرع';

  @override
  String get donationDescription => 'الوصف';

  @override
  String get selectNeighborhood => 'اختر الحي';

  @override
  String get publishDonation => 'نشر التبرع';

  @override
  String get sendMessage => 'إرسال رسالة';

  @override
  String get phoneNumbersHidden => 'أرقام الهواتف مخفية لحمايتك';

  @override
  String get shareSuccess => 'شاركت وجبة هذا الشهر! 🤲';

  @override
  String get announceSurplus => 'الإبلاغ عن فائض';

  @override
  String get selectAssociation => 'اختر الجمعية';

  @override
  String get estimatedQuantity => 'الكمية المقدرة';

  @override
  String get acceptDonation => 'قبول التبرع';

  @override
  String get generateTransferDeed => 'إنشاء وثيقة التنازل';

  @override
  String get signTransferDeed => 'توقيع وثيقة التنازل';

  @override
  String get rseDashboard => 'لوحة المسؤولية الاجتماعية';

  @override
  String get deleteAccount => 'حذف حسابي';

  @override
  String get deleteAccountConfirm =>
      'هل أنت متأكد؟ هذا الإجراء لا يمكن التراجع عنه.';

  @override
  String get settings => 'الإعدادات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get howItWorksTitle => 'كيف تعمل؟';

  @override
  String get howItWorksBody =>
      'احجز كيسًا مفاجئًا بسعر مخفض، ادفع عبر الإنترنت، واستلمه خلال الوقت المحدد باستخدام رمز الاستجابة السريعة (QR) الخاص بك.';

  @override
  String get comeBackLater => 'عد لاحقًا — تصل عروض جديدة بانتظام 🌱';

  @override
  String get dlcVsDdmTitle => 'DLC مقابل DDM';

  @override
  String get dlcVsDdmBody =>
      'DLC (تاريخ انتهاء الاستهلاك): يجب استهلاكه قبل هذا التاريخ، لأسباب تتعلق بسلامة الأغذية.\n\nDDM (تاريخ الصلاحية المفضل): إرشادي — يبقى المنتج جيدًا بعده، مع احتمال انخفاض الجودة قليلاً.';

  @override
  String get paymentWaitingMessage =>
      'بمجرد تأكيد الدفع، سيظهر رمز الاستجابة السريعة الخاص بك هنا.';

  @override
  String get devModeTitle => 'وضع المطور / المسؤول';

  @override
  String get devModeSubtitle => 'عرض مؤشرات وهمية';

  @override
  String get openAdminDashboard => 'فتح لوحة تحكم المسؤول';

  @override
  String get cancel => 'إلغاء';

  @override
  String get mapTooltip => 'عرض على الخريطة';

  @override
  String get retry => 'إعادة المحاولة';
}
