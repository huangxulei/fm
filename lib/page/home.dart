import 'dart:convert';
import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/ffi/ffi.dart';
import 'package:path/path.dart' as p;

import '../database/song.dart';
import '../global.dart';
import 'image_place_holder.dart';
import 'player.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Song> allSongs = []; //歌曲列表
  Song nowPlaying =
      Song(0, 'No song playing', "Unknown", "Unknown", "Unknown", "Unknown");
  Map<String, bool> selectedFiles = {}; //选择文件

  @override
  void initState() {
    super.initState();
    updatePlaylist();
  }

  Future<void> updatePlaylist() async {
    final List<Song> songs = await Global.songDao!.findAllSong();

    setState(() {
      allSongs = songs;
    });
  }

  Future<void> addToDB(Song song) async {
    await Global.songDao!.insertSong(song);
  }

  Future<void> addFile() async {
    FilePicker.platform
        .pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'flac'],
      allowMultiple: true,
    )
        .then((value) async {
      if (value == null) return;
      final files = value.files;
      for (final file in files) {
        final track = File(file.path!);
        final metadata = await readMetadata(track, getImage: true);
        String? coverStr;
        if (metadata.pictures.isNotEmpty) {
          coverStr = base64Encode(metadata.pictures[0].bytes);
          if (coverStr.length > 90000) {
            coverStr = "Unkonwn";
          }
        }
        final s = Song.optional(
            name: metadata.title ?? p.basename(file.path!),
            path: file.path,
            artist: metadata.artist ?? "Unkonwn",
            album: metadata.album ?? "Unkonwn",
            cover: coverStr ?? "Unkonwn");
        await addToDB(s);
        updatePlaylist();
        setState(() {});
      }
    });
  }

  Future<void> cleanFile() async {
    await Global.songDao?.clearAllSong();
    updatePlaylist();
    allSongs = [];
    nowPlaying =
        Song(0, 'No song playing', "Unknown", "Unknown", "Unknown", "Unknown");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      PlayerWidget(allSongs: allSongs, nowPlaying: nowPlaying),
      Container(
        height: 50,
        child: Row(children: [
          SizedBox(
            width: 20,
          ),
          const Text(
            "播放列表",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            width: 10,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addFile, //添加歌曲
            tooltip: '添加歌曲',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: cleanFile, //删除列表
            tooltip: '清空列表',
          ),
        ]),
      ),
      Expanded(
          child: FutureBuilder<List<Song>>(
              future: Global.songDao!.findAllSong(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final songs = snapshot.data!;
                  if (songs.isEmpty) {
                    return const Center(child: Text('No songs found'));
                  } else {
                    return ListView.builder(
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          Song song = songs[index];
                          return ListTile(
                              leading: song.cover != "Unkonwn"
                                  ? Image.memory(base64Decode(song.cover!))
                                  : const ImagePlaceHolder(
                                      height: 50,
                                      width: 50,
                                      error: true,
                                    ),
                              title: Text(song.name),
                              subtitle: Text("${song.artist} - ${song.album}"),
                              trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final nameTextController =
                                        TextEditingController(text: song.name);
                                    final artistTextController =
                                        TextEditingController(
                                            text: song.artist);
                                    final albumTextController =
                                        TextEditingController(text: song.album);
                                    if (context.mounted) {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                                title:
                                                    Text("Edit ${song.name}"),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText: 'Name',
                                                      ),
                                                      controller:
                                                          nameTextController,
                                                    ),
                                                    TextField(
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText: 'Artist',
                                                      ),
                                                      controller:
                                                          artistTextController,
                                                    ),
                                                    TextField(
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText: 'Album',
                                                      ),
                                                      controller:
                                                          albumTextController,
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        albumTextController
                                                            .dispose();
                                                        artistTextController
                                                            .dispose();
                                                        nameTextController
                                                            .dispose();
                                                        if (context.mounted) {
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      },
                                                      child: const Text("取消")),
                                                  TextButton(
                                                      onPressed: () async {
                                                        await Global.songDao!
                                                            .removeSong(song);
                                                        setState(() {});
                                                        albumTextController
                                                            .dispose();
                                                        artistTextController
                                                            .dispose();
                                                        nameTextController
                                                            .dispose();
                                                        if (context.mounted) {
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      },
                                                      child: const Text("删除")),
                                                  TextButton(
                                                      onPressed: () async {
                                                        Song _song = Song(
                                                            song.id,
                                                            nameTextController
                                                                .text,
                                                            song.path,
                                                            artistTextController
                                                                .text,
                                                            albumTextController
                                                                .text,
                                                            song.cover);

                                                        await Global.songDao!
                                                            .updateSong(_song);
                                                        updatePlaylist();
                                                        setState(() {});
                                                        albumTextController
                                                            .dispose();
                                                        artistTextController
                                                            .dispose();
                                                        nameTextController
                                                            .dispose();
                                                        if (context.mounted) {
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      },
                                                      child: const Text("修改")),
                                                ]);
                                          });
                                    }
                                  }),
                              onTap: () {
                                setState(() {
                                  nowPlaying = song;
                                });
                              });
                        });
                  }
                }
              })),
    ]));
  }
}
