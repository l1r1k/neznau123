import 'dart:math';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:my_mpt/data/models/lesson.dart';

class ScheduleTeacherParser {
  ScheduleTeacherParser();

  static const dayOrder = [
    "ПОНЕДЕЛЬНИК",
    "ВТОРНИК",
    "СРЕДА",
    "ЧЕТВЕРГ",
    "ПЯТНИЦА",
    "СУББОТА",
    "ВОСКРЕСЕНЬЕ",
  ];

  static const time = {
    1: ('8:30', '10:00'),
    2: ('10:10', '11:40'),
    3: ('12:00', '13:30'),
    4: ('13:50', '15:20'),
    5: ('15:30', '17:00'),
  };

    Map<String, List<Lesson>>? parseHTML(String html, String teacherName) {
    final document = html_parser.parse(html);
    final Map<String, Map<String, List<Lesson>>> result = {};

    final tabPanes = document.querySelectorAll('div.tab-pane');

    for (var pane in tabPanes) {
      final groupHeader = pane.querySelector('h3');
      if (groupHeader == null) continue;

      final groupName = groupHeader.text.replaceAll('Группа ', '').trim();

      // Собираем только таблицы данной группы (до следующего <h3>)
      final tables = <Element>[];
      bool inside = false;
      for (var node in pane.nodes) {
        if (node is Element && node.localName == 'h3') {
          final text = node.text.replaceAll('Группа ', '').trim();
          if (text == groupName) {
            inside = true;
            continue;
          } else {
            inside = false;
          }
        }
        if (inside && node is Element && node.localName == 'table') {
          tables.add(node);
        }
      }

      for (var table in tables) {
        final h4 = table.querySelector('h4');
        if (h4 == null) continue;

        final dayAndLocation = _extractDayAndLocation(h4);

        // Последний tbody содержит реальные пары
        final tbodies = table.querySelectorAll('tbody');
        if (tbodies.isEmpty) continue;
        final tbody = tbodies.last;
        final rows = tbody.querySelectorAll('tr');

        for (var row in rows) {
          final cols = row.querySelectorAll('td');
          if (cols.length != 3) continue;

          final num = int.tryParse(cols[0].text.trim());
          if (num == null) continue;

          // извлекаем предметы по типу (numerator/denominator/default)
          final subjectMap = _extractByType(cols[1]);
          // извлекаем преподавателей по типу
          final teacherMap = _extractByType(cols[2]);

          final hasSubNum = subjectMap['numerator'] != null;
          final hasSubDen = subjectMap['denominator'] != null;
          final hasSubDef = subjectMap['default'] != null;

          final hasTeachNum = teacherMap['numerator'] != null;
          final hasTeachDen = teacherMap['denominator'] != null;
          final hasTeachDef = teacherMap['default'] != null;

          // 1) Если есть числитель (только тогда) — создаём записи для числителя (если есть преподаватель)
          if (hasSubNum || hasTeachNum) {
            final subj = subjectMap['numerator'];
            final teach = teacherMap['numerator'];
            if (_hasText(teach)) {
              final teachers = _splitTeachers(teach!);
              for (var t in teachers) {
                _addLesson(result, t, Lesson(
                  number: num.toString(),
                  subject: subj ?? '',
                  groupName: groupName,
                  startTime: time[num]!.$1,
                  endTime: time[num]!.$2,
                  building: dayAndLocation.$2,
                  lessonType: 'numerator',
                ), dayAndLocation.$1);
              }
            }
            // если предмет есть, а преподавателя нет — ничего не добавляем для этой части
          }

          // 2) Если есть знаменатель (только тогда) — создаём записи для знаменателя (если есть преподаватель)
          if (hasSubDen || hasTeachDen) {
            final subj = subjectMap['denominator'];
            final teach = teacherMap['denominator'];
            if (_hasText(teach)) {
              final teachers = _splitTeachers(teach!);
              for (var t in teachers) {
                _addLesson(result, t, Lesson(
                  number: num.toString(),
                  subject: subj ?? '',
                  groupName: groupName,
                  startTime: time[num]!.$1,
                  endTime: time[num]!.$2,
                  building: dayAndLocation.$2,
                  lessonType: 'denominator',
                ), dayAndLocation.$1);
              }
            }
          }

          // 3) Если **ни** numerator, ни denominator присутствуют в предметах и преподавателях —
          //    считаем это ОДНОЙ обычной парой (weekType = null), но только если есть преподаватель default.
          if (!hasSubNum && !hasSubDen && !hasTeachNum && !hasTeachDen) {
            final subj = subjectMap['default'];
            final teach = teacherMap['default'];
            if (_hasText(teach)) {
              final teachers = _splitTeachers(teach!);
              for (var t in teachers) {
                _addLesson(result, t, Lesson(
                  number: num.toString(),
                  subject: subj ?? '',
                  groupName: groupName,
                  startTime: time[num]!.$1,
                  endTime: time[num]!.$2,
                  building: dayAndLocation.$2,
                  lessonType: null,
                ), dayAndLocation.$1);
              }
            }
          }
        }
      }
    }

    // Сортируем пары и дни недели
    for (var teacher in result.keys.toList()) {
      // сортировка пар
      for (var day in result[teacher]!.keys) {
        result[teacher]![day]!.sort((a, b) {
          final cmp = a.number.compareTo(b.number);
          if (cmp != 0) return cmp;
          // если номера равны, упорядочим: обычная (null) -> Числитель -> Знаменатель
          final order = {null: 0, 'Числитель': 1, 'Знаменатель': 2};
          return (order[a.lessonType] ?? 3).compareTo(order[b.lessonType] ?? 3);
        });
      }

      // сортировка дней по dayOrder
      result[teacher] = Map<String, List<Lesson>>.fromEntries(
        result[teacher]!.entries.toList()
          ..sort((a, b) {
            final dayA = a.key.split(' ').first;
            final dayB = b.key.split(' ').first;
            final ia = dayOrder.indexOf(dayA);
            final ib = dayOrder.indexOf(dayB);
            return ia.compareTo(ib);
          }),
      );
    }

    return result[teacherName];
  }

