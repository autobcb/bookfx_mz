import 'package:flutter/material.dart';

class BookController extends ChangeNotifier {
  int nextType = 0;
  int currentIndex = 0; // 当前页
  int goToIndex = 0; // 跳转页
  bool canlast = true;
  bool cannext = true;

  /// 上一页
  void last() {
    if(!canlast){
      return;
    }
    nextType = -1;
    notifyListeners();
  }

  /// 下一页
  void next() {
    if(!cannext){
      return;
    }
    nextType = 1;
    notifyListeners();
  }

  /// 跳页
  void goTo(int index) {
    nextType = 0;
    goToIndex = index;
    notifyListeners();
  }
}
