import 'dart:convert';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

class CustomAssetLoader extends AssetLoader {
  const CustomAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    try {
      // Xác định tên file dựa trên locale
      String fileName;
      if (locale.languageCode == 'zh') {
        // Đối với tiếng Trung, sử dụng mã vùng để phân biệt giản thể/phồn thể
        fileName = '${locale.languageCode}_${locale.countryCode}.json';
      } else {
        // Đối với các ngôn ngữ khác, chỉ sử dụng mã ngôn ngữ
        fileName = '${locale.languageCode}.json';
      }

      final String jsonString = await rootBundle.loadString('$path/$fileName');
      return jsonDecode(jsonString);
    } catch (e) {
      // Nếu không tìm thấy file, fallback sang tiếng Anh
      if (locale.languageCode != 'en') {
        final String jsonString = await rootBundle.loadString('$path/en.json');
        return jsonDecode(jsonString);
      }
      rethrow;
    }
  }
}