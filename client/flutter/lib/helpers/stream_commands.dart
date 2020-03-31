import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

abstract class StreamCommand<T, R> {
  /// input stream sink (receives commands)
  Sink<T> get input => _inputController.sink;
  final _inputController = StreamController<T>();
  StreamSubscription _inputSubscription;

  /// output stream (returns data)
  Stream<R> get output => _outputSubject.stream;
  final _outputSubject = BehaviorSubject<R>();

  Stream<bool> get processing => _processingSubject.stream;
  final _processingSubject = BehaviorSubject<bool>.seeded(false);

  bool _canRun = true;

  StreamCommand() {
    _inputSubscription = _inputController.stream.listen((_) async {
      if (_canRun) {
        try {
          _processingSubject.add(true);

          final out = await _run(_);
          _outputSubject.add(out);
        } catch (e) {
          _outputSubject.addError(e);
        } finally {
          _processingSubject.add(false);
        }
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

  Future<R> _run(T input);
}

class StreamCommandPassThrough<T> extends StreamCommand<T, T> {
  @override
  Future<T> _run(T input) async {
    return input;
  }
}

class StreamCommandDebounce extends StreamCommandPassThrough<void> {
  /// debounce milliseconds
  final int debounce;

  /// callback on output stream results
  final VoidCallback callback;

  /// time to wait before receiving processing other commands, after callback calls
  final int thenWait;

  StreamSubscription<void> _outputSubscription;
  StreamSubscription<void> _waitSubscription;

  StreamCommandDebounce({
    @required this.debounce,
    @required this.callback,
    @required this.thenWait,
  })  : assert(debounce > 0),
        assert(callback != null),
        assert(thenWait >= 0) {
    final outputStream = output.debounceTime(Duration(milliseconds: debounce));
    final waitStream = thenWait > 0 ? outputStream.debounceTime(Duration(milliseconds: thenWait)) : null;

    _outputSubscription = outputStream.listen((_) {
      if (_waitSubscription != null) {
        _canRun = false;
      }

      callback();
    });

    if (waitStream != null) {
      _waitSubscription = waitStream.listen((_) {
        _canRun = true;
      });
    }
  }

  @override
  void dispose() {
    _outputSubscription?.cancel();
    _waitSubscription?.cancel();

    super.dispose();
  }
}