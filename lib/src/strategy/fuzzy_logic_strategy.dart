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

/// An adaption strategy based on fuzzy logic.
///
/// Uses the [Fuzzy Logic package](https://pub.dartlang.org/packages/fuzzylogic) for the implementation.
class FuzzyLogicStrategy extends BaseStrategy {
  /// Creates a strategy with the given [monitor] implementation.
  FuzzyLogicStrategy(monitor) : super(monitor);

  @override
  Future<Execution> evaluate(Requirement req) async {
    Measurement measurement = await monitor.retrieveMeasurement();

    var bandwidth = new _FuzzyBandwidthUp();
    var cpu = new _FuzzyCPU();
    var memory = new _FuzzyMemory();
    var decision = new _FuzzyDecision();

    FuzzyRuleBase ruleBase = new FuzzyRuleBase();

    if (req.cpu == Consumption.high) {
      ruleBase.addRule(new FuzzyRule((cpu.slow | cpu.medium), decision.remote));
    } else {
      ruleBase
        ..addRule(new FuzzyRule(cpu.fast, decision.local))
        ..addRule(new FuzzyRule(cpu.medium, decision.remote));
    }

    if (req.memory == Consumption.high) {
      ruleBase.addRule(new FuzzyRule((memory.low | memory.medium), decision.remote));
    } else if (req.memory == Consumption.medium) {
      ruleBase
        ..addRule(new FuzzyRule((memory.low), decision.remote))
        ..addRule(new FuzzyRule((memory.medium), decision.local));
    }

    if (req.bandwidth == Consumption.high) {
      ruleBase
        ..addRule(new FuzzyRule((bandwidth.low | bandwidth.medium), decision.local))
        ..addRule(new FuzzyRule((cpu.slow & memory.low), decision.remote));
    }

    if ((req.cpu == Consumption.medium) || (req.memory == Consumption.medium)) {
      ruleBase.addRule(new FuzzyRule(((cpu.medium | cpu.fast) & (memory.high)), decision.local));
    }
    if ((req.cpu != Consumption.low) && (req.memory != Consumption.low) && (req.bandwidth == Consumption.low)) {
      ruleBase.addRule(new FuzzyRule((bandwidth.medium | bandwidth.high), decision.remote));
    }

    var output = decision.createOutputPlaceholder();

    ruleBase.resolve(
        inputs: [bandwidth.assign(measurement.bandwidth), cpu.assign(measurement.cpu), memory.assign(measurement.memory)],
        outputs: [output]);

    if (output.crispValue == null) {
      return Execution.local;
    }

    var decisionValue = output.confidence * output.crispValue;
    if (decisionValue > 40) {
      return Execution.local;
    }
    return Execution.remote;
  }
}

class _FuzzyBandwidthUp extends FuzzyVariable<int> {
  var low = new FuzzySet.LeftShoulder(0, 64, 96);
  var medium = new FuzzySet.Trapezoid(64, 128, 320, 512);
  var high = new FuzzySet.RightShoulder(384, 512, 2048);

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
  var low = new FuzzySet.LeftShoulder(0, 512, 768);
  var medium = new FuzzySet.Trapezoid(512, 1024, 2048, 2560);
  var high = new FuzzySet.RightShoulder(2048, 2560, 3072);

  _FuzzyMemory() {
    sets = [low, medium, high];
    init();
  }
}

class _FuzzyDecision extends FuzzyVariable<int> {
  var remote = new FuzzySet.LeftShoulder(0, 30, 60);
  var local = new FuzzySet.RightShoulder(40, 60, 100);

  _FuzzyDecision() {
    sets = [local, remote];
    init();
  }
}