  void _addLesson(Map<String, Map<String, List<Lesson>>> result, String teacher, Lesson lesson, String day) {
    result.putIfAbsent(teacher, () => {});
    result[teacher]!.putIfAbsent(day, () => []);
    result[teacher]![day]!.add(lesson);
  }

  /// Возвращает map с ключами 'numerator','denominator','default' - значения nullable String
  Map<String, String?> _extractByType(Element td) {
    String? numerator;
    String? denominator;
    String? def;

    final numEl = td.querySelector('.label-danger');
    final denEl = td.querySelector('.label-info');

    if (numEl != null) numerator = _normalizeText(numEl.text);
    if (denEl != null) denominator = _normalizeText(denEl.text);

    // если нет специальных блоков, берем общий текст (trim)
    if (numerator == null && denominator == null) {
      final full = td.text.trim();
      if (full.isNotEmpty) def = _normalizeText(full);
    }

    return {
      'numerator': numerator,
      'denominator': denominator,
      'default': def,
    };
  }

  bool _hasText(String? s) => s != null && s.trim().isNotEmpty;

  List<String> _splitTeachers(String s) {
    return s.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
  }

  String _normalizeText(String s) {
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Правильное извлечение день недели + локация из <h4>
  (String, String) _extractDayAndLocation(Element h4) {
    String day = "";
    String? location;

    for (var node in h4.nodes) {
      if (node.nodeType == Node.TEXT_NODE) {
        final text = node.text!.trim();
        if (text.isNotEmpty) {
          day = text;
        }
      }

      if (node is Element && node.localName == 'span') {
        final loc = node.text.trim();
        if (loc.isNotEmpty) location = loc;
      }
    }

    location ??= "Дистанционно";
    return (day, location);
  }
}

class ScheduleGroupParser {
  /// Регулярное выражение для извлечения времени из текста
  static final RegExp _timePattern = RegExp(
    r'(\d{1,2}:\d{2})\s*[-–]\s*(\d{1,2}:\d{2})',
  );

