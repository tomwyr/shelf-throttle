import 'package:http/http.dart';

void main() async {
  await get(url('hello'));
  await Future.delayed(Duration(seconds: 3));
  await get(url('world'));
}

Uri url(String path) => Uri.parse('http://localhost:8080/$path');
