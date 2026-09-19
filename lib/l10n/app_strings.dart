import 'package:flutter/material.dart';
import 'app_locale.dart';

/// Central dictionary of localized strings for all 9 supported Indian languages.
class AppStrings {
  static AppLanguage get _current => LocaleController.language;

  // -------------------------------------------------------------
  // NAVIGATION BAR
  // -------------------------------------------------------------
  static String get navPosSplit {
    switch (_current) {
      case AppLanguage.hindi:
        return 'पीओएस स्प्लिट';
      case AppLanguage.hinglish:
        return 'POS Split';
      case AppLanguage.marathi:
        return 'पीओएस स्प्लिट';
      case AppLanguage.gujarati:
        return 'પીઓએસ સ્પ્લિટ';
      case AppLanguage.tamil:
        return 'பிஓஎஸ் ஸ்ப்ளிட்';
      case AppLanguage.telugu:
        return 'పీవోఎస్ స్ప్లిట్';
      case AppLanguage.kannada:
        return 'ಪಿಒಎಸ್ ಸ್ಪ್ಲಿಟ್';
      case AppLanguage.bengali:
        return 'পিওএস স্প্লিট';
      case AppLanguage.english:
        return 'POS Split';
    }
  }

  static String get navGroupSplit {
    switch (_current) {
      case AppLanguage.hindi:
        return 'ग्रुप स्प्लिट';
      case AppLanguage.hinglish:
        return 'Dost Split';
      case AppLanguage.marathi:
        return 'ग्रुप स्प्लिट';
      case AppLanguage.gujarati:
        return 'ગ્રુપ સ્પ્લિટ';
      case AppLanguage.tamil:
        return 'குழு ஸ்ப்ளிட்';
      case AppLanguage.telugu:
        return 'గ్రూప్ స్ప్లిట్';
      case AppLanguage.kannada:
        return 'ಗುಂಪು ಸ್ಪ್ಲಿಟ್';
      case AppLanguage.bengali:
        return 'গ্রুপ স্প্লিট';
      case AppLanguage.english:
        return 'Group Split';
    }
  }

  static String get navMdrRoast {
    switch (_current) {
      case AppLanguage.hindi:
        return 'एमडीआर रोस्ट';
      case AppLanguage.hinglish:
        return 'MDR Roast 🔥';
      case AppLanguage.marathi:
        return 'एमडीआर रोस्ट';
      case AppLanguage.gujarati:
        return 'એમડીઆર રોસ્ટ';
      case AppLanguage.tamil:
        return 'எம்டிஆர் ரோஸ்ட்';
      case AppLanguage.telugu:
        return 'ఎండీఆర్ రోస్ట్';
      case AppLanguage.kannada:
        return 'ಎಂಡಿಆರ್ ರೋಸ್ಟ್';
      case AppLanguage.bengali:
        return 'এমডিআর রোস্ট';
      case AppLanguage.english:
        return 'MDR Roast';
    }
  }

  // -------------------------------------------------------------
  // MERCHANT & VPA HEADER
  // -------------------------------------------------------------
  static String get merchantUpiIdRequired {
    switch (_current) {
      case AppLanguage.hindi:
        return 'मर्चेंट यूपीआई आईडी (आवश्यक)';
      case AppLanguage.hinglish:
        return 'MERCHANT UPI ID (REQUIRED)';
      case AppLanguage.marathi:
        return 'मर्चंट यूपीआय आयडी (आवश्यक)';
      case AppLanguage.gujarati:
        return 'મર્ચન્ટ UPI ID (જરૂરી)';
      case AppLanguage.tamil:
        return 'வணிகர் UPI ஐடி (தேவை)';
      case AppLanguage.telugu:
        return 'వ్యాపారి UPI ఐడి (తప్పనిసరి)';
      case AppLanguage.kannada:
        return 'ವರ್ತಕ UPI ಐಡಿ (ಅಗತ್ಯ)';
      case AppLanguage.bengali:
        return 'মার্চেন্ট UPI আইডি (প্রয়োজন)';
      case AppLanguage.english:
        return 'MERCHANT UPI ID (REQUIRED)';
    }
  }

  static String get payingToUpiId {
    switch (_current) {
      case AppLanguage.hindi:
        return 'इस यूपीआई आईडी पर भुगतान';
      case AppLanguage.hinglish:
        return 'PAYING TO UPI ID';
      case AppLanguage.marathi:
        return 'या यूपीआय आयडीवर भरणार';
      case AppLanguage.gujarati:
        return 'આ UPI ID પર ચુકવણી';
      case AppLanguage.tamil:
        return 'இந்த UPI ஐடிக்கு செலுத்துகிறது';
      case AppLanguage.telugu:
        return 'ఈ UPI ఐడికి చెల్లింపు';
      case AppLanguage.kannada:
        return 'ಈ UPI ಐಡಿಗೆ ಪಾವತಿಸಲಾಗುತ್ತಿದೆ';
      case AppLanguage.bengali:
        return 'এই UPI আইডিতে পেমেন্ট';
      case AppLanguage.english:
        return 'PAYING TO UPI ID';
    }
  }

  static String get tapToSetUpiId {
    switch (_current) {
      case AppLanguage.hindi:
        return 'यूपीआई आईडी सेट करने के लिए टैप करें';
      case AppLanguage.hinglish:
        return 'TAP TO SET UPI ID / VPA';
      case AppLanguage.marathi:
        return 'UPI आयडी सेट करण्यासाठी टॅप करा';
      case AppLanguage.gujarati:
        return 'UPI ID સેટ કરવા માટે ટેપ કરો';
      case AppLanguage.tamil:
        return 'UPI ஐடியை அமைக்க தட்டவும்';
      case AppLanguage.telugu:
        return 'UPI ఐడిని సెట్ చేయడానికి నొక్కండి';
      case AppLanguage.kannada:
        return 'UPI ಐಡಿ ಹೊಂದಿಸಲು ಟ್ಯಾಪ್ ಮಾಡಿ';
      case AppLanguage.bengali:
        return 'UPI আইডি সেট করতে ট্যাপ করুন';
      case AppLanguage.english:
        return 'TAP TO SET UPI ID / VPA';
    }
  }

