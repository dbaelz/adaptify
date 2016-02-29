# Adaptify
A library for adaptive decision-making with Dart. It supports the Dart VM and the browser with dart2js.
This library was initially created for my master's thesis.
Also, a second library for code distribution, called [Code Mobility](https://github.com/dbaelz/code_mobility), was developed.
For more information on this topic see the [blog post](https://blog.inovex.de/adaptive-code-execution-with-dart/) on the blog of my employer [inovex GmbH](https://www.inovex.de/).

For information how to use the library in a project see the description on the [Pub Repository](https://pub.dartlang.org/packages/adaptify).

Description
---------
The Adaptify library is responsible for the decision-making. It utilizes the three basic resources CPU, memory and bandwidth.
For every task used with Adaptify metadata with consumption information for the three resources must be defined.
In the metadata the resource requirement is graded into low, medium or high consumption.
Additionally, there is a fourth metadata which defines whether a task is time-critical.

Several components of the library interact with each other for the decision-making.
At first the resource requirements of a task, as defined before, are determined.
In addition, the monitor component provides information about the current capacity of the device.
Both information sources are evaluated by an adaptation strategy and a decision is made.
Adaptify is able to make a decision based on the resource requirements alone, if no monitor information has been collected or the adaptation strategy doesn't intend the use of a monitor.
The decision is then forwarded to the decision unit which determines a final result and returns it to the application.
The decision unit may further process the decision of an adaptation strategy.
For example, several adaptation strategies can be evaluated within a decision unit.
Subsequently, the decisions are collected and the result is determined by a majority decision.

The implementation with Dart provides several challenges.
At first the two very different runtime environments (Dart VM and browser) offer different and very limited options to acquire the capacity information of a system.
Furthermore, the comparability of measurements on different devices is a problem that makes it hard to use the results in an adaptation strategy.
The implementation and conducted tests revealed that it's difficult to capture meaningful results for the three resources in both runtimes.
Especially the browser complicates the data collection and only limited information are available.
Therefore, the manual user input of the performance values is a good strategy to collect information for the monitor.
In addition to the collection of information a good adaptation strategy is important.
Adaptify currently provides two strategies based on conditional expressions and fuzzy logic.
They are tested with user provided values and have proven their suitable for the decision-making in tests.

Development
-----------
For feedback and bug reports just open an issue. Feel free to fork this project, create pull request and contact me for any questions.

Documentation
-------------
The features are explained in the [dartdoc](https://github.com/dart-lang/dartdoc) documentation and the [example implementations](https://github.com/dbaelz/adaptify/blob/master/example).


License
-------------
Adaptify is licensed under the [BSD License](https://github.com/dbaelz/adaptify/blob/master/LICENSE).
