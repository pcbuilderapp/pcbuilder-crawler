import 'package:yaml/yaml.dart';

final Config config = new Config();

class Config {
  YamlMap _yaml;

  void init(String cfgSource) {
    _yaml = loadYaml(cfgSource);
  }
  bool contains(String key) => _yaml.containsKey(key);
  dynamic operator[](String key) => _yaml != null ? _yaml[key] : null;
}