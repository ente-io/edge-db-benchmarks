import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:objectbox/objectbox.dart' as ob;

part 'embedding.g.dart';

@ob.Entity()
@collection
class Embedding {
  @ob.Id(assignable: true)
  int id = 0;
  Id isarID = Isar.autoIncrement;

  List<double> embedding;
  Embedding({
    required this.embedding,
  });

  Embedding copyWith({
    List<double>? embedding,
  }) {
    return Embedding(
      embedding: embedding ?? this.embedding,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'e': embedding,
    };
  }

  factory Embedding.fromMap(Map<String, dynamic> map) {
    return Embedding(
      embedding: List<double>.from(map['e']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Embedding.fromJson(String source) =>
      Embedding.fromMap(json.decode(source));

  @override
  String toString() => 'Embedding(embedding: $embedding)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Embedding && listEquals(other.embedding, embedding);
  }

  @override
  int get hashCode => embedding.hashCode;
}
