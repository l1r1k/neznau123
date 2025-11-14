/// Сущность, представляющая учебную группу
class Group {
  /// Код группы
  final String code;
  
  /// Код специальности, к которой относится группа
  final String specialtyCode;

  Group({required this.code, required this.specialtyCode});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Group &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() {
    return 'Group{code: $code, specialtyCode: $specialtyCode}';
  }
}