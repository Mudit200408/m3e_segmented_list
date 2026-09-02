import 'package:flutter/material.dart';
import 'package:m3e_segmented_list/m3e_segmented_list.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple),
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: const SegmentedListDemo(),
    );
  }
}

class SegmentedListDemo extends StatefulWidget {
  const SegmentedListDemo({super.key});

  @override
  State<SegmentedListDemo> createState() => _SegmentedListDemoState();
}

class _SegmentedListDemoState extends State<SegmentedListDemo> {
  Set<int> _selected = <int>{};
  final List<String> _items = ['Design', 'Develop', 'Test', 'Ship'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('M3E Segmented List')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Interactive & Selectable'),
          M3ESegmentedList(
            itemCount: 4,
            selectedIndices: _selected,
            selectionMode: M3ESelectionMode.multiple,
            showSelectionCheckmark: true,
            onSelectionChanged: (value) => setState(() => _selected = value),
            itemBuilder: (context, index) => M3EListItem(
              leading: const Icon(Icons.person_outline),
              headline: Text('Person $index'),
              supportingText: const Text('Tap to select'),
            ),
          ),
          const SizedBox(height: 32.0),
          const Text('Reorderable'),
          M3EReorderableSegmentedList(
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = _items.removeAt(oldIndex);
                _items.insert(newIndex, item);
              });
            },
            children: [
              for (final item in _items)
                M3EListItem(
                  headline: Text(item),
                  trailing: const Icon(Icons.drag_handle_rounded),
                ),
            ],
          ),
          const SizedBox(height: 32.0),
          const Text('Expandable'),
          M3ESegmentedColumn(
            children: [
              M3EExpandableSegmentedItem(
                index: 0,
                totalCount: 1,
                isExpanded: true,
                onToggle: () {},
                header: const M3EListItem(
                  leading: Icon(Icons.folder_outlined),
                  headline: Text('Folder'),
                ),
                children: const [
                  M3EListItem(headline: Text('Child 1')),
                  M3EListItem(headline: Text('Child 2')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
