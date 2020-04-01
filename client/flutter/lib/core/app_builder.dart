import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bootstrap_config.dart';
import '../blocs/locale_bloc.dart';

class AppBuilder extends StatefulWidget {
  final Widget theApp;
  final SharedPreferences sharedPreferences;

  final String locale;
  final LocaleBloc localeBloc;

  AppBuilder({
    Key key,
    @required this.theApp,
    @required this.sharedPreferences,
    this.locale,
  })  : localeBloc = LocaleBloc(locale: locale),
        super(key: key);

  @override
  State<StatefulWidget> createState() => AppBuilderState();

  void onInitState() {
    _setupLocale();
  }

  void onDispose() {
    _disposeLocale();
    _disposeEnv();
  }

  void _disposeEnv() {
    BootstrapConfig.current.dispose();
  }

  //region locale
  void _setupLocale() {
    // registering a singleton with get it
    // you can retrieve it back like this, final localeBloc = GetIt.I.get<LocaleBloc>();
    GetIt.I.registerSingleton<LocaleBloc>(localeBloc);
  }

  void _disposeLocale() {
    localeBloc.dispose();
  }

//endregion
}

class AppBuilderState extends State<AppBuilder> {
  @override
  void initState() {
    super.initState();
    widget.onInitState();
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theApp = widget.theApp;

    // TODO: wrap the app with providers if needed
    //region example
    //    return MultiProvider(
    //      providers: [
    //        // TASK: routing observer
    //        RouteObserverProvider(),
    //      ],
    //      // TASK: keyboard listener
    //      child: BlocProvider<KeyboardBloc>(
    //          bloc: _keyboardBloc,
    //          child: theApp,
    //        ),
    //      ),
    //    );
    //endregion

    return theApp;
  }
}
