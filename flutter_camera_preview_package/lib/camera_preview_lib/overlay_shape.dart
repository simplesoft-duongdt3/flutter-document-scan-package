import 'package:flutter/material.dart';

class OverlayShape extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const OverlayShape({
    Key? key,
    required this.width,
    required this.height,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
            alignment: Alignment.center,
            child: Container(
              width: width,
              height: height,
              decoration: ShapeDecoration(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: borderRadius,
                      side: const BorderSide(width: 1, color: Colors.white))),
            )),
        ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcOut),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: borderRadius,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
