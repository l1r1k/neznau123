import 'package:flutter/material.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  static const _backgroundColor = Color(0xFF000000);
  static const List<Color> _headerGradient = [
    Color(0xFF333333),
    Color(0xFF111111),
  ];

  static final List<Map<String, String>> _callsData = [
    {'period': '1', 'time': '08:30 - 10:00', 'description': 'Перемена 10 минут'},
    {'period': '2', 'time': '10:10 - 11:40', 'description': 'Перемена 20 минут'},
    {'period': '3', 'time': '12:00 - 13:30', 'description': 'Перемена 20 минут'},
    {'period': '4', 'time': '13:50 - 15:20', 'description': 'Перемена 10 минут'},
    {'period': '5', 'time': '15:30 - 17:00', 'description': 'Перемена 5 минут'},
    {'period': '6', 'time': '17:05 - 18:35', 'description': 'Перемена 5 минут'},
    {'period': '7', 'time': '18:40 - 20:10', 'description': 'Конец учебного дня'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CallsHeader(),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  children: List.generate(_callsData.length, (index) {
                    final call = _callsData[index];
                    final isLast = index == _callsData.length - 1;
                    return _CallTimelineTile(
                      period: call['period']!,
                      time: call['time']!,
                      description: call['description']!,
                      showConnector: !isLast,
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallsHeader extends StatelessWidget {
  const _CallsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: CallsScreen._headerGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Звонки техникума',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Расписание звонков на учебный день',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallTimelineTile extends StatelessWidget {
  final String period;
  final String time;
  final String description;
  final bool showConnector;

  const _CallTimelineTile({
    required this.period,
    required this.time,
    required this.description,
    required this.showConnector,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8C00), Color(0xFFFFA500)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  period,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (showConnector)
              Container(
                width: 2,
                height: 48,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: const Color(0xFFFF8C00).withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
