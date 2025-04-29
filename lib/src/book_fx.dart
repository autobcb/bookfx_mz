import 'dart:math';
import 'package:bookfx_mz/src/book_painter.dart';
import 'package:bookfx_mz/src/current_paper.dart';
import 'package:bookfx_mz/src/model/paper_point.dart';
import 'package:flutter/material.dart';

import 'book_controller.dart';

/// 作者： lixp
/// 创建时间： 2022/8/1 16:05
/// 类介绍：模拟书籍翻页效果
class BookFx extends StatefulWidget {
  /// 翻页时长
  final Duration? duration;

  /// 书籍区域
  final Size size;

  /// 一般情况页面布局是固定的 变化的是布局当中的内容
  /// 不过若是页面之间有布局不同时，须同时更新布局
  /// 当前页布局
  /// [index] 当前页码
  final Widget Function(int index) currentPage;

  /// 下一页布局
  /// [index] 下一页页码
  final Widget Function(int index) nextPage;

  /// 当前翻页的背面色值
  final Color? currentBgColor;

  /// 书籍页数
  final int pageCount;

  /// 下一页回调
  final Function(int index)? nextCallBack;

  /// 上一页回调
  final Function(int index)? lastCallBack;

  final Function()? nextwarnCallBack;
  final Function()? lastwarnCallBack;

  final BookController controller;

