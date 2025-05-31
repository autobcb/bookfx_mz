import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:bookfx_mz/bookfx.dart';
import 'package:stack_trace/stack_trace.dart';

void main() {
  // 设置 Flutter 错误处理
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    
    // 格式化错误信息和堆栈跟踪
    final stack = details.stack;
    if (stack != null) {
      // 使用 Trace 来解析堆栈
      final trace = Trace.from(stack);
      final frames = trace.frames;
      
      debugPrint('=== Error ===');
      debugPrint('${details.exception}');
      debugPrint('=== Stack trace ===');
      for (var frame in frames) {
        // 只打印应用代码相关的堆栈（排除框架代码）
        if (frame.library.contains('package:') || frame.library.startsWith('dart:')) {
          debugPrint('${frame.uri}:${frame.line}:${frame.column} - ${frame.member}');
        }
      }
    }
  };

  // 捕获异步错误
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('=== Async Error ===');
    debugPrint('$error');
    
    // 格式化堆栈跟踪
    final trace = Trace.from(stack);
    final frames = trace.frames;
    
    debugPrint('=== Stack trace ===');
    for (var frame in frames) {
      if (frame.library.contains('package:') || frame.library.startsWith('dart:')) {
        debugPrint('${frame.uri}:${frame.line}:${frame.column} - ${frame.member}');
      }
    }
    
    return true;
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookFX Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BookController _bookController = BookController();
  final EBookController _eBookController = EBookController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BookFX Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 500,
              height: 200,
              child: BookFx(
                pageCount: 5,
                currentBgColor: Colors.grey.shade200,
                duration: const Duration(milliseconds: 800),
                currentPage: (index) => Container(
                  color: Colors.white,
                  child: Center(
                    child: SelectableText(
                      'Page ${index + 1}',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                nextPage: (index) => Container(
                  color: Colors.white,
                  child: Center(
                    child: SelectableText(
                      'Page ${index + 1}',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                controller: _bookController,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _bookController.last(),
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _bookController.next(),
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bookController.dispose();
    _eBookController.dispose();
    super.dispose();
  }
}
