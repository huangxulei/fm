import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite/src/factory_mixin.dart' as impl;

import 'database/database.dart';
import 'database/song_dao.dart';

class Global with ChangeNotifier {
  static late bool _isDesktop;
  static bool get isDesktop => _isDesktop;

  /// 默认分隔线高度
  static double lineSize = 0.35;

  static SongDao? _songDao;
  static SongDao? get songDao => _songDao;

  static Future<bool> init() async {
    _isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    if (isDesktop) {
      sqflite.databaseFactory = databaseFactoryFfi;
      final factory =
          sqflite.databaseFactory as impl.SqfliteDatabaseFactoryMixin;
    }
    final database =
        await $FloorAppDatabase.databaseBuilder('audio.db').build();
    _songDao = database.songDao;
    print("delay global init");
    return true;
  }
}
