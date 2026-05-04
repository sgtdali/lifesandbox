import '../models/active_company.dart';

class CompanyOutlookService {
  const CompanyOutlookService();

  String labelFor(ActiveCompany company) {
    if (company.health < 30) return 'At Risk';
    if (company.pipeline < 28) return 'Thin Pipeline';
    if (company.operations < 30) return 'Operational Strain';
    if (company.momentum >= 68 && company.pipeline >= 60) return 'Growing';
    if (company.health >= 65 && company.operations >= 58) return 'Stable';
    return 'Developing';
  }

  List<String> signalsFor(ActiveCompany company) {
    final signals = <String>[];
    if (company.health < 40) signals.add('Fragile health');
    if (company.pipeline < 35) signals.add('Pipeline is weak');
    if (company.operations < 35) signals.add('Operations are strained');
    if (company.lastNetResult < 0) signals.add('Last month was negative');
    if (company.pipeline >= 65) signals.add('Strong pipeline');
    if (company.operations >= 65) signals.add('Operations are stable');
    if (company.momentum >= 70) signals.add('Momentum is improving');
    if (signals.isEmpty) signals.add('No major pressure signal');
    return signals.take(3).toList();
  }
}
