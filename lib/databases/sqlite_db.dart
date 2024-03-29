import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:edge_db_benchmarks/models/embedding.dart';
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

  Future<void> insertMultipleEmbeddings(List<Embedding> embeddings) async {
    final db = await _database;
    final inputs = embeddings
        .map((e) => [Float32List.fromList(e.embedding).buffer.asUint8List()])
        .toList();
    await db.executeBatch(
        'INSERT INTO $tableName ($columnEmbedding) values(?)', inputs);
  }

  Future<List<Embedding>> embeddings() async {
    final List<Embedding> results = await _fetchAll();
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

  Future<List<Embedding>> _fetchAll() async {
    final db = await _database;
    final stopwatch = Stopwatch()..start();
    final results = await db.getAll(
      'SELECT $columnEmbedding FROM $tableName',
    );
    stopwatch.stop();
    log('SqliteDB fetch all took: ${stopwatch.elapsedMilliseconds} ms');
    stopwatch.reset();
    stopwatch.start();
    final deserialzed = results.map((row) {
      final bytes = row[columnEmbedding] as Uint8List;
      final list = Float32List.view(bytes.buffer);
      return Embedding(embedding: list);
    }).toList();
    stopwatch.stop();
    log('SqliteDB deserialization took: ${stopwatch.elapsedMilliseconds} ms');
    return deserialzed;
  }
}
