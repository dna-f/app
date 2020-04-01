import 'dart:async';

import 'package:WHOFlutter/api/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_locale/flutter_device_locale.dart';
import 'package:meta/meta.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'app.dart';
import 'app_builder.dart';

enum Environment { DEVELOPMENT, STAGING, PRODUCTION }

PackageInfo _packageInfo;

PackageInfo get packageInfo => _packageInfo;

abstract class BootstrapConfig {
  static BootstrapConfig get current => _singleton;
  static BootstrapConfig _singleton;

  //  final String topicDefault;
  //
  //  final String baseUrl;
  //  final String authUrl;
  //  final String socketUrl;
  //
  //  final int connectTimeout;
  //  final int sendTimeout;
  //  final int receiveTimeout;

  final Environment type;

  //region cache config

  //  final String cacheName;
  //  final int cacheVersion;

  //endregion

  String locale;

  SharedPreferences get sharedPreferences => _sharedPreferences;
  SharedPreferences _sharedPreferences;

  BootstrapConfig({
    @required this.type,
    //    @required this.appName,
    //    this.topicDefault,
    //    this.baseUrl,
    //    this.authUrl,
    //    this.socketUrl,
    //    this.cacheName,
    //    this.cacheVersion = 1,
    //    this.connectTimeout,
    //    this.sendTimeout,
    //    this.receiveTimeout,
  }) : assert(_singleton == null) {
    _singleton = this;
    _bootstrap();
  }

  void _bootstrap() async {
    if (!kIsWeb) {
      // Initialises binding so we can use the framework before calling runApp
      WidgetsFlutterBinding.ensureInitialized();
      _packageInfo = await PackageInfo.fromPlatform();
    }

    switch (type) {
      case Environment.DEVELOPMENT:
      case Environment.STAGING:
        //        if (Platform.isAndroid) {
        //          // hance network debugging through Chrome dev tools (on Android build)
        //          Stetho.initialize(); // en
        //        }

        break;

      case Environment.PRODUCTION:
        // NOTE: avoid error red screen
        //        ErrorWidget.builder = (FlutterErrorDetails details) => Empty;
        break;

      default:
        break;
    }

    // debugPaintSizeEnabled = true;
    // debugPaintBaselinesEnabled = true;
    // debugPaintPointersEnabled = true; // any objects that are being tapped get highlighted in teal
    // timeDilation = 50.0; // the easiest way to debug animations is to slow them way down

    //region setup

    //    _setupLocator();
    //    _setupRoutes();
    //    _setupVersion();
    //
    //    await _setupLog();
    //
    await _setupSharedPref();
    //    await _setupCache();
    //
    //    await _setupApi();
    //
    //    await _setupMessaging();
    //    await _setupAuthentication();
    //
    //    await _setupSocket();
    //    await _setupDynamicLinks();

    await _setupLocale();

    //endregion

    // running a new dart zone to handle exceptions at app level
    await runZoned<Future<void>>(
      () async {
        runApp(AppBuilder(
          sharedPreferences: sharedPreferences,
          enableLocale: true,
          locale: locale,
          theApp: MyApp(),
        ));
      },
      // TODO: error handling at app level
      //      onError: (dynamic error, StackTrace stackTrace) async {
      //        await ErrorHandler.handler(error, stackTrace: stackTrace);
      //      },
    );
  }

  void dispose() {
    //    _disposeApi();
    //    _disposeCache();
    //    _disposeMessaging();
    //    _disposeDynamicLinks();
    //    // NOTE: dispose socket before auth, as socket may need an auth reference
    //    _disposeSocket();
    //    _disposeAuthentication();
    //
    //    _disposeLog();
  }

  //region service locator

  //  void _setupLocator() {
  //    GetIt.I..allowReassignment = true;
  //  }

  //endregion

  //region logs

  //  Future<void> _setupLog() async {
  //    Logging.setupLog(
  //      printer: PrettyPrinter(methodCount: 1, errorMethodCount: 8, lineLength: 120, colors: true, printEmojis: true, printTime: true),
  //    );
  //
  //    switch (type) {
  //      case EnvironmentType.DEVELOPMENT:
  //      case EnvironmentType.STAGING:
  //        Logging.setLevel(Level.debug);
  //        break;
  //
  //      case EnvironmentType.PRODUCTION:
  //        Logging.setLevel(Level.info);
  //        break;
  //    }
  //  }

  //  void _disposeLog() {}

  //endregion

  Future<void> _setupLocale() async {
    locale = UserPreferences().getLocale();
    if (locale == null) {
      final deviceLocale = await DeviceLocale.getCurrentLocale();
      if (deviceLocale != null) {
        locale = deviceLocale.languageCode;
      }
    }
  }

  //region routes

  //  void _setupRoutes() {
  //  }

  //endregion

  //region storage

  Future<void> _setupSharedPref() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  //endregion

  //region cache

  //  Future<void> _setupCache() async {
  //  }
  //
  //  void _disposeCache() {
  //  }

  //endregion

  //region api

  //  Future<void> _setupApi() async {
  //  }
  //
  //  void _disposeApi() {
  //  }

  //endregion

  //region messaging

  //  Future<void> _setupMessaging() async {
  //  }
  //
  //  void _disposeMessaging() {
  //  }

  //endregion

  //region authentication

  //  Future<void> _setupAuthentication() async {
  //  }
  //
  //  void _disposeAuthentication() {
  //  }

  //endregion

  //region sockets

  //  Future<void> _setupSocket() async {
  //  }
  //
  //  void _disposeSocket() {
  //  }

  //endregion

  //region dynamicLinks

  //  Future<void> _setupDynamicLinks() async {
  //  }
  //
  //  void _disposeDynamicLinks() {
  //  }

  //endregion

  //region version

  //  void _setupVersion() {
  //  }

  //endregion

  // check release mode
  static get isRelease {
    return const bool.fromEnvironment("dart.vm.product");
  }
}
