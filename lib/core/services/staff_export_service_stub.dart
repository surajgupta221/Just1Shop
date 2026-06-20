import 'package:flutter/services.dart';

Future<String> exportStaffCsv({
  required String csv,
  required String filename,
}) async {
  await Clipboard.setData(ClipboardData(text: csv));
  return 'Excel-ready staff sheet copied. Paste it into Excel or Google Sheets.';
}
