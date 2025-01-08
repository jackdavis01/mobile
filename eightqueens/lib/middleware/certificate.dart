import 'dart:io';
import 'package:flutter/services.dart';

class CertificatesStorage {
  static List<int> _liCertRailway = [];
  //static List<int> _liCertLocal = [];

  static Future<void> load() async {
    ByteData certRailway = await rootBundle.load('assets/certificates/_.up.railway.app.pem');
    _liCertRailway = certRailway.buffer.asInt8List();
    /*ByteData certLocal = await rootBundle.load('assets/certificates/localhost.crt');
    _liCertLocal = certLocal.buffer.asInt8List();*/
  }

  static List<int> get getCertRailway => _liCertRailway;

  //static List<int> get getCertLocalNotInUse => _liCertLocal;
}

class CertificateSecurityContext {
  static SecurityContext get(List<int> liCert) {
    SecurityContext securityContext = SecurityContext(withTrustedRoots: false);
    securityContext.setTrustedCertificatesBytes(liCert);
    return securityContext;
  }
}
