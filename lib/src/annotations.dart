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

library adaptify.annotations;

@MirrorsUsed(metaTargets: Requirement)
import 'dart:mirrors';

enum Consumption {
  low, medium, high
}

class Requirement {
  final Consumption memory;
  final Consumption cpu;
  final Consumption bandwidth;
  final bool timeCritical;

  const Requirement({this.memory: Consumption.low, this.cpu: Consumption.low, this.bandwidth: Consumption.low, this.timeCritical: false});
}

class AnnotationParser {
  static Requirement getRequirement(Type classType) {
    return getMetadata(classType, Requirement);
  }

  static dynamic getMetadata(Type classType, Type annotation) {
    ClassMirror classMirror = reflectClass(classType);
    var annotations = classMirror.metadata.where((element) => element.reflectee.runtimeType == annotation).toList();
    if (annotations.length == 1) {
      return annotations.first.reflectee;
    }
    return null;
  }
}