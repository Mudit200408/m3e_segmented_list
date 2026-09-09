import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:m3e_segmented_list/m3e_segmented_list.dart';

void main() {
  group('M3ESegmentedColumn isVisible', () {
    testWidgets('a collapsed child adds no gap between its neighbours', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          M3ESegmentedColumn(
            gap: 6,
            padding: EdgeInsets.zero,
            children: [_cell('A'), _cell('C')],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final baseline = _verticalSeam(tester, 'A', 'C');

      await tester.pumpWidget(
        _app(
          M3ESegmentedColumn(
            gap: 6,
            padding: EdgeInsets.zero,
            isVisible: (index) => index != 1,
            children: [_cell('A'), const SizedBox.shrink(), _cell('C')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_verticalSeam(tester, 'A', 'C'), baseline);
      expect(baseline, 6);
    });

    testWidgets('a hidden trailing child does not steal the last position', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          M3ESegmentedColumn(
            isVisible: (index) => index != 2,
            children: [_cell('A'), _cell('B'), const SizedBox.shrink()],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final items = _items(tester);
      expect(items[0].position, M3ESegmentedItemPosition.first);
      expect(items[1].position, M3ESegmentedItemPosition.last);
      expect(items[2].position, M3ESegmentedItemPosition.middle);
    });

    testWidgets('a hidden leading child does not steal the first position', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          M3ESegmentedColumn(
            isVisible: (index) => index != 0,
            children: [const SizedBox.shrink(), _cell('A'), _cell('B')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final items = _items(tester);
      expect(items[0].position, M3ESegmentedItemPosition.middle);
      expect(items[1].position, M3ESegmentedItemPosition.first);
      expect(items[2].position, M3ESegmentedItemPosition.last);
    });

    testWidgets('a single visible child is positioned as single', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          M3ESegmentedColumn(
            isVisible: (index) => index == 1,
            children: [
              const SizedBox.shrink(),
              _cell('A'),
              const SizedBox.shrink(),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_items(tester)[1].position, M3ESegmentedItemPosition.single);
    });

    testWidgets('hidden children carry no gap, padding, or interaction', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          M3ESegmentedColumn(
            padding: const EdgeInsets.all(12),
            onTap: (_) {},
            isVisible: (index) => index != 1,
            children: [_cell('A'), _cell('B'), _cell('C')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final items = _items(tester);
      expect(items[1].isLast, isTrue);
      expect(items[1].padding, EdgeInsets.zero);
      expect(items[1].enabled, isFalse);
      expect(items[1].onTap, isNull);

      expect(items[0].isLast, isNull);
      expect(items[0].padding, const EdgeInsets.all(12));
      expect(items[0].enabled, isTrue);
      expect(items[0].onTap, isNotNull);
    });

    testWidgets('isVisible and isEnabled combine', (tester) async {
      await tester.pumpWidget(
        _app(
          M3ESegmentedColumn(
            onTap: (_) {},
            isEnabled: (index) => index != 2,
            isVisible: (index) => index != 1,
            children: [_cell('A'), _cell('B'), _cell('C')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final items = _items(tester);
      expect(items[0].enabled, isTrue);
      expect(items[1].enabled, isFalse);
      expect(items[2].enabled, isFalse);
      // Hidden index 1 is excluded, so A and C are first and last.
      expect(items[0].position, M3ESegmentedItemPosition.first);
      expect(items[2].position, M3ESegmentedItemPosition.last);
    });

    testWidgets('callbacks keep reporting the raw child index', (tester) async {
      final taps = <int>[];
      final labels = <int>[];

      await tester.pumpWidget(
        _app(
          M3ESegmentedColumn(
            isVisible: (index) => index != 0,
            onTap: taps.add,
            semanticLabelBuilder: (index) {
              labels.add(index);
              return 'label-$index';
            },
            children: [const SizedBox.shrink(), _cell('A'), _cell('B')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('B')));
      await tester.pumpAndSettle();

      expect(taps, [2]);
      expect(labels, [1, 2]);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == 'label-0',
        ),
        findsNothing,
      );
    });

    testWidgets('selection reports the raw child index', (tester) async {
      final selections = <Set<int>>[];

      await tester.pumpWidget(
        _app(
          M3ESegmentedColumn(
            selectionMode: M3ESelectionMode.multiple,
            isVisible: (index) => index != 1,
            onSelectionChanged: selections.add,
            children: [_cell('A'), const SizedBox.shrink(), _cell('C')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('C')));
      await tester.pumpAndSettle();

      expect(selections.last, {2});
    });

    testWidgets('a null isVisible reproduces the positional behaviour', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          M3ESegmentedColumn(children: [_cell('A'), _cell('B'), _cell('C')]),
        ),
      );
      await tester.pumpAndSettle();

      final items = _items(tester);
      expect(items[0].position, M3ESegmentedItemPosition.first);
      expect(items[1].position, M3ESegmentedItemPosition.middle);
      expect(items[2].position, M3ESegmentedItemPosition.last);
      expect(items.every((item) => item.isLast == null), isTrue);
    });
  });

  group('M3ESegmentedRow isVisible', () {
    testWidgets('a collapsed child adds no gap between its neighbours', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          M3ESegmentedRow(
            gap: 6,
            padding: EdgeInsets.zero,
            equalWidth: false,
            children: [_wideCell('A'), _wideCell('C')],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final baseline = _horizontalSeam(tester, 'A', 'C');

      await tester.pumpWidget(
        _app(
          M3ESegmentedRow(
            gap: 6,
            padding: EdgeInsets.zero,
            equalWidth: false,
            isVisible: (index) => index != 1,
            children: [_wideCell('A'), const SizedBox.shrink(), _wideCell('C')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_horizontalSeam(tester, 'A', 'C'), baseline);
      expect(baseline, 6);
    });

    testWidgets('a hidden child takes no share of an equal-width row', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          M3ESegmentedRow(
            gap: 6,
            padding: EdgeInsets.zero,
            isVisible: (index) => index != 1,
            children: [_wideCell('A'), const SizedBox.shrink(), _wideCell('C')],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Without excluding the hidden child from flex distribution it would keep
      // an Expanded slot and leave a blank stretch a third of the row wide.
      expect(_horizontalSeam(tester, 'A', 'C'), 6);

      final row = tester.getRect(find.byType(M3ESegmentedRow));
      final a = tester.getRect(find.byKey(const ValueKey('A')));
      final c = tester.getRect(find.byKey(const ValueKey('C')));
      // The two visible cells plus the single gap between them fill the row
      // exactly, so the hidden child left no blank share behind.
      expect(a.width + 6 + c.width, row.width);
      expect(a.left, row.left);
      expect(c.right, row.right);
    });

    testWidgets('a hidden trailing child does not steal the last position', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          M3ESegmentedRow(
            equalWidth: false,
            isVisible: (index) => index != 2,
            children: [_wideCell('A'), _wideCell('B'), const SizedBox.shrink()],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final items = _items(tester);
      expect(items[0].position, M3ESegmentedItemPosition.first);
      expect(items[1].position, M3ESegmentedItemPosition.last);
      expect(items[1].axis, Axis.horizontal);
    });
  });
}

Widget _cell(String label) =>
    SizedBox(key: ValueKey(label), height: 40, child: Text(label));

Widget _wideCell(String label) =>
    SizedBox(key: ValueKey(label), width: 60, height: 40, child: Text(label));

Widget _app(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

List<M3ESegmentedItem> _items(WidgetTester tester) =>
    tester.widgetList<M3ESegmentedItem>(find.byType(M3ESegmentedItem)).toList();

double _verticalSeam(WidgetTester tester, String before, String after) {
  final first = tester.getRect(find.byKey(ValueKey(before)));
  final second = tester.getRect(find.byKey(ValueKey(after)));
  return second.top - first.bottom;
}

double _horizontalSeam(WidgetTester tester, String before, String after) {
  final first = tester.getRect(find.byKey(ValueKey(before)));
  final second = tester.getRect(find.byKey(ValueKey(after)));
  return second.left - first.right;
}
