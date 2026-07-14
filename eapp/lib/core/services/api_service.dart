import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../utils/constants.dart';
import 'storage_service.dart';

class ApiService extends GetxService {
  late final StorageService _storage;

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<StorageService>();
  }

  Map<String, String> _getHeaders() {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final String? token = _storage.read(Constants.tokenKey);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${Constants.apiBaseUrl}$endpoint');
    return await http.get(url, headers: _getHeaders());
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${Constants.apiBaseUrl}$endpoint');
    return await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${Constants.apiBaseUrl}$endpoint');
    return await http.put(
      url,
      headers: _getHeaders(),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('${Constants.apiBaseUrl}$endpoint');
    return await http.delete(url, headers: _getHeaders());
  }

  Future<http.Response> uploadFile(String endpoint, String filePath) async {
    final url = Uri.parse('${Constants.apiBaseUrl}$endpoint');
    final request = http.MultipartRequest('POST', url);
    
    // Get headers and remove application/json Content-Type so the request boundary is correctly auto-generated
    final Map<String, String> headers = _getHeaders();
    headers.remove('Content-Type');
    request.headers.addAll(headers);
    
    request.files.add(await http.MultipartFile.fromPath('image', filePath));
    
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
