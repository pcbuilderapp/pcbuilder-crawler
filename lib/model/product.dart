import "connector.dart";

class Product {
  String name;
  String brand;
  String ean;
  String mpn;
  double price;
  String url;
  String shop;
  String type;
  String pictureUrl;
  List<Connector> connectors = [];

  Map toJson() => {
    "name": name,
    "brand": brand,
    "ean": ean,
    "mpn": mpn,
    "price": price,
    "url" : url,
    "shop" : shop,
    "type" : type,
    "pictureUrl" : pictureUrl,
    "connectors" : connectors
  };
}