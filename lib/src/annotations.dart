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

/// Resource consumption of a task.
enum Consumption {
  low, medium, high
}

/// Resource requirement of a task.
///
/// This class is either used by initialization or via class annotation.
class Requirement {
  final Consumption cpu;
  final Consumption memory;
  final Consumption bandwidth;
  final bool timeCritical;

  const Requirement({this.cpu: Consumption.low, this.memory: Consumption.low, this.bandwidth: Consumption.low, this.timeCritical: false});
}

/// A parser for class annotations.
class AnnotationParser {
  /// Parses the given [classType] class for the [Requirement] annotation.
  ///
  /// Returns null if the annotation does not exist.
  static Requirement getRequirement(Type classType) {
    return getMetadata(classType, Requirement);
  }

  /// Parses the given [classType] class for the [annotation].
  ///
  /// Returns null if the annotation does not exist.
  static dynamic getMetadata(Type classType, Type annotation) {
    ClassMirror classMirror = reflectClass(classType);
    var annotations = classMirror.metadata.where((element) => element.reflectee.runtimeType == annotation).toList();
    if (annotations.length == 1) {
      return annotations.first.reflectee;
    }
    return null;
  }
}