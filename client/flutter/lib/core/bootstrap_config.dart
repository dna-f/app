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

enum Environment { DEVELOPMENT, PRODUCTION }

PackageInfo _packageInfo;

PackageInfo get packageInfo => _packageInfo;

abstract class BootstrapConfig {
  static BootstrapConfig get current => _singleton;
  static BootstrapConfig _singleton;

  // TODO: add specific setup parameters here
  //region example
  //  final String baseUrl;
  //  final String authUrl;
  //  final String socketUrl;

  //  final int connectTimeout;
  //  final int sendTimeout;
  //  final int receiveTimeout;
  //endregion

  final Environment type;

  String locale;

  SharedPreferences get sharedPreferences => _sharedPreferences;
  SharedPreferences _sharedPreferences;

  BootstrapConfig({
    @required this.type,
    // TODO: add specific setup parameters here
    //region example
    //    this.baseUrl,
    //    this.authUrl,
    //    this.socketUrl,
    //    this.connectTimeout,
    //    this.sendTimeout,
    //    this.receiveTimeout,
    //endregion
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
        //        if (Platform.isAndroid) {
        //          // hance network debugging through Chrome dev tools (on Android build)
        //          Stetho.initialize(); // en
        //        }

        break;

      case Environment.PRODUCTION:
        // TODO: uncomment to avoid error red screen
        //        ErrorWidget.builder = (FlutterErrorDetails details) => Empty;
        break;

      default:
        break;
    }

    //region setup

    // TODO: setup routes and logs

    await _setupSharedPref();

    // TODO: setup all needed providers: cache, api provider, authentication, pushing notifications, dynamic-links

    await _setupLocale();

    //endregion

    // running a new dart zone to handle exceptions at app level
    await runZoned<Future<void>>(
      () async {
        runApp(AppBuilder(
          sharedPreferences: sharedPreferences,
          locale: locale,
          theApp: MyApp(),
        ));
      },
      // TODO: uncomment to handle error at app level
      //      onError: (dynamic error, StackTrace stackTrace) async {
      //        await ErrorHandler.handler(error, stackTrace: stackTrace);
      //      },
    );
  }

  void dispose() {
    // TODO: dispose providers
  }

  //region logs example

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

  //endregion

  //region storage

  Future<void> _setupSharedPref() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  //endregion

  //region cache

  //endregion

  //region api

  //endregion

  //region messaging

  //endregion

  //region authentication

  //endregion

  //region dynamicLinks

  //endregion

  // check release mode
  static get isRelease {
    return const bool.fromEnvironment("dart.vm.product");
  }
}
