install dart:

https://www.dartlang.org/install

run `pub get` in crawlertest

run the crawler:

dart bin/crawler.dart

make sure you have a ```config.yaml``` file in your project root containing:
```yaml
backendServerUrl: http://localhost:8090/

printProducts: false
waitForBackend: false

addProductUrl: /product/add
createShopUrl: /shop/create
crawlerInfoUrl: /crawler/findbyname?name=

whiteListDisks: [M.2, mSATA, SATA, PCIe]
whiteListGpu: [PCIe]
whiteListMemory: [DDR4, DDR3, DDR2]

crawlerNotLaunching: Crawler NAME won't run because it has been deactivated.
crawlerLaunching: Crawler NAME launching...

informatiqueName: Informatique
informatiqueUrl: www.informatique.nl

alternateName: Alternate
alternateUrl: www.alternate.nl

memoryType: MEMORY
processorType: CPU
storageType: STORAGE
graphicsCardType: GPU
computerCaseType: CASE
powerSupplyUnitType: PSU
motherboardType: MOTHERBOARD

informatiqueStorageUrls:
  - http://www.informatique.nl/?m=usl&g=026&view=6&&sort=pop&pl=119
  - http://www.informatique.nl/?m=usl&g=028&view=6&&sort=pop&pl=32
  - http://www.informatique.nl/?m=usl&g=559&view=6&&sort=pop&pl=221
  - http://www.informatique.nl/?m=art&g=170&view=6&&sort=pop&pl=22
informatiqueProcessorUrls:
  - http://www.informatique.nl/?m=usl&g=611&pl=500
  - http://www.informatique.nl/?m=usl&g=218&pl=500
informatiquePowerSupplyUnitUrls:
  - http://www.informatique.nl/?m=usl&g=171&view=6&&sort=pop&pl=196
informatiqueMemoryUrls:
  - http://www.informatique.nl/?m=usl&g=522&view=6&&sort=pop&pl=277
  - http://www.informatique.nl/?m=usl&g=194&view=6&&sort=pop&pl=21
informatiqueMotherboardUrls:
  - http://www.informatique.nl/?m=usl&g=726&view=6&&sort=pop&pl=46
  - http://www.informatique.nl/pc_componenten/moederborden/socket_2011_(intel)/c001-h033-g670/
  - http://www.informatique.nl/?m=usl&g=744&view=6&&sort=pop&pl=272
  - http://www.informatique.nl/?m=usl&g=699&view=6&&sort=pop&pl=77
  - http://www.informatique.nl/?m=usl&g=713&view=6&&sort=pop&pl=26
  - http://www.informatique.nl/pc_componenten/moederborden/socket_am1_(amd)/c001-h033-g717/
  - http://www.informatique.nl/?m=usl&g=655&view=6&&sort=pop&pl=30
  - http://www.informatique.nl/pc_componenten/moederborden/socket_fm2_(amd)/c001-h033-g686/
  - http://www.informatique.nl/pc_componenten/moederborden/on-board_cpu/c001-h033-g558/
informatiqueVideocardUrls:
  - http://www.informatique.nl/?m=usl&g=166&view=6&&sort=pop&pl=211
  - http://www.informatique.nl/?m=usl&g=188&view=6&&sort=pop&pl=53
informatiqueCaseUrls:
  - http://www.informatique.nl/?m=usl&g=004&view=6&&sort=pop&pl=547

alternateStorageUrls:
  - https://www.alternate.nl/Hardware/html/listings/1472811138409?size=500
  - https://www.alternate.nl/Harde-schijven-intern/SATA-2-5-inch?size=500
  - https://www.alternate.nl/Harde-schijven-intern/SATA-3-5-inch?size=500
  - https://www.alternate.nl/Harde-schijven-intern/Hybride?size=500
alternateProcessorUrls:
  - https://www.alternate.nl/Processoren/Desktop/Alle-processoren?size=500
alternatePowerSupplyUnitUrls:
  - https://www.alternate.nl/Hardware-Componenten-Voedingen-Alle-voedingen/html/listings/11604?size=500
alternateMemoryUrls:
  - https://www.alternate.nl/Geheugen/DDR4?size=500
  - https://www.alternate.nl/Geheugen/DDR3?size=500
  - https://www.alternate.nl/Geheugen/DDR2?size=500
alternateMotherboardUrls:
  - https://www.alternate.nl/Moederborden/AMD?size=500
  - https://www.alternate.nl/Moederborden/Intel?size=500
alternateVideocardUrls:
  - https://www.alternate.nl/Grafische-kaarten/NVIDIA-GeForce?size=500
  - https://www.alternate.nl/Grafische-kaarten/AMD-Radeon?size=500
alternateCaseUrls:
  - https://www.alternate.nl/Behuizingen/Alle-behuizingen?size=500
```
