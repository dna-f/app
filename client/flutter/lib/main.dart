import 'package:WHOFlutter/core/bootstrap_config.dart';

void main() => Production();

class Production extends BootstrapConfig {
  Production()
      : super(
          type: Environment.PRODUCTION,
          // TODO: add specific setup parameters here
          //region example
          //    baseUrl: Api.baseUrl,
          //    authUrl: Api.authUrl,
          //    socketUrl: Api.socketUrl,
          //    connectTimeout: 30000,
          //    sendTimeout: 30000,
          //    receiveTimeout: 30000,
          //endregion
        );
}
