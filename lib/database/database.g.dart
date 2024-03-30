// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  SongDao? _songDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Song` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `path` TEXT NOT NULL, `artist` TEXT, `album` TEXT, `cover` TEXT)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  SongDao get songDao {
    return _songDaoInstance ??= _$SongDao(database, changeListener);
  }
}

class _$SongDao extends SongDao {
  _$SongDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _songInsertionAdapter = InsertionAdapter(
            database,
            'Song',
            (Song item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'path': item.path,
                  'artist': item.artist,
                  'album': item.album,
                  'cover': item.cover
                },
            changeListener),
        _songUpdateAdapter = UpdateAdapter(
            database,
            'Song',
            ['id'],
            (Song item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'path': item.path,
                  'artist': item.artist,
                  'album': item.album,
                  'cover': item.cover
                },
            changeListener),
        _songDeletionAdapter = DeletionAdapter(
            database,
            'Song',
            ['id'],
            (Song item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'path': item.path,
                  'artist': item.artist,
                  'album': item.album,
                  'cover': item.cover
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Song> _songInsertionAdapter;

  final UpdateAdapter<Song> _songUpdateAdapter;

  final DeletionAdapter<Song> _songDeletionAdapter;

  @override
  Future<List<Song>> findAllSong() async {
    return _queryAdapter.queryList('SELECT * FROM Song',
        mapper: (Map<String, Object?> row) => Song(
            row['id'] as int?,
            row['name'] as String,
            row['path'] as String,
            row['artist'] as String?,
            row['album'] as String?,
            row['cover'] as String?));
  }

  @override
  Stream<List<String>> findAllSongName() {
    return _queryAdapter.queryListStream('SELECT name FROM Song',
        mapper: (Map<String, Object?> row) => row.values.first as String,
        queryableName: 'Song',
        isView: false);
  }

  @override
  Stream<Song?> findSongById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM Song WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Song(
            row['id'] as int?,
            row['name'] as String,
            row['path'] as String,
            row['artist'] as String?,
            row['album'] as String?,
            row['cover'] as String?),
        arguments: [id],
        queryableName: 'Song',
        isView: false);
  }

  @override
  Future<void> insertSong(Song song) async {
    await _songInsertionAdapter.insert(song, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateSong(Song song) {
    return _songUpdateAdapter.updateAndReturnChangedRows(
        song, OnConflictStrategy.abort);
  }

  @override
  Future<void> removeSong(Song song) async {
    await _songDeletionAdapter.delete(song);
  }
}
