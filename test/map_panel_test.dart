import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gps_mock/providers/app_state.dart';
import 'package:gps_mock/ui/map_view.dart';
import 'package:gps_mock/ui/widgets/m3_segmented_control.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpMap(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>(
        create: (_) => AppState(),
        child: const MaterialApp(home: MapView()),
      ),
    );
    await tester.pump();
  }

  double panelHeight(WidgetTester tester) =>
      tester.getSize(find.byKey(MapViewState.sheetKey)).height;

  testWidgets('control panel starts expanded with its controls visible', (
    tester,
  ) async {
    await pumpMap(tester);

    expect(find.byType(M3SegmentedControl<bool>), findsOneWidget);
    expect(panelHeight(tester), greaterThan(100));
  });

  testWidgets('swiping the handle down hides the panel', (tester) async {
    await pumpMap(tester);
    final expanded = panelHeight(tester);

    await tester.fling(
      find.byKey(MapViewState.sheetHandleKey),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    expect(panelHeight(tester), lessThan(expanded));
    expect(panelHeight(tester), lessThanOrEqualTo(40));
    expect(find.byType(M3SegmentedControl<bool>), findsNothing);
  });

  testWidgets('swiping the handle back up shows the panel again', (
    tester,
  ) async {
    await pumpMap(tester);
    final expanded = panelHeight(tester);

    await tester.fling(
      find.byKey(MapViewState.sheetHandleKey),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.byType(M3SegmentedControl<bool>), findsNothing);

    // A short upward flick steps back to the default stop.
    await tester.fling(
      find.byKey(MapViewState.sheetHandleKey),
      const Offset(0, -60),
      800,
    );
    await tester.pumpAndSettle();

    expect(panelHeight(tester), closeTo(expanded, 1));
    expect(find.byType(M3SegmentedControl<bool>), findsOneWidget);
  });

  testWidgets('a hard upward fling opens the panel fully', (tester) async {
    await pumpMap(tester);
    final expanded = panelHeight(tester);

    await tester.fling(
      find.byKey(MapViewState.sheetHandleKey),
      const Offset(0, -200),
      2000,
    );
    await tester.pumpAndSettle();

    expect(panelHeight(tester), greaterThan(expanded));
  });

  testWidgets('a slow drag down past the halfway point collapses the panel', (
    tester,
  ) async {
    await pumpMap(tester);
    final expanded = panelHeight(tester);

    // A drag (not a fling) releases with ~no velocity, so the panel has to
    // settle on the nearest snap size rather than springing back.
    await tester.drag(
      find.byKey(MapViewState.sheetHandleKey),
      const Offset(0, 300),
    );
    await tester.pumpAndSettle();

    expect(panelHeight(tester), lessThan(expanded / 2));
  });

  testWidgets('flinging the panel body down hides it too', (tester) async {
    await pumpMap(tester);
    final expanded = panelHeight(tester);

    await tester.fling(
      find.byKey(MapViewState.sheetKey),
      const Offset(0, 400),
      1200,
    );
    await tester.pumpAndSettle();

    expect(panelHeight(tester), lessThan(expanded));
    expect(find.byType(M3SegmentedControl<bool>), findsNothing);
  });

  testWidgets('tapping the handle toggles the panel', (tester) async {
    await pumpMap(tester);
    final expanded = panelHeight(tester);

    await tester.tap(find.byKey(MapViewState.sheetHandleKey));
    await tester.pumpAndSettle();
    expect(panelHeight(tester), lessThanOrEqualTo(40));

    await tester.tap(find.byKey(MapViewState.sheetHandleKey));
    await tester.pumpAndSettle();
    expect(panelHeight(tester), closeTo(expanded, 1));
  });
}
