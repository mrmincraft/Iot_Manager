import 'package:flutter_test/flutter_test.dart';
import 'package:iot_manager/core/exceptions/exceptions.dart';

void main() {
  group('App Exception Tests', () {
    group('AppException Base Class', () {
      test('creates exception with message', () {
        final exception = AppException(message: 'Test error');

        expect(exception.message, 'Test error');
        expect(exception.code, null);
      });

      test('creates exception with message and code', () {
        final exception = AppException(
          message: 'Test error',
          code: 'TEST_CODE',
        );

        expect(exception.message, 'Test error');
        expect(exception.code, 'TEST_CODE');
      });

      test('toString returns message', () {
        final exception = AppException(message: 'Test error');

        expect(exception.toString(), 'AppException: Test error');
      });

      test('toString includes code when present', () {
        final exception = AppException(
          message: 'Test error',
          code: 'ERR_001',
        );

        expect(exception.toString(), 'AppException: Test error (ERR_001)');
      });

      test('exception is Throwable', () {
        final exception = AppException(message: 'Test error');

        expect(exception is Exception, true);
      });
    });

    group('DataException', () {
      test('creates DataException with message', () {
        final exception = DataException(message: 'Database error');

        expect(exception.message, 'Database error');
        expect(exception, isA<AppException>());
      });

      test('toString identifies as DataException', () {
        final exception = DataException(message: 'Query failed');

        expect(exception.toString(), contains('DataException'));
      });

      test('DataException can be caught as AppException', () {
        expect(
          () => throw DataException(message: 'db error'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('CacheException', () {
      test('creates CacheException with message', () {
        final exception = CacheException(message: 'Cache miss');

        expect(exception.message, 'Cache miss');
        expect(exception, isA<DataException>());
      });

      test('CacheException can be caught as DataException', () {
        expect(
          () => throw CacheException(message: 'cache error'),
          throwsA(isA<DataException>()),
        );
      });

      test('CacheException can be caught as AppException', () {
        expect(
          () => throw CacheException(message: 'cache error'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('ValidationException', () {
      test('creates ValidationException with message', () {
        final exception = ValidationException(
          message: 'Invalid input',
          field: 'email',
        );

        expect(exception.message, 'Invalid input');
        expect(exception.field, 'email');
      });

      test('ValidationException has field information', () {
        final exception = ValidationException(
          message: 'Required field',
          field: 'username',
        );

        expect(exception.field, 'username');
      });

      test('ValidationException without field', () {
        final exception = ValidationException(message: 'Invalid');

        expect(exception.field, null);
      });

      test('ValidationException can be caught', () {
        expect(
          () => throw ValidationException(
            message: 'validation error',
            field: 'test_field',
          ),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('NetworkException', () {
      test('creates NetworkException with message', () {
        final exception = NetworkException(message: 'Connection timeout');

        expect(exception.message, 'Connection timeout');
        expect(exception, isA<AppException>());
      });

      test('NetworkException with code', () {
        final exception = NetworkException(
          message: 'Failed to connect',
          code: 'TIMEOUT',
        );

        expect(exception.code, 'TIMEOUT');
      });

      test('NetworkException can be caught', () {
        expect(
          () => throw NetworkException(message: 'network error'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('NotImplementedException', () {
      test('creates NotImplementedException', () {
        final exception = NotImplementedException(message: 'Feature not ready');

        expect(exception.message, 'Feature not ready');
        expect(exception, isA<AppException>());
      });

      test('can be caught as AppException', () {
        expect(
          () => throw NotImplementedException(message: 'not implemented'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('Exception Hierarchy', () {
      test('DataException is child of AppException', () {
        final exception = DataException(message: 'data error');

        expect(exception, isA<AppException>());
      });

      test('CacheException is grandchild of AppException', () {
        final exception = CacheException(message: 'cache error');

        expect(exception, isA<DataException>());
        expect(exception, isA<AppException>());
      });

      test('Multiple exceptions can be handled differently', () {
        final exceptions = [
          DataException(message: 'db error'),
          CacheException(message: 'cache error'),
          ValidationException(message: 'validation error', field: 'name'),
          NetworkException(message: 'network error'),
          NotImplementedException(message: 'not impl'),
        ];

        int dataCount = 0;
        int validationCount = 0;
        int networkCount = 0;

        for (final ex in exceptions) {
          if (ex is DataException && ex is! CacheException) {
            dataCount++;
          }
          if (ex is ValidationException) {
            validationCount++;
          }
          if (ex is NetworkException) {
            networkCount++;
          }
        }

        expect(dataCount, 1);
        expect(validationCount, 1);
        expect(networkCount, 1);
      });
    });

    group('Exception messages', () {
      test('exception message is preserved', () {
        const message = 'This is a detailed error message';
        final exception = AppException(message: message);

        expect(exception.message, message);
      });

      test('exception code is preserved', () {
        const code = 'ERROR_CODE_123';
        final exception = AppException(message: 'error', code: code);

        expect(exception.code, code);
      });

      test('special characters in message', () {
        final message = 'Error: @#\$%^&*()[]{}';
        final exception = AppException(message: message);

        expect(exception.message, message);
      });

      test('long message is preserved', () {
        final longMessage = 'a' * 1000;
        final exception = AppException(message: longMessage);

        expect(exception.message, longMessage);
        expect(exception.message.length, 1000);
      });
    });

    group('Exception rethrow', () {
      test('exception can be rethrown', () {
        try {
          throw AppException(message: 'original error', code: 'CODE_001');
        } catch (e) {
          expect(() => throw e, throwsA(isA<AppException>()));
        }
      });

      test('rethrown exception preserves data', () {
        const originalMessage = 'original error';
        const originalCode = 'CODE_001';

        try {
          throw AppException(message: originalMessage, code: originalCode);
        } catch (e) {
          final exception = e as AppException;
          expect(exception.message, originalMessage);
          expect(exception.code, originalCode);
        }
      });
    });

    group('Exception comparison', () {
      test('same exception type and message', () {
        final ex1 = AppException(message: 'error');
        final ex2 = AppException(message: 'error');

        expect(ex1.message, ex2.message);
      });

      test('different exception messages', () {
        final ex1 = AppException(message: 'error 1');
        final ex2 = AppException(message: 'error 2');

        expect(ex1.message != ex2.message, true);
      });

      test('different exception types', () {
        final ex1 = DataException(message: 'db error');
        final ex2 = NetworkException(message: 'network error');

        expect(ex1.runtimeType != ex2.runtimeType, true);
      });
    });
  });
}
