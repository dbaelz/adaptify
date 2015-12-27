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