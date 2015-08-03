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

library adaptify.example.tasks.fibonacci;

import 'package:adaptify/adaptify.dart';

@Requirement(cpu: Consumption.medium)
class Fibonacci {
  static int calculate(int n) {
    if (n == 0 || n == 1) {
      return n;
    }

    var current = 1;
    var previous = 1;
    for (var i = 2; i < n; i++) {
      var next = previous + current;
      previous = current;
      current = next;
    }
    return current;
  }
}
