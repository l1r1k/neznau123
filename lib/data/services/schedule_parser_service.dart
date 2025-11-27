import 'package:my_mpt/data/datasources/schedule_remote_data_source.dart';
import 'package:my_mpt/data/models/lesson.dart';
import 'package:my_mpt/data/parsers/schedule_html_parser.dart';

class ScheduleParserService {
  ScheduleParserService({
    ScheduleRemoteDataSource? remoteDataSource,
    ScheduleTeacherParser? htmlTeacherParser,
    ScheduleGroupParser? htmlGroupParser
  })  : _remoteDataSource = remoteDataSource ?? ScheduleRemoteDataSource(),
        _htmlTeacherParser = htmlTeacherParser ?? ScheduleTeacherParser(),
        _htmlGroupParser = htmlGroupParser ?? ScheduleGroupParser();

  final ScheduleRemoteDataSource _remoteDataSource;
  final ScheduleTeacherParser _htmlTeacherParser;
  final ScheduleGroupParser _htmlGroupParser;

  Future<Map<String, List<Lesson>>> parseScheduleForGroup(
    String groupCode, {
    bool forceRefresh = false,
  }) async {
    if (groupCode.isEmpty) return {};

    try {
      final html = await _remoteDataSource.fetchSchedulePage(
        forceRefresh: forceRefresh,
      );
      return _htmlGroupParser.parseHTML(html, groupCode);
    } catch (error) {
      throw Exception('Error parsing schedule for group $groupCode: $error');
    }
  }

  /// Парсит расписание для конкретного преподавателя
  Future<Map<String, List<Lesson>>?> parseScheduleForTeacher(
    String teacherName, {
    bool forceRefresh = false,
  }) async {
    if (teacherName.isEmpty) return {};

    try {
      final html = await _remoteDataSource.fetchSchedulePage(
        forceRefresh: forceRefresh,
      );
      return _htmlTeacherParser.parseHTML(html, teacherName);
    } catch (error) {
      throw Exception('Error parsing schedule for group $teacherName: $error');
    }
  }

  void clearCache() => _remoteDataSource.clearCache();
}
