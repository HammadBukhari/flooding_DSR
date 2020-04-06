import 'dart:convert';

void main() {
  final list = [
    false,
    true,
    false,
    true,
    false,
    true,
  ];
  final json = {
    'list': list,
  };

  String content = jsonEncode(json);
  print(content);
  final secList = jsonDecode(content)['list'];
  print(secList);
}
