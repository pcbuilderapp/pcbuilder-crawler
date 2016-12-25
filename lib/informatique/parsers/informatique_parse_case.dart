import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'dart:convert';

class InformatiqueCaseParser implements PageWorker {

  parse(Document document, arguments) async {

    List caseUnits = [];
    var rows = document.querySelectorAll("div.listRow");
    for (Element listRow in rows) {
      Product pcCase = new Product();
      pcCase.name = listRow.querySelector("span.name").text.trim();
      pcCase.brand = listRow.querySelectorAll("span.name span")[0].text.trim();
      pcCase.url = "https://www.alternate.nl" + listRow.querySelector(".productLink").attributes["href"];
      pcCase.type = "CASING";
      pcCase.price = price(listRow.querySelector("span.price").text);
      pcCase.shop = "Alternate";
      await Crawler.crawl(pcCase.url, new InformatiqueCaseDetailParser(), arguments: pcCase);

      caseUnits.add(pcCase);
    }
    return caseUnits;
  }
}

class InformatiqueCaseDetailParser implements PageWorker {

  parse(Document document, arguments) async {

    Product product = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    product.ean = dataFlix.attributes["data-flix-ean"];
    product.mpn = dataFlix.attributes["data-flix-mpn"];

    String caseForm = "";
    var techDataTableElements = document.querySelectorAll("div.productShort ul li");
    for (int i = 0; i < techDataTableElements.length; i++) {

      List<String> productShort = techDataTableElements[i].text.split(":");

      String techDataLabel = productShort[0];
      String techData = productShort[1];

      if (techDataLabel == "Formfactor") {
        caseForm = techData;
      }

    }
    product.connectors.add(new Connector(caseForm, "CASING"));

    String productJSON = new JsonEncoder.withIndent("  ").convert(product);
    postRequest(getBackendServerURL()+"/product/add", productJSON);
    print(productJSON);
    await sleepRnd();
  }
}