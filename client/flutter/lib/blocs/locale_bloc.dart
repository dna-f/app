import 'dart:async';

import '../api/user_preferences.dart';

import 'interfaces.dart';
import 'streams/stream_command.dart';

/// Bloc to handle locale choice
/// You can call localeBloc.setLocale('ru'); to change current locale
class LocaleBloc extends IBloc {
  String _stored;

  String get current => _current;
  String _current;

  StreamCommandPassThrough<String> _localeCommand;

  Stream<String> get stream => _localeCommand.output.distinct();

  LocaleBloc({String locale}) {
    _localeCommand = StreamCommandPassThrough<String>(handler: _handleLocale);

    // seed the stream even if the value is not changed
    // try to get the last user choice
    _stored = UserPreferences().getLocale();

    setLocale(locale);
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
