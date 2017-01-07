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
  List<Connector> connectors = [];
  List<String> pictureUrls = [];

  Map toJson() => {
    "name": name,
    "brand": brand,
    "ean": ean,
    "mpn": mpn,
    "price": price,
    "url" : url,
    "shop" : shop,
    "type" : type,
    "connectors" : connectors,
    "pictureUrls" : pictureUrls
  };
}