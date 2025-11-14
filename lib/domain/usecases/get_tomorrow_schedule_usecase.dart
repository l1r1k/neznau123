import 'package:my_mpt/domain/entities/schedule.dart';
import 'package:my_mpt/domain/repositories/schedule_repository_interface.dart';

/// Use case для получения расписания на завтра
class GetTomorrowScheduleUseCase {
  /// Репозиторий для работы с расписанием
  final ScheduleRepositoryInterface repository;

  GetTomorrowScheduleUseCase(this.repository);

  /// Выполнить получение расписания на завтра
  Future<List<Schedule>> call() async {
    return await repository.getTomorrowSchedule();
  }
}