  const BookFx({
    this.duration,
    required this.size,
    required this.currentPage,
    required this.nextPage,
    this.currentBgColor,
    this.pageCount = 10000,
    this.nextCallBack,
    this.lastCallBack,
    this.nextwarnCallBack,
    this.lastwarnCallBack,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  _BookFxState createState() => _BookFxState();
}

class _BookFxState extends State<BookFx> with SingleTickerProviderStateMixin {
  late Size size = widget.size;
  late Offset downPos;
  Point<double> currentA = const Point(0, 0);

  AnimationController? _controller;

  // 控制点类
  late final ValueNotifier<PaperPoint> _p;

  @override
  void initState() {
    super.initState();

    // 修改初始化位置，确保是有效值
    _p = ValueNotifier(
        PaperPoint(
            Point(widget.size.width, widget.size.height),
            widget.size
        )
    );

    _controller = AnimationController(
        vsync: this,
        duration: widget.duration ?? const Duration(milliseconds: 300)
    );

    _controller?.addListener(() {
      if (_type == 1) {
        /// 翻页
        _p.value = PaperPoint(
            Point(currentA.x - (currentA.x + size.width) * _controller!.value,
                currentA.y + (size.height - currentA.y) * _controller!.value),
            size);
      } else {
        /// 不翻页 回到原始位置
        _p.value = PaperPoint(
            Point(
              currentA.x + (size.width - currentA.x) * _controller!.value,
              currentA.y + (size.height - currentA.y) * _controller!.value,
            ),
            size);
      }
    });
    _controller?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_type == 1) {
          isAlPath = true;
          widget.controller.currentIndex++;
        }else{
          isAlPath = true;
          widget.controller.currentIndex--;
        }
        setState(() {
          _type = 0;
          isAnimation = false;
        });

        widget.nextCallBack?.call(widget.controller.currentIndex);
      }
      if (status == AnimationStatus.dismissed) {
        //起点停止
        // print("起点停止");
      }
    });

    // build完毕初始化首页
    // 当前页码
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _p.value = PaperPoint(Point(size.width, size.height), size);
    });
    widget.controller.addListener(() {
      if (isAnimation == true) {
        // 翻页动画正在执行
        return;
      }
      if (widget.controller.nextType == 1) {
        /// 下一页
        /// 当前页currentIndex是角标索引 0开始 页码是从 1开始的
        if (widget.controller.currentIndex >= widget.pageCount - 1) {
          //最后一页了
          widget.nextCallBack?.call(widget.pageCount);
          return;
        }
        next();
      } else if (widget.controller.nextType == -1) {
        /// 上一页
        if (widget.controller.currentIndex != 0) {
          last();
          return;
        } else {
          // 首页了
          widget.lastCallBack?.call(widget.controller.currentIndex);
        }
      } else if (widget.controller.nextType == 0) {
        // 跳页
        // 当前页 = 跳转页  || 当前页<0 || 当前页>页码
        if (widget.controller.currentIndex == widget.controller.goToIndex - 1 ||
            widget.controller.goToIndex < 0 ||
            widget.controller.goToIndex > widget.pageCount) {
          return;
        } else {
          setState(() {
            widget.controller.currentIndex = widget.controller.goToIndex - 1;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  int _type = 0; // 是否翻页到下一页
  bool isAlPath = true; //
  bool isAnimation = false; // 是否正在执行翻页

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: LayoutBuilder(builder: (context, dimens){
        return GestureDetector(
          child: Stack(
            children: [
              widget.controller.currentIndex == widget.pageCount - 1
                  ? const SizedBox()
              // 下一页
                  : _type == 2 ?widget.nextPage(widget.controller.currentIndex ):widget.nextPage(widget.controller.currentIndex + 1),
              // // 当前页
              ClipPath(
                child: widget.currentPage(_type == 2 && widget.controller.currentIndex>0 ?widget.controller.currentIndex-1:widget.controller.currentIndex),
                clipper: isAlPath ? null : CurrentPaperClipPath(_p, _type == 1),
              ),


              CustomPaint(
                size: size,
                painter: BookPainter(
                  _p,
                  widget.currentBgColor,
                ),
              ),
            ],
          ),
          onPanDown: (d) {
            downPos = d.localPosition;
          },
          onPanUpdate: (d) {
            if (isAnimation) {
              return;
            }
            if(_type == 0){
              if(downPos.dx > d.localPosition.dx){
                setState(() {
                  _type=1;
                });
              }else{
                setState(() {
                  _type=2;
                });
              }
            }

            if(_type == 1){
              if(!widget.controller.cannext ||  widget.controller.currentIndex >= widget.pageCount - 1){
                return;
              }
            }

            if(_type == 2){
              if(!widget.controller.canlast  ||  widget.controller.currentIndex <= 0){
                return;
              }
            }

            var move = d.localPosition;
            // 临界值取消更新
            if (move.dx >= size.width ||
                move.dx < 0 ||
                move.dy >= size.height ||
                move.dy < 0) {
              return;
            }
            if (isAlPath == true) {
              setState(() {
                isAlPath = false;
              });
            }
            if(_type == 1){
              if (downPos.dy > size.height / 3 &&
                  downPos.dy < size.height * 2 / 3) {
                // 横向翻页
                currentA = Point(move.dx, size.height - 1);
                _p.value = PaperPoint(Point(move.dx, size.height - 1), size);
              } else {
                // 右下角翻页
                currentA = Point(move.dx, move.dy);
                _p.value = PaperPoint(Point(move.dx, move.dy), size);
              }
            }else{
              currentA = Point(move.dx, size.height - 1);
              _p.value = PaperPoint(Point(move.dx, size.height - 1), size);
            }
            // currentA = Point(move.dx, size.height - 1);
            // _p.value = PaperPoint(Point(move.dx, size.height - 1), size);

          },
          onPanEnd: (d) {
            if (isAnimation) {
              return;
            }
            print("end");

            if(_type == 1){
              print(d.localPosition.dx / dimens.maxWidth );
              if(d.localPosition.dx / dimens.maxWidth > 0.95){
                _type =0;
                return;
              }
              if(!widget.controller.cannext  ||  widget.controller.currentIndex >= widget.pageCount - 1){
                widget.nextwarnCallBack?.call();
                _type =0;
                return;
              }

            }

            if(_type == 2){
              if(d.localPosition.dx / dimens.maxWidth < 0.5){
                setState(() {
                  _type =0;
                  _p.value= PaperPoint(
                      Point(widget.size.width, widget.size.height),
                      widget.size
                  );
                });
                return;
              }
              if(!widget.controller.canlast  ||  widget.controller.currentIndex <= 0){
                widget.lastwarnCallBack?.call();
                _type =0;
                return;
              }
            }

            /// 手指首次触摸屏幕左侧区域
            if (_type == 2) {
              setState(() {
                isAlPath = false;
                isAnimation = true;
                _controller?.forward(
                  from: 0,
                );
              });
            }else{
              setState(() {
                isAlPath = false;
              });
              isAnimation = true;
              _controller?.forward(
                from: 0,
              );
            }
          },
        );
      })
    );
  }

  void last() {
    setState(() {
      isAlPath = false;
      _type = 2;
      isAnimation = true;
      currentA = Point(-200, size.height - 100);
      _controller?.forward(
        from: 0,
      );
    });
  }

  void next() {
    setState(() {
      isAlPath = false;
      _type = 1;
    });
    isAnimation = true;
    currentA = Point(size.width - 50, size.height - 50);
    _controller?.forward(
      from: 0,
    );
  }
}