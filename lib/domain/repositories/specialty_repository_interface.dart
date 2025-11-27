import '../entities/specialty.dart';
import '../entities/group.dart';
import '../entities/teacher.dart';

/// Интерфейс репозитория для работы со специальностями и группами
abstract class SpecialtyRepositoryInterface {
  /// Получить все специальности
  Future<List<Specialty>> getSpecialties();

  /// Получить группы по коду специальности
  Future<List<Group>> getGroupsBySpecialty(String specialtyCode);

  Future<List<Teacher>> getTeachers();
}