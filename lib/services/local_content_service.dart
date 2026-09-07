import 'dart:convert';
import 'package:flutter/services.dart';

class LocalContentService {
  static const writingFiles = <String>[
    'paragraphs.json',
    'compositions.json',
    'stories.json',
    'completing_stories.json',
    'dialogues.json',
    'letters_applications.json',
    'emails.json',
    'reports.json',
    'cv_job.json',
  ];

  static Future<List<dynamic>> loadList(String fileName) async {
    final raw = await rootBundle.loadString('assets/data/$fileName');
    final data = jsonDecode(raw);
    if (data is List) return data;
    throw FormatException('$fileName must contain a JSON list');
  }

  static Future<List<dynamic>> loadWritingCategories() =>
      loadList('writing_categories.json');

  static Future<List<dynamic>> loadGrammar() => loadList('grammar.json');
  static Future<List<dynamic>> loadVocabulary() => loadList('vocabulary.json');
  static Future<List<dynamic>> loadTranslation() => loadList('translation.json');
  static Future<List<dynamic>> loadPractice() => loadList('practice.json');

  static Map<String, dynamic> normalize(
    Map<String, dynamic> raw,
    String sourceFile,
  ) {
    if (sourceFile == 'grammar.json') {
      return {
        ...raw,
        'title_bn': raw['title_bn'] ?? raw['title_en'],
        'content': raw['lesson'] ?? '',
        'preview': raw['lesson'] ?? '',
        'source_file': sourceFile,
      };
    }
    if (sourceFile == 'vocabulary.json') {
      return {
        ...raw,
        'title_en': raw['word'],
        'title_bn': raw['meaning_bn'],
        'content':
            '${raw['word']} = ${raw['meaning_bn']}\n\nExample: ${raw['example']}',
        'preview': raw['example'],
        'bangla_explanation': raw['meaning_bn'],
        'source_file': sourceFile,
      };
    }
    if (sourceFile == 'translation.json') {
      return {
        ...raw,
        'title_en': raw['english'],
        'title_bn': raw['bangla'],
        'content': 'Bangla: ${raw['bangla']}\n\nEnglish: ${raw['english']}',
        'preview': raw['bangla'],
        'bangla_explanation': '',
        'source_file': sourceFile,
      };
    }
    return {...raw, 'source_file': sourceFile};
  }

  static Future<List<Map<String, dynamic>>> loadNormalized(String fileName) async {
    final raw = await loadList(fileName);
    return raw
        .map((e) => normalize(Map<String, dynamic>.from(e), fileName))
        .toList();
  }

  static Future<Map<String, Map<String, dynamic>>> loadContentIndex() async {
    final files = <String>[
      ...writingFiles,
      'grammar.json',
      'vocabulary.json',
      'translation.json',
    ];
    final index = <String, Map<String, dynamic>>{};
    for (final file in files) {
      final items = await loadNormalized(file);
      for (final item in items) {
        index['${item['id']}'] = item;
      }
    }
    return index;
  }
}
