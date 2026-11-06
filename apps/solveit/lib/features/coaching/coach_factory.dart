import 'coach_provider.dart';
import 'firebase_ai_coach_provider.dart';
import 'firebase_runtime_config.dart';

CoachProvider configuredCoach() {
  if (FirebaseRuntimeConfig.isConfigured) {
    return FirebaseAiCoachProvider();
  }
  const address = String.fromEnvironment('SOLVEIT_COACH_URL');
  return address.isEmpty ? const DisabledCoach() : LocalCoachProvider(address);
}
