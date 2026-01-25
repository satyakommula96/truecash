import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truecash/domain/usecases/usecase_base.dart';
import 'package:truecash/presentation/providers/usecase_providers.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final bootProvider = FutureProvider<String?>((ref) async {
  final startupUseCase = ref.watch(startupUseCaseProvider);
  final result = await startupUseCase(NoParams());

  if (result.isFailure) {
    throw Exception(result.failureOrThrow.message);
  }

  const storage = FlutterSecureStorage();
  try {
    return await storage.read(key: 'app_pin');
  } catch (e) {
    // If secure storage fails (e.g. simulator/tests), return null
    return null;
  }
});
