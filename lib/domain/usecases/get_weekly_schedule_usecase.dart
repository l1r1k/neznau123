import 'package:my_mpt/domain/entities/schedule.dart';
import 'package:my_mpt/domain/repositories/schedule_repository_interface.dart';

/// Use case для получения расписания на неделю
class GetWeeklyScheduleUseCase {
  /// Репозиторий для работы с расписанием
  final ScheduleRepositoryInterface repository;

  GetWeeklyScheduleUseCase(this.repository);

  /// Выполнить получение расписания на неделю
  Future<Map<String, List<Schedule>>> call() async {
    return await repository.getWeeklySchedule();
  }
}