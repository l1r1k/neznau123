import 'package:flutter/material.dart';
import 'package:my_mpt/core/constants/app_constants.dart';

/// Экран "Звонки"
class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Данные звонков для периодов 1-7
    final List<Map<String, String>> callsData = [
      {'period': '1', 'time': '08:30', 'description': 'Начало занятий'},
      {'period': '2', 'time': '09:15', 'description': 'Первый звонок'},
      {'period': '3', 'time': '09:25', 'description': 'Начало второго занятия'},
      {'period': '4', 'time': '10:10', 'description': 'Второй звонок'},
      {'period': '5', 'time': '10:30', 'description': 'Начало третьего занятия'},
      {'period': '6', 'time': '11:15', 'description': 'Третий звонок'},
      {'period': '7', 'time': '11:25', 'description': 'Начало четвертого занятия'},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Звонки',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Single container for all calls
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF333333),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: List.generate(
                    callsData.length,
                    (index) {
                      final data = callsData[index];
                      return Column(
                        children: [
                          if (index > 0) const Divider(
                            color: Color(0xFF333333),
                            height: 1,
                            thickness: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Номер периода (обычный текст, белый цвет)
                                Text(
                                  data['period']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Время и описание
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['time']!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        data['description']!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}