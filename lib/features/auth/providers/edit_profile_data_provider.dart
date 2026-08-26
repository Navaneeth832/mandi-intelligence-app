import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_intelligence_app/features/auth/providers/profile_notifier.dart';
import 'package:mandi_intelligence_app/features/mandi_prices/providers/mandi_prices_provider.dart';
import 'package:mandi_intelligence_app/data/models/commodity_model.dart';
import 'package:mandi_intelligence_app/data/models/district_model.dart';
import 'package:mandi_intelligence_app/data/models/market_model.dart';
import 'package:mandi_intelligence_app/data/models/state_model.dart';
import 'package:mandi_intelligence_app/data/models/auth/user_profile.dart';

class EditProfileData {
  final UserProfile? user;
  final List<Map<String, dynamic>> prefs;
  final List<Commodity> allCrops;
  final List<StateModel> states;
  final List<District>? districts;
  final List<Market>? markets;

  EditProfileData({
    required this.user,
    required this.prefs,
    required this.allCrops,
    required this.states,
    this.districts,
    this.markets,
  });
}

final editProfileDataProvider = FutureProvider.autoDispose<EditProfileData>((ref) async {
  final user = await ref.watch(profileNotifierProvider.future);
  final prefs = await ref.watch(preferredCropsNotifierProvider.future);
  final allCrops = await ref.watch(activeCommoditiesProvider.future);
  final states = await ref.watch(statesProvider.future);
  
  List<District>? districts;
  if (user != null && user.stateId != null) {
      districts = await ref.watch(districtsProvider(user.stateId!).future);
  }

  List<Market>? markets;
  if (user != null && user.districtId != null) {
      markets = await ref.watch(allMarketsListProvider(user.districtId!).future);
  }

  return EditProfileData(
    user: user,
    prefs: prefs,
    allCrops: allCrops,
    states: states,
    districts: districts,
    markets: markets,
  );
});
