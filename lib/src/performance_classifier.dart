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

library adaptify.performance_classifier;

import 'monitor/base_monitor.dart';

/// Capacity of a resource.
enum Capacity {
  unavailable, low, medium, high
}

/// Performance (in [Capacity] classification) of a task.
class Performance {
  final Capacity memory;
  final Capacity cpu;
  final Capacity bandwidth;

  const Performance(this.bandwidth, this.cpu, this.memory);
}

/// Abstract classifier for classification of [Measurement] information into a [Performance] class.
abstract class BaseClassifier {
  /// Classifies the [measurement] into a [Performance] object.
  Performance classifyMeasurement(Measurement measurement);
}

/// Default classifier, that classifies the [measurement] with given limits.
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
