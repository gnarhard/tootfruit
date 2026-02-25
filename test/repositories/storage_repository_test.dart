import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tootfruit/repositories/storage_repository.dart';

void main() {
  group('FileStorageRepository', () {
    test(
      'persists values to disk when a storage directory is available',
      () async {
        final tempDir = Directory.systemTemp.createTempSync(
          'tootfruit-storage-test-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        final repository = FileStorageRepository(
          storageDirectoryProvider: () async => tempDir.path,
        );

        await repository.set('fruit', 'banana');
        final firstRead = await repository.get<String>('fruit');
        expect(firstRead, equals('banana'));

        final freshRepository = FileStorageRepository(
          storageDirectoryProvider: () async => tempDir.path,
        );
        final secondRead = await freshRepository.get<String>('fruit');
        expect(secondRead, equals('banana'));
      },
    );

    test(
      'falls back to in-memory storage when file storage is unavailable',
      () async {
        var providerCallCount = 0;
        final repository = FileStorageRepository(
          storageDirectoryProvider: () async {
            providerCallCount += 1;
            throw StateError('storage unavailable');
          },
        );

        await repository.set('fruit', 'strawberry');
        final fruit = await repository.get<String>('fruit');
        final exists = await repository.exists('fruit');

        expect(fruit, equals('strawberry'));
        expect(exists, isTrue);
        expect(providerCallCount, equals(1));
      },
    );
  });
}
