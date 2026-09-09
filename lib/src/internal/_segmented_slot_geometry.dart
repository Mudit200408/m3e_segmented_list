import '../m3e_segmented_item.dart';

/// The geometry a static segmented container gives the child at one raw index.
///
/// Produced by [resolveSegmentedSlots].
class SegmentedSlotGeometry {
  const SegmentedSlotGeometry({
    required this.isVisible,
    required this.position,
  });

  /// Whether the child occupies a slot in the segmented layout.
  final bool isVisible;

  /// Position among the *visible* children only.
  ///
  /// For a hidden child this is [M3ESegmentedItemPosition.middle]. The value is
  /// inert: the container also suppresses the child's gap and corner influence,
  /// so a hidden child paints no chrome of its own.
  final M3ESegmentedItemPosition position;
}

/// Maps a static child list onto the geometry each child should receive.
///
/// `M3ESegmentedColumn` and `M3ESegmentedRow` derive both the corner radii and
/// the trailing gap of an item from its position (first / middle / last /
/// single). Computing that position from the raw child index means a child that
/// paints nothing — a collapsed row, or a platform-conditional row the caller
/// deliberately keeps mounted so it can animate out — still consumes a gap of
/// its own *and* shifts the radii of every neighbour around it.
///
/// This resolves [isVisible] once per build and returns one
/// [SegmentedSlotGeometry] per raw index, so geometry follows what is actually
/// on screen while `index`-keyed callbacks keep reporting the raw index the
/// caller supplied.
///
/// Passing `null` for [isVisible] reproduces the positional behaviour exactly.
List<SegmentedSlotGeometry> resolveSegmentedSlots({
  required int count,
  bool Function(int index)? isVisible,
}) {
  if (isVisible == null) {
    return List<SegmentedSlotGeometry>.generate(
      count,
      (index) => SegmentedSlotGeometry(
        isVisible: true,
        position: calculateSegmentedItemPosition(index, count),
      ),
    );
  }

  final visibleIndices = <int>[];
  for (var index = 0; index < count; index++) {
    if (isVisible(index)) visibleIndices.add(index);
  }

  final ordinalByIndex = <int, int>{};
  for (var ordinal = 0; ordinal < visibleIndices.length; ordinal++) {
    ordinalByIndex[visibleIndices[ordinal]] = ordinal;
  }

  return List<SegmentedSlotGeometry>.generate(count, (index) {
    final ordinal = ordinalByIndex[index];
    if (ordinal == null) {
      return const SegmentedSlotGeometry(
        isVisible: false,
        position: M3ESegmentedItemPosition.middle,
      );
    }
    return SegmentedSlotGeometry(
      isVisible: true,
      position: calculateSegmentedItemPosition(ordinal, visibleIndices.length),
    );
  });
}
