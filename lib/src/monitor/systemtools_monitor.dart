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

library adaptify.monitor.systemtools;

import 'dart:async';
import 'dart:io';

import 'base_monitor.dart';

/// Provides resource measurements with operating system tools.
///
/// Supports Linux, Mac OS X and Windows.
class SystemToolsMonitor extends BaseMonitor {

  /// Not implemented yet, therefore returns 0 for all platforms.
  @override
  Future<int> measureBandwidth() {
    return (new Completer()..complete(0)).future;
  }

  @override
  Future<int> measureCPU() {
    var value = 0;

    Completer completer = new Completer();
    if (Platform.isLinux) {
      Process.run("cat", ["/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq"]).then((ProcessResult processResult) {
        try {
          value = (int.parse(processResult.stdout)/1000).round();
        } catch (exception) {
          print('Could not fetch CPU information.');
        }
        completer.complete(value);
      });
    } else if (Platform.isMacOS) {
      //TODO: Find a system tool for Mac OS X
      completer.complete(0);
    } else if (Platform.isWindows) {
      //TODO: Find a system tool for windows
      completer.complete(0);
    } else {
      completer.complete(0);
    }
    return completer.future;
  }

  @override
  Future<int> measureMemory() {
    var value = 0;

    Completer completer = new Completer();
    if (Platform.isLinux) {
      Process.run("sh", ["-c", "free -m  | awk 'FNR == 2 {print \$4}'"]).then((ProcessResult processResult) {
        String result = processResult.stdout;
        try {
          value = int.parse(result.trim());
        } catch (exception) {
          print('Could not fetch memory information.');
        }
        completer.complete(value);
      });
    } else if (Platform.isMacOS) {
      //TODO: Find a system tool for Mac OS X
      completer.complete(0);
    } else if (Platform.isWindows) {
      Process.run("wmic", ["os get FreePhysicalMemory"]).then((ProcessResult processResult) {
        String result = processResult.stdout;
        String stringValue = result.split('\n')[1];
        try {
          value = int.parse(stringValue.trim());
          value = (value/1024).round();
        } catch (exception) {
          print('Could not fetch memory information.');
        }
        completer.complete(value);
      });
    } else {
      completer.complete(0);
    }
    return completer.future;
  }
}


