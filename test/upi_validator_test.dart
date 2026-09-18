import 'package:flutter_test/flutter_test.dart';
import 'package:splitpe/services/upi_validator.dart';

void main() {
  group('UpiValidator - Valid Standard URIs & VPAs', () {
    test('Validates full NPCI UPI URI with all parameters', () {
      const raw =
          'upi://pay?pa=merchant@okhdfcbank&pn=Super%20Mart&am=3500.50&cu=INR&tn=Invoice%20102&mc=5411&tr=TXN12345';
      final result = UpiValidator.validate(raw);

      expect(result.isValid, isTrue);
      expect(result.vpa, 'merchant@okhdfcbank');
      expect(result.merchantName, 'Super Mart');
      expect(result.amount, 3500.50);
      expect(result.currency, 'INR');
      expect(result.note, 'Invoice 102');
      expect(result.merchantCategoryCode, '5411');
      expect(result.txnRef, 'TXN12345');
      expect(result.issuingApp, 'Google Pay');
      expect(result.issuingBank, 'HDFC Bank');
      expect(result.errorMessage, isNull);
    });

    test('Validates standalone plain VPA string', () {
      const raw = 'technoaman@okaxis';
      final result = UpiValidator.validate(raw);

      expect(result.isValid, isTrue);
      expect(result.vpa, 'technoaman@okaxis');
      expect(result.issuingApp, 'Google Pay');
      expect(result.issuingBank, 'Axis Bank');
    });

    test('Validates phone-number based VPAs', () {
      final phonePeResult = UpiValidator.validate('9876543210@ybl');
      expect(phonePeResult.isValid, isTrue);
      expect(phonePeResult.vpa, '9876543210@ybl');
      expect(phonePeResult.issuingApp, 'PhonePe');
      expect(phonePeResult.issuingBank, 'Yes Bank');

      final paytmResult = UpiValidator.validate('9876543210@paytm');
      expect(paytmResult.isValid, isTrue);
      expect(paytmResult.issuingApp, 'Paytm');
    });

    test('Validates BHIM and official direct bank handles', () {
      final bhim = UpiValidator.validate('modi@upi');
      expect(bhim.isValid, isTrue);
      expect(bhim.issuingApp, 'BHIM');
      expect(bhim.issuingBank, 'NPCI');

      final sbi = UpiValidator.validate('store@sbi');
      expect(sbi.isValid, isTrue);
      expect(sbi.issuingApp, 'SBI Pay');
      expect(sbi.issuingBank, 'State Bank of India');

      final icici = UpiValidator.validate('retail@icici');
      expect(icici.isValid, isTrue);
      expect(icici.issuingApp, 'iMobile');
      expect(icici.issuingBank, 'ICICI Bank');

      final amazon = UpiValidator.validate('order@apl');
      expect(amazon.isValid, isTrue);
      expect(amazon.issuingApp, 'Amazon Pay');
      expect(amazon.issuingBank, 'Axis Bank');

      final whatsapp = UpiValidator.validate('shop@waaxis');
      expect(whatsapp.isValid, isTrue);
      expect(whatsapp.issuingApp, 'WhatsApp Pay');
    });

    test('Accepts valid future/unlisted handles gracefully via universal regex', () {
      final unlisted = UpiValidator.validate('vendor@futuristicbank');
      expect(unlisted.isValid, isTrue);
      expect(unlisted.vpa, 'vendor@futuristicbank');
      expect(unlisted.issuingApp, isNull);
      expect(unlisted.issuingBank, isNull);
    });
  });

  group('UpiValidator - Security, Injection & Malformed Attacks', () {
    test('Rejects arbitrary non-UPI phishing URLs', () {
      final phishing = UpiValidator.validate('https://malicious-login-phishing.com/account');
      expect(phishing.isValid, isFalse);
      expect(phishing.errorMessage, contains('Invalid'));
    });

    test('Rejects JavaScript / Script scheme injections', () {
      final xss = UpiValidator.validate('javascript:alert(document.cookie)');
      expect(xss.isValid, isFalse);
    });

    test('Sanitizes HTML / XSS payloads in name and note fields', () {
      const raw =
          'upi://pay?pa=store@okicici&pn=<script>alert("xss")</script>Store&tn=<b>PayNow</b>';
      final result = UpiValidator.validate(raw);

      expect(result.isValid, isTrue);
      expect(result.merchantName, 'Store'); // Script tags stripped
      expect(result.note, 'PayNow'); // HTML tags stripped
    });

    test('Rejects malformed VPAs (spaces, missing @, illegal chars)', () {
      expect(UpiValidator.validate('store space@okhdfcbank').isValid, isFalse);
      expect(UpiValidator.validate('store@').isValid, isFalse);
      expect(UpiValidator.validate('@okhdfcbank').isValid, isFalse);
      expect(UpiValidator.validate('store@@okhdfcbank').isValid, isFalse);
      expect(UpiValidator.validate('store!#\$%@okhdfcbank').isValid, isFalse);
      expect(UpiValidator.validate('').isValid, isFalse);
    });

    test('Rejects negative or NaN amounts', () {
      const negative = 'upi://pay?pa=store@okhdfcbank&am=-500';
      final resultNegative = UpiValidator.validate(negative);
      expect(resultNegative.amount, isNull); // Filtered out

      const nanAmt = 'upi://pay?pa=store@okhdfcbank&am=invalid_number';
      final resultNan = UpiValidator.validate(nanAmt);
      expect(resultNan.amount, isNull);
    });

    test('Rejects non-INR foreign currencies', () {
      const foreign = 'upi://pay?pa=store@okhdfcbank&am=500&cu=USD';
      final result = UpiValidator.validate(foreign);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Currency'));
    });
  });
}
