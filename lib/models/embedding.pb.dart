//
//  Generated code. Do not modify.
//  source: embedding.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class EmbeddingProto extends $pb.GeneratedMessage {
  factory EmbeddingProto({
    $core.Iterable<$core.double>? embedding,
  }) {
    final $result = create();
    if (embedding != null) {
      $result.embedding.addAll(embedding);
    }
    return $result;
  }
  EmbeddingProto._() : super();
  factory EmbeddingProto.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EmbeddingProto.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EmbeddingProto', package: const $pb.PackageName(_omitMessageNames ? '' : 'ente'), createEmptyInstance: create)
    ..p<$core.double>(1, _omitFieldNames ? '' : 'embedding', $pb.PbFieldType.KD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EmbeddingProto clone() => EmbeddingProto()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EmbeddingProto copyWith(void Function(EmbeddingProto) updates) => super.copyWith((message) => updates(message as EmbeddingProto)) as EmbeddingProto;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EmbeddingProto create() => EmbeddingProto._();
  EmbeddingProto createEmptyInstance() => create();
  static $pb.PbList<EmbeddingProto> createRepeated() => $pb.PbList<EmbeddingProto>();
  @$core.pragma('dart2js:noInline')
  static EmbeddingProto getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EmbeddingProto>(create);
  static EmbeddingProto? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.double> get embedding => $_getList(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