  /// Регулярное выражение для извлечения номера пары из текста
  static final RegExp _lessonNumberPattern = RegExp(r'\d+');

  /// Парсит HTML-страницу с расписанием и возвращает структурированные данные
  ///
  /// Метод находит вкладку соответствующей группы в HTML-документе,
  /// извлекает таблицы с расписанием по дням недели и преобразует
  /// их в структурированный формат
  ///
  /// Параметры:
  /// - [html]: HTML-страница с расписанием
  /// - [groupCode]: Код группы для которой нужно получить расписание
  ///
  /// Возвращает:
  /// - Map<String, List<Lesson>>: Расписание, где ключ - день недели, значение - список уроков
  Map<String, List<Lesson>> parseHTML(String html, String groupCode) {
    // Парсим HTML-документ
    final document = html_parser.parse(html);
    // Находим вкладку для указанной группы
    final tabPane = _findTabPaneForGroup(document, groupCode);

    // Если вкладка не найдена, возвращаем пустое расписание
    if (tabPane == null) {
      return {};
    }

    // Создаем карту для хранения расписания по дням недели
    final schedule = <String, List<Lesson>>{};
    // Ищем все таблицы с расписанием в вкладке
    final tables = tabPane.children.where(
      (element) =>
          element.localName == 'table' && element.classes.contains('table'),
    );

    // Проходим по всем таблицам и парсим расписание
    for (final table in tables) {
      // Ищем заголовок таблицы с днем недели
      final header = table.querySelector('thead h4');
      if (header == null) continue;

      // Извлекаем день недели из заголовка
      final day = _extractDay(header);
      if (day.isEmpty) continue;

      // Извлекаем информацию о корпусе из заголовка
      final building = header.querySelector('span')?.text.trim() ?? '';
      // Парсим уроки из таблицы
      final lessons = _parseLessons(table, building);

      // Добавляем уроки в расписание, если они есть
      if (lessons.isNotEmpty) {
        schedule[day] = lessons;
      }
    }

    return schedule;
  }

  /// Находит вкладку для указанной группы в HTML-документе
  ///
  /// Метод ищет вкладку, соответствующую коду группы, в навигационном меню
  /// и возвращает соответствующий элемент tab-pane
  ///
  /// Параметры:
  /// - [document]: HTML-документ
  /// - [groupCode]: Код группы
  ///
  /// Возвращает:
  /// - Element?: Элемент tab-pane для группы или null, если не найден
  Element? _findTabPaneForGroup(Document document, String groupCode) {
    // Нормализуем код группы для поиска
    final normalizedGroupCode = groupCode.trim().toUpperCase();
    
    // Ищем все ссылки на вкладки в навигационном меню (строгий селектор)
    final tabLinks = document.querySelectorAll('ul.nav-tabs > li > a[href^="#"]');
    String? tabId;

    // Пробуем найти точное совпадение кода группы
    for (var link in tabLinks) {
      final text = link.text.trim().toUpperCase();
      if (text == normalizedGroupCode) {
        final href = link.attributes['href'];
        if (href != null && href.startsWith('#')) {
          tabId = href.substring(1);
          break;
        }
      }
    }

    // Если точное совпадение не найдено, ищем частичное совпадение
    if (tabId == null) {
      for (var link in tabLinks) {
        final text = link.text.trim().toUpperCase();
        if (text.contains(normalizedGroupCode) || normalizedGroupCode.contains(text)) {
          final href = link.attributes['href'];
          if (href != null && href.startsWith('#')) {
            tabId = href.substring(1);
            break;
          }
        }
      }
    }

    // Если ID вкладки не найден, возвращаем null
    if (tabId == null || tabId.isEmpty) {
      return null;
    }

    // Возвращаем элемент tab-pane с найденным ID (строгий селектор)
    return document.querySelector('[role="tabpanel"][id="$tabId"]');
  }


