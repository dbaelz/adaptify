/*
 * Copyright (c) 2015, Daniel Bälz
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

library adaptify.strategy.conditional;

import 'dart:async';

import 'base_strategy.dart';
import '../annotations.dart';
import '../performance_classifier.dart';
import '../monitor/base_monitor.dart';

/// An adaption strategy based on conditional expressions.
class ConditionalExpStrategy extends BaseStrategy {
  /// Creates a strategy with the given [monitor] implementation.
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
    if (req.memory != Consumption.low && (perf.memory == Capacity.medium || perf.memory == Capacity.high)) {
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

/// An adaption strategy, that uses only the [Requirement] information and ignores the [BaseMonitor].
class ProfilingOnlyStrategy extends BaseStrategy {
  /// Creates the strategy, the [monitor] implementation is ignored in the evaluation.
  ProfilingOnlyStrategy(monitor) : super(monitor);

  @override
  Future<Execution> evaluate(Requirement req) {
    if (req.timeCritical && req.bandwidth == Consumption.low) {
        return (new Completer()..complete(Execution.remote)).future;
    }

    Execution cpuExec = Execution.local;
    if (req.cpu == Consumption.medium || req.cpu == Consumption.high) {
      if (req.bandwidth == Consumption.low) {
        cpuExec = Execution.remote;
      }
    }

    Execution memoryExec = Execution.local;
    if (req.memory == Consumption.medium && req.bandwidth == Consumption.low) {
      memoryExec = Execution.remote;
    }
    if (req.memory == Consumption.high && (req.bandwidth == Consumption.low || req.bandwidth == Consumption.medium)) {
      memoryExec = Execution.remote;
    }

    if (cpuExec == Execution.remote || memoryExec == Execution.remote) {
      return (new Completer()..complete(Execution.remote)).future;
    }

    return (new Completer()..complete(Execution.local)).future;
  }
}