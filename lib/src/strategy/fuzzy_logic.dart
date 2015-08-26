/*
 * Copyright 2015 Daniel Bälz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

library adaptify.strategy.fuzzy;

import 'dart:async';

import 'package:fuzzylogic/fuzzylogic.dart';

import 'base_strategy.dart';
import '../annotations.dart';
import '../monitor/base_monitor.dart';

class FuzzyLogic extends BaseStrategy {
  FuzzyLogic(monitor) : super(monitor);

  @override
  Future<Execution> evaluate(Requirement req) async {
    Measurement measurement = await monitor.retrieveMeasurement();

    var bandwidth = new _FuzzyBandwidthUp();
    var cpu = new _FuzzyCPU();
    var memory = new _FuzzyMemory();
    var decision = new _FuzzyDecision();

    FuzzyRuleBase ruleBase = new FuzzyRuleBase();
    ruleBase
      ..addRule(new FuzzyRule((bandwidth.low & cpu.slow & memory.low), decision.local))
      ..addRule(new FuzzyRule((bandwidth.low & cpu.slow & memory.medium), decision.local))
      ..addRule(new FuzzyRule((bandwidth.low & cpu.slow & memory.high), decision.local))

      ..addRule(new FuzzyRule((bandwidth.low & cpu.medium & memory.low), decision.local))
      ..addRule(new FuzzyRule((bandwidth.low & cpu.medium & memory.medium), decision.local))
      ..addRule(new FuzzyRule((bandwidth.low & cpu.medium & memory.high), decision.local))

      ..addRule(new FuzzyRule((bandwidth.medium & cpu.slow & memory.low), decision.remote))
      ..addRule(new FuzzyRule((bandwidth.medium & cpu.medium & memory.low), decision.remote))
      ..addRule(new FuzzyRule((bandwidth.medium & cpu.fast & memory.low), decision.remote))

      ..addRule(new FuzzyRule((bandwidth.high & cpu.slow & memory.low), decision.remote))
      ..addRule(new FuzzyRule((bandwidth.high & cpu.medium & memory.low), decision.remote))
      ..addRule(new FuzzyRule((bandwidth.high & cpu.slow & memory.medium), decision.remote))

      ..addRule(new FuzzyRule((bandwidth.medium & cpu.medium & memory.medium), decision.local));

    if ((req.bandwidth == Consumption.high) || (req.bandwidth == Consumption.medium)) {
      ruleBase
        ..addRule(new FuzzyRule((bandwidth.medium & cpu.slow & memory.low), decision.local))
        ..addRule(new FuzzyRule((bandwidth.high & cpu.slow & memory.low), decision.remote));
    }
    if ((req.cpu == Consumption.high) || (req.cpu == Consumption.medium)) {
      ruleBase
        ..addRule(new FuzzyRule((bandwidth.medium & cpu.slow & memory.low), decision.remote))
        ..addRule(new FuzzyRule((bandwidth.medium & cpu.medium & memory.low), decision.local))
        ..addRule(new FuzzyRule((bandwidth.medium & cpu.fast & memory.medium), decision.local));
    }
    if ((req.memory == Consumption.high) || (req.memory == Consumption.medium)) {
      ruleBase
        ..addRule(new FuzzyRule((bandwidth.low & cpu.slow & memory.medium), decision.local))
        ..addRule(new FuzzyRule((bandwidth.low & cpu.slow & memory.high), decision.local))
        ..addRule(new FuzzyRule((bandwidth.medium & cpu.slow & memory.medium), decision.remote))
        ..addRule(new FuzzyRule((bandwidth.medium & cpu.slow & memory.high), decision.local));
    }

    var output = decision.createOutputPlaceholder();

    ruleBase.resolve(
        inputs: [bandwidth.assign(measurement.bandwidth), cpu.assign(measurement.cpu), memory.assign(measurement.memory)],
        outputs: [output]);

    if ((output.crispValue == null) || (output.crispValue > 50 && output.confidence > 0.60)) {
      return Execution.local;
    } else {
      return Execution.remote;
    }
  }
}

class _FuzzyBandwidthDown extends FuzzyVariable<int> {
  var low = new FuzzySet.LeftShoulder(0, 192, 384);
  var medium = new FuzzySet.Trapezoid(192, 256, 448, 512);
  var high = new FuzzySet.Trapezoid(384, 512, 768, 896);
  var superior = new FuzzySet.RightShoulder(768, 896, 14 * 1024);

  _FuzzyBandwidthDown() {
    sets = [low, medium, high, superior];
    init();
  }
}

class _FuzzyBandwidthUp extends FuzzyVariable<int> {
  var low = new FuzzySet.LeftShoulder(0, 64, 96);
  var medium = new FuzzySet.Trapezoid(64, 128, 320, 512);
  var high = new FuzzySet.RightShoulder(384, 512, 5120);

  _FuzzyBandwidthUp() {
    sets = [low, medium, high];
    init();
  }
}

class _FuzzyCPU extends FuzzyVariable<int> {
  var slow = new FuzzySet.LeftShoulder(0, 512, 1024);
  var medium = new FuzzySet.Trapezoid(640, 1024, 1536, 2048);
  var fast = new FuzzySet.RightShoulder(1792, 2048, 4096);

  _FuzzyCPU() {
    sets = [slow, medium, fast];
    init();
  }
}

class _FuzzyMemory extends FuzzyVariable<int> {
  var low = new FuzzySet.LeftShoulder(0, 1024, 1536);
  var medium = new FuzzySet.Trapezoid(1024, 1536, 2048, 2560);
  var high = new FuzzySet.RightShoulder(2048, 2560, 3072);

  _FuzzyMemory() {
    sets = [low, medium, high];
    init();
  }
}

class _FuzzyDecision extends FuzzyVariable<int> {
  var local = new FuzzySet.LeftShoulder(0, 30, 60);
  var remote = new FuzzySet.RightShoulder(40, 60, 100);

  _FuzzyDecision() {
    sets = [local, remote];
    init();
  }
}
