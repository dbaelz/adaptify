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

library adaptify.strategy.conditional;

import 'dart:async';

import 'base_strategy.dart';
import '../annotations.dart';
import '../performance_classifier.dart';
import '../monitor/base_monitor.dart';

class ConditionalExpStrategy extends BaseStrategy {
  ConditionalExpStrategy(monitor) : super(monitor);

  @override
  Future<Execution> evaluate(Requirement req) async {
    Measurement measurement = await monitor.retrieveMeasurement();
    Performance perf = new DefaultClassifier().classifyMeasurement(measurement);

    if (req.timeCritical && (perf.bandwidth == Capacity.medium || perf.bandwidth == Capacity.high)) {
      return Execution.remote;
    }

    Execution cpuExec = Execution.local;
    if ((req.cpu == Consumption.medium || req.cpu == Consumption.high) && perf.cpu == Capacity.low) {
      cpuExec = Execution.remote;
    }

    Execution memoryExec = Execution.local;
    if(req.memory != Consumption.low && (perf.memory == Capacity.medium || perf.memory == Capacity.high)) {
      memoryExec = Execution.remote;
    } else if (req.memory == Consumption.medium && perf.memory == Capacity.low) {
      memoryExec = Execution.remote;
    } else if (req.memory == Consumption.high && (perf.memory == Capacity.low || perf.memory == Capacity.medium)) {
      memoryExec = Execution.remote;
    }

    if (cpuExec == Execution.remote || memoryExec == Execution.remote) {
      if (perf.bandwidth == Capacity.medium || perf.bandwidth == Capacity.high) {
        return Execution.remote;
      }
    }
    return Execution.local;
  }
}

class ProfilingOnlyStrategy extends BaseStrategy {
  ProfilingOnlyStrategy(monitor) : super(monitor);

  @override
  Future<Execution> evaluate(Requirement req) {
    if (req.timeCritical && req.bandwidth == Consumption.high) {
      return (new Completer()
        ..complete(Execution.local)).future;
    }

    if ((req.cpu == Consumption.high && req.memory == Consumption.high) && req.bandwidth != Consumption.high) {
      return (new Completer()
        ..complete(Execution.remote)).future;
    }
    return (new Completer()
      ..complete(Execution.local)).future;
  }
}