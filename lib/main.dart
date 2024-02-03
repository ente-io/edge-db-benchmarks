import 'dart:math';
import 'dart:developer' as dev;

import 'package:edge_db_benchmarks/databases/isar_db.dart';
import 'package:edge_db_benchmarks/databases/object_box_db.dart';
import 'package:edge_db_benchmarks/databases/sqlite_db.dart';
import 'package:edge_db_benchmarks/models/embedding.dart';
import 'package:edge_db_benchmarks/models/embedding.pb.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const MainApp());

  final embeddings = <Embedding>[];
  final embeddingsProto = <EmbeddingProto>[];
  for (int i = 0; i < count; i++) {
    final randomVector = getRandom512DoubleList();
    embeddings.add(Embedding(embedding: randomVector));
    embeddingsProto.add(EmbeddingProto(embedding: randomVector));
  }
  await benchmarkSqlite(embeddingsProto);
  await benchmarkObjectBox(embeddings);
  await benchmarkIsar(embeddings);
}

const count = 100000;

Future<void> benchmarkSqlite(List<EmbeddingProto> embeddings) async {
  await SqliteDB.instance.init();
  final stopwatch = Stopwatch()..start();
  await SqliteDB.instance.insertMultipleEmbeddings(embeddings);
  stopwatch.stop();
  dev.log(
      'SQLite: $count embeddings inserted in ${stopwatch.elapsedMilliseconds} ms');
  stopwatch.reset();
  stopwatch.start();
  final response = await SqliteDB.instance.embeddings();
  stopwatch.stop();
  dev.log(
      'SQLite: ${response.length} embeddings retrieved in ${stopwatch.elapsedMilliseconds} ms');
}

Future<void> benchmarkObjectBox(List<Embedding> embeddings) async {
  await ObjectBoxDB.instance.init();
  final stopwatch = Stopwatch()..start();
  await ObjectBoxDB.instance.insertMultipleEmbeddings(embeddings);
  stopwatch.stop();
  dev.log(
      'ObjectBox: $count embeddings inserted in ${stopwatch.elapsedMilliseconds} ms');
  stopwatch.reset();
  stopwatch.start();
  final response = await ObjectBoxDB.instance.embeddings();
  stopwatch.stop();
  dev.log(
      'ObjectBox: ${response.length} embeddings retrieved in ${stopwatch.elapsedMilliseconds} ms');
}

Future<void> benchmarkIsar(List<Embedding> embeddings) async {
  await IsarDB.instance.init();
  final stopwatch = Stopwatch()..start();
  await IsarDB.instance.putMany(embeddings);
  stopwatch.stop();
  dev.log(
      'Isar: $count embeddings inserted in ${stopwatch.elapsedMilliseconds} ms');
  stopwatch.reset();
  stopwatch.start();
  final response = await IsarDB.instance.embeddings();
  stopwatch.stop();
  dev.log(
      'Isar: ${response.length} embeddings retrieved in ${stopwatch.elapsedMilliseconds} ms');
}

List<double> getRandom512DoubleList() {
  final random = Random();
  final list = <double>[];
  for (var i = 0; i < 512; i++) {
    list.add(random.nextDouble());
  }
  return list;
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
