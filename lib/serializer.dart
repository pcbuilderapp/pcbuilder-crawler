import 'package:dartson/dartson.dart';

Dartson _dson = _initSerializer();

Dartson _initSerializer() {
  var dson = new Dartson.JSON();
  return dson;
}

String toJson(dynamic object) {
  return _dson.encode(object);
}

dynamic fromJson(String json, Object target) {
  return _dson.decode(json,target);
}