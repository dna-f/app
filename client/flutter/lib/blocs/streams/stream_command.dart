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

  int _processingCounter = 0;

  Stream<bool> get processing => _processingSubject.stream.distinct();
  BehaviorSubject<bool> _processingSubject;

  final bool enqueueLastRequestOnExecuting;
  T _pendingRequest;

  final StreamCommandCallback<T, R> handler;

  StreamCommand({
    @required this.handler,
    this.enqueueLastRequestOnExecuting = true,
  }) : assert(handler != null) {
    _processingSubject = BehaviorSubject<bool>.seeded(false);

    _inputSubscription = _inputController.stream.listen((arg) async {
      final canExecute = _processingCounter == 0 || enqueueLastRequestOnExecuting != true;

      if (canExecute) {
        try {
          //          print('• executing request $arg');

          _processingCounter++;
          _processingSubject?.add(true);

          // TEST delay for enqueuing requests
          //          await Future.delayed(Duration(seconds: 2));

          final out = await handler(arg);
          _outputSubject.add(out);
        } catch (e) {
          _outputSubject.addError(e);
        } finally {
          _processingCounter--;
          final stillProcessing = _processingCounter > 0;

          _processingSubject?.add(stillProcessing);

          if (!stillProcessing) {
            final pendingRequest = _pendingRequest;
            if (pendingRequest != null) {
              _pendingRequest = null;
              execute(input: pendingRequest);
            }
          }
        }
      } else {
        //        print('• enqueue request $arg');
        _pendingRequest = arg;
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
  StreamCommandPassThrough({StreamCommandCallback<T, T> handler, bool enqueueLastRequestOnExecuting = true})
      : super(
          handler: handler ??
              (T input) async {
                return input;
              },
          enqueueLastRequestOnExecuting: enqueueLastRequestOnExecuting,
        );
}
