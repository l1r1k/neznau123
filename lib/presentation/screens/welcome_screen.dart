import 'package:flutter/material.dart';
import 'package:my_mpt/domain/entities/specialty.dart';
import 'package:my_mpt/domain/entities/group.dart';
import 'package:my_mpt/domain/usecases/get_specialties_usecase.dart';
import 'package:my_mpt/domain/usecases/get_groups_by_specialty_usecase.dart';
import 'package:my_mpt/domain/repositories/specialty_repository_interface.dart';
import 'package:my_mpt/data/repositories/mpt_repository.dart' as repo_impl;
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onSetupComplete;

  const WelcomeScreen({super.key, required this.onSetupComplete});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late SpecialtyRepositoryInterface _repository;
  late GetSpecialtiesUseCase _getSpecialtiesUseCase;
  late GetGroupsBySpecialtyUseCase _getGroupsBySpecialtyUseCase;

  List<Specialty> _specialties = [];
  List<Group> _groups = [];
  Specialty? _selectedSpecialty;
  Group? _selectedGroup;
  bool _isLoading = false;
  bool _isGroupsLoading = false;
  int _currentPage = 0; // 0: welcome, 1: specialty, 2: group

  static const String _selectedGroupKey = 'selected_group';
  static const String _selectedSpecialtyKey = 'selected_specialty';
  static const String _firstLaunchKey = 'first_launch';

  @override
  void initState() {
    super.initState();
    _repository = repo_impl.MptRepository();
    _getSpecialtiesUseCase = GetSpecialtiesUseCase(_repository);
    _getGroupsBySpecialtyUseCase = GetGroupsBySpecialtyUseCase(_repository);
  }

  Future<void> _loadSpecialties() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final specialties = await _getSpecialtiesUseCase();
      setState(() {
        _specialties = specialties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка загрузки специальностей')),
        );
      }
    }
  }

  Future<void> _loadGroups(String specialtyCode) async {
    setState(() {
      _isGroupsLoading = true;
      _groups = [];
    });

    try {
      final groups = await _getGroupsBySpecialtyUseCase(specialtyCode);
      setState(() {
        _groups = groups;
        _isGroupsLoading = false;
      });
    } catch (e) {
      setState(() {
        _isGroupsLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ошибка загрузки групп')));
      }
    }
  }

  Future<void> _saveSelectionAndProceed() async {
    if (_selectedSpecialty == null || _selectedGroup == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пожалуйста, выберите специальность и группу'),
          ),
        );
      }
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedSpecialtyKey, _selectedSpecialty!.code);
      await prefs.setString(
        '${_selectedSpecialtyKey}_name',
        _selectedSpecialty!.name,
      );
      await prefs.setString(_selectedGroupKey, _selectedGroup!.code);
      await prefs.setBool(_firstLaunchKey, false);

      if (mounted) {
        widget.onSetupComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка сохранения настроек')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Container(
        color: const Color(0xFF000000),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildPageContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_currentPage) {
      case 0:
        return _buildWelcomePage();
      case 1:
        return _buildSpecialtySelectionPage();
      case 2:
        return _buildGroupSelectionPage();
      default:
        return _buildWelcomePage();
    }
  }

  Widget _buildWelcomePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Логотип или иконка (можно заменить на реальный логотип)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFFF8C00),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8C00).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.school, size: 60, color: Colors.black),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Добро пожаловать в',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '"Мой МПТ"',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF8C00),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          const Text(
            'Мы рады, что вы выбрали именно этот техникум для обучения. Мы разработали это приложение, чтобы вам было более комфортно смотреть расписание.',
            style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentPage = 1;
                });
                _loadSpecialties();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Отлично',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtySelectionPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Выберите свою специальность',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Container(
          height: 50, // Уменьшена высота контейнера
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: _isLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFFF8C00),
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<Specialty>(
                    value: _selectedSpecialty,
                    hint: const Text(
                      'Выберите специальность',
                      style: TextStyle(color: Colors.white70),
                    ),
                    items: _specialties.map((Specialty specialty) {
                      return DropdownMenuItem<Specialty>(
                        value: specialty,
                        child: Text(
                          specialty.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (Specialty? newValue) {
                      setState(() {
                        _selectedSpecialty = newValue;
                      });
                    },
                    isExpanded: true,
                    dropdownColor: const Color(0xFF111111),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFFFF8C00),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _selectedSpecialty != null
                ? () {
                    setState(() {
                      _currentPage = 2;
                    });
                    _loadGroups(_selectedSpecialty!.code);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 5,
            ),
            child: const Text(
              'Продолжить',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            setState(() {
              _currentPage = 0;
            });
          },
          child: const Text(
            'Назад',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupSelectionPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Выберите свою группу',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Container(
          height: 50, // Уменьшена высота контейнера
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: _isGroupsLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFFF8C00),
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<Group>(
                    value: _selectedGroup,
                    hint: const Text(
                      'Выберите группу',
                      style: TextStyle(color: Colors.white70),
                    ),
                    items: _groups.map((Group group) {
                      return DropdownMenuItem<Group>(
                        value: group,
                        child: Text(
                          group.code,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (Group? newValue) {
                      setState(() {
                        _selectedGroup = newValue;
                      });
                    },
                    isExpanded: true,
                    dropdownColor: const Color(0xFF111111),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFFFF8C00),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Поменять группу можно в настройках',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _selectedGroup != null ? _saveSelectionAndProceed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 5,
            ),
            child: const Text(
              'Готово',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            setState(() {
              _currentPage = 1;
            });
          },
          child: const Text(
            'Назад',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
