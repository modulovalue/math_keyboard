import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:url_launcher/url_launcher.dart';

import 'resources.dart';

/// Demo application for `math_keyboard`.
class Example extends StatefulWidget {
  /// Constructs a [Example].
  const Example({
    final Key? key,
  }) : super(key: key);

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  var _darkMode = false;

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        brightness: _darkMode ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.amber,
        ).copyWith(
          secondary: Colors.amberAccent,
        ),
      ),
      home: DemoScaffold(
        onToggleBrightness: () {
          setState(() {
            _darkMode = !_darkMode;
          });
        },
      ),
    );
  }
}

/// Scaffold for the demo page.
class DemoScaffold extends StatelessWidget {
  /// Creates a [DemoScaffold] widget.
  const DemoScaffold({
    required final this.onToggleBrightness,
    final Key? key,
  }) : super(key: key);

  /// Called when the brightness toggle is tapped.
  final void Function() onToggleBrightness;

  @override
  Widget build(
    final BuildContext context,
  ) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    final buttons = [
      LinkButton(
        label: pubLabel,
        url: pubUrl,
        child: SvgPicture.network(pubBadgeUrl),
      ),
      LinkButton(
        label: gitHubLabel,
        url: gitHubUrl,
        child: Stack(
          children: [
            // Always insert both icons into the tree in order to prevent the
            // layout from jumping around when changing the brightness (because
            // the dark version would need to be loaded later).
            Image.network(darkGitHubIconUrl),
            if (!darkMode) Image.network(lightGitHubIconUrl),
          ],
        ),
      ),
      const LinkButton(
        label: docsLabel,
        url: docsUrl,
      ),
    ];
    SystemChrome.setSystemUIOverlayStyle(darkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
    return MathKeyboardViewInsets(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(0, 42 + 16 * 2),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: brightnessSwitchTooltip,
                      onPressed: onToggleBrightness,
                      splashRadius: 20,
                      icon: Icon(darkMode ? Icons.brightness_6_outlined : Icons.brightness_2_outlined),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 3,
                        bottom: 3,
                      ),
                      child: MouseRegion(
                        cursor: MaterialStateMouseCursor.clickable,
                        child: GestureDetector(
                          onTap: () {
                            launch(gitHubUrl);
                          },
                          child: Text(
                            header,
                            style: Theme.of(context).textTheme.headline5?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                thickness: 1,
                height: 0,
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Material(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                    ),
                    child: LayoutBuilder(
                      builder: (final context, final constraints) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 64,
                                right: 64,
                                bottom: 8,
                              ),
                              child: Text.rich(
                                TextSpan(
                                  children: const [
                                    TextSpan(
                                      text: descriptionPrefix,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' $description',
                                    ),
                                  ],
                                  style: Theme.of(context).textTheme.headline5?.copyWith(
                                        fontSize: 28,
                                      ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (constraints.maxWidth < 6e2) ...[
                              for (final button in buttons)
                                Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: button,
                                ),
                            ] else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (final button in buttons)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 16,
                                      ),
                                      child: button,
                                    ),
                                ],
                              ),
                            const Padding(
                              padding: EdgeInsets.only(
                                top: 32,
                              ),
                              child: DemoPageView(),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SizedBox(
          height: 42 + 16 * 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(
                thickness: 1,
                height: 0,
              ),
              MouseRegion(
                cursor: MaterialStateMouseCursor.clickable,
                child: GestureDetector(
                  onTap: () {
                    launch(organizationUrl);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.network(
                      darkMode ? darkLogoUrl : lightLogoUrl,
                      height: 42,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stylized button widget for linking to outside resources.
class LinkButton extends StatelessWidget {
  /// Constructs a [LinkButton] from a [label], a [url], and an optional
  /// [child].
  const LinkButton({
    required final this.label,
    required final this.url,
    final Key? key,
    final this.child,
  }) : super(key: key);

  /// Label for the button.
  final String label;

  /// URL to link to, i.e. to open.
  final String url;

  /// Icon for this button.
  ///
  /// Can be left null.
  final Widget? child;

  @override
  Widget build(final BuildContext context) {
    void onPressed() => launch(url);
    final style = OutlinedButton.styleFrom(
      padding: const EdgeInsets.all(16),
      textStyle: const TextStyle(
        fontSize: 20,
        decoration: TextDecoration.underline,
      ),
    );

    if (child == null) {
      return OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: style,
      label: Text(label),
      icon: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 32,
        ),
        child: child,
      ),
    );
  }
}

/// Page view for presenting the features that math_keyboard has to offer.
class DemoPageView extends StatefulWidget {
  const DemoPageView({
    final Key? key,
  }) : super(key: key);

  @override
  _DemoPageViewState createState() => _DemoPageViewState();
}

class _DemoPageViewState extends State<DemoPageView> {
  late final _controller = PageController();

  int get _page {
    if (!_controller.hasClients) {
      return _controller.initialPage;
    }
    return _controller.page?.round() ?? _controller.initialPage;
  }

  @override
  void initState() {
    super.initState();

    _controller.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  late int previousIndex = _page;

  void _handleScroll() {
    if (previousIndex == _page) return;

    // Remove focus from all keyboards when navigating between the pages.
    // Otherwise, the behavior is really weird because page views always
    // keep the pages to the left and right alive.
    FocusScope.of(context).unfocus();

    setState(() {
      previousIndex = _page;
    });
  }

  @override
  Widget build(final BuildContext context) {
    final pages = [
      const _Page(child: _PrimaryPage()),
      const _Page(child: _InputDecorationPage()),
      const _Page(child: _ControllerPage()),
      _Page(
        child: _AutofocusPage(
          autofocus: _page == 3,
        ),
      ),
      const _Page(child: _FocusTreePage()),
      const _Page(child: _DecimalSeparatorPage()),
      const _Page(child: _MathExpressionsPage()),
      const _Page(child: _FormFieldPage()),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 5e2,
          child: Stack(
            children: [
              PageView(
                controller: _controller,
                allowImplicitScrolling: true,
                children: pages,
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: 8,
                child: MouseRegion(
                  cursor: MaterialStateMouseCursor.clickable,
                  child: GestureDetector(
                    onTap: () {
                      _controller.animateToPage(
                        (_page - 1) % pages.length,
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.ease,
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(Icons.chevron_left_outlined),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                right: 8,
                child: MouseRegion(
                  cursor: MaterialStateMouseCursor.clickable,
                  child: GestureDetector(
                    onTap: () {
                      _controller.animateToPage(
                        (_page + 1) % pages.length,
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.ease,
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(Icons.chevron_right_outlined),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (final context, final child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length; i++)
                  _PageIndicator(
                    selected: i == _page,
                    onTap: () => _controller.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.ease,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.child,
    final Key? key,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 56,
      ),
      child: child,
    );
  }
}

/// Widget displaying a dot indicating a page.
///
/// If selected, the dot will be bigger.
class _PageIndicator extends StatelessWidget {
  /// Constructs a [_PageIndicator] widget.
  const _PageIndicator({
    required final this.selected,
    required final this.onTap,
    final Key? key,
  }) : super(key: key);

  final bool selected;

  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) {
    final size = Size.fromRadius(selected ? 6.5 : 5);
    return MouseRegion(
      cursor: MaterialStateMouseCursor.clickable,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: SizedBox.fromSize(
            size: const Size.fromRadius(6.5),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 214),
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(selected ? 1 : 1 / 2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryPage extends StatefulWidget {
  const _PrimaryPage({final Key? key}) : super(key: key);

  @override
  _PrimaryPageState createState() => _PrimaryPageState();
}

class _PrimaryPageState extends State<_PrimaryPage> {
  late final _expressionController = MathFieldEditingController()
    ..updateValue(Parser().parse('4.2 - (cos(x)/(x^3 - sin(x))) + e^(4^2)'));
  late final _numberController = MathFieldEditingController()..updateValue(Parser().parse('42'));

  @override
  void dispose() {
    _expressionController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 16,
          ),
          child: Text(
            'Try it now!',
            style: Theme.of(context).textTheme.headline5!.copyWith(
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(32),
          child: SizedBox(
            width: 5e2,
            child: Text(
              'You can tap on the math fields and enter math '
              'expressions using the on-screen keyboard on mobile and/or using '
              'your physical keyboard on desktop 🚀',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(
          width: 420,
          child: MathField(
            controller: _expressionController,
            decoration: const InputDecoration(
              labelText: 'Expression math field',
              filled: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 32,
          ),
          child: SizedBox(
            width: 420,
            child: MathField(
              controller: _numberController,
              keyboardType: MathKeyboardType.numberOnly,
              decoration: const InputDecoration(
                labelText: 'Number-only math field',
                filled: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InputDecorationPage extends StatelessWidget {
  const _InputDecorationPage({
    final Key? key,
  }) : super(key: key);

  @override
  Widget build(
    final BuildContext context,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 16,
          ),
          child: Text(
            'Completely customizable with InputDecoration!',
            style: Theme.of(context).textTheme.headline5!.copyWith(
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(32),
          child: SizedBox(
            width: 5e2,
            child: Text(
              'Math fields are configurable using InputDecoration from the '
              'framework, which means that you can use everything with it '
              'you are used to from TextField e.g. 🔥',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(
          width: 420,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'This is a text field',
              filled: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(
            top: 16,
          ),
          child: SizedBox(
            width: 420,
            child: MathField(
              decoration: InputDecoration(
                hintText: 'And this is a math field',
                filled: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 32),
          child: SizedBox(
            width: 6e2,
            child: Row(
              children: [
                const Expanded(
                  child: MathField(
                    variables: ['a', 'b', 'd', 'g', 'h_2', 'x', 'y', 'z'],
                    decoration: InputDecoration(
                      helperText: 'Here you can use many variables :)',
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                const Expanded(
                  child: MathField(
                    keyboardType: MathKeyboardType.numberOnly,
                    decoration: InputDecoration(
                      helperText: 'This math field has some icons.',
                      prefixIcon: Icon(Icons.keyboard_outlined),
                      suffixIcon: Icon(Icons.format_shapes_sharp),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ControllerPage extends StatefulWidget {
  const _ControllerPage({
    final Key? key,
  }) : super(key: key);

  @override
  _ControllerPageState createState() => _ControllerPageState();
}

class _ControllerPageState extends State<_ControllerPage> {
  late final _clipboardController = MathFieldEditingController()
    ..updateValue(Parser().parse('log(2, x) - log(5, 2) / 24'));
  late final _clearAllController = MathFieldEditingController();
  late final _magicController = MathFieldEditingController()..updateValue(Parser().parse('42'));

  @override
  void dispose() {
    _clipboardController.dispose();
    _clearAllController.dispose();
    _magicController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 16,
          ),
          child: Text(
            'Fully controllable using custom controllers!',
            style: Theme.of(context).textTheme.headline5!.copyWith(
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(32),
          child: SizedBox(
            width: 5e2,
            child: Text(
              'You can always provide your own MathFieldEditingController, which'
              'you can use to perform custom actions like clearing the input'
              'field and more ✨',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 3e2,
              child: MathField(
                controller: _clipboardController,
                decoration: const InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
              ),
              child: Tooltip(
                message: 'If the on-screen keyboard is opened, the snack bar '
                    'will appear above the keyboard (view insets feature).',
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: _clipboardController.currentEditingValue(),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [const Text('Copied TeX string to clipboard :)')],
                      ),
                    ));
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy to clipboard'),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 32,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 3e2,
                child: MathField(
                  keyboardType: MathKeyboardType.numberOnly,
                  controller: _clearAllController,
                  decoration: InputDecoration(
                    helperText: 'Clear all field',
                    suffix: MouseRegion(
                      cursor: MaterialStateMouseCursor.clickable,
                      child: GestureDetector(
                        onTap: _clearAllController.clear,
                        child: const Icon(
                          Icons.highlight_remove_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                ),
                child: Tooltip(
                  message: 'Works from anywhere - thanks to the controller pattern.',
                  child: OutlinedButton(
                    onPressed: _clearAllController.clear,
                    child: const Text('Clear all'),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 32,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 3e2,
                child: MathField(
                  keyboardType: MathKeyboardType.numberOnly,
                  controller: _magicController,
                  decoration: const InputDecoration(
                    labelText: 'Magic field',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                ),
                child: OutlinedButton(
                  onPressed: () {
                    _magicController.addLeaf('+');
                    _magicController.addLeaf('4');
                    _magicController.addLeaf('2');
                  },
                  child: const Text('Add 42'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AutofocusPage extends StatelessWidget {
  const _AutofocusPage({
    required final this.autofocus,
    final Key? key,
  }) : super(key: key);

  final bool autofocus;

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 16,
          ),
          child: Text(
            'With autofocus support!',
            style: Theme.of(context).textTheme.headline5!.copyWith(
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(32),
          child: SizedBox(
            width: 5e2,
            child: Text(
              'The math field on this page will automatically receive focus '
              'when you navigate to this page 👌',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(
          width: 420,
          child: MathField(
            autofocus: autofocus,
            decoration: const InputDecoration(
              hintText: 'Autofocus math field',
              filled: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

class _FocusTreePage extends StatefulWidget {
  const _FocusTreePage({
    final Key? key,
  }) : super(key: key);

  @override
  _FocusTreePageState createState() => _FocusTreePageState();
}

class _FocusTreePageState extends State<_FocusTreePage> {
  final _focusNodeOne = FocusNode(debugLabel: 'one');
  final _focusNodeTwo = FocusNode(debugLabel: 'two');
  final _focusNodeThree = FocusNode(debugLabel: 'three');
  final _focusNodeFour = FocusNode(debugLabel: 'four');

  @override
  void dispose() {
    _focusNodeOne.dispose();
    _focusNodeTwo.dispose();
    _focusNodeThree.dispose();
    _focusNodeFour.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 16,
          ),
          child: Text(
            'And focus tree integration!',
            style: Theme.of(context).textTheme.headline5!.copyWith(
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(32),
          child: SizedBox(
            width: 5e2,
            child: Text(
              "Math fields integrate completely with Flutter's tree 💪\n"
              'On desktop, you can try using *tab* on this page after clicking'
              'on a math field :)',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 420,
              child: FocusScope(
                child: Column(
                  children: [
                    MathField(
                      focusNode: _focusNodeOne,
                      variables: ['o', 'n', 'e'],
                      decoration: const InputDecoration(
                        labelText: 'One',
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                      ),
                      child: MathField(
                        focusNode: _focusNodeTwo,
                        variables: ['t', 'w', 'o'],
                        decoration: const InputDecoration(
                          labelText: 'Two',
                          filled: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                      ),
                      child: MathField(
                        focusNode: _focusNodeThree,
                        variables: ['t', 'h', 'r', 'e'],
                        decoration: const InputDecoration(
                          labelText: 'Three',
                          filled: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                      ),
                      child: MathField(
                        focusNode: _focusNodeFour,
                        variables: ['f', 'o', 'u', 'r'],
                        decoration: const InputDecoration(
                          labelText: 'Four',
                          filled: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: FloatingActionButton(
                onPressed: () {
                  if (_focusNodeOne.hasFocus) {
                    _focusNodeTwo.requestFocus();
                    return;
                  }
                  if (_focusNodeTwo.hasFocus) {
                    _focusNodeThree.requestFocus();
                    return;
                  }
                  if (_focusNodeThree.hasFocus) {
                    _focusNodeFour.requestFocus();
                    return;
                  }
                  if (_focusNodeFour.hasFocus) {
                    _focusNodeFour.unfocus();
                    return;
                  }

                  _focusNodeOne.requestFocus();
                },
                tooltip: 'Rotate focus',
                child: const Icon(Icons.rotate_90_degrees_ccw_outlined),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DecimalSeparatorPage extends StatefulWidget {
  const _DecimalSeparatorPage({
    final Key? key,
  }) : super(key: key);

  @override
  _DecimalSeparatorPageState createState() => _DecimalSeparatorPageState();
}

class _DecimalSeparatorPageState extends State<_DecimalSeparatorPage> {
  late final _controller = MathFieldEditingController()..updateValue(Parser().parse('4.2'));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 16,
          ),
          child: Text(
            'Adaptive decimal separators!',
            style: Theme.of(context).textTheme.headline5!.copyWith(
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(32),
          child: SizedBox(
            width: 5e2,
            child: Text(
              'The decimal separator on the math keyboard and the ones '
              'displayed in the math field change based on the current '
              'locale!',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(
          width: 420,
          child: Localizations.override(
            context: context,
            locale: const Locale('en', 'US'),
            child: MathField(
              controller: _controller,
              keyboardType: MathKeyboardType.numberOnly,
              decoration: const InputDecoration(
                labelText: 'English locale',
                filled: true,
                border: OutlineInputBorder(),
                suffixText: '🇺🇸',
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 32,
          ),
          child: SizedBox(
            width: 420,
            child: Localizations.override(
              context: context,
              locale: const Locale('de', 'DE'),
              child: MathField(
                controller: _controller,
                keyboardType: MathKeyboardType.numberOnly,
                decoration: const InputDecoration(
                  labelText: 'German locale',
                  filled: true,
                  border: OutlineInputBorder(),
                  suffixText: '🇩🇪',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MathExpressionsPage extends StatefulWidget {
  const _MathExpressionsPage({final Key? key}) : super(key: key);

  @override
  _MathExpressionsPageState createState() => _MathExpressionsPageState();
}

class _MathExpressionsPageState extends State<_MathExpressionsPage> {
  String? _tex;
  late Expression _expression = Parser().parse('(x^2)/2 + 1');
  double _value = 4;
  double? _result;

  late final _expressionController = MathFieldEditingController()..updateValue(_expression);
  late final _valueController = MathFieldEditingController()..updateValue(Parser().parse('$_value'));

  @override
  void initState() {
    _calculateResult();
    super.initState();
  }

  @override
  void dispose() {
    _expressionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _calculateResult() {
    try {
      setState(() {
        _result = _expression.evaluate(
          EvaluationType.REAL,
          ContextModel()
            ..bindVariableName(
              'x',
              Number(_value),
            ),
        ) as double?;
      });
      // TODO(modulovalue) very very bad.
    } on Object catch (_) {}
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 16,
          ),
          child: Text(
            'Math expression support!',
            style: Theme.of(context).textTheme.headline5!.copyWith(
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(32),
          child: SizedBox(
            width: 5e2,
            child: Text(
              'The math_keyboard package is built to work with math '
              'expressions while it displays everything as TeX.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(
          width: 420,
          child: Localizations.override(
            context: context,
            locale: const Locale('en', 'US'),
            child: MathField(
              controller: _expressionController,
              onChanged: (final tex) {
                try {
                  _expression = TeXParser(tex).parse();
                  _calculateResult();
                } on Object catch (_) {}
                setState(() {
                  _tex = tex;
                });
              },
              variables: ['x'],
              decoration: const InputDecoration(
                labelText: 'Expression field',
                filled: true,
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 32,
            left: 32,
            right: 32,
          ),
          child: Text(
            'TeX: ${_tex ?? 'waiting for input'}',
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 16,
            left: 32,
            right: 32,
          ),
          child: Text(
            'Math expression: $_expression',
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 32,
            left: 32,
            right: 32,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 125,
                child: MathField(
                  controller: _valueController,
                  keyboardType: MathKeyboardType.numberOnly,
                  onChanged: (final value) {
                    try {
                      _value = (TeXParser(value).parse().evaluate(EvaluationType.REAL, ContextModel())
                          as double?)!;
                      _calculateResult();
                      // TODO(modulovalue) very very bad
                    } on Object catch (_) {}
                  },
                  decoration: const InputDecoration(
                    labelText: 'Value for x',
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Icon(Icons.arrow_right_alt_outlined),
              ),
              Text('Result: ${_result?.toString() ?? 'waiting for valid input'}'),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormFieldPage extends StatelessWidget {
  const _FormFieldPage({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return Form(
      child: Builder(
        builder: (final context) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 16,
                ),
                child: Text(
                  'Last but not least: form fields!',
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(32),
                child: SizedBox(
                  width: 5e2,
                  child: Text(
                    'The math_keyboard package has built-in support for Flutter '
                    'forms and offers a MathFormField widget 🎉',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                width: 420,
                child: MathFormField(
                  validator: (final value) {
                    if (value == null || value.isEmpty || value == r'\Box') {
                      return 'Missing expression (:';
                    }

                    try {
                      TeXParser(value).parse().evaluate(EvaluationType.REAL, ContextModel());
                      return null;
                    } on Object catch (_) {
                      return 'Invalid expression (:';
                    }
                  },
                  variables: [],
                  decoration: const InputDecoration(
                    hintText: 'Enter a valid expression',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextButton(
                  onPressed: () {
                    final result = Form.of(context)!.validate();

                    if (result == true) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [const Text('Form is valid :)')],
                        ),
                      ));
                    }
                  },
                  child: const Text('Submit form'),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
