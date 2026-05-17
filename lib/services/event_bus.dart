import 'dart:async';

class AppEventBus {
  static final AppEventBus _instance = AppEventBus._internal();
  factory AppEventBus() => _instance;
  AppEventBus._internal();

  final _controller = StreamController<dynamic>.broadcast();
  Stream<dynamic> get stream => _controller.stream;

  void emit(dynamic event) => _controller.add(event);
}
