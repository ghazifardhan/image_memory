import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> platformDirectory() async {
  if (Platform.isIOS) {
    var path = await getApplicationDocumentsDirectory();
    return path.path;
  } else {
    Directory dir = await getExternalStorageDirectory();
    String localPath = dir.path + Platform.pathSeparator + 'Download';
    final savedDir = Directory(localPath);
    bool isExisted = savedDir.existsSync();

    if (!isExisted) {
      await savedDir.create();
      return savedDir.path;
    } else {
      return savedDir.path;
    } 
  }
}

Future<String> cacheDirectory() async {
  if (Platform.isIOS) {
    var path = await getApplicationDocumentsDirectory();
    return path.path;
  } else {
    Directory dir = await getTemporaryDirectory();
    String localPath = dir.path + Platform.pathSeparator + 'Download';
    final savedDir = Directory(localPath);
    bool isExisted = savedDir.existsSync();

    if (!isExisted) {
      await savedDir.create();
      return savedDir.path;
    } else {
      return savedDir.path;
    } 
  }
}