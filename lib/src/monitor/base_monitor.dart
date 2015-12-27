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

library adaptify.monitor;

import 'dart:async';

/// Accumulates the results of measurement.
class Measurement {
  final int memory;
  final int cpu;
  final int bandwidth;

  const Measurement({this.cpu: 0, this.memory: 0, this.bandwidth: 0});
}

/// The abstract monitor class for measuring resources.
///
/// Resource information are either collected separate by the [measureCPU], [measureMemory] and [measureBandwidth] methods
/// or together with [retrieveMeasurement].
abstract class BaseMonitor {

  /// Returns a [:Future<int>:] that completes with the maximum frequency of a CPU core in MHz.
  ///
  /// Returns 0 if the value could not be determined.
  Future<int> measureCPU();

  /// Returns a [:Future<int>:] that completes with the free or maximum available memory in MB.
  ///
  /// Returns 0 if the value could not be determined.
  Future<int> measureMemory();

  /// Returns a [:Future<int>:] that completes with the maximum bandwidth in kbit/s.
  ///
  /// Returns 0 if the value could not be determined.
  Future<int> measureBandwidth();


  /// Returns a [:Future<Measurement>:] that completes with a [:Measurement:] object containing CPU, memory and bandwidth measurement.
  Future<Measurement> retrieveMeasurement() async {
    return new Measurement(cpu: await measureCPU(), memory: await measureMemory(), bandwidth: await measureBandwidth());
  }
}

/// Monitor that returns 0 for all measurements.
class InactiveMonitor extends BaseMonitor {
  @override
  Future<int> measureBandwidth() {
    return (new Completer()..complete(0)).future;
  }

  @override
  Future<int> measureCPU() {
    return (new Completer()..complete(0)).future;
  }

  @override
  Future<int> measureMemory() {
    return (new Completer()..complete(0)).future;
  }
}
