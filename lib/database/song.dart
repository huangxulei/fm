import 'package:floor/floor.dart';

@entity
class Song {
  // 基本信息
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;
  final String path;
  final String? artist;
  final String? album;
  final String? cover;

  Song(this.id, this.name, this.path, this.artist, this.album, this.cover);

  factory Song.optional(
          {int? id,
          String? name,
          String? path,
          String? artist,
          String? album,
          String? cover}) =>
      Song(id, name ?? "Unkonwn", path ?? "Unkonwn", artist ?? "Unkonwn",
          album ?? "Unkonwn", cover ?? "Unkonwn");
}