  static String get btnEnter {
    switch (_current) {
      case AppLanguage.hindi:
        return 'दर्ज करें ▾';
      case AppLanguage.hinglish:
        return 'ENTER ▾';
      case AppLanguage.marathi:
        return 'नोंदवा ▾';
      case AppLanguage.gujarati:
        return 'દાખલ કરો ▾';
      case AppLanguage.tamil:
        return 'உள்ளிடு ▾';
      case AppLanguage.telugu:
        return 'నమోదు ▾';
      case AppLanguage.kannada:
        return 'ನಮೂದಿಸಿ ▾';
      case AppLanguage.bengali:
        return 'লিখুন ▾';
      case AppLanguage.english:
        return 'ENTER ▾';
    }
  }

  static String get enterMerchantUpiId {
    switch (_current) {
      case AppLanguage.hindi:
        return 'मर्चेंट यूपीआई आईडी दर्ज करें';
      case AppLanguage.hinglish:
        return 'ENTER MERCHANT UPI ID';
      case AppLanguage.marathi:
        return 'मर्चंट यूपीआय आयडी टाका';
      case AppLanguage.gujarati:
        return 'મર્ચન્ટ UPI ID દાખલ કરો';
      case AppLanguage.tamil:
        return 'வணிகர் UPI ஐடியை உள்ளிடவும்';
      case AppLanguage.telugu:
        return 'వ్యాపారి UPI ఐడిని నమోదు చేయండి';
      case AppLanguage.kannada:
        return 'ವರ್ತಕ UPI ಐಡಿ ನಮೂದಿಸಿ';
      case AppLanguage.bengali:
        return 'মার্চেন্ট UPI আইডি লিখুন';
      case AppLanguage.english:
        return 'ENTER MERCHANT UPI ID';
    }
  }

  static String get upiIdVpa {
    switch (_current) {
      case AppLanguage.hindi:
        return 'यूपीआई आईडी (VPA)';
      case AppLanguage.hinglish:
        return 'UPI ID (VPA)';
      case AppLanguage.marathi:
        return 'यूपीआय आयडी (VPA)';
      case AppLanguage.gujarati:
        return 'UPI ID (VPA)';
      case AppLanguage.tamil:
        return 'UPI ஐடி (VPA)';
      case AppLanguage.telugu:
        return 'UPI ఐడి (VPA)';
      case AppLanguage.kannada:
        return 'UPI ಐಡಿ (VPA)';
      case AppLanguage.bengali:
        return 'UPI আইডি (VPA)';
      case AppLanguage.english:
        return 'UPI ID (VPA)';
    }
  }

  static String get merchantNameOptional {
    switch (_current) {
      case AppLanguage.hindi:
        return 'दुकानदार / मर्चेंट का नाम (वैकल्पिक)';
      case AppLanguage.hinglish:
        return 'STORE / MERCHANT NAME (OPTIONAL)';
      case AppLanguage.marathi:
        return 'दुकानदार / मर्चंटचे नाव (पर्यायी)';
      case AppLanguage.gujarati:
        return 'દુકાન / વેપારીનું નામ (વૈકલ્પિક)';
      case AppLanguage.tamil:
        return 'கடை / வணிகர் பெயர் (விருப்பமானது)';
      case AppLanguage.telugu:
        return 'దుకాణం / వ్యాపారి పేరు (ఐచ్ఛికం)';
      case AppLanguage.kannada:
        return 'ಅಂಗಡಿ / ವರ್ತಕರ ಹೆಸರು (ಐಚ್ಛಿಕ)';
      case AppLanguage.bengali:
        return 'দোকান / মার্চেন্টের নাম (ঐচ্ছিক)';
      case AppLanguage.english:
        return 'STORE / MERCHANT NAME (OPTIONAL)';
    }
  }

  static String get saveUpiId {
    switch (_current) {
      case AppLanguage.hindi:
        return 'यूपीआई आईडी सेव करें';
      case AppLanguage.hinglish:
        return 'SAVE UPI ID';
      case AppLanguage.marathi:
        return 'UPI आयडी जतन करा';
      case AppLanguage.gujarati:
        return 'UPI ID સાચવો';
      case AppLanguage.tamil:
        return 'UPI ஐடியைச் சேமிக்கவும்';
      case AppLanguage.telugu:
        return 'UPI ఐడిని సేవ్ చేయండి';
      case AppLanguage.kannada:
        return 'UPI ಐಡಿ ಉಳಿಸಿ';
      case AppLanguage.bengali:
        return 'UPI আইডি সংরক্ষণ করুন';
      case AppLanguage.english:
        return 'SAVE UPI ID';
    }
  }

  // -------------------------------------------------------------
  // POS CHECKOUT VIEW & PRESETS
  // -------------------------------------------------------------
  static String get totalBillAmount {
    switch (_current) {
      case AppLanguage.hindi:
        return 'कुल बिल राशि';
      case AppLanguage.hinglish:
        return 'TOTAL BILL AMOUNT';
      case AppLanguage.marathi:
        return 'एकूण बिल रक्कम';
      case AppLanguage.gujarati:
        return 'કુલ બિલ રકમ';
      case AppLanguage.tamil:
        return 'மொத்த பில் தொகை';
      case AppLanguage.telugu:
        return 'మొత్తం బిల్లు మొత్తం';
      case AppLanguage.kannada:
        return 'ಒಟ್ಟು ಬಿಲ್ ಮೊತ್ತ';
      case AppLanguage.bengali:
        return 'মোট বিলের পরিমাণ';
      case AppLanguage.english:
        return 'TOTAL BILL AMOUNT';
    }
  }

