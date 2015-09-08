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

library adaptify.example.monitor.observatory;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adaptify/adaptify.dart';

/// Standalone Monitor which uses the services provided by the VM for Observatory.
///
/// Activate this services with the `--observe` flag. Connection is established with a WebSocket.
///
/// The documentation of the interfaces in the vm is still incomplete and work in progress.
/// [Documentation on GitHub]
/// (https://github.com/dart-lang/sdk/blob/master/runtime/vm/service/service.md)
/// [C++ file]
/// (https://github.com/dart-lang/sdk/blob/master/runtime/vm/service.cc)
class ObservatoryMonitor extends BaseMonitor {
  String hostname;
  int port;
  _VirtualMachine _virtualMachine;

  ObservatoryMonitor({String this.hostname: 'localhost', int this.port: 8181});

  @override
  Future<int> measureBandwidth() {
    return (new Completer()..complete(0)).future;
  }

  @override
  Future<int> measureCPU() async {
    await _getVMInfo();
    int value = 0;
    if (_virtualMachine != null) {
      String cpuInfo = _virtualMachine.hostCPU;
      cpuInfo = cpuInfo.substring(cpuInfo.indexOf('@'));
      cpuInfo = cpuInfo.replaceAll(new RegExp('[^0-9.]'), '');
      try {
        value = (double.parse(cpuInfo) * 1000).round();
      } catch (exception) {
        print('Could not fetch cpu information.');
      }
    }
    return value;
  }

  @override
  Future<int> measureMemory() async {
    return (new Completer()..complete(0)).future;
  }

  Future _getVMInfo() async {
    if (_virtualMachine == null) {
      var connector;
      var response;

      try {
        connector = await _ObservatoryConnector.create(hostname, port);
        response = await connector.request('getVM');
        connector.close();
      } catch (exception) {
        return;
      }

      List<_Isolate> isolates = [];
      response['isolates'].forEach((element) {
        isolates.add(new _Isolate(element['fixedId'], element['id'], element['name'], element['number']));
      });

      _virtualMachine = new _VirtualMachine(response['architectureBits'], response['targetCPU'],
          response['hostCPU'], response['version'], response['pid'], response['startTime'], isolates);
    }
  }
}

class _ObservatoryConnector {
  WebSocket _socket;
  Map<int, Completer> _requests = {};
  int _requestId = 1;

  _ObservatoryConnector(WebSocket this._socket) {
    _socket.listen(_handleResponse);
  }

  static Future<_ObservatoryConnector> create(String host, int port) async {
    try {
      WebSocket socket = await WebSocket.connect('ws://$host:$port/ws');
      return new _ObservatoryConnector(socket);
    } catch (exception) {
      return;
    }
  }

  Future close() async => await _socket.close();

  Future<Map> request(String method, [Map params = const {}]) async {
    if (_socket != null) {
      _requests[_requestId] = new Completer();
      _socket.add(JSON.encode({'id': _requestId, 'method': method, 'params': params,}));
      return _requests[_requestId++].future;
    }
    return {};
  }

  _handleResponse(String jsonResponse) {
    print(jsonResponse);
    var decoded = JSON.decode(jsonResponse);
    var id = int.parse(decoded['id']);
    var resultData = decoded['result'];
    if (id == null || resultData == null) {
      return;
    }

    var completer = _requests.remove(id);
    if (completer == null) {
      return;
    }
    completer.complete(resultData);
  }
}

class _VirtualMachine {
  final int architectureBits;
  final String targetCPU;
  final String hostCPU;
  final String version;
  final String pid;
  final int startTime;
  final List<_Isolate> isolates;

  _VirtualMachine(this.architectureBits, this.targetCPU, this.hostCPU,
      this.version, this.pid, this.startTime, this.isolates);
}

class _Isolate {
  final bool fixedId;
  final String id;
  final String name;
  final String number;

  _Isolate(this.fixedId, this.id, this.name, this.number);
}
