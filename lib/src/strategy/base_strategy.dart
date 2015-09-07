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

library adaptify.strategy.base;

import 'dart:async';

import '../annotations.dart';
import '../monitor/base_monitor.dart';

enum Execution {
  local, remote
}

/// The abstract strategy for adaption decisions.
abstract class BaseStrategy {
  BaseMonitor monitor;

  /// Creates a strategy with the given [monitor] implementation.
  BaseStrategy(BaseMonitor this.monitor);

  /// Returns a [:Future<Execution>:] that completes after the evaluation of the [req] and [monitor] is done.
  ///
  /// This method contains the adaption logic for the implemented strategy.
  /// Usually, the requirements are compared with the measurements of the monitor.
  Future<Execution> evaluate(Requirement req);
}