  static String get npciCap {
    switch (_current) {
      case AppLanguage.hindi:
        return 'NPCI 0.4% कैप: ₹2,000';
      case AppLanguage.hinglish:
        return 'NPCI 0.4% CAP: ₹2,000';
      case AppLanguage.marathi:
        return 'NPCI 0.4% मर्यादा: ₹2,000';
      case AppLanguage.gujarati:
        return 'NPCI 0.4% મર્યાદા: ₹2,000';
      case AppLanguage.tamil:
        return 'NPCI 0.4% வரம்பு: ₹2,000';
      case AppLanguage.telugu:
        return 'NPCI 0.4% పరిమితి: ₹2,000';
      case AppLanguage.kannada:
        return 'NPCI 0.4% ಮಿತಿ: ₹2,000';
      case AppLanguage.bengali:
        return 'NPCI 0.4% ক্যাপ: ₹২,০০০';
      case AppLanguage.english:
        return 'NPCI 0.4% CAP: ₹2,000';
    }
  }

  static String get customBill {
    switch (_current) {
      case AppLanguage.hindi:
        return 'कस्टम बिल';
      case AppLanguage.hinglish:
        return 'CUSTOM BILL';
      case AppLanguage.marathi:
        return 'कस्टम बिल';
      case AppLanguage.gujarati:
        return 'કસ્ટમ બિલ';
      case AppLanguage.tamil:
        return 'தனிப்பயன் பில்';
      case AppLanguage.telugu:
        return 'కస్టమ్ బిల్లు';
      case AppLanguage.kannada:
        return 'ಕಸ್ಟಮ್ ಬಿಲ್';
      case AppLanguage.bengali:
        return 'কাস্টম বিল';
      case AppLanguage.english:
        return 'CUSTOM BILL';
    }
  }

  static String get presetAttaOil {
    switch (_current) {
      case AppLanguage.hindi:
        return 'आटा और तेल';
      case AppLanguage.hinglish:
        return 'ATTA & OIL';
      case AppLanguage.marathi:
        return 'पीठ आणि तेल';
      case AppLanguage.gujarati:
        return 'લોટ અને તેલ';
      case AppLanguage.tamil:
        return 'ஆட்டா & எண்ணெய்';
      case AppLanguage.telugu:
        return 'పిండి & నూనె';
      case AppLanguage.kannada:
        return 'ಹಿಟ್ಟು & ಎಣ್ಣೆ';
      case AppLanguage.bengali:
        return 'আটা এবং তেল';
      case AppLanguage.english:
        return 'ATTA & OIL';
    }
  }

  static String get presetDairyGhee {
    switch (_current) {
      case AppLanguage.hindi:
        return 'दूध और घी';
      case AppLanguage.hinglish:
        return 'DAIRY & GHEE';
      case AppLanguage.marathi:
        return 'दूध आणि तूप';
      case AppLanguage.gujarati:
        return 'ડેરી અને ઘી';
      case AppLanguage.tamil:
        return 'பால் & நெய்';
      case AppLanguage.telugu:
        return 'డైరీ & నెయ్యి';
      case AppLanguage.kannada:
        return 'ಡೈರಿ & ತುಪ್ಪ';
      case AppLanguage.bengali:
        return 'দুগ্ধ ও ঘি';
      case AppLanguage.english:
        return 'DAIRY & GHEE';
    }
  }

  static String get presetDhabaDinner {
    switch (_current) {
      case AppLanguage.hindi:
        return 'ढाबा डिनर';
      case AppLanguage.hinglish:
        return 'DHABA DINNER';
      case AppLanguage.marathi:
        return 'ढाबा जेवण';
      case AppLanguage.gujarati:
        return 'ઢાબા ડિનર';
      case AppLanguage.tamil:
        return 'தாபா இரவு உணவு';
      case AppLanguage.telugu:
        return 'ధాబా డిన్నర్';
      case AppLanguage.kannada:
        return 'ಧಾಬಾ ಊಟ';
      case AppLanguage.bengali:
        return 'ধাবা ডিনার';
      case AppLanguage.english:
        return 'DHABA DINNER';
    }
  }

  static String get presetDryFruits {
    switch (_current) {
      case AppLanguage.hindi:
        return 'काजू बादाम';
      case AppLanguage.hinglish:
        return 'DRY FRUITS';
      case AppLanguage.marathi:
        return 'सुका मेवा';
      case AppLanguage.gujarati:
        return 'ડ્રાય ફ્રુટ્સ';
      case AppLanguage.tamil:
        return 'உலர் பழங்கள்';
      case AppLanguage.telugu:
        return 'డ్రై ఫ్రూట్స్';
      case AppLanguage.kannada:
        return 'ಒಣ ಹಣ್ಣುಗಳು';
      case AppLanguage.bengali:
        return 'ড্রাই ফ্রুটস';
      case AppLanguage.english:
        return 'DRY FRUITS';
    }
  }

  static String get presetFullRation {
    switch (_current) {
      case AppLanguage.hindi:
        return 'पूरा राशन';
      case AppLanguage.hinglish:
        return 'FULL RATION';
      case AppLanguage.marathi:
        return 'पूर्ण रेशन';
      case AppLanguage.gujarati:
        return 'આખું રાશન';
      case AppLanguage.tamil:
        return 'முழு மளிகை';
      case AppLanguage.telugu:
        return 'మొత్తం రేషన్';
      case AppLanguage.kannada:
        return 'ಪೂರ್ಣ ರೇಷನ್';
      case AppLanguage.bengali:
        return 'সম্পূর্ণ রেশন';
      case AppLanguage.english:
        return 'FULL RATION';
    }
  }

  // -------------------------------------------------------------
  // ARBITRAGE BREAKDOWN CARD
  // -------------------------------------------------------------
  static String get arbitrageBreakdown {
    switch (_current) {
      case AppLanguage.hindi:
        return 'आर्बिट्राज ब्रेकडाउन';
      case AppLanguage.hinglish:
        return 'ARBITRAGE BREAKDOWN';
      case AppLanguage.marathi:
        return 'आर्बिट्राज तपशील';
      case AppLanguage.gujarati:
        return 'આર્બિટ્રેજ બ્રેકડાઉન';
      case AppLanguage.tamil:
        return 'ஆர்பிட்ரேஜ் விவரம்';
      case AppLanguage.telugu:
        return 'ఆర్బిట్రేజ్ వివరాలు';
      case AppLanguage.kannada:
        return 'ಆರ್ಬಿಟ್ರೇಜ್ ವಿವರಣೆ';
      case AppLanguage.bengali:
        return 'আরবিট্রেজ ব্রেকডাউন';
      case AppLanguage.english:
        return 'ARBITRAGE BREAKDOWN';
    }
  }

