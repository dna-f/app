import 'package:WHOFlutter/core/bootstrap_config.dart';

void main() => Development();

class Development extends BootstrapConfig {
  Development()
      : super(
          type: Environment.DEVELOPMENT,
          //    topicDefault: TODO_DEV,
          //    baseUrl: Api.baseDevUrl,
          //    authUrl: Api.authDevUrl,
          //    socketUrl: Api.socketDevUrl,
          //    connectTimeout: 30000,
          //    sendTimeout: 30000,
          //    receiveTimeout: 30000,
        );
}
