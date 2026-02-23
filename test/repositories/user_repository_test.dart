import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tootfruit/constants/storage_keys.dart';
import 'package:tootfruit/models/toot.dart';
import 'package:tootfruit/repositories/user_repository.dart';

import '../test_helpers.dart';
import '../test_helpers.mocks.dart';

void main() {
  group('UserRepository', () {
    late UserRepository repository;
    late MockIStorageRepository mockStorage;
    final allFruitNames = toots.map((toot) => toot.fruit).toList();

    setUp(() {
      mockStorage = MockIStorageRepository();
      repository = UserRepository(mockStorage);
    });

    group('currentUser', () {
      test('returns null initially', () {
        expect(repository.currentUser, isNull);
      });

      test('returns user after loadUser', () async {
        final testUser = TestData.createUser();
        when(
          mockStorage.get<dynamic>(StorageKeys.user),
        ).thenAnswer((_) async => testUser);

        await repository.loadUser();

        expect(repository.currentUser, isNotNull);
        expect(repository.currentUser!.currentFruit, equals('peach'));
      });
    });

    group('loadUser', () {
      test('creates new user when storage is empty', () async {
        when(
          mockStorage.get<dynamic>(StorageKeys.user),
        ).thenAnswer((_) async => null);
        when(mockStorage.set(any, any)).thenAnswer((_) async => {});

        final user = await repository.loadUser();

        expect(user, isNotNull);
        expect(user.ownedFruit, equals(allFruitNames));
        expect(user.currentFruit, equals('peach'));
        verify(mockStorage.set(StorageKeys.user, any)).called(1);
      });

      test('loads existing user from storage', () async {
        final storedUser = TestData.createUser(
          ownedFruit: ['peach', 'banana'],
          currentFruit: 'banana',
        );
        when(
          mockStorage.get<dynamic>(StorageKeys.user),
        ).thenAnswer((_) async => storedUser);
        when(mockStorage.set(any, any)).thenAnswer((_) async => {});

        final user = await repository.loadUser();

        expect(user.ownedFruit, equals(allFruitNames));
        expect(user.currentFruit, equals('banana'));
      });

      test('deserializes user from JSON', () async {
        final userJson = <String, dynamic>{
          'ownedFruit': ['peach', 'cherry'],
          'currentFruit': 'cherry',
          'settings': <String, dynamic>{},
        };
        when(
          mockStorage.get<dynamic>(StorageKeys.user),
        ).thenAnswer((_) async => userJson);
        when(mockStorage.set(any, any)).thenAnswer((_) async => {});

        final user = await repository.loadUser();

        expect(user.ownedFruit, equals(allFruitNames));
        expect(user.currentFruit, equals('cherry'));
      });

      test('saves user after loading', () async {
        when(
          mockStorage.get<dynamic>(StorageKeys.user),
        ).thenAnswer((_) async => null);
        when(mockStorage.set(any, any)).thenAnswer((_) async => {});

        await repository.loadUser();

        verify(mockStorage.set(StorageKeys.user, any)).called(1);
      });
    });

    group('saveUser', () {
      test('saves user to storage', () async {
        final user = TestData.createUser();
        when(mockStorage.set(any, any)).thenAnswer((_) async => {});

        await repository.saveUser(user);

        verify(mockStorage.set(StorageKeys.user, user)).called(1);
      });

      test('updates currentUser reference', () async {
        final user = TestData.createUser(currentFruit: 'banana');
        when(mockStorage.set(any, any)).thenAnswer((_) async => {});

        await repository.saveUser(user);

        expect(repository.currentUser, equals(user));
        expect(repository.currentUser!.currentFruit, equals('banana'));
      });
    });

    group('updateCurrentFruit', () {
      test('updates fruit and saves user', () async {
        final user = TestData.createUser(currentFruit: 'peach');
        when(
          mockStorage.get<dynamic>(StorageKeys.user),
        ).thenAnswer((_) async => user);
        when(mockStorage.set(any, any)).thenAnswer((_) async => {});

        await repository.loadUser();
        await repository.updateCurrentFruit('banana');

        expect(repository.currentUser!.currentFruit, equals('banana'));
        verify(
          mockStorage.set(StorageKeys.user, any),
        ).called(2); // loadUser + updateCurrentFruit
      });

      test('throws StateError when user not loaded', () async {
        expect(() => repository.updateCurrentFruit('banana'), throwsStateError);
      });

      test('throws with descriptive message', () async {
        expect(
          () => repository.updateCurrentFruit('banana'),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('User must be loaded before updating'),
            ),
          ),
        );
      });
    });

    group('addOwnedFruit', () {
      test('adds fruit to owned list', () async {
        final user = TestData.createUser(ownedFruit: ['peach']);
        when(
          mockStorage.get<dynamic>(StorageKeys.user),
        ).thenAnswer((_) async => user);
        when(mockStorage.set(any, any)).thenAnswer((_) async => {});

        await repository.loadUser();
        await repository.addOwnedFruit('banana');

        expect(repository.currentUser!.ownedFruit, contains('banana'));
        expect(
          repository.currentUser!.ownedFruit.length,
          equals(allFruitNames.length + 1),
        );
      });

      test('saves user after adding fruit', () async {
        final user = TestData.createUser(ownedFruit: ['peach']);
        when(
          mockStorage.get<dynamic>(StorageKeys.user),
        ).thenAnswer((_) async => user);
        when(mockStorage.set(any, any)).thenAnswer((_) async => {});

        await repository.loadUser();
        await repository.addOwnedFruit('banana');

        verify(mockStorage.set(StorageKeys.user, any)).called(2);
      });

      test('throws StateError when user not loaded', () async {
        expect(() => repository.addOwnedFruit('banana'), throwsStateError);
      });
    });

    group('setAllFruitsOwned', () {
      test('replaces owned fruit list', () async {
        final user = TestData.createUser(ownedFruit: ['peach']);
        when(
          mockStorage.get<dynamic>(StorageKeys.user),
        ).thenAnswer((_) async => user);
        when(mockStorage.set(any, any)).thenAnswer((_) async => {});

        await repository.loadUser();
        await repository.setAllFruitsOwned(['peach', 'banana', 'cherry']);

        expect(
          repository.currentUser!.ownedFruit,
          equals(['peach', 'banana', 'cherry']),
        );
      });

      test('saves user after setting fruits', () async {
        final user = TestData.createUser();
        when(
          mockStorage.get<dynamic>(StorageKeys.user),
        ).thenAnswer((_) async => user);
        when(mockStorage.set(any, any)).thenAnswer((_) async => {});

        await repository.loadUser();
        await repository.setAllFruitsOwned(['peach', 'banana']);

        verify(mockStorage.set(StorageKeys.user, any)).called(2);
      });

      test('throws StateError when user not loaded', () async {
        expect(() => repository.setAllFruitsOwned(['peach']), throwsStateError);
      });
    });
  });
}