  static String get zeroMdrPolicy {
    switch (_current) {
      case AppLanguage.hindi:
        return 'ज़ीरो MDR पॉलिसी';
      case AppLanguage.hinglish:
        return 'ZERO MDR POLICY';
      case AppLanguage.marathi:
        return 'झिरो MDR पॉलिसी';
      case AppLanguage.gujarati:
        return 'ઝીરો MDR પોલિસી';
      case AppLanguage.tamil:
        return 'ஜீரோ MDR கொள்கை';
      case AppLanguage.telugu:
        return 'జీరో MDR పాలసీ';
      case AppLanguage.kannada:
        return 'ಶೂನ್ಯ MDR ನೀತಿ';
      case AppLanguage.bengali:
        return 'জিরো MDR নীতি';
      case AppLanguage.english:
        return 'ZERO MDR POLICY';
    }
  }

  static String get regularGpay {
    switch (_current) {
      case AppLanguage.hindi:
        return 'सामान्य गूगल पे';
      case AppLanguage.hinglish:
        return 'REGULAR GPAY';
      case AppLanguage.marathi:
        return 'नेहमीचे जीपे';
      case AppLanguage.gujarati:
        return 'સામાન્ય જીપે';
      case AppLanguage.tamil:
        return 'வழக்கமான ஜிபே';
      case AppLanguage.telugu:
        return 'రెగ్యులర్ జీపే';
      case AppLanguage.kannada:
        return 'ಸಾಮಾನ್ಯ ಜೀಪೇ';
      case AppLanguage.bengali:
        return 'সাধারণ জিপে';
      case AppLanguage.english:
        return 'REGULAR GPAY';
    }
  }

  static String get feeTag {
    switch (_current) {
      case AppLanguage.hindi:
        return 'शुल्क';
      case AppLanguage.hinglish:
        return 'FEE';
      case AppLanguage.marathi:
        return 'शुल्क';
      case AppLanguage.gujarati:
        return 'ફી';
      case AppLanguage.tamil:
        return 'கட்டணம்';
      case AppLanguage.telugu:
        return 'రుసుము';
      case AppLanguage.kannada:
        return 'ಶುಲ್ಕ';
      case AppLanguage.bengali:
        return 'ফি';
      case AppLanguage.english:
        return 'FEE';
    }
  }

  static String get regularMdrDesc {
    switch (_current) {
      case AppLanguage.hindi:
        return '0.4% MDR + 18% GST';
      case AppLanguage.hinglish:
        return '0.4% MDR + 18% GST';
      case AppLanguage.marathi:
        return '0.4% MDR + 18% GST';
      case AppLanguage.gujarati:
        return '0.4% MDR + 18% GST';
      case AppLanguage.tamil:
        return '0.4% MDR + 18% GST';
      case AppLanguage.telugu:
        return '0.4% MDR + 18% GST';
      case AppLanguage.kannada:
        return '0.4% MDR + 18% GST';
      case AppLanguage.bengali:
        return '0.4% MDR + 18% GST';
      case AppLanguage.english:
        return '0.4% MDR + 18% GST';
    }
  }

  static String get splitpeZeroMdr {
    switch (_current) {
      case AppLanguage.hindi:
        return 'स्प्लिटपे (0% MDR)';
      case AppLanguage.hinglish:
        return 'SPLITPE (0% MDR)';
      case AppLanguage.marathi:
        return 'स्प्लिटपे (0% MDR)';
      case AppLanguage.gujarati:
        return 'સ્પ્લિટપે (0% MDR)';
      case AppLanguage.tamil:
        return 'ஸ்ப்ளிட்பே (0% MDR)';
      case AppLanguage.telugu:
        return 'స్ప్లిట్పే (0% MDR)';
      case AppLanguage.kannada:
        return 'ಸ್ಪ್ಲಿಟ್‌ಪೇ (0% MDR)';
      case AppLanguage.bengali:
        return 'স্প্লিটপে (০% MDR)';
      case AppLanguage.english:
        return 'SPLITPE (0% MDR)';
    }
  }

  static String get free100Percent {
    switch (_current) {
      case AppLanguage.hindi:
        return '₹0.00 (100% मुफ़्त)';
      case AppLanguage.hinglish:
        return '₹0.00 (100% FREE)';
      case AppLanguage.marathi:
        return '₹0.00 (100% मोफत)';
      case AppLanguage.gujarati:
        return '₹0.00 (100% મફત)';
      case AppLanguage.tamil:
        return '₹0.00 (100% இலவசம்)';
      case AppLanguage.telugu:
        return '₹0.00 (100% ఉచితం)';
      case AppLanguage.kannada:
        return '₹0.00 (100% ಉಚಿತ)';
      case AppLanguage.bengali:
        return '₹০.০০ (১০০% বিনামূল্যে)';
      case AppLanguage.english:
        return '₹0.00 (100% FREE)';
    }
  }

  static String get zeroMdrGstDesc {
    switch (_current) {
      case AppLanguage.hindi:
        return '0% MDR · 0% GST';
      case AppLanguage.hinglish:
        return '0% MDR · 0% GST';
      case AppLanguage.marathi:
        return '0% MDR · 0% GST';
      case AppLanguage.gujarati:
        return '0% MDR · 0% GST';
      case AppLanguage.tamil:
        return '0% MDR · 0% GST';
      case AppLanguage.telugu:
        return '0% MDR · 0% GST';
      case AppLanguage.kannada:
        return '0% MDR · 0% GST';
      case AppLanguage.bengali:
        return '0% MDR · 0% GST';
      case AppLanguage.english:
        return '0% MDR · 0% GST';
    }
  }

