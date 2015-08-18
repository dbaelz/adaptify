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

enum Capacity {
  unavailable, low, medium, high
}

class Performance {
  final Capacity memory;
  final Capacity cpu;
  final Capacity bandwidth;

  const Performance({this.cpu: Capacity.unavailable, this.memory: Capacity.unavailable, this.bandwidth: Capacity.unavailable});
}

abstract class BaseMonitor {
  Capacity measureCPU();
  Capacity measureMemory();
  Capacity measureBandwidth();

  Performance retrievePerformanceInfo() {
    return new Performance(cpu: measureCPU(), memory: measureMemory(), bandwidth: measureBandwidth());
  }
}

class InactiveMonitor extends BaseMonitor {
  @override
  Capacity measureBandwidth() {
    return Capacity.unavailable;
  }

  @override
  Capacity measureCPU() {
    return Capacity.unavailable;
  }

  @override
  Capacity measureMemory() {
    return Capacity.unavailable;
  }
}