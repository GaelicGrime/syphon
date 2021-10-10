import 'dart:convert';

import 'package:moor/moor.dart';
import 'package:syphon/store/media/encryption.dart';
import 'package:syphon/store/media/model.dart';

class EncryptInfoToJsonConverter extends TypeConverter<EncryptInfo?, String> {
  const EncryptInfoToJsonConverter();

  @override
  EncryptInfo? mapToDart(String? fromDb) {
    return json.decode(fromDb!) as EncryptInfo?;
  }

  @override
  String? mapToSql(EncryptInfo? value) {
    return json.encode(value);
  }
}

///
/// Messages Model (Table)
///
/// Meant to store messages in _cold storage_
///
@UseRowClass(Media)
class Medias extends Table {
  TextColumn get mxcUri => text().customConstraint('UNIQUE')();
  BlobColumn get data => blob().nullable()();
  TextColumn get type => text().nullable()();
  TextColumn get info => text().map(const EncryptInfoToJsonConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {mxcUri};
}
