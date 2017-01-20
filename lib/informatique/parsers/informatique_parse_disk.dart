import "package:pcbuilder.crawler/model/product.dart";
import "package:pcbuilder.crawler/model/connector.dart";
import "package:pcbuilder.crawler/utils.dart";
import "package:pcbuilder.crawler/crawler.dart";
import 'package:pcbuilder.crawler/pageworker.dart';

class InformatiqueDiskParser implements PageWorker {
  parse(Document document, arguments) async {
    var rows = document.querySelectorAll("ul.novendorlogo");

    for (Element listRow in rows) {
      var productRows = listRow.querySelectorAll("li");

      for (Element productRow in productRows) {
        Product disk = new Product();

        var querySelector = productRow.querySelector(".product_overlay");
        if (querySelector == null) {
          continue;
        }

        disk.name = removeTip(productRow.querySelector("#title").text);
        disk.url = querySelector.attributes["href"];
        disk.type = "STORAGE";
        disk.shop = "Informatique";

        await Crawler.crawl(disk.url, new InformatiqueDiskDetailParser(),
            arguments: disk);
      }
    }
  }
}

class InformatiqueDiskDetailParser implements PageWorker {
  parse(Document document, arguments) async {
    Product disk = arguments as Product;

    disk.brand = document.querySelector("span[itemprop='brand']").text;
    disk.price = price(document.querySelector("p.verkoopprijs").text);

    var prodImgA =
        document.querySelector("div#product-image a[data-thumbnail]");
    if (prodImgA != null) {
      disk.pictureUrl = prodImgA.attributes["data-thumbnail"];
    }

    var tables = document.querySelectorAll("table#details");
    bool isM2 = false;
    bool isPCIe = false;
    bool isMSata = false;

    for (var table in tables) {
      var rows = table.querySelectorAll("tr");



      for (var row in rows) {
        var label = row.querySelector("strong");

        if (label == null) {
          continue;
        } else if (label.text == "EAN code") {
          disk.ean = row.querySelector("td:last-child").text;
        } else if (label.text == "Fabrikantcode") {
          disk.mpn = row.querySelector("tr:last-child span").text;
        } else if (label.text == "M.2 (SATA)") {
          if(row.querySelector("td:last-child") != null && row.querySelector("td:last-child").text == "Ja"){
            isM2 = true;
          }
        } else if (label.text == "M.2 (PCIe)") {
          if(row.querySelector("td:last-child") != null && row.querySelector("td:last-child").text == "Ja"){
            isM2 = true;
          }
        }else if (label.text == "PCIe") {
          if(row.querySelector("td:last-child") != null && row.querySelector("td:last-child").text == "Ja"){
            isPCIe = true;
          }
        }else if (label.text == "mSATA") {
          if(row.querySelector("td:last-child") != null && row.querySelector("td:last-child").text == "Ja"){
            isMSata = true;
          }
        }else if (row.querySelector("td:last-child") != null && label.text == "SATA") {
           disk.connectors.add(new Connector(row.querySelector("td:last-child").text, "STORAGE"));
        }

        if(disk.ean != null && disk.mpn != null && (isMSata || isPCIe || isM2)){
          break;
        }
      }

    }
    if(isM2){
      disk.connectors.add(new Connector("M.2", "STORAGE"));
    } else if(isPCIe){
      disk.connectors.add(new Connector("PCIe", "STORAGE"));
    } else if(isMSata){
      disk.connectors.add(new Connector("mSATA", "STORAGE"));
    } else {
      disk.connectors.add(new Connector("SATA", "STORAGE"));
    }


    await postProduct(disk);
    await sleepRnd();
  }
}
