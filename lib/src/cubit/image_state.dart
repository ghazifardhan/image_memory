import 'dart:typed_data';

enum ImageType {
  ImageUnload,
  ImageLoaded
}

class ImageState {

  final ImageType type;
  final String url;
  final double width;
  final double height;
  final int counter;
  final Uint8List imageBytes;

  ImageState({
    this.type,
    this.url,
    this.width,
    this.height,
    this.counter,
    this.imageBytes,
  });
}