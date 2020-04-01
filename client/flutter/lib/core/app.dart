import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../pages/home_page.dart';
import '../constants.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../generated/l10n.dart';
import '../blocs/locale_bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class MyApp extends StatefulWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  _MyAppState createState() => _MyAppState(analytics, observer);
}

class _MyAppState extends State<MyApp> {
  _MyAppState(this.analytics, this.observer);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _registerLicenses();
  }

  Future<LicenseEntry> _loadLicense() async {
    final licenseText = await rootBundle.loadString('assets/REPO_LICENSE');
    return LicenseEntryWithLineBreaks(["https://github.com/WorldHealthOrganization/app"], licenseText);
  }

  Future<LicenseEntry> _load3pLicense() async {
    final licenseText = await rootBundle.loadString('assets/THIRD_PARTY_LICENSE');
    return LicenseEntryWithLineBreaks(["https://github.com/WorldHealthOrganization/app - THIRD_PARTY_LICENSE"], licenseText);
  }

  _registerLicenses() {
    LicenseRegistry.addLicense(() {
      return Stream<LicenseEntry>.fromFutures(<Future<LicenseEntry>>[
        _loadLicense(),
        _load3pLicense(),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    // get localeBloc singleton
    final localeBloc = GetIt.I.get<LocaleBloc>();

    // NOTE: this streamBuilder listen for a locale change to rebuild the whole app
    // TEST: to change current locale, you can call localeBloc.setLocale('ru');
    return StreamBuilder<String>(
        stream: localeBloc.stream,
        initialData: null,
        builder: (context, snapshot) {
          var connectionState = snapshot.connectionState;

          // force the app if locale disabled
          // if (!localeEnabled) connectionState = ConnectionState.active;

          switch (connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              // return const Loader();
              break;
            case ConnectionState.active:
              return _buildMaterialApp(
                context,
                snapshot.data,
              );
            case ConnectionState.done:
              // final widget
              break;
          }

          return Container();
        });
  }

  Widget _buildMaterialApp(BuildContext context, String locale) {
    return MaterialApp(
      title: "WHO COVID-19",
      localizationsDelegates: [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, S.delegate],
      locale: locale != null ? Locale(locale, '') : null,
      supportedLocales: S.delegate.supportedLocales,
      navigatorObservers: <NavigatorObserver>[observer],
      theme: ThemeData(
        scaffoldBackgroundColor: Constants.backgroundColor,
        primaryColor: Constants.primaryColor,
        accentColor: Constants.textColor,
        brightness: Brightness.light,
        buttonTheme: ButtonThemeData(buttonColor: Constants.primaryColor, textTheme: ButtonTextTheme.accent),
      ),
      home: Directionality(
        child: HomePage(analytics),
        textDirection: GlobalWidgetsLocalizations(Locale(Intl.getCurrentLocale())).textDirection,
      ),
    );
  }
}
