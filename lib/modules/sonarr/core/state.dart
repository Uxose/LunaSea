import 'dart:async';
import 'package:lunasea/core.dart';
import 'package:lunasea/modules/sonarr.dart';

class SonarrState extends LunaModuleState {
  SonarrState() {
    reset();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void reset() {
    _series = null;
    _upcoming = null;
    _missing = null;
    _rootFolders = null;
    _qualityProfiles = null;
    _languageProfiles = null;
    _tags = null;

    resetProfile();
    if (_enabled) {
      fetchAllSeries();
      fetchUpcoming();
      fetchMissing();
      fetchRootFolders();
      fetchQualityProfiles();
      fetchLanguageProfiles();
      fetchTags();
    }
    notifyListeners();
  }

  ///////////////
  /// PROFILE ///
  ///////////////

  /// API handler instance
  Sonarr _api;
  Sonarr get api => _api;

  /// Is the API enabled?
  bool _enabled;
  bool get enabled => _enabled;

  /// Sonarr host
  String _host;
  String get host => _host;

  /// Sonarr API key
  String _apiKey;
  String get apiKey => _apiKey;

  /// Headers to attach to all requests
  Map<dynamic, dynamic> _headers;
  Map<dynamic, dynamic> get headers => _headers;

  /// Reset the profile data, reinitializes API instance
  void resetProfile() {
    ProfileHiveObject _profile = Database.currentProfileObject;
    // Copy profile into state
    _api = null;
    _enabled = _profile.sonarrEnabled ?? false;
    _host = _profile.sonarrHost ?? '';
    _apiKey = _profile.sonarrKey ?? '';
    _headers = _profile.sonarrHeaders ?? {};
    // Create the API instance if Sonarr is enabled
    if (_enabled) {
      _api = Sonarr(
        host: _host,
        apiKey: _apiKey,
        headers: Map<String, dynamic>.from(_headers),
      );
    }
  }

  /////////////////
  /// CATALOGUE ///
  /////////////////

  String _seriesSearchQuery = '';
  String get seriesSearchQuery => _seriesSearchQuery;
  set seriesSearchQuery(String seriesSearchQuery) {
    assert(seriesSearchQuery != null);
    _seriesSearchQuery = seriesSearchQuery;
    notifyListeners();
  }

  SonarrSeriesSorting _seriesSortType =
      SonarrDatabaseValue.DEFAULT_SORTING_SERIES.data;
  SonarrSeriesSorting get seriesSortType => _seriesSortType;
  set seriesSortType(SonarrSeriesSorting seriesSortType) {
    assert(seriesSortType != null);
    _seriesSortType = seriesSortType;
    notifyListeners();
  }

  SonarrSeriesFilter _seriesFilterType =
      SonarrDatabaseValue.DEFAULT_FILTERING_SERIES.data;
  SonarrSeriesFilter get seriesFilterType => _seriesFilterType;
  set seriesFilterType(SonarrSeriesFilter seriesFilterType) {
    assert(seriesFilterType != null);
    _seriesFilterType = seriesFilterType;
    notifyListeners();
  }

  bool _seriesSortAscending =
      SonarrDatabaseValue.DEFAULT_SORTING_SERIES_ASCENDING.data;
  bool get seriesSortAscending => _seriesSortAscending;
  set seriesSortAscending(bool seriesSortAscending) {
    assert(seriesSortAscending != null);
    _seriesSortAscending = seriesSortAscending;
    notifyListeners();
  }

  //////////////
  /// SERIES ///
  //////////////

  Future<Map<int, SonarrSeries>> _series;
  Future<Map<int, SonarrSeries>> get series => _series;
  void fetchAllSeries() {
    if (_api != null) {
      _series = _api.series.getAll().then((series) {
        return {
          for (SonarrSeries s in series) s.id: s,
        };
      });
    }
    notifyListeners();
  }

  Future<void> fetchSeries(int seriesId) async {
    assert(seriesId != null);
    if (_api != null) {
      SonarrSeries series = await _api.series.get(seriesId: seriesId);
      (await _series)[seriesId] = series;
    }
    notifyListeners();
  }

  Future<void> setSingleSeries(SonarrSeries series) async {
    assert(series != null);
    (await _series)[series.id] = series;
    notifyListeners();
  }

  Future<void> removeSingleSeries(int seriesId) async {
    assert(seriesId != null);
    (await _series).remove(seriesId);
    notifyListeners();
  }

  ///////////////
  /// MISSING ///
  ///////////////

  Future<SonarrMissing> _missing;
  Future<SonarrMissing> get missing => _missing;
  set missing(Future<SonarrMissing> missing) {
    assert(missing != null);
    _missing = missing;
    notifyListeners();
  }

  void fetchMissing() {
    if (_api != null)
      _missing = _api.wanted.getMissing(
        pageSize: SonarrDatabaseValue.CONTENT_PAGE_SIZE.data,
        sortDir: SonarrSortDirection.DESCENDING,
        sortKey: SonarrWantedMissingSortKey.AIRDATE_UTC,
      );
    notifyListeners();
  }

  ////////////////
  /// UPCOMING ///
  ////////////////

  Future<List<SonarrCalendar>> _upcoming;
  Future<List<SonarrCalendar>> get upcoming => _upcoming;
  set upcoming(Future<List<SonarrCalendar>> upcoming) {
    assert(upcoming != null);
    _upcoming = upcoming;
    notifyListeners();
  }

  void fetchUpcoming() {
    DateTime start = DateTime.now();
    DateTime end = start
        .add(Duration(days: SonarrDatabaseValue.UPCOMING_FUTURE_DAYS.data));
    if (_api != null)
      _upcoming = _api.calendar.get(
        start: start,
        end: end,
        includeEpisodeFile: true,
      );
    notifyListeners();
  }

  ////////////////
  /// PROFILES ///
  ////////////////

  Future<List<SonarrQualityProfile>> _qualityProfiles;
  Future<List<SonarrQualityProfile>> get qualityProfiles => _qualityProfiles;
  set qualityProfiles(Future<List<SonarrQualityProfile>> qualityProfiles) {
    assert(qualityProfiles != null);
    _qualityProfiles = qualityProfiles;
    notifyListeners();
  }

  void fetchQualityProfiles() {
    if (_api != null) _qualityProfiles = _api.profile.getQualityProfiles();
    notifyListeners();
  }

  Future<List<SonarrLanguageProfile>> _languageProfiles;
  Future<List<SonarrLanguageProfile>> get languageProfiles => _languageProfiles;
  set languageProfiles(Future<List<SonarrLanguageProfile>> languageProfiles) {
    assert(languageProfiles != null);
    _languageProfiles = languageProfiles;
    notifyListeners();
  }

  void fetchLanguageProfiles() {
    if (_api != null) _languageProfiles = _api.profile.getLanguageProfiles();
    notifyListeners();
  }

  ////////////////////
  /// ROOT FOLDERS ///
  ////////////////////

  Future<List<SonarrRootFolder>> _rootFolders;
  Future<List<SonarrRootFolder>> get rootFolders => _rootFolders;
  void fetchRootFolders() {
    if (_api != null) _rootFolders = _api.rootFolder.get();
    notifyListeners();
  }

  ////////////
  /// TAGS ///
  ////////////

  Future<List<SonarrTag>> _tags;
  Future<List<SonarrTag>> get tags => _tags;
  set tags(Future<List<SonarrTag>> tags) {
    assert(tags != null);
    _tags = tags;
    notifyListeners();
  }

  void fetchTags() {
    if (_api != null) _tags = _api.tag.getAll();
    notifyListeners();
  }

  //////////////
  /// IMAGES ///
  //////////////

  String _baseImageURL() {
    return _host.endsWith('/')
        ? '${_host}api/v3/MediaCover'
        : '$_host/api/v3/MediaCover';
  }

  String getBannerURL(int seriesId, {bool highRes = false}) {
    if (_enabled) {
      return highRes
          ? '${_baseImageURL()}/$seriesId/banner.jpg?apikey=$_apiKey'
          : '${_baseImageURL()}/$seriesId/banner-70.jpg?apikey=$_apiKey';
    }
    return null;
  }

  String getPosterURL(int seriesId, {bool highRes = false}) {
    if (_enabled) {
      return highRes
          ? '${_baseImageURL()}/$seriesId/poster.jpg?apikey=$_apiKey'
          : '${_baseImageURL()}/$seriesId/poster-500.jpg?apikey=$_apiKey';
    }
    return null;
  }

  String getFanartURL(int seriesId, {bool highRes = false}) {
    if (_enabled) {
      return highRes
          ? '${_baseImageURL()}/$seriesId/fanart.jpg?apikey=$_apiKey'
          : '${_baseImageURL()}/$seriesId/fanart-360.jpg?apikey=$_apiKey';
    }
    return null;
  }
}
