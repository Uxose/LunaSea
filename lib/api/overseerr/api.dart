import 'package:lunasea/api/overseerr/models/content/movie.dart';
import 'package:lunasea/api/overseerr/models/content/series.dart';
import 'package:lunasea/api/overseerr/models/issues/issue.dart';
import 'package:lunasea/api/overseerr/models/issues/issue_page.dart';
import 'package:lunasea/api/overseerr/models/requests/request.dart';
import 'package:lunasea/api/overseerr/models/requests/request_count.dart';
import 'package:lunasea/api/overseerr/models/requests/request_page.dart';
import 'package:lunasea/api/overseerr/models/status/status.dart';
import 'package:lunasea/api/overseerr/models/status/status_appdata.dart';
import 'package:lunasea/api/overseerr/models/users/user_page.dart';
import 'package:lunasea/api/overseerr/models/users/user_quota.dart';
import 'package:lunasea/vendor.dart';

part 'api.g.dart';

@RestApi()
abstract class OverseerrAPI {
  factory OverseerrAPI({
    required String host,
    required String apiKey,
    Map<String, dynamic> headers = const {},
  }) {
    String _baseUrl = host.endsWith('/') ? '${host}api/v1/' : '$host/api/v1/';
    Dio _dio = Dio(
      BaseOptions(
        headers: {
          'X-Api-Key': apiKey,
          ...headers,
        },
        followRedirects: true,
        maxRedirects: 5,
      ),
    );
    return _OverseerrAPI(_dio, baseUrl: _baseUrl);
  }

  @GET('issue')
  Future<OverseerrIssuePage> getIssues({
    @Query('take') int? take,
    @Query('skip') int? skip,
    @Query('filter') String? filter,
    @Query('sort') String? sort,
  });

  @GET('issue/{id}')
  Future<OverseerrIssue> getIssue(
    @Path('id') int id,
  );

  @GET('movie/{id}')
  Future<OverseerrMovie> getMovie(
    @Path('id') int id, {
    @Query('language') String? language,
  });

  @GET('request')
  Future<OverseerrRequestPage> getRequests({
    @Query('take') int? take,
    @Query('skip') int? skip,
    @Query('filter') String? filter,
    @Query('sort') String? sort,
    @Query('requestedBy') int? requestedBy,
  });

  @GET('request/{id}')
  Future<OverseerrRequest> getRequest(
    @Path('id') String id,
  );

  @GET('request/count')
  Future<OverseerrRequestCount> getRequestCount();

  @GET('status')
  Future<OverseerrStatus> getStatus();

  @GET('status/appdata')
  Future<OverseerrStatusAppData> getStatusAppData();

  @GET('tv/{id}')
  Future<OverseerrSeries> getSeries(
    @Path('id') int id, {
    @Query('language') String? language,
  });

  @GET('user')
  Future<OverseerrUserPage> getUsers({
    @Query('take') int? take,
    @Query('skip') int? skip,
    @Query('sort') String? sort,
  });

  @GET('user/{id}')
  Future<OverseerrUserPage> getUser(
    @Path('id') String id,
  );

  @GET('user/{id}/quota')
  Future<OverseerrUserQuota> getUserQuota(
    @Path('id') String id,
  );
}
