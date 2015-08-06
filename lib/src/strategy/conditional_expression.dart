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

import 'base_strategy.dart';
import '../annotations.dart';

class ConditionalExpression extends BaseStrategy {
  ConditionalExpression(monitor) : super(monitor);

  @override
  Execution evaluate(Requirement req) {
    // TODO: Add real algorithm
    if (req.cpu == Consumption.high && req.memory == Consumption.high) {
      return Execution.remote;
    }
    return Execution.local;
  }
}

class ProfilingConditionalExpression extends BaseStrategy {
  ProfilingConditionalExpression(monitor) : super(monitor);

  @override
  Execution evaluate(Requirement req) {
    if (req.timeCritical && req.bandwidth == Consumption.high) {
      return Execution.local;
    }

    if ((req.cpu == Consumption.high && req.memory == Consumption.high) && req.bandwidth != Consumption.high) {
      return Execution.remote;
    }
    return Execution.local;
  }
}