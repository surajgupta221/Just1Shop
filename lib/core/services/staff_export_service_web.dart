import 'dart:convert';
import 'dart:html' as html;

Future<String> exportStaffCsv({
  required String csv,
  required String filename,
}) async {
  final bytes = utf8.encode(csv);
  final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();

  html.Url.revokeObjectUrl(url);
  return 'Excel-ready staff sheet downloaded as $filename.';
}
