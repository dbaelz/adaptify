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

library adaptify.performance_classifier;

import 'monitor/base_monitor.dart';

enum Capacity {
  unavailable, low, medium, high
}

class Performance {
  final Capacity memory;
  final Capacity cpu;
  final Capacity bandwidth;

  const Performance(this.bandwidth, this.cpu, this.memory);
}

abstract class BaseClassifier {
  Performance classifyMeasurement(Measurement measurement);
}

class DefaultClassifier extends BaseClassifier {
  @override
  Performance classifyMeasurement(Measurement measurement) {
    Capacity bandwidth = Capacity.unavailable;
    Capacity cpu = Capacity.unavailable;
    Capacity memory = Capacity.unavailable;

    if (measurement.bandwidth >= 384) {
      bandwidth = Capacity.high;
    } else if (measurement.bandwidth >= 96) {
      bandwidth = Capacity.medium;
    } else if (measurement.bandwidth >= 0) {
      bandwidth = Capacity.low;
    }

    if (measurement.cpu >= 1792) {
      cpu = Capacity.high;
    } else if (measurement.cpu >= 640) {
      cpu = Capacity.medium;
    } else if (measurement.cpu >= 0) {
      cpu = Capacity.low;
    }
    
    if (measurement.memory >= 2048) {
      memory = Capacity.high;
    } else if (measurement.memory >= 1024) {
      memory = Capacity.medium;
    } else if (measurement.memory >= 0) {
      memory = Capacity.low;
    }

    return new Performance(bandwidth, cpu, memory);
  }
}
