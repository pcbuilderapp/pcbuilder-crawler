class Metrics {
  String shop;

  Stopwatch totalTime = new Stopwatch();

  Stopwatch caseBackendTime = new Stopwatch();
  Stopwatch caseParserTime = new Stopwatch();
  int caseCount = 0;

  Stopwatch storageBackendTime = new Stopwatch();
  Stopwatch storageParserTime = new Stopwatch();
  int storageCount = 0;

  Stopwatch memoryBackendTime = new Stopwatch();
  Stopwatch memoryParserTime = new Stopwatch();
  int memoryCount = 0;

  Stopwatch motherboardBackendTime = new Stopwatch();
  Stopwatch motherboardParserTime = new Stopwatch();
  int motherboardCount = 0;

  Stopwatch powerSupplyUnitBackendTime = new Stopwatch();
  Stopwatch powerSupplyUnitParserTime = new Stopwatch();
  int powerSupplyUnitCount = 0;

  Stopwatch processorBackendTime = new Stopwatch();
  Stopwatch processorParserTime = new Stopwatch();
  int processorCount = 0;

  Stopwatch videoCardBackendTime = new Stopwatch();
  Stopwatch videoCardParserTime = new Stopwatch();
  int videoCardCount = 0;

  printMetrics() {
    print("");
    print(">>> >>> >>> >>> METRICS <<< <<< <<< <<<");
    print(">>> " + shop + " parser has finished with the following metrics: ");
    print(">>> total products: " +
               (caseCount +
                storageCount +
                memoryCount +
                motherboardCount +
                powerSupplyUnitCount +
                processorCount +
                videoCardCount)
            .toString() +
        " time " +
        totalTime.elapsed.inMinutes.toString() +
        " minutes.");

    print(">>> case --- amount: " +
        caseCount.toString() +
        " --- time: " +
        (caseParserTime.elapsed.inSeconds + caseBackendTime.elapsed.inSeconds)
            .toString() +
        " seconds, of which " +
        caseParserTime.elapsed.inSeconds.toString() +
        "s parsing and " +
        caseBackendTime.elapsed.inSeconds.toString() +
        "s posting.");
    print(">>> storage --- amount: " +
        storageCount.toString() +
        " --- time: " +
        (storageParserTime.elapsed.inSeconds +
                storageBackendTime.elapsed.inSeconds)
            .toString() +
        " seconds, of which " +
        storageParserTime.elapsed.inSeconds.toString() +
        "s parsing and " +
        storageBackendTime.elapsed.inSeconds.toString() +
        "s posting.");
    print(">>> memory --- amount: " +
        memoryCount.toString() +
        " --- time: " +
        (memoryParserTime.elapsed.inSeconds +
                memoryBackendTime.elapsed.inSeconds)
            .toString() +
        " seconds, of which " +
        memoryParserTime.elapsed.inSeconds.toString() +
        "s parsing and " +
        memoryBackendTime.elapsed.inSeconds.toString() +
        "s posting.");
    print(">>> motherboard --- amount: " +
        motherboardCount.toString() +
        " --- time: " +
        (motherboardParserTime.elapsed.inSeconds +
                motherboardBackendTime.elapsed.inSeconds)
            .toString() +
        " seconds, of which " +
        motherboardParserTime.elapsed.inSeconds.toString() +
        "s parsing and " +
        motherboardBackendTime.elapsed.inSeconds.toString() +
        "s posting.");
    print(">>> psu --- amount: " +
        powerSupplyUnitCount.toString() +
        " --- time: " +
        (powerSupplyUnitParserTime.elapsed.inSeconds +
                powerSupplyUnitBackendTime.elapsed.inSeconds)
            .toString() +
        " seconds, of which " +
        powerSupplyUnitParserTime.elapsed.inSeconds.toString() +
        "s parsing and " +
        powerSupplyUnitBackendTime.elapsed.inSeconds.toString() +
        "s posting.");
    print(">>> cpu --- amount: " +
        processorCount.toString() +
        " --- time: " +
        (processorParserTime.elapsed.inSeconds +
                processorBackendTime.elapsed.inSeconds)
            .toString() +
        " seconds, of which " +
        processorParserTime.elapsed.inSeconds.toString() +
        "s parsing and " +
        processorBackendTime.elapsed.inSeconds.toString() +
        "s posting.");
    print(">>> gpu --- amount: " +
        videoCardCount.toString() +
        " --- time: " +
        (videoCardParserTime.elapsed.inSeconds +
                videoCardBackendTime.elapsed.inSeconds)
            .toString() +
        " seconds, of which " +
        videoCardParserTime.elapsed.inSeconds.toString() +
        "s parsing and " +
        videoCardBackendTime.elapsed.inSeconds.toString() +
        "s posting.");
  }
}
