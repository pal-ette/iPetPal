import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: "PAL_ETTE_API_KEY")
  static const String palEtteApiKey = _Env.palEtteApiKey;
}
