import 'package:flutter/material.dart';

import '../../common/data/audio.dart';
import 'album_view.dart';
import 'artists_view.dart';
import 'genres_view.dart';
import 'local_audio_view.dart';
import 'titles_view.dart';

class LocalAudioBody extends StatelessWidget {
  const LocalAudioBody({
    super.key,
    required this.localAudioView,
    required this.titles,
    required this.artists,
    required this.albums,
    required this.genres,
    this.noResultMessage,
    this.noResultIcon,
  });

  final LocalAudioView localAudioView;
  final List<Audio>? titles;
  final List<String>? artists;
  final List<String>? albums;
  final List<String>? genres;
  final Widget? noResultMessage, noResultIcon;

  @override
  Widget build(BuildContext context) {
    return switch (localAudioView) {
      LocalAudioView.titles => TitlesView(
          audios: titles,
          noResultMessage: noResultMessage,
          noResultIcon: noResultIcon,
        ),
      LocalAudioView.artists => ArtistsView(
          artists: artists,
          noResultMessage: noResultMessage,
          noResultIcon: noResultIcon,
        ),
      LocalAudioView.albums => AlbumsView(
          albums: albums,
          noResultMessage: noResultMessage,
          noResultIcon: noResultIcon,
        ),
      LocalAudioView.genres => GenresView(
          genres: genres,
          noResultMessage: noResultMessage,
          noResultIcon: noResultIcon,
        ),
    };
  }
}