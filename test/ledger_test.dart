import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitpe/models/ledger_entry.dart';
import 'package:splitpe/models/tranche.dart';
import 'package:splitpe/models/user_profile.dart';
import 'package:splitpe/services/ledger_exporter.dart';
import 'package:splitpe/services/session_ledger_service.dart';
import 'package:splitpe/services/upi_phone_extractor.dart';
import 'package:splitpe/services/user_profile_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });
  group('1. UPI ID Phone Extraction (extractPhoneFromUpiId)', () {
    test('returns 10-digit phone for valid phone VPAs', () {
      expect(extractPhoneFromUpiId('9876543210@paytm'), '9876543210');
      expect(extractPhoneFromUpiId('9123456780@ybl'), '9123456780');
      expect(extractPhoneFromUpiId('8000012345@okhdfcbank'), '8000012345');
      expect(extractPhoneFromUpiId('9999999999@upi'), '9999999999');
    });

    test('returns null for valid non-numeric VPAs', () {
      expect(extractPhoneFromUpiId('merchant@upi'), isNull);
      expect(extractPhoneFromUpiId('john.doe@okaxis'), isNull);
      expect(extractPhoneFromUpiId('store@okhdfcbank'), isNull);
      expect(extractPhoneFromUpiId('guptakirana@icici'), isNull);
    });

    test('degrades gracefully and returns null on malformed input', () {
      // No @
      expect(extractPhoneFromUpiId('9876543210'), isNull);
      // Empty string
      expect(extractPhoneFromUpiId(''), isNull);
      // Letters mixed with digits in phone part
      expect(extractPhoneFromUpiId('98765a4321@paytm'), isNull);
      // Too short (5 digits)
      expect(extractPhoneFromUpiId('12345@paytm'), isNull);
      // Too long (11 digits)
      expect(extractPhoneFromUpiId('98765432109@paytm'), isNull);
      // Multiple @ symbols
      expect(extractPhoneFromUpiId('9876543210@paytm@ok'), isNull);
      // Empty local part
      expect(extractPhoneFromUpiId('@paytm'), isNull);
      // Country code prefixed (+91)
      expect(extractPhoneFromUpiId('+919876543210@paytm'), isNull);
    });
  });

  group('2. CSV Generation & Escaping (LedgerExporter)', () {
    test('generates expected CSV header for an empty ledger', () {
      final csv = LedgerExporter.generateCsv([]);
      expect(csv.trim(), 'Date,Time,Amount,Sender UPI,Receiver UPI,Note');
    });

    test('generates proper CSV formatting for standard entries', () {
      final entries = [
        LedgerEntry(
          timestamp: DateTime(2026, 9, 18, 14, 30, 0),
          amount: 1999.00,
          senderUpiId: 'alice@upi',
          receiverUpiId: 'bob@upi',
          note: 'Tranche 1',
          trancheIndex: 0,
        ),
      ];

      final csv = LedgerExporter.generateCsv(entries);
      final lines = csv.trim().split('\n');
      expect(lines.length, 2);
      expect(lines[0], 'Date,Time,Amount,Sender UPI,Receiver UPI,Note');
      expect(lines[1], '2026-09-18,14:30:00,1999.00,alice@upi,bob@upi,Tranche 1');
    });

    test('properly escapes special characters in notes (commas, quotes, newlines)', () {
      // Test commas in note
      expect(
        LedgerExporter.escapeCsvNote('Split 1, dinner, drinks'),
        '"Split 1, dinner, drinks"',
      );

      // Test double quotes in note
      expect(
        LedgerExporter.escapeCsvNote('He said "urgent"'),
        '"He said ""urgent"""',
      );

      // Test newlines in note
      expect(
        LedgerExporter.escapeCsvNote('Line1\nLine2'),
        '"Line1\nLine2"',
      );

      // Test combined commas and double quotes
      expect(
        LedgerExporter.escapeCsvNote('Item 1, "special deal"'),
        '"Item 1, ""special deal"""',
      );

      // Test null note
      expect(LedgerExporter.escapeCsvNote(null), '');

      // Test empty note
      expect(LedgerExporter.escapeCsvNote(''), '');

      // Test full CSV export with special characters
      final entries = [
        LedgerEntry(
          timestamp: DateTime(2026, 9, 18, 10, 0, 0),
          amount: 1500.0,
          senderUpiId: 'user@upi',
          receiverUpiId: 'shop@upi',
          note: 'Groceries, "fresh" fruits\n& veg',
        ),
      ];

      final csv = LedgerExporter.generateCsv(entries);
      expect(csv, contains('1500.00,user@upi,shop@upi,"Groceries, ""fresh"" fruits\n& veg"'));
    });

    test('generates plain-text summary optimized for SMS with amount and count', () {
      final emptySummary = LedgerExporter.generatePlainTextSummary([]);
      expect(emptySummary, 'SplitPe: No transactions in this session.');

      final entries = [
        LedgerEntry(
          timestamp: DateTime.now(),
          amount: 1999.0,
          senderUpiId: 'payer@upi',
          receiverUpiId: '9876543210@paytm',
          note: 'Tranche 1/2',
          trancheIndex: 0,
        ),
        LedgerEntry(
          timestamp: DateTime.now(),
          amount: 1851.0,
          senderUpiId: 'payer@upi',
          receiverUpiId: '9876543210@paytm',
          note: 'Tranche 2/2',
          trancheIndex: 1,
        ),
      ];

      final summary = LedgerExporter.generatePlainTextSummary(entries);
      expect(summary, contains('2 tranches'));
      expect(summary, contains('Total ₹3850'));
      expect(summary, contains('₹1999 to 9876543210@paytm (Tranche 1/2)'));
      expect(summary, contains('₹1851 to 9876543210@paytm (Tranche 2/2)'));
    });
  });

  group('3. Session Ledger Provider (SessionLedgerService)', () {
    setUp(() {
      SessionLedgerService.instance.clear();
    });

    test('appends entries correctly and maintains newest-first order', () {
      final service = SessionLedgerService.instance;
      expect(service.count, 0);
      expect(service.totalVolume, 0.0);

      service.recordTrancheLaunch(
        amount: 1000.0,
        receiverUpiId: 'merchant@upi',
        senderUpiId: 'alice@upi',
        note: 'First tranche',
        trancheIndex: 0,
      );

      service.recordTrancheLaunch(
        amount: 1500.0,
        receiverUpiId: 'merchant@upi',
        senderUpiId: 'alice@upi',
        note: 'Second tranche',
        trancheIndex: 1,
      );

      expect(service.count, 2);
      expect(service.totalVolume, 2500.0);

      // Check newest-first ordering
      final newest = service.newestFirst;
      expect(newest.first.amount, 1500.0);
      expect(newest.first.note, 'Second tranche');
      expect(newest.last.amount, 1000.0);
      expect(newest.last.note, 'First tranche');

      // Status defaults to self-reported / inProgress
      expect(newest.first.status, TrancheStatus.inProgress);
      expect(newest.first.statusLabel, 'LAUNCHED (SELF-REPORTED)');
    });

    test('clears ledger entries on demand', () {
      final service = SessionLedgerService.instance;
      service.recordTrancheLaunch(
        amount: 1999.0,
        receiverUpiId: 'store@upi',
      );
      expect(service.count, 1);

      service.clear();
      expect(service.count, 0);
      expect(service.entries, isEmpty);
      expect(service.totalVolume, 0.0);
    });

    test('filters entries accurately by TrancheStatus', () {
      final service = SessionLedgerService.instance;

      service.recordTrancheLaunch(
        amount: 1000.0,
        receiverUpiId: 'store1@upi',
        status: TrancheStatus.inProgress,
        trancheIndex: 0,
      );

      service.recordTrancheLaunch(
        amount: 1200.0,
        receiverUpiId: 'store2@upi',
        status: TrancheStatus.paid,
        trancheIndex: 1,
      );

      service.recordTrancheLaunch(
        amount: 800.0,
        receiverUpiId: 'store3@upi',
        status: TrancheStatus.failed,
        trancheIndex: 2,
      );

      final inProgress = service.getFilteredEntries(statusFilter: TrancheStatus.inProgress);
      final paid = service.getFilteredEntries(statusFilter: TrancheStatus.paid);
      final failed = service.getFilteredEntries(statusFilter: TrancheStatus.failed);
      final all = service.getFilteredEntries(statusFilter: null);

      expect(inProgress.length, 1);
      expect(inProgress.first.amount, 1000.0);

      expect(paid.length, 1);
      expect(paid.first.amount, 1200.0);

      expect(failed.length, 1);
      expect(failed.first.amount, 800.0);

      expect(all.length, 3);
    });

    test('updates tranche status correctly', () {
      final service = SessionLedgerService.instance;

      service.recordTrancheLaunch(
        amount: 1999.0,
        receiverUpiId: 'store@upi',
        trancheIndex: 0,
        billId: 42,
        status: TrancheStatus.inProgress,
      );

      expect(service.entries.first.status, TrancheStatus.inProgress);

      service.updateTrancheStatus(
        trancheIndex: 0,
        billId: 42,
        status: TrancheStatus.paid,
      );

      expect(service.entries.first.status, TrancheStatus.paid);
      expect(service.entries.first.statusLabel, 'PAID (SELF-REPORTED)');
    });
  });

  group('4. User Profile Persistence (UserProfile & UserProfileService)', () {
    test('validates UserProfile correctly', () {
      const validProfile = UserProfile(name: 'Vikram', upiId: 'vikram@okhdfcbank');
      expect(validProfile.isValid, isTrue);

      const invalidName = UserProfile(name: '   ', upiId: 'vikram@okhdfcbank');
      expect(invalidName.isValid, isFalse);

      const invalidUpi = UserProfile(name: 'Vikram', upiId: 'notAnEmailVpa');
      expect(invalidUpi.isValid, isFalse);
    });

    test('saves, loads, and clears profile accurately', () async {
      final service = UserProfileService.instance;
      await service.clearProfile();
      expect(service.hasProfile, isFalse);

      const profile = UserProfile(name: 'Aman', upiId: 'aman@paytm');
      await service.saveProfile(profile);

      expect(service.hasProfile, isTrue);
      expect(service.profile?.name, 'Aman');
      expect(service.profile?.upiId, 'aman@paytm');

      // Clear profile
      await service.clearProfile();
      expect(service.hasProfile, isFalse);
      expect(service.profile, isNull);
    });
  });
}
