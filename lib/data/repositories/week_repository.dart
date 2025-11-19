import 'package:my_mpt/data/services/week_parser_service.dart';
import 'package:my_mpt/data/models/week_info.dart';

class WeekRepository {
  final WeekParserService _parserService = WeekParserService();
  
  Future<WeekInfo> getWeekInfo({bool forceRefresh = false}) async {
    try {
      final weekInfo = await _parserService.parseWeekInfo(forceRefresh: forceRefresh);
      return weekInfo;
    } catch (e) {
      return WeekInfo(
        weekType: 'Неизвестно',
        date: 'Неизвестно',
        day: 'Неизвестно',
      );
    }
  }
}