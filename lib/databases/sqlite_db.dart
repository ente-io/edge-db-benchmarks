import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:edge_db_benchmarks/models/embedding.pb.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite_async/sqlite_async.dart';

class SqliteDB {
  static const databaseName = "embeddings.sqlite.db";
  static const tableName = "embeddings";
  static const columnGeneratedID = "_id";
  static const columnEmbedding = "embedding";

  SqliteDB._privateConstructor();

  static final SqliteDB instance = SqliteDB._privateConstructor();

  static Future<SqliteDatabase>? _dbFuture;

  Future<void> init() async {
    await _database;
    log('SqliteDB initialized');
  }

  Future<SqliteDatabase> get _database async {
    _dbFuture ??= _initDatabase();
    return _dbFuture!;
  }

  Future<SqliteDatabase> _initDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, databaseName);
    log('SqliteDB path: $path');
    // Start afresh each time
    if (await File(path).exists()) {
      await File(path).delete();
    }
    final migrations = SqliteMigrations()
      ..add(SqliteMigration(
        1,
        (tx) async {
          await tx.execute(
              'CREATE TABLE $tableName ($columnGeneratedID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $columnEmbedding BLOB)');
        },
      ));
    final database = SqliteDatabase(path: path);
    await migrations.migrate(database);
    return database;
  }

  Future<void> insertEmbedding(EmbeddingProto embedding) async {
    final db = await _database;
    await db.writeTransaction((tx) async {
      await tx.execute('INSERT INTO $tableName ($columnEmbedding) values(?)',
          [embedding.writeToBuffer()]);
    });
  }

  Future<void> insertMultipleEmbeddings(List<EmbeddingProto> embeddings) async {
    final db = await _database;
    final inputs = embeddings.map((e) => [e.writeToBuffer()]).toList();
    await db.executeBatch(
        'INSERT INTO $tableName ($columnEmbedding) values(?)', inputs);
  }

  Future<List<EmbeddingProto>> embeddings() async {
    int offset = 0;
    List<EmbeddingProto> currentBatch;
    final List<EmbeddingProto> results = [];
    do {
      currentBatch = await _fetchBatch(offset: offset);
      offset += currentBatch.length;
      results.addAll(currentBatch);
    } while (currentBatch.isNotEmpty);
    return results;
  }

  Future<List<EmbeddingProto>> _fetchBatch({int offset = 0}) async {
    final db = await _database;
    final results = await db.getAll(
      'SELECT $columnEmbedding FROM $tableName LIMIT 10000 OFFSET $offset',
    );

    return results
        .map((row) =>
            EmbeddingProto.fromBuffer(row[columnEmbedding] as Uint8List))
        .toList();
  }
}
