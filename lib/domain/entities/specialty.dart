/// Сущность, представляющая специальность обучения
class Specialty {
  /// Код специальности
  final String code;
  
  /// Название специальности
  final String name;

  Specialty({required this.code, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Specialty &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() {
    return 'Specialty{code: $code, name: $name}';
  }
}