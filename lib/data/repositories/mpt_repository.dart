import 'package:my_mpt/data/services/mpt_parser_service.dart';
import 'package:my_mpt/data/models/tab_info.dart';
import 'package:my_mpt/domain/repositories/specialty_repository_interface.dart';
import 'package:my_mpt/domain/entities/specialty.dart';
import 'package:my_mpt/domain/entities/group.dart';

class MptRepository implements SpecialtyRepositoryInterface {
  final MptParserService _parserService = MptParserService();
  
  // Кэш для маппинга код -> имя специальности
  Map<String, String>? _codeToNameCache;
  List<Specialty>? _cachedSpecialties;

  @override
  Future<List<Specialty>> getSpecialties() async {
    try {
      // Используем кэш, если он есть
      if (_cachedSpecialties != null) {
        return _cachedSpecialties!;
      }

      final tabs = await _parserService.parseTabList();
      final specialties = tabs
          .map((tab) => _createSpecialtyFromTab(tab))
          .toList();

      specialties.sort((a, b) => a.name.compareTo(b.name));

      // Сохраняем в кэш
      _cachedSpecialties = specialties;
      _codeToNameCache = {
        for (var s in specialties) s.code: s.name,
      };

      return specialties;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Group>> getGroupsBySpecialty(String specialtyCode) async {
    try {
      String? specialtyName;
      
      // Пытаемся найти имя по коду из кэша
      if (_codeToNameCache != null) {
        specialtyName = _codeToNameCache![specialtyCode];
      }
      
      // Если не нашли в кэше, загружаем специальности (использует кэш парсера)
      if (specialtyName == null) {
        final specialties = await getSpecialties();
        final specialty = specialties.firstWhere(
          (s) => s.code == specialtyCode,
          orElse: () => Specialty(code: '', name: ''),
        );

        // Если специальность не найдена, возвращаем пустой список
        if (specialty.code.isEmpty) {
          return [];
        }
        
        specialtyName = specialty.name;
      }

      // Используем имя специальности для поиска в парсере
      // Парсер ищет по tab.name, а не по коду
      final groupInfos = await _parserService.parseGroups(specialtyName);

      final result = groupInfos
          .map(
            (groupInfo) => Group(
              code: groupInfo.code,
              specialtyCode: groupInfo.specialtyCode,
            ),
          )
          .toList();

      result.sort((a, b) => a.code.compareTo(b.code));

      return result;
    } catch (e) {
      return [];
    }
  }

  Specialty _createSpecialtyFromTab(TabInfo tab) {
    String code = tab.href;
    if (code.startsWith('#specialty-')) {
      code = code
          .substring(11)
          .toUpperCase()
          .replaceAll('-', '.')
          .replaceAll('E', 'Э');
    }

    String name = tab.name;
    if (name.isEmpty) {
      name = tab.ariaControls;
    }

    return Specialty(code: code, name: name);
  }
}
