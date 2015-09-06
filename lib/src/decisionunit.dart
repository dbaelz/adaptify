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

abstract class BaseDecisionUnit {
  List<BaseStrategy> strategies;

  BaseDecisionUnit(List<BaseStrategy> this.strategies);

  Future<bool> shouldExecutedLocal(Type classType);
}

class ConsensusDecisionUnit extends BaseDecisionUnit {
  ConsensusDecisionUnit(List<BaseStrategy> strategies) : super(strategies);

  @override
  Future<bool> shouldExecutedLocal(Type classType) async {
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