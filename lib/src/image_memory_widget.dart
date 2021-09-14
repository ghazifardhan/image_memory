import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'cubit/image_cubit.dart';
import 'cubit/image_state.dart';

class ImageMemoryWidget extends StatefulWidget {
  
  final String imageUrl;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final BoxFit fit;

  const ImageMemoryWidget({
    Key key, 
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit,
  }) : super(key: key);
  
  @override
  State<StatefulWidget> createState() => _ImageMemoryWidgetState();

}

class _ImageMemoryWidgetState extends State<ImageMemoryWidget> {
  
  bool isImageReady = false;
  File myImage;
  Directory dir;
  String targetPath = "";
  Uint8List imageData;
  ImageCubit _imageCubit = new ImageCubit();
  
  @override
  void initState() {
    super.initState();
    _imageCubit.getImageDataNormal(widget.imageUrl, widget.width, widget.height);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width == null ? MediaQuery.of(context).size.width : widget.width,
      height: widget.height == null ? 183 : widget.height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0)
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius == null ? BorderRadius.circular(10.0) : widget.borderRadius,
        child: imageWithCubit(),
      ),
    );
  }

  Widget imageWithCubit() {
    return BlocProvider<ImageCubit>(
      create: (context) => _imageCubit,
      child: BlocConsumer<ImageCubit, ImageState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state.type == ImageType.ImageLoaded) {
            return Image.memory(
              state.imageBytes,
              // cacheHeight: state.height ~/ 1.2,
              // cacheWidth: state.width ~/ 1.2,
              width: state.width.toDouble(),
              height: state.height.toDouble(),
              fit: widget.fit != null ? widget.fit : BoxFit.cover,
              filterQuality: FilterQuality.low,
            );
          }
          return Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            ),
          );
        }
      )
    );
  }

}