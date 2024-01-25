import 'dart:developer';
import 'dart:io';

import 'package:edge_db_benchmarks/models/embedding.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDB {
  static const databaseName = "embeddings.sqlite.db";
  static const tableName = "embeddings";
  static const columnGeneratedID = "_id";
  static const columnEmbedding = "embedding";

  SqliteDB._privateConstructor();

  static final SqliteDB instance = SqliteDB._privateConstructor();

  static Future<Database>? _dbFuture;

  Future<void> init() async {
    await _database;
    log('SqliteDB initialized');
  }

  Future<Database> get _database async {
    _dbFuture ??= _initDatabase();
    return _dbFuture!;
  }

  Future<Database> _initDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, databaseName);
    // Start afresh each time
    await deleteDatabase(path);
    final database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
        'CREATE TABLE $tableName ($columnGeneratedID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $columnEmbedding TEXT)',
      );
    });
    return database;
  }

  Future<void> insertEmbedding(Embedding embedding) async {
    final Database db = await _database;
    await db.insert(
      tableName,
      <String, dynamic>{
        columnEmbedding: embedding.toJson(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertMultipleEmbeddings(List<Embedding> embeddings) async {
    final Database db = await _database;
    final batch = db.batch();
    for (final embedding in embeddings) {
      batch.insert(
        tableName,
        <String, dynamic>{
          columnEmbedding: embedding.toJson(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Embedding>> embeddings() async {
    final Database db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return Embedding.fromJson(maps[i][columnEmbedding] as String);
    });
  }
}
