import 'package:flutter/material.dart';

import '../global.dart';

//空图片占位
class ImagePlaceHolder extends StatelessWidget {
  final double height;
  final double width;
  final bool error;

  const ImagePlaceHolder(
      {super.key, this.height = 400, this.width = 400, required this.error});
  // const ImagePlaceHolder(
  //     { this.height = 400, this.width = 400, this.error = false})
  //     : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).dividerColor.withOpacity(0.02),
      shape: Border.all(
          color: Theme.of(context).dividerColor, width: Global.lineSize),
      child: Container(
        height: height,
        width: width,
        padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(error ? Icons.broken_image : Icons.image,
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    size: 64),
                Text(
                  "封面缺失",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
