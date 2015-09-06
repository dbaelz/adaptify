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

library adaptify.example.standalone;

import 'package:adaptify/adaptify.dart';
import 'package:adaptify/standalone.dart';

import 'tasks/fibonacci.dart';

main() async {
  ConsensusDecisionUnit decisionUnit = new ConsensusDecisionUnit([new ConditionalExpression(new SystemToolsMonitor())]);
  String decision = await decisionUnit.shouldExecutedLocal(Fibonacci) ? 'local' : 'remote';
  print('Fibonacci should be executed ${decision}');

}