  static String get gandhisSaved {
    switch (_current) {
      case AppLanguage.hindi:
        return 'गांधी बचाए (MDR + GST)';
      case AppLanguage.hinglish:
        return 'GANDHIS SAVED (MDR + GST)';
      case AppLanguage.marathi:
        return 'गांधी वाचवले (MDR + GST)';
      case AppLanguage.gujarati:
        return 'ગાંધી બચાવ્યા (MDR + GST)';
      case AppLanguage.tamil:
        return 'காந்திகள் சேமிப்பு (MDR + GST)';
      case AppLanguage.telugu:
        return 'గాంధీలు ఆదా అయ్యాయి (MDR + GST)';
      case AppLanguage.kannada:
        return 'ಉಳಿಸಿದ ಗಾಂಧಿಗಳು (MDR + GST)';
      case AppLanguage.bengali:
        return 'গান্ধী বাঁচানো হয়েছে (MDR + GST)';
      case AppLanguage.english:
        return 'GANDHIS SAVED (MDR + GST)';
    }
  }

  static String get under2000Free {
    switch (_current) {
      case AppLanguage.hindi:
        return '₹2,000 या कम के लेन-देन पहले से मुफ़्त हैं';
      case AppLanguage.hinglish:
        return 'Transactions ≤ ₹2,000 are already free';
      case AppLanguage.marathi:
        return '₹2,000 किंवा कमी रकमेचे व्यवहार आधीच विनामूल्य आहेत';
      case AppLanguage.gujarati:
        return '₹2,000 અથવા તેનાથી ઓછા વ્યવહારો પહેલેથી જ મફત છે';
      case AppLanguage.tamil:
        return '₹2,000 அல்லது அதற்குக் குறைவான பரிவர்த்தனைகள் ஏற்கனவே இலவசம்';
      case AppLanguage.telugu:
        return '₹2,000 లేదా అంతకంటే తక్కువ లావాదేవీలు ఇప్పటికే ఉచితం';
      case AppLanguage.kannada:
        return '₹2,000 ಅಥವಾ ಅದಕ್ಕಿಂತ ಕಡಿಮೆ ವಹಿವಾಟುಗಳು ಈಗಾಗಲೇ ಉಚಿತವಾಗಿವೆ';
      case AppLanguage.bengali:
        return '₹২,০০০ বা তার কম লেনদেন ইতিমধ্যেই বিনামূল্যে';
      case AppLanguage.english:
        return 'Transactions ≤ ₹2,000 are already free';
    }
  }

  static String savingsDesc(String mdr, String gst) {
    switch (_current) {
      case AppLanguage.hindi:
        return '₹$mdr MDR + ₹$gst GST (18%) की बचत हुई';
      case AppLanguage.hinglish:
        return 'Saved ₹$mdr MDR + ₹$gst GST (18%)';
      case AppLanguage.marathi:
        return '₹$mdr MDR + ₹$gst GST (18%) बचत झाली';
      case AppLanguage.gujarati:
        return '₹$mdr MDR + ₹$gst GST (18%) બચાવ્યા';
      case AppLanguage.tamil:
        return '₹$mdr MDR + ₹$gst GST (18%) சேமிக்கப்பட்டது';
      case AppLanguage.telugu:
        return '₹$mdr MDR + ₹$gst GST (18%) ఆదా అయింది';
      case AppLanguage.kannada:
        return '₹$mdr MDR + ₹$gst GST (18%) ಉಳಿಸಲಾಗಿದೆ';
      case AppLanguage.bengali:
        return '₹$mdr MDR + ₹$gst GST (18%) সঞ্চয় হয়েছে';
      case AppLanguage.english:
        return 'Saved ₹$mdr MDR + ₹$gst GST (18%)';
    }
  }

  static String get dynamicTranches {
    switch (_current) {
      case AppLanguage.hindi:
        return 'डायनामिक ज़ीरो-एमडीआर किश्तें';
      case AppLanguage.hinglish:
        return 'DYNAMIC ZERO-MDR TRANCHES';
      case AppLanguage.marathi:
        return 'डायनॅमिक झिरो-एमडीआर हप्ते';
      case AppLanguage.gujarati:
        return 'ડાયનેમિક ઝીરો-MDR હપ્તાઓ';
      case AppLanguage.tamil:
        return 'டைனமிக் ஜீரோ-MDR தவணைகள்';
      case AppLanguage.telugu:
        return 'డైనమిక్ జీరో-MDR విభాగాలు';
      case AppLanguage.kannada:
        return 'ಡೈನಾಮಿಕ್ ಶೂನ್ಯ-MDR ಕಂತುಗಳು';
      case AppLanguage.bengali:
        return 'ডায়নামিক জিরো-MDR কিস্তি';
      case AppLanguage.english:
        return 'DYNAMIC ZERO-MDR TRANCHES';
    }
  }

  static String get reRoll {
    switch (_current) {
      case AppLanguage.hindi:
        return 'री-रोल';
      case AppLanguage.hinglish:
        return 'RE-ROLL';
      case AppLanguage.marathi:
        return 'री-रोल';
      case AppLanguage.gujarati:
        return 'રી-રોલ';
      case AppLanguage.tamil:
        return 'மீண்டும் உருட்டு';
      case AppLanguage.telugu:
        return 'రీ-రోల్';
      case AppLanguage.kannada:
        return 'ರೀ-ರೋಲ್';
      case AppLanguage.bengali:
        return 'পুনরায় রোল';
      case AppLanguage.english:
        return 'RE-ROLL';
    }
  }

  static String get educationalDisclaimer {
    switch (_current) {
      case AppLanguage.hindi:
        return 'केवल शैक्षणिक और अनुसंधान उद्देश्यों के लिए';
      case AppLanguage.hinglish:
        return 'FOR EDUCATIONAL & RESEARCH PURPOSES ONLY';
      case AppLanguage.marathi:
        return 'केवळ शैक्षणिक आणि संशोधन हेतूसाठी';
      case AppLanguage.gujarati:
        return 'માત્ર શૈક્ષણિક અને સંશોધન હેતુઓ માટે';
      case AppLanguage.tamil:
        return 'கல்வி மற்றும் ஆராய்ச்சி நோக்கங்களுக்காக மட்டுமே';
      case AppLanguage.telugu:
        return 'కేవలం విద్యా మరియు పరిశోధన ప్రయోజనాల కోసం మాత్రమే';
      case AppLanguage.kannada:
        return 'ಕೇವಲ ಶೈಕ್ಷಣಿಕ ಮತ್ತು ಸಂಶೋಧನಾ ಉದ್ದೇಶಗಳಿಗಾಗಿ ಮಾತ್ರ';
      case AppLanguage.bengali:
        return 'শুধুমাত্র শিক্ষামূলক এবং গবেষণার উদ্দেশ্যে';
      case AppLanguage.english:
        return 'FOR EDUCATIONAL & RESEARCH PURPOSES ONLY';
    }
  }

