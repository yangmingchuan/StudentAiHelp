import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:little_hero/core/database/local_database.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite3;

void main() {
  test('legacy database copy includes committed WAL rows', () async {
    final directory = await Directory.systemTemp.createTemp('little-hero-db-');
    addTearDown(() => directory.delete(recursive: true));
    final source = p.join(directory.path, 'legacy.sqlite');
    final target = p.join(directory.path, 'account.sqlite');
    final db = sqlite3.sqlite3.open(source);
    addTearDown(db.close);
    db.execute('PRAGMA journal_mode=WAL');
    db.execute('CREATE TABLE sample (value TEXT NOT NULL)');
    db.execute("INSERT INTO sample VALUES ('preserved')");

    await copyLegacyDatabase(source, target);

    final copied = sqlite3.sqlite3.open(target);
    addTearDown(copied.close);
    expect(
      copied.select('SELECT value FROM sample').single['value'],
      'preserved',
    );
  });
}
