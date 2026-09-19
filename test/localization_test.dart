import 'package:flutter_test/flutter_test.dart';
import 'package:splitpe/l10n/app_locale.dart';
import 'package:splitpe/l10n/app_strings.dart';

void main() {
  group('Localization Tests', () {
    test('LocaleController switches languages properly', () {
      LocaleController.setLanguage(AppLanguage.english);
      expect(LocaleController.language, AppLanguage.english);
      expect(AppStrings.navPosSplit, 'POS Split');

      LocaleController.setLanguage(AppLanguage.hindi);
      expect(LocaleController.language, AppLanguage.hindi);
      expect(AppStrings.navPosSplit, 'पीओएस स्प्लिट');
      expect(AppStrings.totalBillAmount, 'कुल बिल राशि');
      expect(AppStrings.merchantUpiIdRequired, 'मर्चेंट यूपीआई आईडी (आवश्यक)');

      LocaleController.setLanguage(AppLanguage.hinglish);
      expect(LocaleController.language, AppLanguage.hinglish);
      expect(AppStrings.navGroupSplit, 'Dost Split');

      LocaleController.setLanguage(AppLanguage.marathi);
      expect(LocaleController.language, AppLanguage.marathi);
      expect(AppStrings.totalBillAmount, 'एकूण बिल रक्कम');

      LocaleController.setLanguage(AppLanguage.gujarati);
      expect(LocaleController.language, AppLanguage.gujarati);
      expect(AppStrings.totalBillAmount, 'કુલ બિલ રકમ');

      LocaleController.setLanguage(AppLanguage.tamil);
      expect(LocaleController.language, AppLanguage.tamil);
      expect(AppStrings.totalBillAmount, 'மொத்த பில் தொகை');

      LocaleController.setLanguage(AppLanguage.telugu);
      expect(LocaleController.language, AppLanguage.telugu);
      expect(AppStrings.totalBillAmount, 'మొత్తం బిల్లు మొత్తం');

      LocaleController.setLanguage(AppLanguage.kannada);
      expect(LocaleController.language, AppLanguage.kannada);
      expect(AppStrings.totalBillAmount, 'ಒಟ್ಟು ಬಿಲ್ ಮೊತ್ತ');

      LocaleController.setLanguage(AppLanguage.bengali);
      expect(LocaleController.language, AppLanguage.bengali);
      expect(AppStrings.totalBillAmount, 'মোট বিলের পরিমাণ');

      // Reset to English
      LocaleController.setLanguage(AppLanguage.english);
    });

    test('All 9 languages have non-empty values for all keys', () {
      for (final lang in AppLanguage.values) {
        LocaleController.setLanguage(lang);

        expect(AppStrings.navPosSplit.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.navGroupSplit.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.navMdrRoast.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.merchantUpiIdRequired.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.payingToUpiId.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.tapToSetUpiId.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.btnEnter.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.enterMerchantUpiId.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.upiIdVpa.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.merchantNameOptional.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.saveUpiId.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.totalBillAmount.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.npciCap.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.customBill.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.presetAttaOil.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.presetDairyGhee.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.presetDhabaDinner.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.presetDryFruits.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.presetFullRation.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.arbitrageBreakdown.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.zeroMdrPolicy.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.regularGpay.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.feeTag.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.regularMdrDesc.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.splitpeZeroMdr.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.free100Percent.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.zeroMdrGstDesc.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.gandhisSaved.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.under2000Free.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.savingsDesc('15.40', '2.77').isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.dynamicTranches.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.reRoll.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.bypassFeePayUpi('18.17').isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.enterUpiId.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.educationalDisclaimer.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.groupBillSplit.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.numberOfFriends.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.shareOnWhatsapp.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.individualShares(3).isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.arbitrageEngine.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.savingsTitle.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.monthlyUpiTurnover.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.avgTicketSize.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.annualLossDrain.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.monthlyExtraSurcharge.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.eliminateSurcharges.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.aboutMdrTitle.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.iUnderstand.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
        expect(AppStrings.selectLanguage.isNotEmpty, true, reason: 'Failed for ${lang.englishName}');
      }

      // Reset to English
      LocaleController.setLanguage(AppLanguage.english);
    });
  });
}
