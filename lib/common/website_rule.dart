import 'dart:io';

String? websiteRuleDomain(String input) {
  final value = input.trim();
  if (value.isEmpty || RegExp(r'\s').hasMatch(value)) {
    return null;
  }
  try {
    final uri = Uri.parse(
      value.startsWith('//')
          ? 'https:$value'
          : value.contains('://')
          ? value
          : 'https://$value',
    );
    if (!{'http', 'https'}.contains(uri.scheme) ||
        uri.userInfo.isNotEmpty ||
        (uri.hasPort && (uri.port < 1 || uri.port > 65535))) {
      return null;
    }
    final host = uri.host.toLowerCase().replaceFirst(RegExp(r'\.$'), '');
    if (host.length > 253 ||
        InternetAddress.tryParse(host) != null ||
        RegExp(r'^[0-9.]+$').hasMatch(host)) {
      return null;
    }
    final labels = host.split('.');
    final labelPattern = RegExp(r'^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$');
    if (labels.length < 2 || !labels.every(labelPattern.hasMatch)) {
      return null;
    }
    return host;
  } on FormatException {
    return null;
  }
}
