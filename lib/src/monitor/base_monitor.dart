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

enum Capacity {
  unavailable, low, medium, high
}

class Performance {
  final Capacity memory;
  final Capacity cpu;
  final Capacity bandwidth;

  const Performance({this.cpu: Capacity.unavailable, this.memory: Capacity.unavailable, this.bandwidth: Capacity.unavailable});
}

class Measurement {
  final int memory;
  final int cpu;
  final int bandwidth;

  const Measurement({this.cpu: 0, this.memory: 0, this.bandwidth: 0});
}

abstract class BaseMonitor {
  Future<int> measureCPU();
  Future<int> measureMemory();
  Future<int> measureBandwidth();

  Future<Measurement> retrieveMeasurement() async {
    return new Measurement(cpu: await measureCPU(), memory: await measureMemory(), bandwidth: await measureBandwidth());
  }
}

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
