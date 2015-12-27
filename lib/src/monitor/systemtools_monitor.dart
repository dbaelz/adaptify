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

library adaptify.monitor.systemtools;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'base_monitor.dart';

/// Provides resource measurements with operating system tools.
///
/// Supports Linux, Mac OS X and Windows.
class SystemToolsMonitor extends BaseMonitor {

  /// Not supported yet, therefore returns 0 for all platforms.
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
      Process.run("sysctl", ["-n", 'hw.cpufrequency_max']).then((ProcessResult processResult) {
        String result = (processResult.stdout).trim();
        try {
          value = int.parse(result);
          value = (value / (1000*1000)).round();
        } catch (exception) {
          print('Could not fetch CPU information.');
        }
        completer.complete(value);
      });
    } else if (Platform.isWindows) {
      Process.run("wmic", ["cpu get MaxClockSpeed"]).then((ProcessResult processResult) {
        String result = processResult.stdout;
        String stringValue = (result.split('\n')[1]).trim();
        try {
          value = int.parse(stringValue);
        } catch (exception) {
          print('Could not fetch CPU information.');
        }
        completer.complete(value);
      });
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
      Process.start('free', ['-m']).then((p1) {
        Process.start('awk', ['FNR == 2 {print \$4}']).then((p2) {
          p1.stdout.pipe(p2.stdin);
          p2.stdout.transform(UTF8.decoder).listen((data) {
            try {
              value = int.parse(data.trim());
            } catch (exception) {
              print('Could not fetch memory information.');
            }
            completer.complete(value);
          });
        });
      });
    } else if (Platform.isMacOS) {
      Process.run("sysctl", ["-n", 'hw.memsize']).then((ProcessResult processResult) {
        String result = (processResult.stdout).trim();
        try {
          value = int.parse(result);
          value = (value / (1024*1024)).round();
        } catch (exception) {
          print('Could not fetch memory information.');
        }
        completer.complete(value);
      });
    } else if (Platform.isWindows) {
      Process.run("wmic", ["os get FreePhysicalMemory"]).then((ProcessResult processResult) {
        String result = processResult.stdout;
        String stringValue = result.split('\n')[1];
        try {
          value = int.parse(stringValue.trim());
          value = (value / 1024).round();
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


