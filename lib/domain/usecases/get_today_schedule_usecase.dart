import 'package:my_mpt/domain/entities/schedule.dart';
import 'package:my_mpt/domain/repositories/schedule_repository_interface.dart';

/// Use case для получения расписания на сегодня
class GetTodayScheduleUseCase {
  /// Репозиторий для работы с расписанием
  final ScheduleRepositoryInterface repository;

  GetTodayScheduleUseCase(this.repository);

  /// Выполнить получение расписания на сегодня
  Future<List<Schedule>> call() async {
    return await repository.getTodaySchedule();
  }
}