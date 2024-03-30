import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fm/page/image_place_holder.dart';

import 'package:media_kit/media_kit.dart';

import '../database/song.dart';

class PlayerWidget extends StatefulWidget {
  final List<Song> allSongs;
  final Song? nowPlaying;

  const PlayerWidget({
    required this.allSongs,
    required this.nowPlaying,
    Key? key,
  }) : super(key: key);

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  late final player = Player();
  bool isShuffle = false;
  String nowPlayingName = 'No song playing';
  String nowPlayingArtist = "Unknown";
  String nowPlayingAlbum = "Unknown";
  bool sleepTimer = false;
  int sleepTimerSeconds = 0;
  Timer? sleepTimerTimer;

  @override
  void didUpdateWidget(covariant PlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nowPlaying != widget.nowPlaying) {
      Playlist playlist = Playlist(
        widget.allSongs
            .map((e) => Media(e.path, extras: {'title': e.name}))
            .toList(),
        index: widget.allSongs.indexWhere(
          (element) => element.path == widget.nowPlaying?.path,
        ),
      );

      player.open(playlist, play: true);
      player.play();
      player.stream.playlist.listen((event) {
        setState(() {
          nowPlayingName = widget.allSongs[player.state.playlist.index].name;
          print(widget.allSongs[player.state.playlist.index].name);
          nowPlayingArtist =
              widget.allSongs[player.state.playlist.index].artist!;
          nowPlayingAlbum = widget.allSongs[player.state.playlist.index].album!;
        });
      });
    }
  }

  void setSleepTimer(int seconds) {
    sleepTimer = true;
    sleepTimerSeconds = seconds;
    sleepTimerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (sleepTimerSeconds == 0) {
        player.pause();
        sleepTimerTimer?.cancel();
        sleepTimer = false;
      } else {
        sleepTimerSeconds--;
      }
      setState(() {});
    });
  }

  static String formatDuration(Duration d) {
    var seconds = d.inSeconds;
    final days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;
    final hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;
    final minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;

    final List<String> tokens = [];
    if (days != 0) {
      tokens.add('${days}d');
    }
    if (tokens.isNotEmpty || hours != 0) {
      tokens.add('${hours}h');
    }
    if (tokens.isNotEmpty || minutes != 0) {
      tokens.add('${minutes}m');
    }
    tokens.add('${seconds}s');

    return tokens.join(':');
  }

  @override
  Widget build(BuildContext context) {
    final String curStr = widget.nowPlaying?.cover ?? "Unkonwn";
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          StreamBuilder(
            stream: player.stream.position,
            builder: (context, snapshot) {
              Duration position = snapshot.data ?? Duration.zero;
              position = Duration(
                  milliseconds: position.inMilliseconds
                      .clamp(0, player.state.duration.inMilliseconds));

              return Card(
                  child: Container(
                      padding: EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                      child: Row(children: <Widget>[
                        Container(
                          margin: const EdgeInsets.all(5.0),
                          child: curStr != "Unkonwn"
                              ? Image.memory(
                                  base64Decode(curStr),
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                )
                              : const ImagePlaceHolder(
                                  height: 100,
                                  width: 100,
                                  error: true,
                                ),
                        ),
                        Expanded(
                            child: Column(
                          children: [
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Text(nowPlayingName,
                                        style: const TextStyle(fontSize: 20)),
                                    Text("$nowPlayingArtist - $nowPlayingAlbum",
                                        style: const TextStyle(fontSize: 15)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Slider(
                                            value: player.state.volume,
                                            label:
                                                player.state.volume.toString(),
                                            onChanged: (e) {
                                              player.setVolume(e);
                                              setState(() {});
                                            },
                                            min: 0,
                                            max: 100),
                                        IconButton(
                                            onPressed: () {
                                              player.state.volume == 0
                                                  ? player.setVolume(100)
                                                  : player.setVolume(0);
                                              setState(() {});
                                            },
                                            icon: Icon(player.state.volume == 0
                                                ? Icons.volume_off
                                                : Icons.volume_up)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.skip_previous),
                                          onPressed: () {
                                            player.previous();
                                            setState(() {});
                                          },
                                        ),
                                        StreamBuilder(
                                            stream: player.stream.playing,
                                            builder: (context, snapshot) {
                                              return IconButton(
                                                icon: Icon(
                                                  player.state.playing
                                                      ? Icons.pause
                                                      : Icons.play_arrow,
                                                  size: 45,
                                                ),
                                                onPressed: () {
                                                  // Toggle play/pause functionality
                                                  if (player.state.playing) {
                                                    player.pause();
                                                  } else {
                                                    player.play();
                                                  }
                                                  setState(() {});
                                                },
                                              );
                                            }),
                                        IconButton(
                                          icon: const Icon(Icons.skip_next),
                                          onPressed: () {
                                            player.next();
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        StreamBuilder(
                                            stream: player.stream.playlistMode,
                                            builder: (context, snapshot) {
                                              return IconButton(
                                                  onPressed: () {
                                                    if (player.state
                                                            .playlistMode ==
                                                        PlaylistMode.loop) {
                                                      player.setPlaylistMode(
                                                          PlaylistMode.single);
                                                    } else if (player.state
                                                            .playlistMode ==
                                                        PlaylistMode.single) {
                                                      player.setPlaylistMode(
                                                          PlaylistMode.none);
                                                    } else {
                                                      player.setPlaylistMode(
                                                          PlaylistMode.loop);
                                                    }
                                                    setState(() {});
                                                  },
                                                  icon: player.state
                                                              .playlistMode ==
                                                          PlaylistMode.loop
                                                      ? const Icon(
                                                          Icons.repeat_on)
                                                      : player.state
                                                                  .playlistMode ==
                                                              PlaylistMode
                                                                  .single
                                                          ? const Icon(
                                                              Icons.repeat_one)
                                                          : const Icon(
                                                              Icons.repeat));
                                            }),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(formatDuration(position)),
                                Expanded(
                                  child: Slider(
                                    value: position.inMilliseconds.toDouble(),
                                    max: player.state.duration.inMilliseconds
                                        .toDouble(),
                                    onChanged: (value) {},
                                    onChangeEnd: (value) {
                                      player.seek(Duration(
                                          milliseconds: value.toInt()));
                                      setState(() {});
                                    },
                                  ),
                                ),
                                Text(formatDuration(player.state.duration)),
                              ],
                            ),
                          ],
                        ))
                      ])));
            },
          ),
        ],
      ),
    );
  }
}
