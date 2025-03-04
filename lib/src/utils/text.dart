import 'package:flutter/material.dart';

class TextUtil {
  /// 获取文字高度
  static double calculateTextHeight(
    String value,
    double fontSize, {
    required double fontHeight,
    required double maxWidth,
    required EdgeInsetsGeometry padding,
    BuildContext? context,
  }) {
    TextPainter painter = TextPainter(
      // 如果没有提供context,使用默认locale
      locale: context != null 
          ? View.of(context).platformDispatcher.locale
          : const Locale('en', 'US'),
      textDirection: TextDirection.ltr,
      maxLines: 1000,
      strutStyle: StrutStyle(
        forceStrutHeight: true,
        fontSize: fontSize,
        height: fontHeight,
      ),
      text: TextSpan(
        text: value,
        style: TextStyle(
          height: fontHeight,
          fontSize: fontSize,
        ),
      ),
      textAlign: TextAlign.center,
    );
    painter.layout(maxWidth: maxWidth - padding.horizontal);
    return painter.size.height;
  }

  /// 获取最大行文字字数
  static int calculateTextMaxTextPos(
    String value,
    double fontSize, {
    required double fontHeight,
    required double maxWidth,
    required EdgeInsetsGeometry padding,
    int maxLines = 3,
    BuildContext? context,
  }) {
    final TextPainter painter = TextPainter(
      locale: context != null 
          ? View.of(context).platformDispatcher.locale
          : const Locale('en', 'US'),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      strutStyle: StrutStyle(
        forceStrutHeight: true,
        fontSize: fontSize,
        height: fontHeight,
      ),
      text: TextSpan(
        text: value,
        style: TextStyle(
          height: fontHeight,
          fontSize: fontSize,
        ),
      ),
      textAlign: TextAlign.center,
    );
    painter.layout(maxWidth: maxWidth - padding.horizontal);
    final didExceedMaxLines = painter.didExceedMaxLines;
    if (didExceedMaxLines) {
      final position = painter.getPositionForOffset(Offset(
        painter.width,
        painter.height,
      ));
      if (value.substring(position.offset).startsWith('\n')) {
        return position.offset + 2;
      }
      return position.offset;
    }
    return 0;
  }
}
