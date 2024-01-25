import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:edge_db_benchmarks/models/embedding.dart';
import 'package:edge_db_benchmarks/objectbox.g.dart';

class ObjectBoxDB {
  static Future<Store>? _dbFuture;

  ObjectBoxDB._privateConstructor();

  static final ObjectBoxDB instance = ObjectBoxDB._privateConstructor();

  Future<void> init() async {
    await _store;
    log('ObjectBoxDB initialized');
  }

  Future<Store> get _store async {
    _dbFuture ??= _initDatabase();
    return _dbFuture!;
  }

  static Future<Store> _initDatabase() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, "embeddings.objectbox.db");
    final directory = Directory(path);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    final store =
        await openStore(directory: path, maxDBSizeInKB: 5 * 1024 * 1024);
    return store;
  }

  Future<void> insertEmbedding(Embedding embedding) async {
    final store = await _store;
    final box = store.box<Embedding>();
    box.put(embedding);
  }

  Future<void> insertMultipleEmbeddings(List<Embedding> embeddings) async {
    final store = await _store;
    final box = store.box<Embedding>();
    box.putMany(embeddings);
  }

  Future<List<Embedding>> embeddings() async {
    final store = await _store;
    final box = store.box<Embedding>();
    return box.getAll();
  }
}
