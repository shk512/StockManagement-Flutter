
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> openMap(var lat, var lng)async{
  final api="AIzaSyAuHsvn7EEzAG910tx3OLbQ0BAlHYcv4IE";
  String googleUrl="https://maps.google.com/maps/search/?api=1&query=$lat,$lng";
  if (await canLaunchUrlString(googleUrl)) {
    await launchUrlString(googleUrl);
  } else {
    throw 'Could not open the map.';
  }
}