  /// Извлекает день недели из заголовка таблицы
  ///
  /// Метод извлекает текст дня недели из заголовка таблицы,
  /// преобразуя его в верхний регистр
  ///
  /// Параметры:
  /// - [header]: Заголовок таблицы
  ///
  /// Возвращает:
  /// - String: День недели в верхнем регистре
  String _extractDay(Element header) {
    // Пробуем извлечь текст из первого дочернего элемента
    final primaryText = header.nodes.isNotEmpty
        ? header.nodes.first.text?.trim() ?? ''
        : '';

    // Если текст найден, возвращаем его в верхнем регистре
    if (primaryText.isNotEmpty) {
      return primaryText.toUpperCase();
    }

    // В противном случае, извлекаем текст из заголовка и берем первое слово
    final fallback = header.text.trim();
    if (fallback.isEmpty) return '';

    return fallback.split(' ').first.toUpperCase();
  }

  /// Парсит уроки из таблицы
  ///
  /// Метод извлекает строки с уроками из таблицы и преобразует
  /// их в список объектов Lesson
  ///
  /// Параметры:
  /// - [table]: Таблица с расписанием
  /// - [building]: Корпус (извлекается из заголовка таблицы)
  ///
  /// Возвращает:
  /// - List<Lesson>: Список уроков
  List<Lesson> _parseLessons(Element table, String building) {
    // Создаем список для хранения уроков
    final lessons = <Lesson>[];
    // Извлекаем строки с уроками из таблицы
    final rows = _collectLessonRows(table);

    // Проходим по всем строкам и парсим уроки
    for (final row in rows) {
      lessons.addAll(_parseLessonRow(row, building));
    }

    return lessons;
  }

  /// Извлекает строки с уроками из таблицы
  ///
  /// Метод извлекает все строки из таблицы, пропуская
  /// первую (заголовок) и последнюю (пустую) строки
  ///
  /// Параметры:
  /// - [table]: Таблица с расписанием
  ///
  /// Возвращает:
  /// - List<Element>: Список строк с уроками
  List<Element> _collectLessonRows(Element table) {
    // Извлекаем все строки из таблицы
    final rows = table.getElementsByTagName('tr');
    // Если строк меньше или равно 2, возвращаем пустой список
    if (rows.length <= 2) return <Element>[];
    // Возвращаем строки, исключая первую и последнюю
    return rows.sublist(1, rows.length - 1);
  }

