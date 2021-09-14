import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:dio/dio.dart';
import 'package:image_memory/src/utils/utils.dart';
import 'image_state.dart';

class DownloadImageIsolateModel {
  final String url;
  final String storagePath;
  final SendPort sendPort;

  DownloadImageIsolateModel({
    this.url,
    this.storagePath,
    this.sendPort
  });
}

class ImageCubit extends Cubit<ImageState> {

  ReceivePort receivePort = ReceivePort();

  ImageCubit() : super(ImageState(
    type: ImageType.ImageUnload,
    url: null,
    width: 0,
    height: 0,
    counter: 0,
    imageBytes: null
  ));

  void getImageDataNormal(String url, double width, double height) async {
    // cache image first
    var storagePath = await cacheDirectory();
    File imageFile = File(storagePath + "/" + url);

    if (imageFile.existsSync()) {
      var imageEvict = new FileImage(imageFile)
        ..resolve(new ImageConfiguration())
        .addListener(new ImageStreamListener((ImageInfo image, bool _) {
          if (state.type == ImageType.ImageUnload) { 
            emit(ImageState(
              type: ImageType.ImageLoaded,
              url: url,
              imageBytes: imageFile.readAsBytesSync(),
              width: image.image.width.toDouble(),
              height: image.image.height.toDouble(),
              // counter: _counter++
            ));
          }
        }));
      
      // release memory
      imageEvict.evict();
    } else {
      _downloadImage(url, storagePath);
    }
  }

  void getImageData(String url, double width, double height) async {
    var storagePath = await platformDirectory();
    try {
      var task = await FlutterDownloader.loadTasksWithRawQuery(query: "SELECT * FROM task WHERE url = '$url' and status = 3");

      if (task.length > 0) {
        File imageFile = File("$storagePath/${task[0].filename}");

        var imageEvict = new FileImage(imageFile)
            ..resolve(new ImageConfiguration())
            .addListener(new ImageStreamListener((ImageInfo image, bool _) {
              if (state.type == ImageType.ImageUnload) { 
                emit(ImageState(
                  type: ImageType.ImageLoaded,
                  url: url,
                  imageBytes: imageFile.readAsBytesSync(),
                  width: image.image.width * (width * 100 / (image.image.width)) / 100,
                  height: image.image.height * (width * 100 / (image.image.width)) / 100,
                  // counter: _counter++
                ));
              }
            }));
        
        // release memory
        imageEvict.evict();
      } else {
        var response = await Dio().get(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
        var imageEvict = new MemoryImage(Uint8List.fromList(response.data))
            ..resolve(new ImageConfiguration())
            .addListener(new ImageStreamListener((ImageInfo image, bool _) {
              print("mantep image width: ${image.image.width} height ${image.image.height}");
              if (state.type == ImageType.ImageUnload) {
                emit(ImageState(
                  type: ImageType.ImageLoaded,
                  url: url,
                  imageBytes: Uint8List.fromList(response.data),
                  width: image.image.width * (width * 100 / (image.image.width)) / 100,
                  height: image.image.height * (width * 100 / (image.image.width)) / 100,
                  // counter: _counter++
                ));
              }
            }));

        // release memory
        imageEvict.evict();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _downloadImage(String url, String storagePath) async {
    DownloadImageIsolateModel params = new DownloadImageIsolateModel(
      url: url,
      storagePath: storagePath,
      sendPort: receivePort.sendPort
    );
    await Isolate.spawn(downloadImageIsolate, params);   
    receivePort.listen((data) { 
      File imageFile = File(data);
      var imageEvict = new FileImage(imageFile)
        ..resolve(new ImageConfiguration())
        .addListener(new ImageStreamListener((ImageInfo image, bool _) {
          if (state.type == ImageType.ImageUnload) { 
            emit(ImageState(
              type: ImageType.ImageLoaded,
              url: url,
              imageBytes: imageFile.readAsBytesSync(),
              width: image.image.width.toDouble(),
              height: image.image.height.toDouble(),
              // counter: _counter++
            ));
          }
        }));

      // release memory
      imageEvict.evict();
    });
  }

  static downloadImageIsolate(DownloadImageIsolateModel params) async {
    await Dio().download(
      params.url, 
      params.storagePath + "/" + params.url
    );
    params.sendPort.send(params.storagePath + "/" + params.url);
  }
  
}