import 'dart:async';

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '_interfaces.dart';
import 'stream_command.dart';

class LocaleBloc extends IBloc {
  String _stored;

  String get current => _current;
  String _current;

  final SharedPreferences sharedPreferences;
  final bool enabled;

  StreamCommandPassThrough<String> localeCommand;

  LocaleBloc({@required this.sharedPreferences, @required this.enabled, String locale}) {
    localeCommand = StreamCommandPassThrough<String>(handler: _handleLocale, processingStreamEnabled: false);

    if (enabled) {
      // eed the stream even if the value is not changed
      // try to retrive settings from preferences
      _stored = sharedPreferences.getString(KeysSharedPref.LOCALE);

      localeCommand.execute(input: locale);
    }
  }

  @override
  void dispose() {
    localeCommand.dispose();
  }

  Future<String> _handleLocale(String locale) async {
    if (locale != _current) {
      _current = locale;

      // Logging.info('• locale changed to $locale');

      if (locale != _stored) {
        await sharedPreferences.setString(KeysSharedPref.LOCALE, locale);
        _stored = locale;
      }
    }

    return locale;
  }
}
