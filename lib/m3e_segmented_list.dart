/// Material 3 Expressive Segmented List components.
///
/// Provides expressive, Material 3 compliant segmented lists with dynamically rounded
/// corners, selection support, and spring physics for reorderable variants.
///
/// ## Components
///
/// - `M3ESegmentedList` - Interactive segmented list with selection support
/// - `M3ESegmentedColumn` - Static segmented column for small lists
/// - `SliverM3ESegmentedList` - Sliver variant for CustomScrollView
/// - `M3ESegmentedItem` - Individual segmented item widget
/// - `M3EExpandableSegmentedItem` - Expandable folder-like item
/// - `M3EReorderableSegmentedList` - Spring-physics reorderable list
///
/// ## Features
///
/// - **Dynamically rounded corners**: First and last items have larger outer radii,
///   inner items have smaller inner radii, adhering to Material 3's expressive design.
/// - **Selection support**: Tappable items with visual feedback.
/// - **Customizable styling**: Through `M3ESegmentedListDecoration`.
/// - **Spring physics**: Smooth animations for interactions.
/// - **Expandable items**: Folder-like parent-child containers.
///
/// ## Usage
///
/// ```dart
/// M3ESegmentedList(
///   itemCount: 5,
///   itemBuilder: (context, index) => M3EListItem(
///     headline: 'Item $index',
///   ),
///   outerRadius: 24.0,
/// )
/// ```
library;

export 'src/segmented_list.dart';
