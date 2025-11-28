import 'package:my_mpt/data/services/schedule_changes_service.dart';
import 'package:my_mpt/domain/entities/schedule_change.dart';
import 'package:my_mpt/domain/repositories/schedule_changes_repository_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleChangesRepository implements ScheduleChangesRepositoryInterface {
  final ScheduleChangesService _changesService = ScheduleChangesService();

  static const String _selectedGroupKey = 'selected_group';
  static const String _selectedTeacherName = 'teacher';
  static const String _selectedRole = 'selected_role';

  /// Получить изменения в расписании для конкретной группы
  @override
  Future<List<ScheduleChangeEntity>> getScheduleChanges() async {
    try {
      // Здесь нужно получить выбранную группу из настроек
      final groupCode = await _getSelectedGroupCode();
      final teacherName = await _getSelectedTeacherName();
      final selectedRole = await _getSelectedRole();

      if (groupCode.isEmpty && teacherName.isEmpty && selectedRole.isEmpty) {
        return [];
      }

      if (selectedRole == 'student'){
        final changes = await _changesService.parseScheduleChangesForGroup(
          groupCode,
        );

        // Преобразуем ScheduleChange в ScheduleChangeEntity
        return changes.map((change) {
          return ScheduleChangeEntity(
            lessonNumber: change.lessonNumber,
            replaceFrom: change.replaceFrom,
            replaceTo: change.replaceTo,
            updatedAt: change.updatedAt,
            changeDate: change.changeDate,
          );
        }).toList();
      } else {
        final changes = await _changesService.parseScheduleChangesForTeacher(
          teacherName,
        );

        // Преобразуем ScheduleChange в ScheduleChangeEntity
        return changes.map((change) {
          return ScheduleChangeEntity(
            lessonNumber: change.lessonNumber,
            replaceFrom: change.replaceFrom,
            replaceTo: change.replaceTo,
            updatedAt: change.updatedAt,
            changeDate: change.changeDate,
          );
        }).toList();
      }
    } catch (e) {
      return [];
    }
  }

  /// Получает код выбранной группы из настроек или из переменной окружения
  Future<String> _getSelectedGroupCode() async {
    try {
      // Проверяем переменную окружения first
      const envGroup = String.fromEnvironment('SELECTED_GROUP');
      if (envGroup.isNotEmpty) {
        return envGroup;
      }

      // Если переменная окружения не задана, используем SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_selectedGroupKey) ?? '';
    } catch (e) {
      return '';
    }
  }

  Future<String> _getSelectedTeacherName() async {
    try {
      // Проверяем переменную окружения first
      const envTeacher = String.fromEnvironment('TEACHER');
      if (envTeacher.isNotEmpty) {
        return envTeacher;
      }

      // Если переменная окружения не задана, используем SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_selectedTeacherName) ?? '';
    } catch (e) {
      return '';
    }
  }

  Future<String> _getSelectedRole() async {
    try {
      // Проверяем переменную окружения first
      const envRole = String.fromEnvironment('SELECTED_ROLE');
      if (envRole.isNotEmpty) {
        return envRole;
      }

      // Если переменная окружения не задана, используем SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_selectedRole) ?? '';
    } catch (e) {
      return '';
    }
  }
}
