import 'package:flutter/foundation.dart';
import 'package:my_mpt/domain/entities/group.dart';
import 'package:my_mpt/domain/entities/specialty.dart';
import 'package:my_mpt/domain/repositories/specialty_repository_interface.dart';
import '../models/specialty.dart' as data_specialty;
import '../models/group.dart' as data_group;
import '../services/mock_api_service.dart';

/// Реализация репозитория для работы со специальностями и группами
class SpecialtyRepository implements SpecialtyRepositoryInterface {
  final MockApiService _apiService = MockApiService();

  /// Получить все специальности
  Future<List<Specialty>> getSpecialties() async {
    try {
      final specialties = await _apiService.getSpecialties();
      return specialties
          .map((s) => Specialty(code: s.code, name: s.name))
          .toList();
    } catch (e) {
      // В реальном приложении мы бы обработали ошибки соответствующим образом
      debugPrint('Ошибка при получении специальностей: $e');
      return [];
    }
  }

  /// Получить группы по коду специальности
  Future<List<Group>> getGroupsBySpecialty(String specialtyCode) async {
    try {
      final groups = await _apiService.getGroupsBySpecialty(specialtyCode);
      return groups
          .map((g) => Group(code: g.code, specialtyCode: g.specialtyCode))
          .toList();
    } catch (e) {
      // В реальном приложении мы бы обработали ошибки соответствующим образом
      debugPrint('Ошибка при получении групп для специальности $specialtyCode: $e');
      return [];
    }
  }
}