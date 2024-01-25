import 'dart:io';

import 'package:edge_db_benchmarks/models/embedding.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class IsarDB {
  late final Isar _isar;

  IsarDB._privateConstructor();

  static final IsarDB instance = IsarDB._privateConstructor();

  Future<void> init() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final path = join(docsDir.path, "embeddings.isar.db");
    final directory = Directory(path);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    await directory.create(recursive: true);
    _isar = await Isar.open(
      [EmbeddingSchema],
      directory: path,
    );
  }

  Future<void> put(Embedding embedding) {
    return _isar.writeTxn(() async {
      await _isar.embeddings.put(embedding);
    });
  }

  Future<void> putMany(List<Embedding> embeddings) {
    return _isar.writeTxn(() async {
      await _isar.embeddings.putAll(embeddings);
    });
  }

  Future<List<Embedding>> embeddings() {
    return _isar.embeddings.filter().embeddingIsNotEmpty().findAll();
  }
}
