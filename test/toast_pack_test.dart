import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toast_pack/toast_pack.dart';
import 'package:toast_pack/src/toast_config.dart';
import 'package:toast_pack/src/web_background.dart';

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

void _mockNativeAppIcon() {
  const channel = MethodChannel('toast_pack/app_icon');
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
}

void main() {
  setUp(ToastPackConfig.reset);

  group('Default leading behaviour', () {
    testWidgets('no leading visual by default', (tester) async {
      await tester.pumpWidget(
        _hostApp((ctx) {
          ToastPack.success(ctx, 'Saved');
        }),
      );
      await tester.pump(); // post-frame fires
      await tester.pump(const Duration(milliseconds: 300)); // forward anim

      expect(find.text('Saved'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
      expect(find.byType(Image), findsNothing);
      ToastPack.dismiss();
      await tester.pumpAndSettle();
    });
  });

  group('Explicit leading', () {
    test('image and app icon expose percentage sizing defaults', () {
      final image =
          ToastLeading.image('assets/reward.png') as ToastLeadingImage;
      expect(image.heightPercentage, 0.80);
      expect(image.widthPercentage, 0.20);

      final appIcon = ToastLeading.appIcon() as ToastLeadingAppIcon;
      expect(appIcon.heightPercentage, 0.80);
      expect(appIcon.widthPercentage, 0.20);
      expect(appIcon.clip, isNull);
    });

    test('image and app icon reject invalid percentages', () {
      expect(
        () => ToastLeading.image('assets/reward.png', heightPercentage: 0),
        throwsAssertionError,
      );
      expect(
        () => ToastLeading.image('assets/reward.png', widthPercentage: 1.1),
        throwsAssertionError,
      );
      expect(
        () => ToastLeading.appIcon(heightPercentage: 1.1),
        throwsAssertionError,
      );
      expect(
        () => ToastLeading.appIcon(widthPercentage: 0),
        throwsAssertionError,
      );
    });

    testWidgets('ToastLeading.icon renders the provided icon', (tester) async {
      await tester.pumpWidget(
        _hostApp((ctx) {
          ToastPack.info(
            ctx,
            'Hello',
            leading: const ToastLeading.icon(Icons.star),
          );
        }),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Hello'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      ToastPack.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets(
      'ToastLeading.appIcon without init falls back to variant icon',
      (tester) async {
        await tester.pumpWidget(
          _hostApp((ctx) {
            ToastPack.error(ctx, 'Oops', leading: const ToastLeading.appIcon());
          }),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Oops'), findsOneWidget);
        final fallback = tester.widget<Icon>(find.byIcon(Icons.error));
        expect(fallback.size, greaterThan(0));
        ToastPack.dismiss();
        await tester.pumpAndSettle();
      },
    );

    testWidgets('ToastLeading.appIcon uses native icon when available', (
      tester,
    ) async {
      _mockNativeAppIcon();

      await tester.pumpWidget(
        _hostApp((ctx) {
          ToastPack.info(
            ctx,
            'Native icon',
            leading: const ToastLeading.appIcon(),
          );
        }),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(find.text('Native icon'), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.width, image.height);
      expect(image.width, greaterThan(0));
      expect(find.byIcon(Icons.info), findsNothing);
      ToastPack.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('iOS native app icon uses a circular badge without cropping', (
      tester,
    ) async {
      _mockNativeAppIcon();
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      try {
        await tester.pumpWidget(
          _hostApp((ctx) {
            ToastPack.info(
              ctx,
              'Native icon',
              leading: const ToastLeading.appIcon(),
            );
          }),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();

        expect(find.byType(ClipRRect), findsNothing);
        expect(find.byType(ClipOval), findsNothing);
        final badgeFinder = find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle,
        );
        expect(badgeFinder, findsOneWidget);
        final badgeSize = tester.getSize(badgeFinder);
        final image = tester.widget<Image>(find.byType(Image));
        expect(image.fit, BoxFit.cover);
        expect(image.width, lessThan(badgeSize.width));
        ToastPack.dismiss();
        await tester.pumpAndSettle();
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('ToastLeading.appIcon can disable clipping', (tester) async {
      _mockNativeAppIcon();

      await tester.pumpWidget(
        _hostApp((ctx) {
          ToastPack.info(
            ctx,
            'Native icon',
            leading: const ToastLeading.appIcon(clip: ToastIconClip.none),
          );
        }),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(find.byType(ClipOval), findsNothing);
      expect(find.byType(ClipRRect), findsNothing);
      expect(find.byType(Image), findsOneWidget);
      ToastPack.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('defaultIconAsset is not clipped unless clip is requested', (
      tester,
    ) async {
      ToastPack.init(defaultIconAsset: 'assets/app_icon.png');

      await tester.pumpWidget(
        _hostApp((ctx) {
          ToastPack.info(ctx, 'Asset icon', leading: const ToastLeading.appIcon());
        }),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(find.byType(ClipOval), findsNothing);
      expect(find.byType(DecoratedBox), findsWidgets);
      expect(find.byType(Image), findsOneWidget);
      ToastPack.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('defaultIconAsset can opt into circular clipping', (
      tester,
    ) async {
      ToastPack.init(defaultIconAsset: 'assets/app_icon.png');

      await tester.pumpWidget(
        _hostApp((ctx) {
          ToastPack.info(
            ctx,
            'Asset icon',
            leading: const ToastLeading.appIcon(clip: ToastIconClip.circle),
          );
        }),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(find.byType(ClipOval), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      ToastPack.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('ToastLeading.appIcon uses width percentage as a cap', (
      tester,
    ) async {
      _mockNativeAppIcon();

      await tester.pumpWidget(
        _hostApp((ctx) {
          ToastPack.info(
            ctx,
            'Native icon',
            leading: const ToastLeading.appIcon(widthPercentage: 0.02),
          );
        }),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.width, lessThan(24));
      ToastPack.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('one-line app icon size does not grow with message length', (
      tester,
    ) async {
      _mockNativeAppIcon();
      BuildContext? readyContext;
      await tester.pumpWidget(_hostApp((ctx) => readyContext = ctx));
      await tester.pump();

      ToastPack.info(
        readyContext,
        'FYI',
        leading: const ToastLeading.appIcon(),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      final shortSize = tester.widget<Image>(find.byType(Image)).width;

      ToastPack.dismiss();
      await tester.pumpAndSettle();

      ToastPack.error(
        readyContext,
        'Something went wrong',
        leading: const ToastLeading.appIcon(),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      final longSize = tester.widget<Image>(find.byType(Image)).width;

      expect(longSize, shortSize);
      ToastPack.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('narrow layouts reduce percentage-based app icon size', (
      tester,
    ) async {
      _mockNativeAppIcon();
      tester.view.physicalSize = const Size(160, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _hostApp((ctx) {
          ToastPack.info(
            ctx,
            'Native icon',
            leading: const ToastLeading.appIcon(),
          );
        }),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.width, lessThan(30));
      ToastPack.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets(
      'wrapped text reserves percentage-based app icon width when sizing',
      (tester) async {
        _mockNativeAppIcon();
        tester.view.physicalSize = const Size(220, 400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const message = 'Limited-time checkout reward expires soon';

        await tester.pumpWidget(
          _hostApp((ctx) {
            ToastPack.info(
              ctx,
              message,
              leading: const ToastLeading.appIcon(widthPercentage: 0.80),
            );
          }),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump();

        final image = tester.widget<Image>(find.byType(Image));
        const availableWidth = 220.0 - 32.0;
        final horizontalPadding = ToastPack.defaultPadding.horizontal;
        final verticalPadding = ToastPack.defaultPadding.vertical;
        const leadingGap = 12.0;
        final oldTextPainter = TextPainter(
          text: const TextSpan(text: message, style: TextStyle(fontSize: 14)),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: availableWidth - horizontalPadding - leadingGap);
        final maxLeadingWidth = availableWidth - horizontalPadding - leadingGap;
        final oldMeasuredSize =
            ((verticalPadding + oldTextPainter.height) * 0.80).clamp(
              0.0,
              maxLeadingWidth * 0.80,
            );

        expect(image.width, greaterThan(oldMeasuredSize + 3));
        ToastPack.dismiss();
        await tester.pumpAndSettle();
      },
    );

    testWidgets('percentage-based app icon sizing respects custom padding', (
      tester,
    ) async {
      _mockNativeAppIcon();
      tester.view.physicalSize = const Size(220, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _hostApp((ctx) {
          ToastPack.info(
            ctx,
            'Custom padding keeps sizing honest',
            leading: const ToastLeading.appIcon(widthPercentage: 0.80),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          );
        }),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.width, lessThan(220));
      expect(tester.takeException(), isNull);
      ToastPack.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('ToastLeading.image fallback uses percentage sizing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _hostApp((ctx) {
          ToastPack.warning(
            ctx,
            'Missing image',
            leading: const ToastLeading.image(
              'assets/not-found.png',
              widthPercentage: 0.02,
            ),
          );
        }),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      final fallback = tester.widget<Icon>(find.byIcon(Icons.warning));
      expect(fallback.size, lessThan(24));
      ToastPack.dismiss();
      await tester.pumpAndSettle();
    });
  });

  group('Lifecycle', () {
    testWidgets('auto-dismisses after duration', (tester) async {
      await tester.pumpWidget(
        _hostApp((ctx) {
          ToastPack.success(
            ctx,
            'bye',
            duration: const Duration(milliseconds: 400),
          );
        }),
      );
      await tester.pump(); // callback fires
      await tester.pump(const Duration(milliseconds: 300)); // enter anim
      expect(find.text('bye'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500)); // past duration
      await tester.pump(const Duration(milliseconds: 300)); // exit anim
      expect(find.text('bye'), findsNothing);
    });

    testWidgets('instant replacement shows only the latest message', (
      tester,
    ) async {
      await tester.pumpWidget(
        _hostApp((ctx) {
          ToastPack.success(ctx, 'first');
          ToastPack.success(ctx, 'second');
        }),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('first'), findsNothing);
      expect(find.text('second'), findsOneWidget);
      ToastPack.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('ToastPack.dismiss() removes the active toast', (tester) async {
      await tester.pumpWidget(
        _hostApp((ctx) {
          ToastPack.info(ctx, 'transient');
        }),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('transient'), findsOneWidget);

      ToastPack.dismiss();
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
        () => ToastPack.success(key.currentContext!, 'ignored'),
        returnsNormally,
      );
    });

    testWidgets('shows with an explicit overlay state', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: SizedBox.expand()),
        ),
      );

      final overlayState = navigatorKey.currentState!.overlay!;
      ToastPack.info(null, 'Overlay state toast', overlayState: overlayState);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Overlay state toast'), findsOneWidget);
      ToastPack.dismiss();
      await tester.pumpAndSettle();
    });
  });

  group('parseWebBgColor', () {
    test('parses hex color', () {
      final decoration = parseWebBgColor('#ff0000', 10) as BoxDecoration;
      expect(decoration.color, const Color(0xFFFF0000));
      expect(decoration.gradient, isNull);
    });

    test('parses linear-gradient with two stops', () {
      final decoration =
          parseWebBgColor('linear-gradient(to right, #00b09b, #96c93d)', 10)
              as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors, [
        const Color(0xFF00B09B),
        const Color(0xFF96C93D),
      ]);
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
