# Adaptify

A library for adaptive decision-making with Dart, supporting the standalone VM and dart2js.

The goal of Adaptify is to determine, if a task should be executed locally or remotely.
For decision-making an implementation of the abstract class `BaseDecisionUnit` is used.
This implementation requires a list of adaption strategies, implementations of the abstract class `BaseStrategy`.
Each strategy uses an implementation of the `BaseMonitor` class, which measures the CPU, memory and bandwidth.
See the `dartdoc` for further information.


License
-------------
Adaptify is licensed under the [BSD License](https://github.com/dbaelz/adaptify/blob/master/LICENSE).