  static String get enterUpiId {
    switch (_current) {
      case AppLanguage.hindi:
        return '⚡ यूपीआई आईडी दर्ज करें · भुगतान करें ⚡';
      case AppLanguage.hinglish:
        return '⚡ ENTER UPI ID · PAY ON UPI ⚡';
      case AppLanguage.marathi:
        return '⚡ UPI आयडी टाका · UPI वर भरा ⚡';
      case AppLanguage.gujarati:
        return '⚡ UPI ID દાખલ કરો · UPI પર ચૂકવો ⚡';
      case AppLanguage.tamil:
        return '⚡ UPI ஐடி உள்ளிடவும் · UPI இல் செலுத்தவும் ⚡';
      case AppLanguage.telugu:
        return '⚡ UPI ఐడిని నమోదు చేయండి · UPI లో చెల్లించండి ⚡';
      case AppLanguage.kannada:
        return '⚡ UPI ಐಡಿ ನಮೂದಿಸಿ · UPI ಮೂಲಕ ಪಾವತಿಸಿ ⚡';
      case AppLanguage.bengali:
        return '⚡ UPI আইডি লিখুন · UPI-তে প্রদান করুন ⚡';
      case AppLanguage.english:
        return '⚡ ENTER UPI ID · PAY ON UPI ⚡';
    }
  }

  static String bypassFeePayUpi(String fee) {
    switch (_current) {
      case AppLanguage.hindi:
        return '⚡ ₹$fee शुल्क बचाएं · UPI से भुगतान करें ⚡';
      case AppLanguage.hinglish:
        return '⚡ BYPASS ₹$fee FEE · PAY ON UPI ⚡';
      case AppLanguage.marathi:
        return '⚡ ₹$fee शुल्क वाचवा · UPI द्वारे भरा ⚡';
      case AppLanguage.gujarati:
        return '⚡ ₹$fee ફી બચાવો · UPI પર ચૂકવો ⚡';
      case AppLanguage.tamil:
        return '⚡ ₹$fee கட்டணத்தைத் தவிர்க்கவும் · UPI இல் செலுத்தவும் ⚡';
      case AppLanguage.telugu:
        return '⚡ ₹$fee రుసుము దాటవేయండి · UPI లో చెల్లించండి ⚡';
      case AppLanguage.kannada:
        return '⚡ ₹$fee ಶುಲ್ಕ ಉಳಿಸಿ · UPI ಮೂಲಕ ಪಾವತಿಸಿ ⚡';
      case AppLanguage.bengali:
        return '⚡ ₹$fee ফি বাঁচান · UPI-তে প্রদান করুন ⚡';
      case AppLanguage.english:
        return '⚡ BYPASS ₹$fee FEE · PAY ON UPI ⚡';
    }
  }

  // -------------------------------------------------------------
  // GROUP SPLIT
  // -------------------------------------------------------------
  static String get groupBillSplit {
    switch (_current) {
      case AppLanguage.hindi:
        return 'ग्रुप बिल स्प्लिट (ज़ीरो MDR)';
      case AppLanguage.hinglish:
        return 'GROUP BILL SPLIT (ZERO MDR)';
      case AppLanguage.marathi:
        return 'ग्रुप बिल स्प्लिट (झिरो MDR)';
      case AppLanguage.gujarati:
        return 'ગ્રુપ બિલ સ્પ્લિટ (ઝીરો MDR)';
      case AppLanguage.tamil:
        return 'குழு பில் ஸ்ப்ளிட் (ஜீரோ MDR)';
      case AppLanguage.telugu:
        return 'గ్రూప్ బిల్లు స్ప్లిట్ (జీరో MDR)';
      case AppLanguage.kannada:
        return 'ಗುಂಪು ಬಿಲ್ ಸ್ಪ್ಲಿಟ್ (ಶೂನ್ಯ MDR)';
      case AppLanguage.bengali:
        return 'গ্রুপ বিল স্প্লিট (জিরো MDR)';
      case AppLanguage.english:
        return 'GROUP BILL SPLIT (ZERO MDR)';
    }
  }

  static String get numberOfFriends {
    switch (_current) {
      case AppLanguage.hindi:
        return 'दोस्तों की संख्या:';
      case AppLanguage.hinglish:
        return 'NUMBER OF FRIENDS:';
      case AppLanguage.marathi:
        return 'मित्रांची संख्या:';
      case AppLanguage.gujarati:
        return 'મિત્રોની સંખ્યા:';
      case AppLanguage.tamil:
        return 'நண்பர்களின் எண்ணிக்கை:';
      case AppLanguage.telugu:
        return 'స్నేహితుల సంఖ్య:';
      case AppLanguage.kannada:
        return 'ಸ್ನೇಹಿತರ ಸಂಖ್ಯೆ:';
      case AppLanguage.bengali:
        return 'বন্ধুর সংখ্যা:';
      case AppLanguage.english:
        return 'NUMBER OF FRIENDS:';
    }
  }

  static String get shareOnWhatsapp {
    switch (_current) {
      case AppLanguage.hindi:
        return 'व्हाट्सएप पर स्प्लिट लिंक भेजें 📲';
      case AppLanguage.hinglish:
        return 'SHARE SPLIT LINKS ON WHATSAPP 📲';
      case AppLanguage.marathi:
        return 'व्हॉट्सॲपवर स्प्लिट लिंक पाठवा 📲';
      case AppLanguage.gujarati:
        return 'વોટ્સએપ પર સ્પ્લિટ લિંક શેર કરો 📲';
      case AppLanguage.tamil:
        return 'வாட்ஸ்அப்பில் ஸ்ப்ளிட் இணைப்புகளைப் பகிரவும் 📲';
      case AppLanguage.telugu:
        return 'వాట్సాప్‌లో స్ప్లిట్ లింక్‌లను షేర్ చేయండి 📲';
      case AppLanguage.kannada:
        return 'ವಾಟ್ಸಾಪ್‌ನಲ್ಲಿ ಸ್ಪ್ಲಿಟ್ ಲಿಂಕ್ ಹಂಚಿಕೊಳ್ಳಿ 📲';
      case AppLanguage.bengali:
        return 'হোয়াটসঅ্যাপে স্প্লিট লিংক শেয়ার করুন 📲';
      case AppLanguage.english:
        return 'SHARE SPLIT LINKS ON WHATSAPP 📲';
    }
  }

