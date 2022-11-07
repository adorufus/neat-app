import 'dart:convert';

import 'package:flutter/material.dart';

void PrettyPrint(dynamic data, {String frontText = ""}) {
  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  String prettyPrint = encoder.convert(data);

  debugPrint(frontText + prettyPrint);
}
