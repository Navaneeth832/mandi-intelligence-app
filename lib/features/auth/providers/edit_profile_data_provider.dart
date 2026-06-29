import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_intelligence_app/core/providers/providers.dart';
import 'package:mandi_intelligence_app/features/auth/providers/profile_notifier.dart';
import 'package:mandi_intelligence_app/features/mandi_prices/providers/mandi_prices_provider.dart';
import 'package:mandi_intelligence_app/data/models/commodity_model.dart';
import 'package:mandi_intelligence_app/data/models/district_model.dart';
import 'package:mandi_intelligence_app/data/models/state_model.dart';
import 'package:mandi_intelligence_app/data/models/auth/user_profile.dart';

class EditProfileData {
  final UserProfile? user;
  final List<Map<String, dynamic>> prefs;
  final List<Commodity> allCrops;
  final List<StateModel> states;
  final List<District>? districts;

  EditProfileData({
    required this.user,
    required this.prefs,
    required this.allCrops,
    required this.states,
    this.districts,
  });
}

final editProfileDataProvider = FutureProvider.autoDispose<EditProfileData>((ref) async {
  final authRepo = ref.read(authRepositoryProvider);
  final user = await ref.watch(profileNotifierProvider.future);
  final prefs = await ref.watch(preferredCropsNotifierProvider.future);
  final allCrops = await ref.watch(commoditiesProvider.future);
  final states = await ref.watch(statesProvider.future);
  
  List<District>? districts;
  if (user != null && user.stateId != null) {
      districts = await ref.watch(districtsProvider(user.stateId!).future);
  }

  return EditProfileData(
    user: user,
    prefs: prefs,
    allCrops: allCrops,
    states: states,
    districts: districts,
  );
});
