import 'package:WHOFlutter/core/bootstrap_config.dart';

void main() => Production();

class Production extends BootstrapConfig {
  Production()
      : super(
          type: Environment.PRODUCTION,
          //    topicDefault: TODO,
          //    baseUrl: Api.baseUrl,
          //    authUrl: Api.authUrl,
          //    socketUrl: Api.socketUrl,
          //    connectTimeout: 30000,
          //    sendTimeout: 30000,
          //    receiveTimeout: 30000,
        );
}
