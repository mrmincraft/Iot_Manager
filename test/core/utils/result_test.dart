import 'package:flutter_test/flutter_test.dart';
import 'package:iot_manager/core/utils/result.dart';

/// Custom exception class for testing error handling
class CustomException implements Exception {
  final String message;
  CustomException(this.message);

  @override
  String toString() => 'CustomException: $message';
}

void main() {
  group('Result Pattern Tests', () {
    group('Result.success()', () {
      test('creates a successful Result with value', () {
        final result = Result.success(42);

        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        expect(result.value, 42);
      });

      test('success result has null error', () {
        final result = Result.success('test');

        expect(result.error, null);
      });

      test('success result works with complex types', () {
        final list = [1, 2, 3];
        final result = Result.success(list);

        expect(result.value, list);
        expect(result.isSuccess, true);
      });

      test('success result works with null value', () {
        final result = Result.success<String?>(null);

        expect(result.isSuccess, true);
        expect(result.value, null);
      });
    });

    group('Result.failure()', () {
      test('creates a failed Result with error', () {
        final error = Exception('Test error');
        final result = Result.failure(error);

        expect(result.isFailure, true);
        expect(result.isSuccess, false);
        expect(result.error, error);
      });

      test('failure result has null value', () {
        final result = Result<int>.failure(Exception('error'));

        expect(result.value, null);
      });

      test('failure result preserves error message', () {
        final errorMsg = 'This is a test error';
        final error = Exception(errorMsg);
        final result = Result.failure(error);

        expect(result.error.toString(), 'Exception: $errorMsg');
      });

      test('failure result works with custom exception types', () {
        final error = CustomException('custom error');
        final result = Result.failure(error);

        expect(result.error, error);
        expect(result.error.toString(), 'CustomException: custom error');
      });
    });

    group('Result.fold()', () {
      test('applies success function on successful result', () {
        final result = Result.success(10);
        final folded = result.fold(
          onSuccess: (value) => value * 2,
          onFailure: (error) => 0,
        );

        expect(folded, 20);
      });

      test('applies failure function on failed result', () {
        final result = Result<int>.failure(Exception('error'));
        final folded = result.fold(
          onSuccess: (value) => value * 2,
          onFailure: (error) => -1,
        );

        expect(folded, -1);
      });

      test('fold can transform types', () {
        final result = Result.success(5);
        final folded = result.fold(
          onSuccess: (value) => 'Number: $value',
          onFailure: (error) => 'Error occurred',
        );

        expect(folded, 'Number: 5');
      });

      test('fold receives correct error in failure case', () {
        final expectedError = Exception('test');
        final result = Result<int>.failure(expectedError);
        
        Exception? receivedError;
        result.fold(
          onSuccess: (value) => null,
          onFailure: (error) {
            receivedError = error;
            return null;
          },
        );

        expect(receivedError, expectedError);
      });
    });

    group('Result.map()', () {
      test('maps value on successful result', () {
        final result = Result.success(5);
        final mapped = result.map((value) => value * 2);

        expect(mapped.isSuccess, true);
        expect(mapped.value, 10);
      });

      test('preserves error on failed result', () {
        final error = Exception('test error');
        final result = Result<int>.failure(error);
        final mapped = result.map((value) => value * 2);

        expect(mapped.isFailure, true);
        expect(mapped.error, error);
      });

      test('can chain multiple maps', () {
        final result = Result.success(2);
        final chained = result
            .map((v) => v * 2)
            .map((v) => v + 10)
            .map((v) => v * 3);

        expect(chained.value, 42); // ((2 * 2) + 10) * 3 = 42
      });

      test('map transformation changes type', () {
        final result = Result.success(42);
        final mapped = result.map((value) => value.toString());

        expect(mapped.isSuccess, true);
        expect(mapped.value, '42');
      });
    });

    group('Result.mapError()', () {
      test('maps error on failed result', () {
        final originalError = Exception('original');
        final result = Result<int>.failure(originalError);
        final mapped = result.mapError((error) {
          return Exception('new error');
        });

        expect(mapped.isFailure, true);
        expect(mapped.error.toString(), 'Exception: new error');
      });

      test('preserves value on successful result', () {
        final result = Result.success(42);
        final mapped = result.mapError((error) => Exception('error'));

        expect(mapped.isSuccess, true);
        expect(mapped.value, 42);
      });

      test('can transform error type', () {
        final result = Result<int>.failure(Exception('error'));
        final mapped = result.mapError((error) => StateError('state error'));

        expect(mapped.isFailure, true);
        expect(mapped.error, isA<StateError>());
      });
    });

    group('Result.flatMap()', () {
      test('flatMap on successful result with successful result', () {
        final result = Result.success(5);
        final flatMapped = result.flatMap((value) => Result.success(value * 2));

        expect(flatMapped.isSuccess, true);
        expect(flatMapped.value, 10);
      });

      test('flatMap on successful result with failed result', () {
        final error = Exception('inner error');
        final result = Result.success(5);
        final flatMapped = result.flatMap((value) => Result.failure(error));

        expect(flatMapped.isFailure, true);
        expect(flatMapped.error, error);
      });

      test('flatMap preserves error on failed result', () {
        final error = Exception('outer error');
        final result = Result<int>.failure(error);
        final flatMapped = result.flatMap((value) => Result.success(value * 2));

        expect(flatMapped.isFailure, true);
        expect(flatMapped.error, error);
      });

      test('can chain multiple flatMaps', () {
        final result = Result.success(2)
            .flatMap((v) => Result.success(v * 2))
            .flatMap((v) => Result.success(v + 10))
            .flatMap((v) => Result.success(v * 3));

        expect(result.value, 42); // ((2 * 2) + 10) * 3 = 42
      });
    });

    group('Result.getOrNull()', () {
      test('returns value on successful result', () {
        final result = Result.success(42);
        expect(result.getOrNull(), 42);
      });

      test('returns null on failed result', () {
        final result = Result<int>.failure(Exception('error'));
        expect(result.getOrNull(), null);
      });
    });

    group('Result.getOrElse()', () {
      test('returns value on successful result', () {
        final result = Result.success(42);
        expect(result.getOrElse(() => 0), 42);
      });

      test('returns default on failed result', () {
        final result = Result<int>.failure(Exception('error'));
        expect(result.getOrElse(() => 0), 0);
      });

      test('default value can be computed', () {
        final result = Result<int>.failure(Exception('error'));
        int callCount = 0;
        
        result.getOrElse(() {
          callCount++;
          return 999;
        });

        expect(callCount, 1);
      });
    });

    group('Result.getErrorOrNull()', () {
      test('returns error on failed result', () {
        final error = Exception('test error');
        final result = Result<int>.failure(error);
        expect(result.getErrorOrNull(), error);
      });

      test('returns null on successful result', () {
        final result = Result.success(42);
        expect(result.getErrorOrNull(), null);
      });
    });

    group('Result.recover()', () {
      test('returns original value on success', () {
        final result = Result.success(42);
        final recovered = result.recover((error) => 0);

        expect(recovered.isSuccess, true);
        expect(recovered.value, 42);
      });

      test('recovers with computed value on failure', () {
        final error = Exception('error');
        final result = Result<int>.failure(error);
        final recovered = result.recover((e) => 999);

        expect(recovered.isSuccess, true);
        expect(recovered.value, 999);
      });

      test('recover receives the error', () {
        final error = Exception('custom error');
        final result = Result<int>.failure(error);
        
        Exception? receivedError;
        result.recover((e) {
          receivedError = e;
          return 0;
        });

        expect(receivedError, error);
      });
    });

    group('Result equality and comparison', () {
      test('two successful results with same value are equal', () {
        final result1 = Result.success(42);
        final result2 = Result.success(42);

        expect(result1 == result2, true);
      });

      test('two successful results with different values are not equal', () {
        final result1 = Result.success(42);
        final result2 = Result.success(43);

        expect(result1 == result2, false);
      });

      test('two failed results with same error are equal', () {
        final error = Exception('same error');
        final result1 = Result.failure(error);
        final result2 = Result.failure(error);

        expect(result1 == result2, true);
      });

      test('success and failure results are not equal', () {
        final success = Result.success(42);
        final failure = Result<int>.failure(Exception('error'));

        expect(success == failure, false);
      });
    });

    group('Result type safety', () {
      test('Result<T, E> maintains type information', () {
        final resultInt = Result<int>.success(42);
        final resultString = Result<String>.success('hello');

        expect(resultInt.value is int, true);
        expect(resultString.value is String, true);
      });
    });
  });
}
