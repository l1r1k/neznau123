import 'package:my_mpt/domain/entities/specialty.dart';
import 'package:my_mpt/domain/repositories/specialty_repository_interface.dart';

/// Use case для получения списка специальностей
class GetSpecialtiesUseCase {
  /// Репозиторий для работы со специальностями
  final SpecialtyRepositoryInterface repository;

  GetSpecialtiesUseCase(this.repository);

  /// Выполнить получение списка специальностей
  Future<List<Specialty>> call() async {
    return await repository.getSpecialties();
  }
}