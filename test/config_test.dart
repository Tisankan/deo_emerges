import 'package:flutter_test/flutter_test.dart';
import 'package:deo_emerges/deo_emerges.dart';

void main() {
  group('DeoConfig', () {
    test('should initialize with default values', () {
      final config = DeoConfig();
      
      expect(config.baseUrl, '');
      expect(config.connectTimeout, const Duration(seconds: 30));
      expect(config.receiveTimeout, const Duration(seconds: 30));
      expect(config.sendTimeout, const Duration(seconds: 30));
      expect(config.validateCertificate, false);
      expect(config.certificates, isEmpty);
    });
    
    test('should initialize with custom values', () {
      final config = DeoConfig(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 20),
        validateCertificate: true,
        certificates: ['cert1', 'cert2'],
      );
      
      expect(config.baseUrl, 'https://api.example.com');
      expect(config.connectTimeout, const Duration(seconds: 10));
      expect(config.receiveTimeout, const Duration(seconds: 15));
      expect(config.sendTimeout, const Duration(seconds: 20));
      expect(config.validateCertificate, true);
      expect(config.certificates, ['cert1', 'cert2']);
    });
    
    test('should handle empty baseUrl', () {
      final config = DeoConfig(baseUrl: '');
      expect(config.baseUrl, '');
    });
    
    test('should handle empty certificates', () {
      final config = DeoConfig(certificates: []);
      expect(config.certificates, isEmpty);
    });
  });
}