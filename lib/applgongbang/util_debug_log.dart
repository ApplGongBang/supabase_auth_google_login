import 'package:flutter/foundation.dart';

void applGbDebugLog(String str) {
  if (kDebugMode) {
    print('[ApplGb] $str');
  }
}