  static String individualShares(int count) {
    switch (_current) {
      case AppLanguage.hindi:
        return 'व्यक्तिगत हिस्से ($count)';
      case AppLanguage.hinglish:
        return 'INDIVIDUAL SHARES ($count)';
      case AppLanguage.marathi:
        return 'वैयक्तिक वाटा ($count)';
      case AppLanguage.gujarati:
        return 'વ્યક્તિગત હિસ્સા ($count)';
      case AppLanguage.tamil:
        return 'தனிநபர் பங்குகள் ($count)';
      case AppLanguage.telugu:
        return 'వ్యక్తిగత వాటాలు ($count)';
      case AppLanguage.kannada:
        return 'ವೈಯಕ್ತಿಕ ಪಾಲುಗಳು ($count)';
      case AppLanguage.bengali:
        return 'ব্যক্তিগত অংশ ($count)';
      case AppLanguage.english:
        return 'INDIVIDUAL SHARES ($count)';
    }
  }

  // -------------------------------------------------------------
  // MDR ROAST / SAVINGS CALCULATOR
  // -------------------------------------------------------------
  static String get arbitrageEngine {
    switch (_current) {
      case AppLanguage.hindi:
        return 'आर्बिट्राज इंजन';
      case AppLanguage.hinglish:
        return 'Arbitrage Engine';
      case AppLanguage.marathi:
        return 'आर्बिट्राज इंजिन';
      case AppLanguage.gujarati:
        return 'આર્બિટ્રેજ એન્જિન';
      case AppLanguage.tamil:
        return 'ஆர்பிட்ரேஜ் என்ஜின்';
      case AppLanguage.telugu:
        return 'ఆర్బిట్రేజ్ ఇంజిన్';
      case AppLanguage.kannada:
        return 'ಆರ್ಬಿಟ್ರೇಜ್ ಎಂಜಿನ್';
      case AppLanguage.bengali:
        return 'আরবিট্রেজ ইঞ্জিন';
      case AppLanguage.english:
        return 'Arbitrage Engine';
    }
  }

  static String get savingsTitle {
    switch (_current) {
      case AppLanguage.hindi:
        return 'नया MDR आपके व्यवसाय को कितना नुकसान पहुंचाता है?';
      case AppLanguage.hinglish:
        return 'HOW MUCH DOES THE NEW MDR COST YOUR BUSINESS?';
      case AppLanguage.marathi:
        return 'नवीन MDR मुळे तुमच्या व्यवसायाचे किती नुकसान होते?';
      case AppLanguage.gujarati:
        return 'નવો MDR તમારા વ્યવસાયને કેટલું નુકસાન કરે છે?';
      case AppLanguage.tamil:
        return 'புதிய MDR உங்கள் வணிகத்திற்கு எவ்வளவு செலவாகும்?';
      case AppLanguage.telugu:
        return 'కొత్త MDR మీ వ్యాపారానికి ఎంత ఖర్చు అవుతుంది?';
      case AppLanguage.kannada:
        return 'ಹೊಸ MDR ನಿಮ್ಮ ವ್ಯವಹಾರಕ್ಕೆ ಎಷ್ಟು ವೆಚ್ಚವಾಗುತ್ತದೆ?';
      case AppLanguage.bengali:
        return 'নতুন MDR আপনার ব্যবসার কতটা ক্ষতি করে?';
      case AppLanguage.english:
        return 'HOW MUCH DOES THE NEW MDR COST YOUR BUSINESS?';
    }
  }

  static String get monthlyUpiTurnover {
    switch (_current) {
      case AppLanguage.hindi:
        return 'मासिक यूपीआई टर्नओवर';
      case AppLanguage.hinglish:
        return 'MONTHLY UPI TURNOVER';
      case AppLanguage.marathi:
        return 'मासिक यूपीआय टर्नओव्हर';
      case AppLanguage.gujarati:
        return 'માસિક UPI ટર્નઓવર';
      case AppLanguage.tamil:
        return 'மாதாந்திர UPI வருவாய்';
      case AppLanguage.telugu:
        return 'నెలవారీ UPI టర్నోవర్';
      case AppLanguage.kannada:
        return 'ಮಾಸಿಕ UPI ವಹಿವಾಟು';
      case AppLanguage.bengali:
        return 'মাসিক UPI টার্নওভার';
      case AppLanguage.english:
        return 'MONTHLY UPI TURNOVER';
    }
  }

  static String get avgTicketSize {
    switch (_current) {
      case AppLanguage.hindi:
        return 'औसत बिल राशि (टिकट साइज)';
      case AppLanguage.hinglish:
        return 'AVERAGE TICKET SIZE';
      case AppLanguage.marathi:
        return 'सरासरी बिल रक्कम';
      case AppLanguage.gujarati:
        return 'સરેરાશ બિલ રકમ';
      case AppLanguage.tamil:
        return 'சராசரி பில் அளவு';
      case AppLanguage.telugu:
        return 'సగటు బిల్లు మొత్తం';
      case AppLanguage.kannada:
        return 'ಸರಾಸರಿ ಬಿಲ್ ಮೊತ್ತ';
      case AppLanguage.bengali:
        return 'গড় বিলের পরিমাণ';
      case AppLanguage.english:
        return 'AVERAGE TICKET SIZE';
    }
  }

