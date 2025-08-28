import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitalong/services/auth/auth_service.dart';
import 'package:mockito/mockito.dart';

// Mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockAuthCredential extends Mock implements AuthCredential {}

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();

      authService = AuthService();
    });

    group('login', () {
      test('should sign in successfully with valid credentials', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        ),).thenAnswer((_) async => mockUserCredential);

        // Act & Assert
        expect(
          () => authService.login(
            email: email,
            password: password,
          ),
          returnsNormally,
        );
      });

      test('should throw AuthException for invalid email', () async {
        // Arrange
        const email = 'invalid-email';
        const password = 'password123';

        // Act & Assert
        expect(
          () => authService.login(
            email: email,
            password: password,
          ),
          throwsException,
        );
      });

      test('should throw AuthException for empty email', () async {
        // Arrange
        const email = '';
        const password = 'password123';

        // Act & Assert
        expect(
          () => authService.login(
            email: email,
            password: password,
          ),
          throwsException,
        );
      });

      test('should throw AuthException for empty password', () async {
        // Arrange
        const email = 'test@example.com';
        const password = '';

        // Act & Assert
        expect(
          () => authService.login(
            email: email,
            password: password,
          ),
          throwsException,
        );
      });

      test('should handle FirebaseAuthException - user not found', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        ),).thenThrow(
          FirebaseAuthException(
            code: 'user-not-found',
            message: 'User not found',
          ),
        );

        // Act & Assert
        expect(
          () => authService.login(
            email: email,
            password: password,
          ),
          throwsException,
        );
      });

      test('should trim whitespace from email and password', () async {
        // Arrange
        const email = '  test@example.com  ';
        const password = '  password123  ';

        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),).thenAnswer((_) async => mockUserCredential);

        // Act
        await authService.login(
          email: email,
          password: password,
        );

        // Assert
        verify(mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),).called(1);
      });
    });

    group('createAccount', () {
      test('should create user successfully with valid credentials', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(mockUser.emailVerified).thenReturn(false);
        when(mockUser.sendEmailVerification()).thenAnswer((_) async {});
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await authService.createAccount(
          email: email,
          password: password,
          displayName: 'Test User',
        );

        // Assert
        expect(result, equals(mockUserCredential));
        verify(mockUser.sendEmailVerification()).called(1);
      });

      test('should throw AuthException for weak password', () async {
        // Arrange
        const email = 'test@example.com';
        const password = '123';

        // Act & Assert
        expect(
          () => authService.createAccount(
            email: email,
            password: password,
            displayName: 'Test User',
          ),
          throwsException,
        );
      });
    });
  });
}
