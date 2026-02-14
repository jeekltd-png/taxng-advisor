import 'package:flutter_test/flutter_test.dart';
import 'package:taxng_advisor/services/hive_service.dart';

/// Unit tests for HiveService box constants and static configuration.
/// Note: Service-level integration tests that require Hive initialization
/// are tested separately in integration tests where the Flutter binding
/// and path_provider are available.

void main() {
  group('HiveService - Box Constants', () {
    test('should have correct CIT box name', () {
      expect(HiveService.citBox, equals('cit_estimates'));
    });

    test('should have correct PIT box name', () {
      expect(HiveService.pitBox, equals('pit_estimates'));
    });

    test('should have correct VAT box name', () {
      expect(HiveService.vatBox, equals('vat_returns'));
    });

    test('should have correct WHT box name', () {
      expect(HiveService.whtBox, equals('wht_records'));
    });

    test('should have correct Stamp Duty box name', () {
      expect(HiveService.stampDutyBox, equals('stamp_duty_records'));
    });

    test('should have correct Payroll box name', () {
      expect(HiveService.payrollBox, equals('payroll_records'));
    });

    test('should have correct Users box name', () {
      expect(HiveService.usersBox, equals('users'));
    });

    test('should have correct Payments box name', () {
      expect(HiveService.paymentsBox, equals('payments'));
    });

    test('should have correct Sync box name', () {
      expect(HiveService.syncBox, equals('sync_status'));
    });

    test('should have correct Profile box name', () {
      expect(HiveService.profileBox, equals('profile_settings'));
    });

    test('should have correct Upgrade Requests box name', () {
      expect(HiveService.upgradeRequestsBox, equals('upgrade_requests'));
    });
  });

  group('HiveService - Box Name Uniqueness', () {
    test('should have unique box names for all tax types', () {
      final boxNames = <String>{
        HiveService.citBox,
        HiveService.pitBox,
        HiveService.vatBox,
        HiveService.whtBox,
        HiveService.stampDutyBox,
        HiveService.payrollBox,
      };

      // All 6 tax type box names should be unique
      expect(boxNames.length, equals(6));
    });

    test('should have unique box names for all system boxes', () {
      final systemBoxNames = <String>{
        HiveService.usersBox,
        HiveService.paymentsBox,
        HiveService.syncBox,
        HiveService.profileBox,
        HiveService.upgradeRequestsBox,
      };

      // All system box names should be unique
      expect(systemBoxNames.length, equals(5));
    });

    test('should not have overlapping tax and system box names', () {
      final taxBoxNames = <String>{
        HiveService.citBox,
        HiveService.pitBox,
        HiveService.vatBox,
        HiveService.whtBox,
        HiveService.stampDutyBox,
        HiveService.payrollBox,
      };

      final systemBoxNames = <String>{
        HiveService.usersBox,
        HiveService.paymentsBox,
        HiveService.syncBox,
        HiveService.profileBox,
        HiveService.upgradeRequestsBox,
      };

      // No box names should appear in both sets
      expect(taxBoxNames.intersection(systemBoxNames), isEmpty);
    });
  });

  group('HiveService - Box Name Format', () {
    test('box names should use lowercase and underscores', () {
      final allBoxNames = [
        HiveService.citBox,
        HiveService.pitBox,
        HiveService.vatBox,
        HiveService.whtBox,
        HiveService.stampDutyBox,
        HiveService.payrollBox,
        HiveService.usersBox,
        HiveService.paymentsBox,
        HiveService.syncBox,
        HiveService.profileBox,
        HiveService.upgradeRequestsBox,
      ];

      for (final name in allBoxNames) {
        // Should be lowercase with underscores (snake_case)
        expect(name, equals(name.toLowerCase()));
        expect(name.contains(' '), isFalse);
      }
    });

    test('box names should not be empty', () {
      final allBoxNames = [
        HiveService.citBox,
        HiveService.pitBox,
        HiveService.vatBox,
        HiveService.whtBox,
        HiveService.stampDutyBox,
        HiveService.payrollBox,
        HiveService.usersBox,
        HiveService.paymentsBox,
        HiveService.syncBox,
        HiveService.profileBox,
        HiveService.upgradeRequestsBox,
      ];

      for (final name in allBoxNames) {
        expect(name.isNotEmpty, isTrue);
      }
    });
  });
}
