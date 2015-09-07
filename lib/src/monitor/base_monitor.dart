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