  /// Парсит строку с уроком
  ///
  /// Метод извлекает данные об уроке из строки таблицы
  /// и создает соответствующий объект Lesson
  ///
  /// Параметры:
  /// - [row]: Строка таблицы с уроком
  /// - [building]: Корпус
  ///
  /// Возвращает:
  /// - List<Lesson>: Список уроков (может содержать несколько для числителя/знаменателя)
  List<Lesson> _parseLessonRow(Element row, String building) {
    // Извлекаем ячейки из строки
    final cells = row.querySelectorAll('td');
    // Если ячеек не 3, возвращаем пустой список
    if (cells.length != 3) return <Lesson>[];

    // Извлекаем текст из первой ячейки (номер пары и время)
    final numberCellText = cells[0].text;
    // Извлекаем номер пары
    final number = _extractLessonNumber(numberCellText);
    // Извлекаем время начала и окончания
    final times = _parseTimeRange(numberCellText);

    // Если номер пары пустой, возвращаем пустой список
    if (number.isEmpty) return <Lesson>[];

    // Извлекаем ячейки с предметом и преподавателем
    final subjectCell = cells[1];
    final teacherCell = cells[2];

    // Ищем элементы с метками предметов и преподавателей (для числителя/знаменателя)
    final subjectLabels = subjectCell.querySelectorAll('div.label');
    final teacherLabels = teacherCell.querySelectorAll('div.label');

    // Если меток нет, парсим как обычный урок
    if (subjectLabels.isEmpty || teacherLabels.isEmpty) {
      final subject = subjectCell.text.trim();
      // Если предмет пустой, возвращаем пустой список
      if (subject.isEmpty) return <Lesson>[];

      // Создаем и возвращаем обычный урок
      return [
        Lesson(
          number: number,
          subject: subject,
          teacher: teacherCell.text.trim(),
          startTime: times.$1,
          endTime: times.$2,
          building: building,
          lessonType: null,
        ),
      ];
    }

    // Если есть метки, парсим как уроки с числителем/знаменателем
    final lessons = <Lesson>[];
    // Определяем количество пар меток
    final count = _pairedLabelsCount(subjectLabels, teacherLabels);

    // Проходим по всем парам меток
    for (var i = 0; i < count; i++) {
      final subjectText = subjectLabels[i].text.trim();
      // Если предмет пустой, пропускаем
      if (subjectText.isEmpty) continue;

      // Добавляем урок в список
      lessons.add(
        Lesson(
          number: number,
          subject: subjectText,
          teacher: teacherLabels[i].text.trim(),
          startTime: times.$1,
          endTime: times.$2,
          building: building,
          lessonType: _resolveLessonType(subjectLabels[i]),
        ),
      );
    }

    return lessons;
  }

  /// Извлекает номер пары из текста
  ///
  /// Метод извлекает номер пары из текста первой ячейки строки
  /// с помощью регулярного выражения
  ///
  /// Параметры:
  /// - [text]: Текст первой ячейки строки
  ///
  /// Возвращает:
  /// - String: Номер пары
  String _extractLessonNumber(String text) {
    // Ищем номер пары с помощью регулярного выражения
    final match = _lessonNumberPattern.firstMatch(text);
    // Возвращаем найденный номер или текст без пробелов
    return match?.group(0) ?? text.trim();
  }

  /// Извлекает время начала и окончания пары из текста
  ///
  /// Метод извлекает время начала и окончания пары из текста
  /// первой ячейки строки с помощью регулярного выражения
  ///
  /// Параметры:
  /// - [text]: Текст первой ячейки строки
  ///
  /// Возвращает:
  /// - (String, String): Кортеж из времени начала и окончания
  (String, String) _parseTimeRange(String text) {
    // Ищем время с помощью регулярного выражения
    final match = _timePattern.firstMatch(text);
    // Если не найдено, возвращаем пустые строки
    if (match == null) return ('', '');

    // Возвращаем время начала и окончания
    return (match.group(1)!, match.group(2)!);
  }

  /// Определяет тип пары (числитель/знаменатель) по метке
  ///
  /// Метод определяет тип пары по CSS-классам метки
  ///
  /// Параметры:
  /// - [label]: Элемент метки
  ///
  /// Возвращает:
  /// - String?: Тип пары ('numerator', 'denominator' или null)
  String? _resolveLessonType(Element label) {
    // Извлекаем CSS-классы метки
    final classes = label.attributes['class'] ?? '';
    // Определяем тип по классам
    if (classes.contains('label-danger')) return 'numerator';
    if (classes.contains('label-info')) return 'denominator';
    return null;
  }

  /// Определяет количество пар меток предметов и преподавателей
  ///
  /// Метод возвращает минимальное количество из двух списков меток
  ///
  /// Параметры:
  /// - [subjects]: Список меток предметов
  /// - [teachers]: Список меток преподавателей
  ///
  /// Возвращает:
  /// - int: Количество пар меток
  int _pairedLabelsCount(List<Element> subjects, List<Element> teachers) {
    // Если один из списков пуст, возвращаем 0
    if (subjects.isEmpty || teachers.isEmpty) return 0;
    // Возвращаем минимальное количество из двух списков
    return min(subjects.length, teachers.length);
  }
}