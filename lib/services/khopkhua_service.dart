// lib/services/khopkhua_service.dart
// ====================================
// ສົ່ງຂໍ້ມູນຊັບໄປ n8n → Claude ຂຽນໂພສ
// ====================================
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class KhopkhuaService {
  static const _webhookUrl =
      'https://n8n-production-f688.up.railway.app/webhook/khopkhua-post';

  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  // ສ້າງໂພສຂາຍຊັບ (ສົ່ງໄປ Claude)
  static Future<String> generatePost({
    required String propType,    // ປະເພດຊັບ
    required String location,    // ທີ່ຕັ້ງ
    required String area,        // ເນື້ອທີ່
    required String price,       // ລາຄາ
    required String phone,       // ເບີຕິດຕໍ່
    String? documents,
    String? highlights,
    String? utilities,
    String? nearby,
    String? access,
  }) async {
    // ສ້າງ property_info string ລວມຂໍ້ມູນ
    final info = StringBuffer();
    info.writeln('ປະເພດຊັບ: $propType');
    info.writeln('ທີ່ຕັ້ງ: $location');
    info.writeln('ເນື້ອທີ່: $area');
    info.writeln('ລາຄາ: $price');
    info.writeln('ເບີຕິດຕໍ່: $phone');
    if (documents != null && documents.isNotEmpty)
      info.writeln('ເອກະສານ: $documents');
    if (utilities != null && utilities.isNotEmpty)
      info.writeln('ໄຟຟ້າ-ນ້ຳ: $utilities');
    if (nearby != null && nearby.isNotEmpty)
      info.writeln('ສະຖານທີ່ໃກ້ຄຽງ: $nearby');
    if (access != null && access.isNotEmpty)
      info.writeln('ທາງເຂົ້າ: $access');
    if (highlights != null && highlights.isNotEmpty)
      info.writeln('ຈຸດເດັ່ນ: $highlights');

    try {
      final res = await _dio.post(
        _webhookUrl,
        data: {'property_info': info.toString()},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      // ດຶງ text ຈາກ response ຂອງ Claude
      final data = res.data;
      if (data is Map) {
        // n8n ສົ່ງກັບ {content:[{type:"text",text:"..."}]}
        final content = data['content'];
        if (content is List && content.isNotEmpty) {
          return content.first['text'] as String? ?? data.toString();
        }
        // ຫລື text ໂດຍກົງ
        if (data['text'] != null) return data['text'] as String;
        if (data['output'] != null) return data['output'] as String;
      }
      return data.toString();
    } on DioException catch (e) {
      throw Exception('ສົ່ງຂໍ້ມູນບໍ່ສຳເລັດ: ${e.message}');
    }
  }
}
