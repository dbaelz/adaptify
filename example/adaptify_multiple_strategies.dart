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

library adaptify.example.multiple_strategies;

import 'package:adaptify/adaptify.dart';
import 'package:adaptify/standalone.dart';

import 'monitor/random_monitor.dart';
import 'tasks/fibonacci.dart';

main() async {
  List<BaseStrategy> strategies = new List<BaseStrategy>()
    ..add(new FuzzyLogicStrategy(new RandomMonitor()))
    ..add(new ConditionalExpStrategy(new SystemToolsMonitor()))
    ..add(new ConditionalExpStrategy(new RandomMonitor()));
  ConsensusDecisionUnit decisionUnitMultiple = new ConsensusDecisionUnit(strategies);

  String decisionMultiple = await decisionUnitMultiple.shouldExecuteLocally(Fibonacci) ? 'locally' : 'remotely';
  print('Fibonacci should be executed ${decisionMultiple}');
}