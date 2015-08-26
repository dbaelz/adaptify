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

library adaptify.example.fuzzy;

import 'dart:async';
import 'dart:math';

import 'package:adaptify/adaptify.dart';

import 'tasks/fibonacci.dart';

main() async {
  DecisionUnit dc = new DecisionUnit(new FuzzyLogic(new RandomFuzzyMonitor()));
  String decision = await dc.shouldExecutedLocal(Fibonacci) ? 'local' : 'remote';
  print('Fibonacci should be executed ${decision}');
}

class RandomFuzzyMonitor extends BaseMonitor {
  @override
  Future<int> measureBandwidth() {
    int value = new Random().nextInt(2048);
    print('Bandwidth: $value');
    return (new Completer()..complete(value)).future;
  }

  @override
  Future<int> measureCPU() {
    int value = new Random().nextInt(4096);
    print('CPU: $value');
    return (new Completer()..complete(value)).future;
  }

  @override
  Future<int> measureMemory() {
    int value = new Random().nextInt(3072);
    print('Memory: $value');
    return (new Completer()..complete(value)).future;
  }
}
