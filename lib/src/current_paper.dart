import 'dart:math';
import 'package:bookfx_mz/src/model/paper_point.dart';
import 'package:flutter/material.dart';

/// 当前页区域
class CurrentPaperClipPath extends CustomClipper<Path> {
  final ValueNotifier<PaperPoint> p;
  final bool isNext;

  const CurrentPaperClipPath(this.p, this.isNext) : super(reclip: p);

  @override
  Path getClip(Size size) {
    try {
      Path mPath = Path();
      mPath.addRect(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width,
          height: size.height,
        ),
      );

      // 如果点无效，返回完整区域
      if (!_isValidPoint(p.value.a) || !_isValidPoint(p.value.f)) {
        return mPath;
      }

      // 翻页
      if (p.value.a != p.value.f && p.value.a.x > -size.width) {
        Path mPathA = Path();
        mPathA.moveTo(p.value.c.x, p.value.c.y);
        mPathA.quadraticBezierTo(
          p.value.e.x,
          p.value.e.y,
          p.value.b.x,
          p.value.b.y,
        );
        mPathA.lineTo(p.value.a.x, p.value.a.y);
        mPathA.lineTo(p.value.k.x, p.value.k.y);
        mPathA.quadraticBezierTo(
          p.value.h.x,
          p.value.h.y,
          p.value.j.x,
          p.value.j.y,
        );
        mPathA.lineTo(p.value.f.x, p.value.f.y);
        mPathA.close();

        try {
          Path mPathC = Path.combine(
            PathOperation.reverseDifference,
            mPathA,
            mPath,
          );
          return mPathC;
        } catch (e) {
          debugPrint('Error combining paths11: $e');
          debugPrint(PathOperation.reverseDifference.toString());
          debugPrint(mPathA.toString());
          debugPrint(mPath.toString());
          return mPath;
        }
      }
      return isNext ? Path() : mPath;
    } catch (e) {
      debugPrint('Error in getClip: $e');
      return Path()..addRect(Offset.zero & size);
    }
  }

  bool _isValidPoint(Point<double> point) {
    return !point.x.isNaN && 
           !point.y.isNaN && 
           !point.x.isInfinite && 
           !point.y.isInfinite;
  }

  @override
  bool shouldReclip(covariant CurrentPaperClipPath oldClipper) =>
      p != oldClipper.p;
}
