import 'package:trueledger/core/error/failure.dart';
import 'package:trueledger/core/utils/result.dart';
import 'package:trueledger/domain/models/models.dart';
import 'package:trueledger/domain/repositories/i_financial_repository.dart';
import 'usecase_base.dart';

class GetMonthlySummaryUseCase extends UseCase<MonthlySummary, NoParams> {
  final IFinancialRepository repository;

  GetMonthlySummaryUseCase(this.repository);

  @override
  Future<Result<MonthlySummary>> call(NoParams params) async {
    try {
      final summary = await repository.getMonthlySummary();
      return Success(summary);
    } catch (e) {
      return Failure(
          DatabaseFailure("Failed to load monthly summary: ${e.toString()}"));
    }
  }
}
