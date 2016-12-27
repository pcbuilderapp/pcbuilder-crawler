import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'dart:convert';

class InformatiquePowerSupplyUnitParser implements PageWorker {

  parse(Document document, arguments) async {

    List psus = [];
    var rows = document.querySelectorAll("div.listRow");
    for (Element listRow in rows) {
      Product psu = new Product();
      psu.name = listRow.querySelector("span.name").text.trim();
      psu.brand = listRow.querySelectorAll("span.name span")[0].text.trim();
      psu.url = "https://www.alternate.nl" +
          listRow.querySelector(".productLink").attributes["href"];
      psu.type = "PSU";
      psu.price = price(listRow.querySelector("span.price").text);
      psu.shop = "Alternate";
      await Crawler.crawl(psu.url, new InformatiquePsuDetailParser(), arguments: psu);

      psus.add(psu);
    }
    return psus;
  }
}

class InformatiquePsuDetailParser implements PageWorker {
  parse(Document document, arguments) async {
    Product psu = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    psu.ean = dataFlix.attributes["data-flix-ean"];
    psu.mpn = dataFlix.attributes["data-flix-mpn"];

    String psuForm = "";
    var techDataTableElements =
        document.querySelectorAll("div.techData table tr");
    bool saveNext = false;
    bool breakMethod = false;
    for (int i = 0; i < techDataTableElements.length; i++) {
      String techDataLabel =
          techDataTableElements[i].querySelector("html td").text.trim();
      if (saveNext) {
        psuForm = techDataTableElements[i].querySelector("html td").text.trim();
        breakMethod = true;
      }

      if (techDataLabel == "Bouwvorm") {
        saveNext = true;
      }

      if (breakMethod) {
        break;
      }
    }
    psu.connectors.add(new Connector(psuForm, "PSU"));

    String productJSON = new JsonEncoder.withIndent("  ").convert(psu);
    postRequest(getBackendServerURL() + "/product/add", productJSON);
    print(productJSON);
    await sleepRnd();
  }
}
