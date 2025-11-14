import 'package:flutter/foundation.dart';
import 'package:my_mpt/domain/entities/schedule.dart';
import '../models/schedule_response.dart';
import '../services/schedule_api_service.dart';

class ScheduleRepository {
  final ScheduleApiService _apiService = ScheduleApiService();

  /// Get schedule data for the week
  Future<ScheduleResponse> getScheduleData() async {
    try {
      return await _apiService.getScheduleData();
    } catch (e) {
      // In a real app, we would handle errors appropriately
      debugPrint('Error fetching schedule data: $e');
      // Return empty data as fallback
      return ScheduleResponse(
        weeklySchedule: {},
        todaySchedule: [],
      );
    }
  }

  /// Get today's schedule
  Future<List<Schedule>> getTodaySchedule() async {
    try {
      return await _apiService.getTodaySchedule();
    } catch (e) {
      // In a real app, we would handle errors appropriately
      debugPrint('Error fetching today\'s schedule: $e');
      return [];
    }
  }

  /// Get weekly schedule
  Future<Map<String, List<Schedule>>> getWeeklySchedule() async {
    try {
      return await _apiService.getWeeklySchedule();
    } catch (e) {
      // In a real app, we would handle errors appropriately
      debugPrint('Error fetching weekly schedule: $e');
      return {};
    }
  }
}