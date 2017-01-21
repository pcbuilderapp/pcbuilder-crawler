class Metrics {

  String shop;

  Stopwatch totalTime = new Stopwatch();

  Stopwatch caseBackendTime = new Stopwatch();
  Stopwatch caseParserTime = new Stopwatch();

  Stopwatch storageBackendTime = new Stopwatch();
  Stopwatch storageParserTime = new Stopwatch();

  Stopwatch memoryBackendTime = new Stopwatch();
  Stopwatch memoryParserTime = new Stopwatch();

  Stopwatch motherboardBackendTime = new Stopwatch();
  Stopwatch motherboardParserTime = new Stopwatch();

  Stopwatch psuBackendTime = new Stopwatch();
  Stopwatch psuParserTime = new Stopwatch();

  Stopwatch cpuBackendTime = new Stopwatch();
  Stopwatch cpuParserTime = new Stopwatch();

  Stopwatch gpuBackendTime = new Stopwatch();
  Stopwatch gpuParserTime = new Stopwatch();

  printMetrics() {
    print(">>> " + shop + " parser has finished with the following metrics: ");
    print(">>> total time " + totalTime.elapsed.inSeconds.toString() + " seconds.");

    print(">>> case time: " + (caseParserTime.elapsed.inSeconds + caseBackendTime.elapsed.inSeconds).toString() + " seconds, of which " + caseParserTime.elapsed.inSeconds.toString() + "s parsing and " + caseBackendTime.elapsed.inSeconds.toString() + "s posting.");
    print(">>> storage time: " + (storageParserTime.elapsed.inSeconds + storageBackendTime.elapsed.inSeconds).toString() + " seconds, of which " + storageParserTime.elapsed.inSeconds.toString() + "s parsing and " + storageBackendTime.elapsed.inSeconds.toString() + "s posting.");
    print(">>> memory time: " + (memoryParserTime.elapsed.inSeconds + memoryBackendTime.elapsed.inSeconds).toString() + " seconds, of which " + memoryParserTime.elapsed.inSeconds.toString() + "s parsing and " + memoryBackendTime.elapsed.inSeconds.toString() + "s posting.");
    print(">>> motherboard time: " + (motherboardParserTime.elapsed.inSeconds + motherboardBackendTime.elapsed.inSeconds).toString() + " seconds, of which " + motherboardParserTime.elapsed.inSeconds.toString() + "s parsing and " + motherboardBackendTime.elapsed.inSeconds.toString() + "s posting.");
    print(">>> psu time: " + (psuParserTime.elapsed.inSeconds + psuBackendTime.elapsed.inSeconds).toString() + " seconds, of which " + psuParserTime.elapsed.inSeconds.toString() + "s parsing and " + psuBackendTime.elapsed.inSeconds.toString() + "s posting.");
    print(">>> cpu time: " + (cpuParserTime.elapsed.inSeconds + cpuBackendTime.elapsed.inSeconds).toString() + " seconds, of which " + cpuParserTime.elapsed.inSeconds.toString() + "s parsing and " + cpuBackendTime.elapsed.inSeconds.toString() + "s posting.");
    print(">>> gpu time: " + (gpuParserTime.elapsed.inSeconds + gpuBackendTime.elapsed.inSeconds).toString() + " seconds, of which " + gpuParserTime.elapsed.inSeconds.toString() + "s parsing and " + gpuBackendTime.elapsed.inSeconds.toString() + "s posting.");

  }
}