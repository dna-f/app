import 'package:WHOFlutter/core/bootstrap_config.dart';

void main() => Development();

class Development extends BootstrapConfig {
  Development()
      : super(
          type: Environment.DEVELOPMENT,
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
