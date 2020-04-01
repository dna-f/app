import 'dart:async';

import 'package:WHOFlutter/api/user_preferences.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '_interfaces.dart';
import 'stream_command.dart';

/// bloc to handle locale choice
/// You can call localeBloc.setLocale('ru'); to change current locale
class LocaleBloc extends IBloc {
  String _stored;

  String get current => _current;
  String _current;

  final bool enabled;

  StreamCommandPassThrough<String> _localeCommand;
  Stream<String> get stream => _localeCommand.output;

  LocaleBloc({@required this.enabled, String locale}) {
    _localeCommand = StreamCommandPassThrough<String>(handler: _handleLocale, processingStreamEnabled: false);

    if (enabled) {
      // seed the stream even if the value is not changed
      // try to get the last user choice
      _stored = UserPreferences().getLocale();

      _localeCommand.execute(input: locale);
    }
  }

  void setLocale(String locale) {
    _localeCommand?.execute(input: locale);
  }

  @override
  void dispose() {
    _localeCommand.dispose();
  }

  Future<String> _handleLocale(String locale) async {
    if (locale != _current) {
      _current = locale;


      // print('• locale changed to $locale');

      if (locale != _stored) {
        await UserPreferences().setLocale(locale);
        _stored = locale;
      }
    }

    return locale;
  }
}
