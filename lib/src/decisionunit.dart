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

library adaptify.decision;

import 'dart:async';

import 'annotations.dart';
import 'strategy/base_strategy.dart';

/// The abstract decision unit.
abstract class BaseDecisionUnit {
  /// List of all the strategies that should be evaluated for decision making.
  List<BaseStrategy> strategies;

  /// Creates a decision unit with the given list of [strategies].
  BaseDecisionUnit(List<BaseStrategy> this.strategies);

  /// Returns true if the task should be executed local, otherwise false.
  ///
  /// This method usually evaluates all [strategies] for the decision.
  Future<bool> shouldExecuteLocally(Type classType);
}

/// The decision unit that evaluates all strategies and performs a consensus decision.
class ConsensusDecisionUnit extends BaseDecisionUnit {
  /// Creates a decision unit with the given list of [strategies].
  ConsensusDecisionUnit(List<BaseStrategy> strategies) : super(strategies);


  /// Returns true if the task should be executed local, otherwise false.
  ///
  /// Performs a consensus decision of the [strategies].
  /// In case of a tie, it returns true.
  @override
  Future<bool> shouldExecuteLocally(Type classType) async {
    Requirement req = AnnotationParser.getRequirement(classType);
    if (req == null) {
      req = new Requirement();
    }

    if (strategies.isNotEmpty) {
      int countLocal = 0;
      int countRemote = 0;
      for (BaseStrategy strategy in strategies) {
        Execution decision = await strategy.evaluate(req);
        if (decision == Execution.local){
          countLocal++;
        } else {
          countRemote++;
        }
      }
      if (countLocal >= countRemote) {
        return true;
      }
      return false;
    }
    return true;
  }
}