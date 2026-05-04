import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../game/state/game_scope.dart';
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
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
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
            Text('Company types', style: textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final type in controller.companyTypes) ...[
              _CompanyTypeCard(
                type: type,
                canFound: controller.canFoundCompany(type),
                onFound: () async {
                  final founded = await controller.foundCompany(type);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        founded
                            ? '${type.title} founded.'
                            : 'Requirements or startup cash are not met.',
                      ),
                    ),
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
            Text('Business actions', style: textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final action in controller.companyActions) ...[
              _CompanyActionCard(
                action: action,
                canUse: state.player.stats.energy >= action.energyCost,
                onUse: () async {
                  final used = await controller.performCompanyAction(action);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        used
                            ? '${action.title} applied.'
                            : 'Not enough energy for that action.',
                      ),
                    ),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Company closed.')),
                );
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
  const _UnlockCard({
    required this.unlocked,
    required this.text,
  });

  final bool unlocked;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surfaceRaised,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              unlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
              color: unlocked ? AppTheme.green : AppTheme.amber,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
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
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(type.title, style: textTheme.titleMedium)),
                _Pill(label: type.risk),
              ],
            ),
            const SizedBox(height: 8),
            Text(type.description, style: textTheme.bodyMedium),
            const SizedBox(height: 12),
            _Metric(label: 'Startup cost', value: '${type.startupCost}'),
            _Metric(label: 'Operating cost', value: '${type.monthlyOperatingCost}/mo'),
            _Metric(
              label: 'Revenue range',
              value: '${type.minRevenue}-${type.maxRevenue}/mo',
            ),
            _Metric(
              label: 'Profile',
              value: const CompanyProfileService().profileFor(type).summary,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: canFound ? onFound : null,
              child: const Text('Found Company'),
            ),
          ],
        ),
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
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: AppTheme.surfaceRaised,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(company.name, style: textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('${company.type.title} - $outlook', style: textTheme.bodyMedium),
            const SizedBox(height: 14),
            _Metric(label: 'Months active', value: '${company.monthsActive}'),
            _Metric(label: 'Health', value: '${company.health}/100'),
            _Metric(label: 'Momentum', value: '${company.momentum}/100'),
            _Metric(label: 'Pipeline', value: '${company.pipeline}/100'),
            _Metric(label: 'Operations', value: '${company.operations}/100'),
            _Metric(label: 'Last net result', value: '${company.lastNetResult}'),
            _Metric(label: 'Current effort', value: '${company.effortThisMonth} EN'),
            const SizedBox(height: 8),
            Text('Business outlook', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final signal in signals)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(signal, style: textTheme.bodyMedium),
              ),
          ],
        ),
      ),
    );
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
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: canUse ? onUse : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(action.title, style: textTheme.titleMedium),
                    const SizedBox(height: 5),
                    Text(action.description, style: textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      _effectText(action),
                      style: textTheme.bodyMedium?.copyWith(color: AppTheme.mutedText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _Pill(label: '${action.energyCost} EN'),
            ],
          ),
        ),
      ),
    );
  }

  String _effectText(CompanyAction action) {
    final parts = <String>[];
    if (action.health != 0) parts.add('Health ${_signed(action.health)}');
    if (action.momentum != 0) parts.add('Momentum ${_signed(action.momentum)}');
    if (action.pipeline != 0) parts.add('Pipeline ${_signed(action.pipeline)}');
    if (action.operations != 0) {
      parts.add('Operations ${_signed(action.operations)}');
    }
    return parts.join(' / ');
  }

  String _signed(int value) => value > 0 ? '+$value' : '$value';
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textTheme.bodyMedium)),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.primary,
            ),
      ),
    );
  }
}
