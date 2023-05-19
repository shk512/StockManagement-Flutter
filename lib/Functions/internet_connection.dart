import 'package:http/http.dart' as http;

Future checkInternetConnection()async{
  try {
    var url = Uri.parse("www.google.com");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return true;
    }
  } catch (e) {
    return e;
  }
}