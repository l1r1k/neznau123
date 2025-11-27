import 'package:my_mpt/domain/entities/teacher.dart';
import 'package:my_mpt/domain/repositories/specialty_repository_interface.dart';

/// Получение списка преподавателей
///
/// Этот класс реализует бизнес-логику для получения преподавателей
/// с использованием репозитория специальностей
class GetTeachersUseCase {
  /// Репозиторий для работы со специальностями и группами
  final SpecialtyRepositoryInterface repository;

  /// Конструктор use case для получения списка преподавателей
  ///
  /// Параметры:
  /// - [repository]: Репозиторий специальностей и групп
  GetTeachersUseCase(this.repository);

  /// Выполнить получение списка преподавателей
  ///
  /// Метод делегирует выполнение получения преподавателей
  /// репозиторию специальностей и групп
  ///
  /// Параметры:
  /// - [specialtyCode]: Код специальности
  ///
  /// Возвращает:
  /// - Future<List<Group>>: Список групп для указанной специальности
  Future<List<Teacher>> call() async {
    final result = await repository.getTeachers();
    return result;
  }
}
