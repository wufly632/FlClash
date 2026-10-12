import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/website_rule.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

class WebsiteRuleDialog extends StatefulWidget {
  const WebsiteRuleDialog({super.key});

  @override
  State<WebsiteRuleDialog> createState() => _WebsiteRuleDialogState();
}

class _WebsiteRuleDialogState extends State<WebsiteRuleDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _includeSubdomains = true;

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    Navigator.of(context).pop(
      Rule(
        id: snowflake.id,
        ruleAction: _includeSubdomains
            ? RuleAction.DOMAIN_SUFFIX
            : RuleAction.DOMAIN,
        content: websiteRuleDomain(_controller.text)!,
        ruleTarget: 'DIRECT',
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.appLocalizations;
    return CommonDialog(
      title: l10n.websiteDirect,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(onPressed: _submit, child: Text(l10n.confirm)),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.websiteDirectDesc),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.websiteAddress,
                hintText: 'example.com',
                errorMaxLines: 4,
              ),
              validator: (value) => websiteRuleDomain(value ?? '') == null
                  ? l10n.websiteAddressInvalid
                  : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.includeSubdomains),
              value: _includeSubdomains,
              onChanged: (value) => setState(() => _includeSubdomains = value),
            ),
          ],
        ),
      ),
    );
  }
}
