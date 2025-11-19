import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:my_mpt/data/models/week_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для парсинга информации о текущей неделе с сайта МПТ
///
/// Этот сервис отвечает за извлечение информации о типе текущей недели
/// (числитель или знаменатель) с официального сайта техникума
class WeekParserService {
  /// Базовый URL сайта с расписанием
  final String baseUrl = 'https://mpt.ru/raspisanie/';

  /// Ключи для кэширования
  static const String _cacheKeyWeekInfo = 'week_info_cache';
  static const String _cacheKeyWeekInfoTimestamp = 'week_info_cache_timestamp';

  /// Получает следующий понедельник в 0:00
  DateTime _getNextMonday() {
    final now = DateTime.now();
    final daysUntilMonday = (8 - now.weekday) % 7;
    final nextMonday = now.add(
      Duration(days: daysUntilMonday == 0 ? 7 : daysUntilMonday),
    );
    return DateTime(
      nextMonday.year,
      nextMonday.month,
      nextMonday.day,
      0,
      0,
    );
  }

  /// Проверяет, нужно ли обновить кэш (каждый понедельник в 0:00)
  bool _shouldRefreshCache(DateTime cacheTime) {
    final now = DateTime.now();
    final nextMonday = _getNextMonday();
    
    // Если текущее время прошло следующий понедельник, обновляем
    if (now.isAfter(nextMonday) || now.isAtSameMomentAs(nextMonday)) {
      return true;
    }
    
    // Если кэш был создан до последнего понедельника, обновляем
    final lastMonday = nextMonday.subtract(const Duration(days: 7));
    return cacheTime.isBefore(lastMonday);
  }

  /// Получает кэшированную информацию о неделе
  Future<WeekInfo?> _getCachedWeekInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheKeyWeekInfoTimestamp);
      final cachedJson = prefs.getString(_cacheKeyWeekInfo);

      if (timestamp != null && cachedJson != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        
        if (!_shouldRefreshCache(cacheTime)) {
          final Map<String, dynamic> decoded = jsonDecode(cachedJson);
          return WeekInfo(
            weekType: decoded['weekType'] as String,
            date: decoded['date'] as String,
            day: decoded['day'] as String,
          );
        } else {
          // Кэш истек, очищаем
          await prefs.remove(_cacheKeyWeekInfo);
          await prefs.remove(_cacheKeyWeekInfoTimestamp);
        }
      }
    } catch (e) {
      // Игнорируем ошибки кэша
    }
    return null;
  }

  /// Сохраняет информацию о неделе в кэш
  Future<void> _saveCachedWeekInfo(WeekInfo weekInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(weekInfo.toJson());
      await prefs.setString(_cacheKeyWeekInfo, json);
      await prefs.setInt(
        _cacheKeyWeekInfoTimestamp,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Игнорируем ошибки кэша
    }
  }

  /// Парсит информацию о текущей неделе
  ///
  /// Метод извлекает HTML-страницу с расписанием и определяет тип текущей недели
  /// (числитель или знаменатель), а также текущую дату и день недели
  ///
  /// Параметры:
  /// - [forceRefresh]: Принудительное обновление без использования кэша
  ///
  /// Возвращает:
  /// - WeekInfo: Информация о текущей неделе
  Future<WeekInfo> parseWeekInfo({bool forceRefresh = false}) async {
    // Проверяем кэш
    if (!forceRefresh) {
      final cached = await _getCachedWeekInfo();
      if (cached != null) {
        return cached;
      }
    }

    try {
      // Отправляем HTTP-запрос к странице с расписанием
      final response = await http.get(Uri.parse(baseUrl));

      // Проверяем успешность запроса
      if (response.statusCode == 200) {
        // Парсим HTML документ с помощью библиотеки html
        final document = parser.parse(response.body);

        // Инициализируем переменные для хранения информации
        String date = '';
        String day = '';

        // Ищем заголовок с датой и днем недели
        final dateHeader = document.querySelector('h2');
        if (dateHeader != null) {
          // Извлекаем текст заголовка и разбиваем по разделителю
          final dateText = dateHeader.text.trim();
          final parts = dateText.split(' - ');
          if (parts.length >= 2) {
            date = parts[0]; // Дата
            day = parts[1]; // День недели
          } else {
            date = dateText;
          }
        }

        // Ищем информацию о типе недели
        String weekType = '';
        final weekHeaders = document.querySelectorAll('h3');

        // Проходим по всем заголовкам h3 и ищем информацию о неделе
        for (var header in weekHeaders) {
          final text = header.text.trim();
          // Проверяем, начинается ли текст с "Неделя:"
          if (text.startsWith('Неделя:')) {
            // Извлекаем тип недели из текста
            weekType = text.substring(7).trim();
            // Проверяем наличие дополнительной информации в элементе .label
            final labelElement = header.querySelector('.label');
            if (labelElement != null) {
              weekType = labelElement.text.trim();
            }
            break;
          }
        }

        // Если тип недели не найден в заголовках h3, ищем в элементах .label
        if (weekType.isEmpty) {
          final labelElements = document.querySelectorAll('.label');
          for (var label in labelElements) {
            final labelText = label.text.trim();
            // Проверяем, является ли текст "Числитель" или "Знаменатель"
            if (labelText == 'Числитель' || labelText == 'Знаменатель') {
              weekType = labelText;
              break;
            }
          }
        }

        // Создаем и возвращаем объект с информацией о неделе
        final weekInfo = WeekInfo(weekType: weekType, date: date, day: day);
        
        // Сохраняем в кэш
        await _saveCachedWeekInfo(weekInfo);
        
        return weekInfo;
      } else {
        throw Exception('Ошибка загрузки страницы: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при парсинге данных: $e');
    }
  }
}
