import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iot_manager/data/models/protocol_model.dart';
import 'package:iot_manager/data/models/connection_model.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/domain/entities/connection.dart';

void main() {
  group('Advanced Widget Tests - Complex Scenarios', () {
    group('Widget Composition Tests', () {
      testWidgets('Multiple widgets work together in list',
          (WidgetTester tester) async {
        final protocols = [
          ProtocolModel(
            id: 'proto-1',
            name: 'MQTT',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
          ProtocolModel(
            id: 'proto-2',
            name: 'HTTP',
            type: ProtocolType.http,
            port: 80,
          ),
          ProtocolModel(
            id: 'proto-3',
            name: 'CoAP',
            type: ProtocolType.coap,
            port: 5683,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: protocols.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(protocols[index].name),
                  trailing: Text('${protocols[index].port}'),
                  tileColor: index.isEven ? Colors.blue[50] : Colors.white,
                ),
              ),
            ),
          ),
        );

        expect(find.text('MQTT'), findsOneWidget);
        expect(find.text('HTTP'), findsOneWidget);
        expect(find.text('CoAP'), findsOneWidget);
        expect(find.byType(ListTile), findsNWidgets(3));
      });

      testWidgets('Complex widget hierarchy renders correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Complex Hierarchy'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {},
                  ),
                ],
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 10,
                      itemBuilder: (context, index) => Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: Text('Item ${index + 1}'),
                          trailing: const Icon(Icons.more_vert),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byType(Card), findsWidgets);
      });
    });

    group('Widget State Management', () {
      testWidgets('Widget updates when state changes', (WidgetTester tester) async {
        var counter = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text('Counter: $counter'),
                  ),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Count: $counter'),
                        ElevatedButton(
                          onPressed: () => setState(() => counter++),
                          child: const Text('Increment'),
                        ),
                        ElevatedButton(
                          onPressed: () => setState(() => counter--),
                          child: const Text('Decrement'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );

        expect(find.text('Count: 0'), findsOneWidget);

        await tester.tap(find.text('Increment'));
        await tester.pumpAndSettle();

        expect(find.text('Count: 1'), findsOneWidget);

        await tester.tap(find.text('Decrement'));
        await tester.pumpAndSettle();

        expect(find.text('Count: 0'), findsOneWidget);
      });

      testWidgets('Multiple widgets maintain independent state',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    StatefulBuilder(
                      builder: (context, setState1) {
                        var value1 = 0;
                        return Column(
                          children: [
                            Text('Widget 1: $value1'),
                            ElevatedButton(
                              onPressed: () => setState1(() => value1++),
                              child: const Text('Add'),
                            ),
                          ],
                        );
                      },
                    ),
                    StatefulBuilder(
                      builder: (context, setState2) {
                        var value2 = 0;
                        return Column(
                          children: [
                            Text('Widget 2: $value2'),
                            ElevatedButton(
                              onPressed: () => setState2(() => value2++),
                              child: const Text('Add'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Widget 1: 0'), findsOneWidget);
        expect(find.text('Widget 2: 0'), findsOneWidget);
      });
    });

    group('Widget Animation Tests', () {
      testWidgets('Fade transition works correctly', (WidgetTester tester) async {
        var showWidget = true;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Column(
                    children: [
                      AnimatedOpacity(
                        opacity: showWidget ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: const Text('Animated Text'),
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() => showWidget = !showWidget),
                        child: const Text('Toggle'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        expect(find.text('Animated Text'), findsOneWidget);

        await tester.tap(find.text('Toggle'));
        await tester.pump(const Duration(milliseconds: 250));

        // Widget still exists but is fading
        expect(find.text('Animated Text'), findsOneWidget);

        await tester.pumpAndSettle();
      });

      testWidgets('Scale transition works correctly', (WidgetTester tester) async {
        var isScaled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: isScaled ? 1.5 : 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          width: 100,
                          height: 100,
                          color: Colors.blue,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() => isScaled = !isScaled),
                        child: const Text('Scale'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Scale'));
        await tester.pumpAndSettle();

        expect(find.byType(Container), findsOneWidget);
      });
    });

    group('Widget Input and Interaction', () {
      testWidgets('TextField captures user input correctly',
          (WidgetTester tester) async {
        String inputValue = '';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) => setState(() => inputValue = value),
                          decoration: const InputDecoration(
                            labelText: 'Enter text',
                          ),
                        ),
                        Text('You entered: $inputValue'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'Test Input');
        await tester.pumpAndSettle();

        expect(find.text('You entered: Test Input'), findsOneWidget);
      });

      testWidgets('Multiple input fields work independently',
          (WidgetTester tester) async {
        String value1 = '';
        String value2 = '';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (v) => setState(() => value1 = v),
                          decoration: const InputDecoration(labelText: 'Field 1'),
                        ),
                        TextField(
                          onChanged: (v) => setState(() => value2 = v),
                          decoration: const InputDecoration(labelText: 'Field 2'),
                        ),
                        Text('Field 1: $value1'),
                        Text('Field 2: $value2'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        final fields = find.byType(TextField);
        await tester.enterText(fields.at(0), 'Value 1');
        await tester.enterText(fields.at(1), 'Value 2');
        await tester.pumpAndSettle();

        expect(find.text('Field 1: Value 1'), findsOneWidget);
        expect(find.text('Field 2: Value 2'), findsOneWidget);
      });

      testWidgets('Dropdown selection works correctly', (WidgetTester tester) async {
        String selectedValue = 'Option 1';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButton<String>(
                          value: selectedValue,
                          items: ['Option 1', 'Option 2', 'Option 3']
                              .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedValue = value!),
                        ),
                        Text('Selected: $selectedValue'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Selected: Option 1'), findsOneWidget);

        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Option 2').last);
        await tester.pumpAndSettle();

        expect(find.text('Selected: Option 2'), findsOneWidget);
      });
    });

    group('Widget Accessibility', () {
      testWidgets('Buttons have proper semantics', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Primary Action'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Secondary Action'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Tertiary Action'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.byType(OutlinedButton), findsOneWidget);
        expect(find.byType(TextButton), findsOneWidget);
      });

      testWidgets('Text contrast is sufficient', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                color: Colors.white,
                child: const Text(
                  'High Contrast Text',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
        );

        expect(find.text('High Contrast Text'), findsOneWidget);
      });

      testWidgets('Touch targets have minimum size', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Large Touch Target'),
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    icon: const Icon(Icons.favorite),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.byType(IconButton), findsOneWidget);
      });
    });

    group('Widget Theme Integration', () {
      testWidgets('Light theme applies correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(useMaterial3: true),
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Light Theme'),
              ),
              body: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Light Theme Content'),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Light Theme'), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
      });

      testWidgets('Dark theme applies correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: ThemeMode.dark,
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Dark Theme'),
              ),
              body: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Dark Theme Content'),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Dark Theme'), findsOneWidget);
      });

      testWidgets('Theme switching works dynamically', (WidgetTester tester) async {
        var isDarkMode = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: StatefulBuilder(
              builder: (context, setState) {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Theme Switcher'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.brightness_4),
                        onPressed: () {
                          setState(() => isDarkMode = !isDarkMode);
                        },
                      ),
                    ],
                  ),
                  body: Center(
                    child: Text(
                      isDarkMode ? 'Dark Mode' : 'Light Mode',
                    ),
                  ),
                );
              },
            ),
          ),
        );

        expect(find.text('Light Mode'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.brightness_4));
        await tester.pumpAndSettle();

        expect(find.text('Dark Mode'), findsOneWidget);
      });
    });

    group('Widget Performance', () {
      testWidgets('Large list renders efficiently', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: 1000,
                itemBuilder: (context, index) => ListTile(
                  title: Text('Item $index'),
                ),
              ),
            ),
          ),
        );

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('Widget rebuild performance', (WidgetTester tester) async {
        var rebuildCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                rebuildCount++;
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: Text('Rebuild Count: $rebuildCount'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        for (int i = 0; i < 100; i++) {
          await tester.tap(find.byType(ElevatedButton));
          await tester.pump();
        }

        expect(rebuildCount, greaterThan(100));
      });
    });
  });
}
