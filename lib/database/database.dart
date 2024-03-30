import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'song.dart';
import 'song_dao.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Song])
abstract class AppDatabase extends FloorDatabase {
  SongDao get songDao;
}
