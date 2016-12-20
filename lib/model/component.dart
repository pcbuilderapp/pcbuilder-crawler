import "connector.dart";

class Component {
  String name;
  String brand;
  String ean;
  String mpn;
  double price;
  String url;
  String shopName;
  String type;
  List<Connector> connectors = [];

  Map toJson() => {
    "name": name,
    "brand": brand,
    "ean": ean,
    "mpn": mpn,
    "price": price,
    "url" : url,
    "shopName" : shopName,
    "type" : type,
    "connectors" : connectors
  };
}