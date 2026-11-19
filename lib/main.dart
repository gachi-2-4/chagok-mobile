import 'package:chagok_mobile/app/app.dart';
import 'package:chagok_mobile/app/font_licenses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  registerFontLicenses();
  runApp(const ProviderScope(child: ChagokApp()));
}