  static String get annualLossDrain {
    switch (_current) {
      case AppLanguage.hindi:
        return 'वार्षिक MDR शुल्क नुकसान';
      case AppLanguage.hinglish:
        return 'ANNUAL MDR SURCHARGE DRAIN';
      case AppLanguage.marathi:
        return 'वार्षिक MDR शुल्क नुकसान';
      case AppLanguage.gujarati:
        return 'વાર્ષિક MDR સરચાર્જ નુકસાન';
      case AppLanguage.tamil:
        return 'ஆண்டு MDR கூடுதல் கட்டண இழப்பு';
      case AppLanguage.telugu:
        return 'వార్షిక MDR సర్‌ఛార్జ్ నష్టం';
      case AppLanguage.kannada:
        return 'ವಾರ್ಷಿಕ MDR ಹೆಚ್ಚುವರಿ ಶುಲ್ಕ ನಷ್ಟ';
      case AppLanguage.bengali:
        return 'বার্ষিক MDR সারচার্জ ক্ষয়';
      case AppLanguage.english:
        return 'ANNUAL MDR SURCHARGE DRAIN';
    }
  }

  static String get monthlyExtraSurcharge {
    switch (_current) {
      case AppLanguage.hindi:
        return 'मासिक अतिरिक्त शुल्क';
      case AppLanguage.hinglish:
        return 'MONTHLY EXTRA SURCHARGE';
      case AppLanguage.marathi:
        return 'मासिक अतिरिक्त शुल्क';
      case AppLanguage.gujarati:
        return 'માસિક વધારાનો સરચાર્જ';
      case AppLanguage.tamil:
        return 'மாதாந்திர கூடுதல் கட்டணம்';
      case AppLanguage.telugu:
        return 'నెలవారీ అదనపు సర్‌ఛార్జ్';
      case AppLanguage.kannada:
        return 'ಮಾಸಿಕ ಹೆಚ್ಚುವರಿ ಶುಲ್ಕ';
      case AppLanguage.bengali:
        return 'মাসিক অতিরিক্ত সারচার্জ';
      case AppLanguage.english:
        return 'MONTHLY EXTRA SURCHARGE';
    }
  }

  static String get eliminateSurcharges {
    switch (_current) {
      case AppLanguage.hindi:
        return 'स्प्लिटपे से सरचार्ज खत्म करें';
      case AppLanguage.hinglish:
        return 'ELIMINATE SURCHARGES WITH SPLITPE';
      case AppLanguage.marathi:
        return 'स्प्लिटपे द्वारे सरचार्ज संपवा';
      case AppLanguage.gujarati:
        return 'સ્પ્લિટપે સાથે સરચાર્જ નાબૂદ કરો';
      case AppLanguage.tamil:
        return 'ஸ்ப்ளிட்பே மூலம் கூடுதல் கட்டணங்களை ஒழிக்கவும்';
      case AppLanguage.telugu:
        return 'స్ప్లిట్పేతో సర్‌ఛార్జీలను తొలగించండి';
      case AppLanguage.kannada:
        return 'ಸ್ಪ್ಲಿಟ್‌ಪೇ ಮೂಲಕ ಹೆಚ್ಚುವರಿ ಶುಲ್ಕಗಳನ್ನು ತೊಡೆದುಹಾಕಿ';
      case AppLanguage.bengali:
        return 'স্প্লিটপে দিয়ে সারচার্জ দূর করুন';
      case AppLanguage.english:
        return 'ELIMINATE SURCHARGES WITH SPLITPE';
    }
  }

  // -------------------------------------------------------------
  // ABOUT DIALOG
  // -------------------------------------------------------------
  static String get aboutMdrTitle {
    switch (_current) {
      case AppLanguage.hindi:
        return '0% MDR आर्बिट्राज के बारे में';
      case AppLanguage.hinglish:
        return 'The 0% MDR Arbitrage';
      case AppLanguage.marathi:
        return '0% MDR आर्बिट्राज बद्दल';
      case AppLanguage.gujarati:
        return '0% MDR આર્બિટ્રેજ વિશે';
      case AppLanguage.tamil:
        return '0% MDR ஆர்பிட்ரேஜ் பற்றி';
      case AppLanguage.telugu:
        return '0% MDR ఆర్బిట్రేజ్ గురించి';
      case AppLanguage.kannada:
        return '0% MDR ಆರ್ಬಿಟ್ರೇಜ್ ಬಗ್ಗೆ';
      case AppLanguage.bengali:
        return '০% MDR আরবিট্রেজ সম্পর্কে';
      case AppLanguage.english:
        return 'The 0% MDR Arbitrage';
    }
  }

  static String get iUnderstand {
    switch (_current) {
      case AppLanguage.hindi:
        return 'मैं समझ गया';
      case AppLanguage.hinglish:
        return 'I UNDERSTAND';
      case AppLanguage.marathi:
        return 'मला समजले';
      case AppLanguage.gujarati:
        return 'હું સમજી ગયો';
      case AppLanguage.tamil:
        return 'எனக்கு புரிகிறது';
      case AppLanguage.telugu:
        return 'నాకు అర్థమైంది';
      case AppLanguage.kannada:
        return 'ನನಗೆ ಅರ್ಥವಾಯಿತು';
      case AppLanguage.bengali:
        return 'আমি বুঝতে পেরেছি';
      case AppLanguage.english:
        return 'I UNDERSTAND';
    }
  }

  // -------------------------------------------------------------
  // LANGUAGE SELECTOR MODAL
  // -------------------------------------------------------------
  static String get selectLanguage {
    switch (_current) {
      case AppLanguage.hindi:
        return 'भाषा चुनें';
      case AppLanguage.hinglish:
        return 'SELECT LANGUAGE';
      case AppLanguage.marathi:
        return 'भाषा निवडा';
      case AppLanguage.gujarati:
        return 'ભાષા પસંદ કરો';
      case AppLanguage.tamil:
        return 'மொழியைத் தேர்ந்தெடுக்கவும்';
      case AppLanguage.telugu:
        return 'ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ';
      case AppLanguage.kannada:
        return 'ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ';
      case AppLanguage.bengali:
        return 'ভাষা নির্বাচন করুন';
      case AppLanguage.english:
        return 'Select Language';
    }
  }
}

/// Extension for convenient access via `context.l10n`
extension LocalizationExtension on BuildContext {
  AppStrings get l10n => AppStrings();
}
