import 'package:flutter/material.dart';
import 'package:snap_toast_flutter/snap_toast_flutter.dart';

void main() {
  // Optional: register an override asset that ToastLeading.appIcon() will use.
  // If omitted, the package now tries the native launcher icon automatically.
  SnapToast.init();
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'snap_toast_flutter demo',
      home: DemoHome(),
    );
  }
}

class DemoHome extends StatefulWidget {
  const DemoHome({super.key});

  @override
  State<DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  ToastGravity _gravity = ToastGravity.bottom;
  ToastAnimation _animation = ToastAnimation.slide;
  final ToastLeading _leading = const ToastLeading.appIcon();
  bool _webShowClose = false;
  ToastWebPosition _webPos = ToastWebPosition.center;
  String? _webBgColor; // null => default gradient on web

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('snap_toast_flutter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionHeader('Variants'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () => SnapToast.success(
                    context,
                    'Item added',
                    gravity: _gravity,
                    animation: _animation,
                    leading: _leading,
                    webBgColor: _webBgColor,
                    webShowClose: _webShowClose,
                    webPosition: _webPos,
                  ),
                  child: const Text('success'),
                ),
                FilledButton(
                  onPressed: () => SnapToast.error(
                    context,
                    'Something went wrong',
                    gravity: _gravity,
                    animation: _animation,
                    leading: _leading,
                    webShowClose: _webShowClose,
                    webPosition: _webPos,
                  ),
                  child: const Text('error'),
                ),
                FilledButton(
                  onPressed: () => SnapToast.warning(
                    context,
                    'Double-check this',
                    gravity: _gravity,
                    animation: _animation,
                    leading: _leading,
                    webShowClose: _webShowClose,
                    webPosition: _webPos,
                  ),
                  child: const Text('warning'),
                ),
                FilledButton(
                  onPressed: () => SnapToast.info(
                    context,
                    'Just FYI',
                    gravity: _gravity,
                    animation: _animation,
                    leading: _leading,
                    webShowClose: _webShowClose,
                    webPosition: _webPos,
                  ),
                  child: const Text('info'),
                ),
                OutlinedButton(
                  onPressed: () => SnapToast.dismiss(),
                  child: const Text('dismiss'),
                ),
              ],
            ),
            const _SectionHeader('Leading'),
            Wrap(
              spacing: 8,
              children: [
                // ChoiceChip(
                //   label: const Text('none'),
                //   selected: _leading is ToastLeadingNone,
                //   onSelected: (_) =>
                //       setState(() => _leading = const ToastLeading.none()),
                // ),
                // ChoiceChip(
                //   label: const Text('icon (star)'),
                //   selected: _leading is ToastLeadingIcon,
                //   onSelected: (_) => setState(
                //     () => _leading = const ToastLeading.icon(Icons.star),
                //   ),
                // ),
                // ChoiceChip(
                //   label: const Text('appIcon (fallback)'),
                //   selected: _leading is ToastLeadingAppIcon,
                //   onSelected: (_) =>
                //       setState(() => _leading = const ToastLeading.appIcon()),
                // ),
              ],
            ),
            const _SectionHeader('Gravity'),
            SegmentedButton<ToastGravity>(
              segments: const [
                ButtonSegment(value: ToastGravity.top, label: Text('top')),
                ButtonSegment(
                  value: ToastGravity.center,
                  label: Text('center'),
                ),
                ButtonSegment(
                  value: ToastGravity.bottom,
                  label: Text('bottom'),
                ),
              ],
              selected: {_gravity},
              onSelectionChanged: (s) => setState(() => _gravity = s.first),
            ),
            const _SectionHeader('Animation'),
            SegmentedButton<ToastAnimation>(
              segments: const [
                ButtonSegment(
                  value: ToastAnimation.slide,
                  label: Text('slide'),
                ),
                ButtonSegment(value: ToastAnimation.fade, label: Text('fade')),
                ButtonSegment(
                  value: ToastAnimation.scale,
                  label: Text('scale'),
                ),
              ],
              selected: {_animation},
              onSelectionChanged: (s) => setState(() => _animation = s.first),
            ),
            const _SectionHeader('Web-only options'),
            const Text(
              'These are ignored on non-web. Default web background is '
              'linear-gradient(to right, #00b09b, #96c93d).',
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('default gradient'),
                    selected: _webBgColor == null,
                    onSelected: (_) => setState(() => _webBgColor = null),
                  ),
                  ChoiceChip(
                    label: const Text('solid #8E44AD'),
                    selected: _webBgColor == '#8E44AD',
                    onSelected: (_) => setState(() => _webBgColor = '#8E44AD'),
                  ),
                  ChoiceChip(
                    label: const Text('blue→cyan gradient'),
                    selected:
                        _webBgColor ==
                        'linear-gradient(to right, #2193b0, #6dd5ed)',
                    onSelected: (_) => setState(
                      () => _webBgColor =
                          'linear-gradient(to right, #2193b0, #6dd5ed)',
                    ),
                  ),
                ],
              ),
            ),
            SwitchListTile(
              title: const Text('Show close button (web only)'),
              value: _webShowClose,
              onChanged: (v) => setState(() => _webShowClose = v),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SegmentedButton<ToastWebPosition>(
                segments: const [
                  ButtonSegment(
                    value: ToastWebPosition.left,
                    label: Text('left'),
                  ),
                  ButtonSegment(
                    value: ToastWebPosition.center,
                    label: Text('center'),
                  ),
                  ButtonSegment(
                    value: ToastWebPosition.right,
                    label: Text('right'),
                  ),
                ],
                selected: {_webPos},
                onSelectionChanged: (s) => setState(() => _webPos = s.first),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
