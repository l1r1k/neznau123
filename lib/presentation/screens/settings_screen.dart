import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _backgroundColor = Color(0xFF000000);
  static const List<Color> _headerGradient = [
    Color(0xFF333333),
    Color(0xFF111111),
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
              const _SettingsHeader(),
              const SizedBox(height: 28),
              const _Section(title: 'Учебная группа'),
              const SizedBox(height: 14),
              const _SettingsCard(
                title: 'Выберите свою группу',
                subtitle: 'Группа не выбрана',
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 28),
              const _Section(title: 'Расписание'),
              const SizedBox(height: 14),
              const _SettingsCard(
                title: 'Обновить расписание',
                subtitle: 'Последнее обновление: сегодня в 08:30',
                icon: Icons.refresh,
              ),
              const SizedBox(height: 28),
              const _Section(title: 'Обратная связь'),
              const SizedBox(height: 14),
              const _SettingsCard(
                title: 'Связаться с разработчиком',
                subtitle: 'Сообщить об ошибке или предложить улучшение',
                icon: Icons.chat_outlined,
              ),
              const SizedBox(height: 28),
              const _Section(title: 'Дополнительно'),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const ListTile(
                  leading: Icon(Icons.info_outline, color: Color(0xFFFF8C00)),
                  title: Text(
                    'О приложении',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white54,
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

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: SettingsScreen._headerGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Настройки',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Персонализируйте расписание и связь с техникумом',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;

  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SettingsCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFF8C00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFFFF8C00)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
        ],
      ),
    );
  }
}
