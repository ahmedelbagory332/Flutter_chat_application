import 'dart:io';


checkConnection()async{
  bool check = false;
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected');
      return check = true;
    }
  } on SocketException catch (_) {
    print('not connected');
    return check = false;

  }
}