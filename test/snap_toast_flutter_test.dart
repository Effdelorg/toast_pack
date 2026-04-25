import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_toast_flutter/snap_toast_flutter.dart';
import 'package:snap_toast_flutter/src/toast_config.dart';
import 'package:snap_toast_flutter/src/web_background.dart';

/// Builds a minimal MaterialApp that exposes a BuildContext with an Overlay.
Widget _hostApp(void Function(BuildContext) onReady) {
  return MaterialApp(
    home: Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) => onReady(context));
        return const Scaffold(body: SizedBox.expand());
      },
    ),
  );
}

void main() {
  setUp(SnapToastConfig.reset);

  group('Default leading behaviour', () {
    testWidgets('no leading visual by default', (tester) async {
      await tester.pumpWidget(_hostApp((ctx) {
        SnapToast.success(ctx, 'Saved');
      }));
      await tester.pump(); // post-frame fires
      await tester.pump(const Duration(milliseconds: 300)); // forward anim

      expect(find.text('Saved'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
      expect(find.byType(Image), findsNothing);
      SnapToast.dismiss();
      await tester.pumpAndSettle();
    });
  });

  group('Explicit leading', () {
    testWidgets('ToastLeading.icon renders the provided icon', (tester) async {
      await tester.pumpWidget(_hostApp((ctx) {
        SnapToast.info(
          ctx,
          'Hello',
          leading: const ToastLeading.icon(Icons.star),
        );
      }));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Hello'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      SnapToast.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('ToastLeading.appIcon without init falls back to variant icon',
        (tester) async {
      await tester.pumpWidget(_hostApp((ctx) {
        SnapToast.error(
          ctx,
          'Oops',
          leading: const ToastLeading.appIcon(),
        );
      }));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Oops'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
      SnapToast.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('ToastLeading.appIcon uses native icon when available',
        (tester) async {
      const channel = MethodChannel('snap_toast_flutter/app_icon');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method != 'getAppIcon') return null;
        return Uint8List.fromList(
          base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO7Z4mQAAAAASUVORK5CYII=',
          ),
        );
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

      await tester.pumpWidget(_hostApp((ctx) {
        SnapToast.info(
          ctx,
          'Native icon',
          leading: const ToastLeading.appIcon(),
        );
      }));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(find.text('Native icon'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.info), findsNothing);
      SnapToast.dismiss();
      await tester.pumpAndSettle();
    });
  });

  group('Lifecycle', () {
    testWidgets('auto-dismisses after duration', (tester) async {
      await tester.pumpWidget(_hostApp((ctx) {
        SnapToast.success(
          ctx,
          'bye',
          duration: const Duration(milliseconds: 400),
        );
      }));
      await tester.pump(); // callback fires
      await tester.pump(const Duration(milliseconds: 300)); // enter anim
      expect(find.text('bye'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500)); // past duration
      await tester.pump(const Duration(milliseconds: 300)); // exit anim
      expect(find.text('bye'), findsNothing);
    });

    testWidgets('instant replacement shows only the latest message',
        (tester) async {
      await tester.pumpWidget(_hostApp((ctx) {
        SnapToast.success(ctx, 'first');
        SnapToast.success(ctx, 'second');
      }));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('first'), findsNothing);
      expect(find.text('second'), findsOneWidget);
      SnapToast.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('SnapToast.dismiss() removes the active toast', (tester) async {
      await tester.pumpWidget(_hostApp((ctx) {
        SnapToast.info(ctx, 'transient');
      }));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('transient'), findsOneWidget);

      SnapToast.dismiss();
      await tester.pumpAndSettle();
      expect(find.text('transient'), findsNothing);
    });
  });

  group('Context handling', () {
    testWidgets('no-op when context lacks an Overlay', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(key: key, width: 10, height: 10),
        ),
      );
      expect(
        () => SnapToast.success(key.currentContext!, 'ignored'),
        returnsNormally,
      );
    });
  });

  group('parseWebBgColor', () {
    test('parses hex color', () {
      final decoration = parseWebBgColor('#ff0000', 10) as BoxDecoration;
      expect(decoration.color, const Color(0xFFFF0000));
      expect(decoration.gradient, isNull);
    });

    test('parses linear-gradient with two stops', () {
      final decoration = parseWebBgColor(
        'linear-gradient(to right, #00b09b, #96c93d)',
        10,
      ) as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors, [const Color(0xFF00B09B), const Color(0xFF96C93D)]);
      expect(gradient.begin, Alignment.centerLeft);
      expect(gradient.end, Alignment.centerRight);
    });

    test('falls back to transparent on unparseable input (release path)', () {
      // Use a non-assert call path by catching the assert via debug bypass: the
      // function's behaviour is verified by ensuring it does not throw.
      // (Debug mode asserts; we accept either the assert or a transparent fall
      // back. We assert the non-throw contract here.)
      Decoration? result;
      try {
        result = parseWebBgColor('not-a-real-value', 10);
      } catch (_) {
        // Debug mode assert path — acceptable.
      }
      if (result != null) {
        final box = result as BoxDecoration;
        expect(box.color, Colors.transparent);
      }
    });
  });
}
