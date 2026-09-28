import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the app-icon inventory: every icon a manifest, page, or native
/// shell references must exist and be a real PNG. Regenerate with
/// `brand/render-icons.sh` after editing the SVG masters.
void main() {
  File file(String path) {
    final f = File(path);
    expect(f.existsSync(), isTrue, reason: 'Missing: $path.');
    return f;
  }

  void isPng(String path) {
    final bytes = file(path).readAsBytesSync();
    expect(
      bytes.length > 8 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47,
      isTrue,
      reason: '$path is not a PNG.',
    );
  }

  const densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];

  test('android launcher icons exist at every density', () {
    final manifest =
        file('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
    for (final dpi in densities) {
      isPng('android/app/src/main/res/mipmap-$dpi/ic_launcher.png');
    }
  });

  test('android adaptive icon references resolve', () {
    final xml = file('android/app/src/main/res/mipmap-anydpi-v26/'
            'ic_launcher.xml')
        .readAsStringSync();
    expect(xml, contains('<adaptive-icon'));
    expect(xml, contains('@color/ic_launcher_background'));
    expect(xml, contains('@mipmap/ic_launcher_foreground'));

    final colors = file('android/app/src/main/res/values/colors.xml')
        .readAsStringSync();
    expect(colors, contains('name="ic_launcher_background"'));

    for (final dpi in densities) {
      isPng('android/app/src/main/res/mipmap-$dpi/'
          'ic_launcher_foreground.png');
    }
  });

  test('android splash background reference resolves', () {
    final splash = file('android/app/src/main/res/drawable/'
            'launch_background.xml')
        .readAsStringSync();
    final match = RegExp(r'@color/([A-Za-z0-9_]+)').firstMatch(splash);
    expect(match, isNotNull);
    final colors = file('android/app/src/main/res/values/colors.xml')
        .readAsStringSync();
    expect(colors, contains('name="${match![1]}"'));
  });

  test('ios appiconset files all exist', () {
    const dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
    final contents =
        jsonDecode(file('$dir/Contents.json').readAsStringSync()) as Map;
    final images = contents['images'] as List;
    expect(images, isNotEmpty);
    for (final entry in images) {
      final name = (entry as Map)['filename'] as String?;
      expect(name, isNotNull);
      isPng('$dir/$name');
    }
  });

  test('linux window icon is bundled and wired up', () {
    isPng('linux/runner/assets/app_icon.png');
    final cmake = file('linux/CMakeLists.txt').readAsStringSync();
    expect(cmake, contains('runner/assets/app_icon.png'));
    final runner =
        file('linux/runner/my_application.cc').readAsStringSync();
    expect(runner, contains('app_icon.png'));
  });

  test('linux desktop entry and hicolor icons are consistent', () {
    final desktop =
        file('linux/com.seasonal.seasonal.desktop').readAsStringSync();
    expect(desktop, contains('Icon=com.seasonal.seasonal'));
    for (final size in [
      16, 22, 24, 32, 36, 48, 64, 72, 96, 128, 192, 256, 512,
    ]) {
      isPng('linux/icons/hicolor/${size}x$size/apps/'
          'com.seasonal.seasonal.png');
    }
  });

  test('static site icon links all resolve', () {
    final html = file('site/index.html').readAsStringSync();
    for (final href in [
      'favicon.svg',
      'favicon.ico',
      'assets/icon-32.png',
      'assets/apple-touch-icon.png',
    ]) {
      expect(html, contains(href));
      file('site/$href');
    }
    // The SVG favicon is a copy of the master; keep it in sync.
    expect(
      file('site/favicon.svg').readAsStringSync(),
      file('brand/icons/icon.svg').readAsStringSync(),
    );
    final webmanifest = jsonDecode(
        file('site/site.webmanifest').readAsStringSync()) as Map;
    for (final icon in webmanifest['icons'] as List) {
      isPng('site/${(icon as Map)['src']}');
    }
  });

  test('flutter web shell is rebranded and complete', () {
    final manifest =
        jsonDecode(file('web/manifest.json').readAsStringSync()) as Map;
    expect(manifest['name'], 'Seasonal');
    expect(manifest['description'], isNot(contains('Flutter project')));
    for (final icon in manifest['icons'] as List) {
      isPng('web/${(icon as Map)['src']}');
    }
    isPng('web/favicon.png');
    final html = file('web/index.html').readAsStringSync();
    expect(html, contains('<title>Seasonal'));
    expect(html, isNot(contains('0175C2')));
  });
}
