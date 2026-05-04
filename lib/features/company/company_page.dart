import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../game/state/game_scope.dart';
import '../../shared/widgets/app_section_card.dart';
import '../../shared/widgets/metric_row.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/warning_banner.dart';
import 'models/active_company.dart';
import 'models/company_action.dart';
import 'models/company_type.dart';
import 'services/company_profile_service.dart';

class CompanyPage extends StatelessWidget {
  const CompanyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final company = state.activeCompany;
    final textTheme = Theme.of(context).textTheme;

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Company', style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Create and operate a small business alongside your life.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          
          if (company == null) ...[
            _UnlockCard(
              unlocked: controller.isCompanyUnlocked(),
              text: controller.companyUnlockText(),
            ),
            const SizedBox(height: 18),
            
            Text('Company Types', style: textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final type in controller.companyTypes) ...[
              _CompanyTypeCard(
                type: type,
                canFound: controller.canFoundCompany(type),
                onFound: () async {
                  final founded = await controller.foundCompany(type);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(founded ? '${type.title} founded.' : 'Requirements or startup cash are not met.')),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ] else ...[
            _CompanyOverview(
              company: company,
              outlook: controller.companyOutlook,
              signals: controller.companySignals,
            ),
            const SizedBox(height: 18),
            
            Text('Business Actions', style: textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final action in controller.companyActions) ...[
              _CompanyActionCard(
                action: action,
                canUse: state.player.stats.energy >= action.energyCost,
                onUse: () async {
                  final used = await controller.performCompanyAction(action);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(used ? '${action.title} applied.' : 'Not enough energy for that action.')),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 12),
            
            OutlinedButton.icon(
              onPressed: () async {
                await controller.closeCompany();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Company closed.')));
              },
              icon: const Icon(Icons.close_rounded, color: AppTheme.red),
              label: const Text('Close Company'),
            ),
          ],
        ],
      ),
    );
  }
}

class _UnlockCard extends StatelessWidget {
  const _UnlockCard({required this.unlocked, required this.text});

  final bool unlocked;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (!unlocked) {
      return WarningBanner(
        title: 'Locked',
        message: text,
        severity: WarningSeverity.warning,
        icon: Icons.lock_rounded,
      );
    }
    
    return AppSectionCard(
      title: 'Unlocked',
      icon: Icons.lock_open_rounded,
      iconColor: AppTheme.green,
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _CompanyTypeCard extends StatelessWidget {
  const _CompanyTypeCard({
    required this.type,
    required this.canFound,
    required this.onFound,
  });

  final CompanyType type;
  final bool canFound;
  final VoidCallback onFound;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: type.title,
      subtitle: type.description,
      action: StatusChip(label: type.risk, color: AppTheme.amber),
      child: Column(
        children: [
          MetricRow(label: 'Startup Cost', value: '${type.startupCost}'),
          MetricRow(label: 'Operating Cost', value: '${type.monthlyOperatingCost}/mo', valueColor: AppTheme.red),
          MetricRow(label: 'Revenue Range', value: '${type.minRevenue}-${type.maxRevenue}/mo', valueColor: AppTheme.green),
          MetricRow(label: 'Profile', value: const CompanyProfileService().profileFor(type).summary),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: canFound ? onFound : null,
            child: const Text('Found Company'),
          ),
        ],
      ),
    );
  }
}

class _CompanyOverview extends StatelessWidget {
  const _CompanyOverview({
    required this.company,
    required this.outlook,
    required this.signals,
  });

  final ActiveCompany company;
  final String outlook;
  final List<String> signals;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: company.name,
      subtitle: '${company.type.title} - $outlook',
      icon: Icons.business_rounded,
      iconColor: AppTheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MetricRow(label: 'Months Active', value: '${company.monthsActive}'),
          MetricRow(label: 'Health', value: '${company.health}/100', valueColor: _colorForMetric(company.health)),
          MetricRow(label: 'Momentum', value: '${company.momentum}/100', valueColor: _colorForMetric(company.momentum)),
          MetricRow(label: 'Pipeline', value: '${company.pipeline}/100', valueColor: _colorForMetric(company.pipeline)),
          MetricRow(label: 'Operations', value: '${company.operations}/100', valueColor: _colorForMetric(company.operations)),
          const Divider(height: 24, color: AppTheme.border),
          MetricRow(label: 'Last Net Result', value: '${company.lastNetResult}', valueColor: company.lastNetResult >= 0 ? AppTheme.green : AppTheme.red),
          MetricRow(label: 'Current Effort', value: '${company.effortThisMonth} EN', valueColor: AppTheme.amber),
          
          if (signals.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Business Outlook', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final signal in signals)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.mutedText),
                    const SizedBox(width: 8),
                    Expanded(child: Text(signal, style: Theme.of(context).textTheme.bodyMedium)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
  
  Color? _colorForMetric(int value) {
    if (value >= 70) return AppTheme.green;
    if (value <= 30) return AppTheme.red;
    return AppTheme.amber;
  }
}

class _CompanyActionCard extends StatelessWidget {
  const _CompanyActionCard({
    required this.action,
    required this.canUse,
    required this.onUse,
  });

  final CompanyAction action;
  final bool canUse;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: action.title,
      subtitle: action.description,
      action: StatusChip(label: '${action.energyCost} EN', color: canUse ? AppTheme.primary : AppTheme.mutedText),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MetricRow(label: 'Effect', value: _effectText(action), valueColor: AppTheme.primary),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: canUse ? onUse : null,
            child: const Text('Apply Focus'),
          ),
        ],
      ),
    );
  }

  String _effectText(CompanyAction action) {
    final parts = <String>[];
    if (action.health != 0) parts.add('Health ${_signed(action.health)}');
    if (action.momentum != 0) parts.add('Momentum ${_signed(action.momentum)}');
    if (action.pipeline != 0) parts.add('Pipeline ${_signed(action.pipeline)}');
    if (action.operations != 0) parts.add('Operations ${_signed(action.operations)}');
    return parts.join(' / ');
  }

  String _signed(int value) => value > 0 ? '+$value' : '$value';
}
