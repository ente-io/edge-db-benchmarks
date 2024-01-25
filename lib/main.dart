import 'dart:math';
import 'dart:developer' as dev;

import 'package:edge_db_benchmarks/databases/sqlite_db.dart';
import 'package:edge_db_benchmarks/models/embedding.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const MainApp());

  final embeddings = <Embedding>[];
  for (int i = 0; i < count; i++) {
    embeddings.add(Embedding(embedding: getRandom512DoubleList()));
  }
  await benchmarkSqlite(embeddings);
}

const count = 100000;

Future<void> benchmarkSqlite(List<Embedding> embeddings) async {
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
