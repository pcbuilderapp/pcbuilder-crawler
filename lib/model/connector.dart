class Connector {
  String name;
  String type;

  Connector(this.name, this.type) {}

  Map toJson() => {
    "name": name,
    "type" : type
  };
}