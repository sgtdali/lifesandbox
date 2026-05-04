import '../models/company_profile.dart';
import '../models/company_type.dart';

class CompanyProfileService {
  const CompanyProfileService();

  CompanyProfile profileFor(CompanyType type) {
    switch (type.id) {
      case 'sales_office':
        return const CompanyProfile(
          pipelineBias: 8,
          operationsBias: -3,
          volatility: 24,
          momentumSensitivity: 10,
          pipelineConversion: 1.15,
          operationsDrag: 10,
          summary: 'Strong lead swings, higher volatility.',
        );
      case 'digital_studio':
        return const CompanyProfile(
          pipelineBias: 2,
          operationsBias: 1,
          volatility: 18,
          momentumSensitivity: 14,
          pipelineConversion: 1.05,
          operationsDrag: 8,
          summary: 'Momentum-sensitive and focus-driven.',
        );
      case 'operations_firm':
        return const CompanyProfile(
          pipelineBias: 1,
          operationsBias: -6,
          volatility: 14,
          momentumSensitivity: 7,
          pipelineConversion: 1.00,
          operationsDrag: 15,
          summary: 'Operationally demanding, steadier upside when stable.',
        );
      case 'service_agency':
      default:
        return const CompanyProfile(
          pipelineBias: 4,
          operationsBias: 2,
          volatility: 12,
          momentumSensitivity: 8,
          pipelineConversion: 0.95,
          operationsDrag: 7,
          summary: 'Stable service work with moderate pressure.',
        );
    }
  }
}
