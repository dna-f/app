import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

typedef StreamCommandCallback<T, R> = Future<R> Function(T input);

abstract class StreamCommand<T, R> {
  /// input stream sink (receives commands)
  Sink<T> get input => _inputController.sink;
  final _inputController = StreamController<T>();
  StreamSubscription _inputSubscription;

  /// output stream (returns data)
  Stream<R> get output => _outputSubject.stream;
  final _outputSubject = BehaviorSubject<R>();

  final bool processingStreamEnabled;

  Stream<bool> get processing => _processingSubject?.stream;
  BehaviorSubject<bool> _processingSubject;

  final StreamCommandCallback<T, R> handler;

  StreamCommand({
    @required this.handler,
    this.processingStreamEnabled,
  }) : assert(handler != null) {
    if (processingStreamEnabled == true) {
      _processingSubject = BehaviorSubject<bool>.seeded(false);
    }

    _inputSubscription = _inputController.stream.listen((_) async {
      try {
        _processingSubject?.add(true);

        final out = await handler(_);
        _outputSubject.add(out);
      } catch (e) {
        _outputSubject.addError(e);
      } finally {
        _processingSubject?.add(false);
      }
    });
  }

  void dispose() {
    _inputSubscription?.cancel();
    _processingSubject?.close();
    _outputSubject?.close();
  }

  void execute({T input}) {
    _inputController.sink.add(input);
  }
}

class StreamCommandPassThrough<T> extends StreamCommand<T, T> {
  StreamCommandPassThrough({StreamCommandCallback<T, T> handler, bool processingStreamEnabled})
      : super(
          handler: handler ??
              (T input) async {
                return input;
              },
          processingStreamEnabled: processingStreamEnabled,
        );
}
