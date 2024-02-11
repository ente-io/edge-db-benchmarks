import 'dart:math';
import 'dart:developer' as dev;

import 'package:edge_db_benchmarks/databases/isar_db.dart';
import 'package:edge_db_benchmarks/databases/object_box_db.dart';
import 'package:edge_db_benchmarks/databases/sqlite_db.dart';
import 'package:edge_db_benchmarks/models/embedding.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const MainApp());
}

const count = 100000;

Future<String> benchmarkSqlite(List<Embedding> embeddings) async {
  String result = "";
  await SqliteDB.instance.init();
  final stopwatch = Stopwatch()..start();
  await SqliteDB.instance.insertMultipleEmbeddings(embeddings);
  stopwatch.stop();
  result +=
      "SQLite: $count embeddings inserted in ${stopwatch.elapsedMilliseconds} ms\n";
  stopwatch.reset();
  stopwatch.start();
  final response = await SqliteDB.instance.embeddings();
  stopwatch.stop();
  result +=
      "SQLite: ${response.length} embeddings retrieved in ${stopwatch.elapsedMilliseconds} ms\n\n";
  dev.log(result);
  return result;
}

Future<String> benchmarkObjectBox(List<Embedding> embeddings) async {
  String result = "";
  await ObjectBoxDB.instance.init();
  final stopwatch = Stopwatch()..start();
  await ObjectBoxDB.instance.insertMultipleEmbeddings(embeddings);
  stopwatch.stop();
  result +=
      "ObjectBox: $count embeddings inserted in ${stopwatch.elapsedMilliseconds} ms\n";
  stopwatch.reset();
  stopwatch.start();
  final response = await ObjectBoxDB.instance.embeddings();
  stopwatch.stop();
  result +=
      "ObjectBox: ${response.length} embeddings retrieved in ${stopwatch.elapsedMilliseconds} ms\n\n";
  dev.log(result);
  return result;
}

Future<String> benchmarkIsar(List<Embedding> embeddings) async {
  String result = "";
  await IsarDB.instance.init();
  final stopwatch = Stopwatch()..start();
  await IsarDB.instance.putMany(embeddings);
  stopwatch.stop();
  result +=
      "Isar: $count embeddings inserted in ${stopwatch.elapsedMilliseconds} ms\n";
  stopwatch.reset();
  stopwatch.start();
  final response = await IsarDB.instance.embeddings();
  stopwatch.stop();
  result +=
      "Isar: ${response.length} embeddings retrieved in ${stopwatch.elapsedMilliseconds} ms\n\n";
  dev.log(result);
  return result;
}

List<double> getRandom512DoubleList() {
  final random = Random();
  final list = <double>[];
  for (var i = 0; i < 512; i++) {
    list.add(random.nextDouble());
  }
  return list;
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String result = "";
  @override
  void initState() {
    benchmark();
    super.initState();
  }

  Future<void> benchmark() async {
    final embeddings = <Embedding>[];
    embeddings.addAll(List.generate(
        count, (index) => Embedding(embedding: getRandom512DoubleList())));
    result += await benchmarkSqlite(embeddings);
    setState(() {});
    result += await benchmarkObjectBox(embeddings);
    setState(() {});
    result += await benchmarkIsar(embeddings);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(result.isEmpty ? "Benchmarking..." : result),
        ),
      ),
    );
  }
}
