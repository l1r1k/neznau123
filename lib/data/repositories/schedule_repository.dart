import 'package:flutter/foundation.dart';
import 'package:my_mpt/domain/entities/schedule.dart';
import 'package:my_mpt/domain/repositories/schedule_repository_interface.dart';
import '../models/schedule_response.dart';
import '../services/schedule_api_service.dart';

/// Реализация репозитория для работы с расписанием
class ScheduleRepository implements ScheduleRepositoryInterface {
  final ScheduleApiService _apiService = ScheduleApiService();

  /// Получить расписание на неделю
  Future<Map<String, List<Schedule>>> getWeeklySchedule() async {
    try {
      final response = await _apiService.getScheduleData();
      // Поскольку ScheduleResponse уже содержит доменные сущности Schedule,
      // мы можем вернуть weeklySchedule напрямую
      return response.weeklySchedule;
    } catch (e) {
      // В реальном приложении мы бы обработали ошибки соответствующим образом
      debugPrint('Ошибка при получении данных расписания: $e');
      // Вернуть пустые данные в качестве резервного варианта
      return {};
    }
  }

  /// Получить расписание на сегодня
  Future<List<Schedule>> getTodaySchedule() async {
    try {
      final response = await _apiService.getScheduleData();
      // Поскольку ScheduleResponse уже содержит доменные сущности Schedule,
      // мы можем вернуть todaySchedule напрямую
      return response.todaySchedule;
    } catch (e) {
      // В реальном приложении мы бы обработали ошибки соответствующим образом
      debugPrint('Ошибка при получении расписания на сегодня: $e');
      return [];
    }
  }

  /// Получить расписание на завтра
  Future<List<Schedule>> getTomorrowSchedule() async {
    try {
      final response = await _apiService.getScheduleData();
      // Для демонстрации возвращаем те же данные, что и для сегодня
      // В реальной реализации здесь должна быть логика получения расписания на завтра
      return response.todaySchedule;
    } catch (e) {
      // В реальном приложении мы бы обработали ошибки соответствующим образом
      debugPrint('Ошибка при получении расписания на завтра: $e');
      return [];
    }
  }
}