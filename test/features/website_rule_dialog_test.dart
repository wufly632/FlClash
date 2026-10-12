import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/website_rule.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void main() {
  Rule? result;

  Future<void> open(WidgetTester tester) async {
    result = null;
    await tester.pumpWidget(
      TestApp(
        overrides: [
          viewSizeProvider.overrideWithBuild(
            (ref, notifier) => const Size(800, 600),
          ),
        ],
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await dialogs.showCommonDialog<Rule>(
                context: context,
                child: const WebsiteRuleDialog(),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('URL creates a direct suffix rule by default', (tester) async {
    await open(tester);
    await tester.enterText(
      find.byType(TextFormField),
      'https://Example.com/path',
    );
    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();
    expect(result?.rawValue, 'DOMAIN-SUFFIX,example.com,DIRECT');
    expect(tester.takeException(), isNull);
  });

  testWidgets('subdomains can be excluded', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextFormField), 'www.example.com');
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();
    expect(result?.ruleAction, RuleAction.DOMAIN);
    expect(result?.rawValue, 'DOMAIN,www.example.com,DIRECT');
  });

  testWidgets('invalid input stays open and can be cancelled', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextFormField), '*.example.com');
    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();
    expect(
      find.text(currentAppLocalizations.websiteAddressInvalid),
      findsOneWidget,
    );
    expect(result, isNull);
    await tester.tap(find.text(currentAppLocalizations.cancel));
    await tester.pumpAndSettle();
    expect(find.byType(WebsiteRuleDialog), findsNothing);
    expect(result, isNull);
    expect(tester.takeException(), isNull);
  });
}
