import 'package:flutter_test/flutter_test.dart';
import 'package:Fintrack/data/models/book.dart';

void main() {
  group('Book Model Tests', () {
    test('Book can be created with required fields', () {
      final book = Book(
        name: 'Test Book',
        balance: 1000.0,
        userId: 1,
      );

      expect(book.name, equals('Test Book'));
      expect(book.balance, equals(1000.0));
      expect(book.userId, equals(1));
      expect(book.id, isNull);
    });

    test('Book can be created with id', () {
      final book = Book(
        id: 1,
        name: 'Test Book',
        balance: 1000.0,
        userId: 1,
      );

      expect(book.id, equals(1));
      expect(book.name, equals('Test Book'));
    });

    test('Book balance can be negative', () {
      final book = Book(
        id: 2,
        name: 'Debt Book',
        balance: -500.0,
        userId: 1,
        createdAt: DateTime.now(),
      );

      expect(book.balance, lessThan(0));
    });

    test('Book toMap creates correct Map', () {
      final now = DateTime.now();
      final book = Book(
        id: 3,
        name: 'Map Test',
        balance: 750.5,
        userId: 1,
        createdAt: now,
      );

      final map = book.toMap();

      expect(map['id'], equals(3));
      expect(map['name'], equals('Map Test'));
      expect(map['balance'], equals(750.5));
      expect(map['user_id'], equals(1));
    });

    test('Book fromMap creates correct Book object', () {
      final now = DateTime.now();
      final map = {
        'id': 4,
        'name': 'From Map',
        'balance': 1234.56,
        'user_id': 2,
        'created_at': now.toIso8601String(),
      };

      final book = Book.fromMap(map);

      expect(book.id, equals(4));
      expect(book.name, equals('From Map'));
      expect(book.balance, equals(1234.56));
      expect(book.userId, equals(2));
    });

    test('Book copyWith creates new instance with updated values', () {
      final original = Book(
        id: 5,
        name: 'Original',
        balance: 100.0,
        userId: 1,
      );

      final updated = original.copyWith(
        name: 'Updated',
        balance: 200.0,
      );

      expect(updated.id, equals(5));
      expect(updated.name, equals('Updated'));
      expect(updated.balance, equals(200.0));
      expect(updated.userId, equals(1));
    });

    test('Book createdAt defaults to now when not provided', () {
      final before = DateTime.now();
      final book = Book(
        name: 'Test',
        balance: 0.0,
        userId: 1,
      );
      final after = DateTime.now();

      expect(book.createdAt.isAfter(before.subtract(Duration(seconds: 1))), isTrue);
      expect(book.createdAt.isBefore(after.add(Duration(seconds: 1))), isTrue);
    });
  });
}
