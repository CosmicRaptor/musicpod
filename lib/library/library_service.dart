import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../common/data/audio.dart';
import '../persistence_utils.dart';

class LibraryService {
  LibraryService({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;

  //
  // Liked Audios
  //
  List<Audio> _likedAudios = [];
  List<Audio> get likedAudios => _likedAudios;
  final _likedAudiosController = StreamController<bool>.broadcast();
  Stream<bool> get likedAudiosChanged => _likedAudiosController.stream;

  void addLikedAudio(Audio audio, [bool notify = true]) {
    if (_likedAudios.contains(audio)) return;
    _likedAudios.add(audio);
    if (notify) {
      writeAudioMap({kLikedAudiosPageId: _likedAudios}, kLikedAudiosFileName)
          .then((value) => _likedAudiosController.add(true));
    }
  }

  void addLikedAudios(List<Audio> audios) {
    for (var audio in audios) {
      addLikedAudio(audio, false);
    }
    writeAudioMap({kLikedAudiosPageId: _likedAudios}, kLikedAudiosFileName)
        .then((value) => _likedAudiosController.add(true));
  }

  bool liked(Audio audio) {
    return likedAudios.contains(audio);
  }

  void removeLikedAudio(Audio audio, [bool notify = true]) {
    _likedAudios.remove(audio);
    if (notify) {
      writeAudioMap({kLikedAudiosPageId: _likedAudios}, kLikedAudiosFileName)
          .then((value) => _likedAudiosController.add(true));
    }
  }

  void removeLikedAudios(List<Audio> audios) {
    for (var audio in audios) {
      removeLikedAudio(audio, false);
    }
    writeAudioMap({kLikedAudiosPageId: _likedAudios}, kLikedAudiosFileName)
        .then((value) => _likedAudiosController.add(true));
  }

  //
  // Starred stations
  //

  Map<String, List<Audio>> _starredStations = {};
  Map<String, List<Audio>> get starredStations => _starredStations;
  int get starredStationsLength => _starredStations.length;
  final _starredStationsController = StreamController<bool>.broadcast();
  Stream<bool> get starredStationsChanged => _starredStationsController.stream;

  void addStarredStation(String url, List<Audio> audios) {
    _starredStations.putIfAbsent(url, () => audios);
    writeAudioMap(_starredStations, kStarredStationsFileName)
        .then((_) => _starredStationsController.add(true));
  }

  void unStarStation(String name) {
    _starredStations.remove(name);
    writeAudioMap(_starredStations, kStarredStationsFileName)
        .then((_) => _starredStationsController.add(true));
  }

  bool isStarredStation(String? url) {
    return url == null ? false : _starredStations.containsKey(url);
  }

  Set<String> get favRadioTags =>
      _sharedPreferences.getStringList(kFavRadioTags)?.toSet() ?? {};
  bool isFavTag(String value) => favRadioTags.contains(value);
  final _favTagsController = StreamController<bool>.broadcast();
  Stream<bool> get favTagsChanged => _favTagsController.stream;

  void addFavRadioTag(String name) {
    if (favRadioTags.contains(name)) return;
    final Set<String> tags = favRadioTags;
    tags.add(name);
    _sharedPreferences.setStringList(kFavRadioTags, tags.toList()).then(
      (saved) {
        if (saved) _favTagsController.add(true);
      },
    );
  }

  void removeFavRadioTag(String name) {
    if (!favRadioTags.contains(name)) return;
    final Set<String> tags = favRadioTags;
    tags.remove(name);
    _sharedPreferences.setStringList(kFavRadioTags, tags.toList()).then(
      (saved) {
        if (saved) _favTagsController.add(true);
      },
    );
  }

  String? get lastCountryCode => _sharedPreferences.getString(kLastCountryCode);
  void setLastCountryCode(String value) {
    _sharedPreferences.setString(kLastCountryCode, value).then(
      (saved) {
        if (saved) _lastCountryCodeController.add(true);
      },
    );
  }

  final _lastCountryCodeController = StreamController<bool>.broadcast();
  Stream<bool> get lastCountryCodeChanged => _lastCountryCodeController.stream;

  Set<String> get favCountryCodes =>
      _sharedPreferences.getStringList(kFavCountryCodes)?.toSet() ?? {};
  bool isFavCountry(String value) => favCountryCodes.contains(value);
  final _favCountriesController = StreamController<bool>.broadcast();
  Stream<bool> get favCountriesChanged => _favCountriesController.stream;

  void addFavCountryCode(String name) {
    if (favCountryCodes.contains(name)) return;
    final favCodes = favCountryCodes;
    favCodes.add(name);
    _sharedPreferences
        .setStringList(kFavCountryCodes, favCodes.toList())
        .then((saved) {
      if (saved) _favCountriesController.add(true);
    });
  }

  void removeFavCountryCode(String name) {
    if (!favCountryCodes.contains(name)) return;
    final favCodes = favCountryCodes;
    favCodes.remove(name);
    _sharedPreferences
        .setStringList(kFavCountryCodes, favCodes.toList())
        .then((saved) {
      if (saved) _favCountriesController.add(true);
    });
  }

  String? get lastLanguageCode =>
      _sharedPreferences.getString(kLastLanguageCode);
  void setLastLanguageCode(String value) {
    _sharedPreferences.setString(kLastLanguageCode, value).then((saved) {
      if (saved) _lastLanguageCodeController.add(true);
    });
  }

  final _lastLanguageCodeController = StreamController<bool>.broadcast();
  Stream<bool> get lastLanguageCodeChanged =>
      _lastLanguageCodeController.stream;

  Set<String> get favLanguageCodes =>
      _sharedPreferences.getStringList(kFavLanguageCodes)?.toSet() ?? {};
  bool isFavLanguage(String value) => favLanguageCodes.contains(value);
  final _favLanguagesController = StreamController<bool>.broadcast();
  Stream<bool> get favLanguagesChanged => _favLanguagesController.stream;

  void addFavLanguageCode(String name) {
    if (favLanguageCodes.contains(name)) return;
    final favLangs = favLanguageCodes;
    favLangs.add(name);
    _sharedPreferences.setStringList(kFavLanguageCodes, favLangs.toList()).then(
      (saved) {
        if (saved) _favLanguagesController.add(true);
      },
    );
  }

  void removeFavLanguageCode(String name) {
    if (!favLanguageCodes.contains(name)) return;
    final favLangs = favLanguageCodes;
    favLangs.remove(name);
    _sharedPreferences.setStringList(kFavLanguageCodes, favLangs.toList()).then(
      (saved) {
        if (saved) _favLanguagesController.add(true);
      },
    );
  }

  //
  // Playlists
  //

  Map<String, List<Audio>> _playlists = {};
  Map<String, List<Audio>> get playlists => _playlists;
  final _playlistsController = StreamController<bool>.broadcast();
  Stream<bool> get playlistsChanged => _playlistsController.stream;

  Future<void> addPlaylist(String id, List<Audio> audios) async {
    if (!_playlists.containsKey(id)) {
      _playlists.putIfAbsent(id, () => audios);
      await writeAudioMap(_playlists, kPlaylistsFileName)
          .then((_) => _playlistsController.add(true));
    }
  }

  Future<void> updatePlaylist(String id, List<Audio> audios) async {
    if (_playlists.containsKey(id)) {
      await writeAudioMap(_playlists, kPlaylistsFileName).then((_) {
        _playlists.update(
          id,
          (value) => audios,
        );
        _playlistsController.add(true);
      });
    }
  }

  void removePlaylist(String id) {
    if (_playlists.containsKey(id)) {
      _playlists.remove(id);
      writeAudioMap(_playlists, kPlaylistsFileName)
          .then((_) => _playlistsController.add(true));
    }
  }

  void updatePlaylistName(String oldName, String newName) {
    if (newName == oldName) return;
    final oldList = _playlists[oldName];
    if (oldList != null) {
      _playlists.remove(oldName);
      _playlists.putIfAbsent(newName, () => oldList);
      writeAudioMap(_playlists, kPlaylistsFileName)
          .then((_) => _playlistsController.add(true));
    }
  }

  void moveAudioInPlaylist({
    required int oldIndex,
    required int newIndex,
    required String id,
  }) {
    final audios = id == kLikedAudiosPageId
        ? likedAudios.toList()
        : playlists[id]?.toList();

    if (audios == null ||
        audios.isEmpty == true ||
        !(newIndex < audios.length)) {
      return;
    }

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final audio = audios.removeAt(oldIndex);
    audios.insert(newIndex, audio);

    if (id == kLikedAudiosPageId) {
      writeAudioMap({kLikedAudiosPageId: _likedAudios}, kLikedAudiosFileName)
          .then((value) {
        likedAudios.clear();
        likedAudios.addAll(audios);
        _likedAudiosController.add(true);
      });
    } else {
      writeAudioMap(_playlists, kPlaylistsFileName).then((_) {
        _playlists.update(id, (value) => audios);
        _playlistsController.add(true);
      });
    }
  }

  void addAudioToPlaylist(String id, Audio audio) {
    final playlist = _playlists[id];
    if (playlist == null || playlist.contains(audio)) return;
    playlist.add(audio);
    writeAudioMap(_playlists, kPlaylistsFileName)
        .then((_) => _playlistsController.add(true));
  }

  void removeAudioFromPlaylist(String id, Audio audio) {
    final playlist = _playlists[id];
    if (playlist != null && playlist.contains(audio)) {
      playlist.remove(audio);
      writeAudioMap(_playlists, kPlaylistsFileName)
          .then((_) => _playlistsController.add(true));
    }
  }

  void clearPlaylist(String id) {
    final playlist = _playlists[id];
    if (playlist != null) {
      playlist.clear();
      writeAudioMap(_playlists, kPlaylistsFileName)
          .then((_) => _playlistsController.add(true));
    }
  }

  // Podcasts
  final dio = Dio();
  Map<String, String> _downloads = {};
  Map<String, String> get downloads => _downloads;
  String? getDownload(String? url) => downloads[url];

  Set<String> _feedsWithDownloads = {};
  bool feedHasDownloads(String feedUrl) =>
      _feedsWithDownloads.contains(feedUrl);
  int get feedsWithDownloadsLength => _feedsWithDownloads.length;

  final _downloadsController = StreamController<bool>.broadcast();
  Stream<bool> get downloadsChanged => _downloadsController.stream;
  void addDownload({
    required String url,
    required String path,
    required String feedUrl,
  }) {
    if (_downloads.containsKey(url)) return;
    _downloads.putIfAbsent(url, () => path);
    _feedsWithDownloads.add(feedUrl);
    writeStringMap(_downloads, kDownloads)
        .then(
          (_) => writeStringIterable(
            iterable: _feedsWithDownloads,
            filename: kFeedsWithDownloads,
          ),
        )
        .then((_) => _downloadsController.add(true));
  }

  void removeDownload({required String url, required String feedUrl}) {
    final path = _downloads[url];

    if (path != null) {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }

    if (_downloads.containsKey(url)) {
      _downloads.remove(url);
      _feedsWithDownloads.remove(feedUrl);

      writeStringMap(_downloads, kDownloads)
          .then(
            (_) => writeStringIterable(
              iterable: _feedsWithDownloads,
              filename: kFeedsWithDownloads,
            ),
          )
          .then((_) => _downloadsController.add(true));
    }
  }

  void _removeFeedWithDownload(String feedUrl) {
    if (!_feedsWithDownloads.contains(feedUrl)) return;
    _feedsWithDownloads.remove(feedUrl);
    writeStringIterable(
      iterable: _feedsWithDownloads,
      filename: kFeedsWithDownloads,
    ).then((_) => _downloadsController.add(true));
  }

  String? _downloadsDir;
  String? get downloadsDir => _downloadsDir;
  Map<String, List<Audio>> _podcasts = {};
  Map<String, List<Audio>> get podcasts => _podcasts;
  int get podcastsLength => _podcasts.length;
  final _podcastsController = StreamController<bool>.broadcast();
  Stream<bool> get podcastsChanged => _podcastsController.stream;

  void addPodcast(String feedUrl, List<Audio> audios) {
    if (_podcasts.containsKey(feedUrl)) return;
    _podcasts.putIfAbsent(feedUrl, () => audios);
    writeAudioMap(_podcasts, kPodcastsFileName)
        .then((_) => _podcastsController.add(true));
  }

  void updatePodcast(String feedUrl, List<Audio> audios) {
    if (feedUrl.isEmpty || audios.isEmpty) return;
    _addPodcastUpdate(feedUrl);
    _podcasts.update(feedUrl, (value) => audios);
    writeAudioMap(_podcasts, kPodcastsFileName)
        .then((_) => _podcastsController.add(true));
  }

  void _addPodcastUpdate(String feedUrl) {
    if (_podcastUpdates?.contains(feedUrl) == true) return;
    _podcastUpdates?.add(feedUrl);
    writeStringIterable(iterable: _podcastUpdates!, filename: kPodcastsUpdates)
        .then((_) => _updateController.add(true));
  }

  Set<String>? _podcastUpdates;
  int? get podcastUpdatesLength => _podcastUpdates?.length;

  bool podcastUpdateAvailable(String feedUrl) =>
      _podcastUpdates?.contains(feedUrl) == true;

  void removePodcastUpdate(String feedUrl) {
    if (_podcastUpdates?.isNotEmpty == false) return;
    _podcastUpdates?.remove(feedUrl);
    writeStringIterable(iterable: _podcastUpdates!, filename: kPodcastsUpdates)
        .then((_) => _updateController.add(true));
  }

  final _updateController = StreamController<bool>.broadcast();
  Stream<bool> get updatesChanged => _updateController.stream;

  void removePodcast(String name) {
    if (!_podcasts.containsKey(name)) return;
    _podcasts.remove(name);
    writeAudioMap(_podcasts, kPodcastsFileName)
        .then((_) => _podcastsController.add(true))
        .then((_) => removePodcastUpdate(name))
        .then((_) => _removeFeedWithDownload(name));
  }

  //
  // Albums
  //

  Map<String, List<Audio>> _pinnedAlbums = {};
  Map<String, List<Audio>> get pinnedAlbums => _pinnedAlbums;
  int get pinnedAlbumsLength => _pinnedAlbums.length;
  final _albumsController = StreamController<bool>.broadcast();
  Stream<bool> get albumsChanged => _albumsController.stream;

  List<Audio> getAlbumAt(int index) =>
      _pinnedAlbums.entries.elementAt(index).value.toList();

  bool isPinnedAlbum(String name) => _pinnedAlbums.containsKey(name);

  void addPinnedAlbum(String name, List<Audio> audios) {
    _pinnedAlbums.putIfAbsent(name, () => audios);
    writeAudioMap(_pinnedAlbums, kPinnedAlbumsFileName)
        .then((_) => _albumsController.add(true));
  }

  void removePinnedAlbum(String name) {
    _pinnedAlbums.remove(name);
    writeAudioMap(_pinnedAlbums, kPinnedAlbumsFileName)
        .then((_) => _albumsController.add(true));
  }

  bool? _libraryInitialized;
  Future<bool> init() async {
    // Ensure [init] is only called once
    if (_libraryInitialized == true) return _libraryInitialized!;

    _playlists = await readAudioMap(kPlaylistsFileName);
    _pinnedAlbums = await readAudioMap(kPinnedAlbumsFileName);
    _podcasts = await readAudioMap(kPodcastsFileName);
    _podcastUpdates = Set.from(
      await readStringIterable(filename: kPodcastsUpdates) ?? <String>{},
    );
    _podcastUpdates ??= {};
    _starredStations = await readAudioMap(kStarredStationsFileName);

    _likedAudios =
        (await readAudioMap(kLikedAudiosFileName)).entries.firstOrNull?.value ??
            <Audio>[];

    _downloadsDir = await getDownloadsDir();
    _downloads = await readStringMap(kDownloads);
    _feedsWithDownloads = Set.from(
      await readStringIterable(filename: kFeedsWithDownloads) ?? <String>{},
    );

    return true;
  }

  String? get selectedPageId => _sharedPreferences.getString(kSelectedPageId);
  Future<void> setSelectedPageId(String value) {
    return _sharedPreferences.setString(kSelectedPageId, value);
  }

  Future<void> dispose() async {
    dio.close();
    await _albumsController.close();
    await _podcastsController.close();
    await _likedAudiosController.close();
    await _playlistsController.close();
    await _starredStationsController.close();
    await _favTagsController.close();
    await _favCountriesController.close();
    await _favLanguagesController.close();
    await _updateController.close();
    await _downloadsController.close();
  }
}