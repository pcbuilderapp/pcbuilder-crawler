import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'dart:convert';

class AlternateCaseParser implements PageWorker {

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
      await Crawler.crawl(pcCase.url, new AlternateCaseDetailParser(), arguments: pcCase);

      caseUnits.add(pcCase);
    }
    return caseUnits;
  }
}

class AlternateCaseDetailParser implements PageWorker {

  parse(Document document, arguments) async {

    Product product = arguments as Product;

    var dataFlix = document.querySelector("script[data-flix-mpn]");
    product.ean = dataFlix.attributes["data-flix-ean"];
    product.mpn = dataFlix.attributes["data-flix-mpn"];

    String caseType = "";
    String caseForm = "";
    String caseSlots = "";
    var techDataTableElements = document.querySelectorAll("div.productShort ul li");
    for (int i = 0; i < techDataTableElements.length; i++) {


      List<String> productShort = techDataTableElements[i].text.split(":");

      String techDataLabel = productShort[0];
      String techData = productShort[1];


      if (techDataLabel == "Type voeding") {
        caseType = techData;
      } else if (techDataLabel == "Formfactor") {
        caseForm = techData;
      } else if (techDataLabel == "Inbouwsloten") {
        caseSlots = techData;
      }

    }
    product.connectors.add(new Connector(caseType, "CASETYPE"));
    product.connectors.add(new Connector(caseForm, "CASEFORM"));
    List<String> caseSlotsList = caseSlots.split(", ");
    for (int i = 0; i < caseSlotsList.length; i++) {
      if (caseSlotsList[i].contains('5,25 inch')) {
        product.connectors.add(new Connector(caseSlotsList[i], "CASESLOTS525"));
      } else if (caseSlotsList[i].contains('3,5 inch')) {
        product.connectors.add(new Connector(caseSlotsList[i], "CASESLOTS35"));
      } else if (caseSlotsList[i].contains('2,5 inch')) {
        product.connectors.add(new Connector(caseSlotsList[i], "CASESLOTS25"));
      }
    }

    String productJSON = new JsonEncoder.withIndent("  ").convert(product);
    postRequest(getBackendServerURL()+"/product/add", productJSON);
    print(productJSON);
    await sleepRnd();
  }
}