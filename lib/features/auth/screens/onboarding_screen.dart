import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_intelligence_app/core/providers/providers.dart';
import 'package:mandi_intelligence_app/data/models/commodity_model.dart';
import 'package:mandi_intelligence_app/data/models/district_model.dart';
import 'package:mandi_intelligence_app/data/models/state_model.dart';
import 'package:mandi_intelligence_app/features/auth/providers/profile_notifier.dart';
import 'package:mandi_intelligence_app/features/auth/providers/edit_profile_data_provider.dart';
import 'package:mandi_intelligence_app/features/mandi_prices/providers/mandi_prices_provider.dart';
import 'package:mandi_intelligence_app/features/mandi_prices/widgets/filter_dropdown.dart';
import 'package:mandi_intelligence_app/main_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final bool isEditMode;
  const OnboardingScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  StateModel? _selectedState;
  District? _selectedDistrict;
  String? _selectedLanguage;
  final List<Commodity> _selectedCrops = [];
  bool _isDataPopulated = false;

  final List<String> _languages = ['English', 'Malayalam', 'Hindi'];

  void _populateFields(EditProfileData data) {
    if (_isDataPopulated) return;

    final user = data.user;
    if (user != null) {
      final foundState = data.states.cast<StateModel?>().firstWhere((s) => s!.id == user.stateId, orElse: () => null);
      
      StateModel? selectedState;
      District? selectedDistrict;

      if (foundState != null) {
        selectedState = foundState;
        final foundDistrict = data.districts?.cast<District?>().firstWhere((d) => d!.id == user.districtId, orElse: () => null);
        selectedDistrict = foundDistrict;
      }

      _selectedState = selectedState;
      _selectedDistrict = selectedDistrict;
      
      switch (user.preferredLanguage) {
        case 'en':
          _selectedLanguage = 'English';
          break;
        case 'ml':
          _selectedLanguage = 'Malayalam';
          break;
        case 'hi':
          _selectedLanguage = 'Hindi';
          break;
        default:
          _selectedLanguage = 'English';
      }
      _selectedCrops.clear();
      _selectedCrops.addAll(data.allCrops.where((c) => data.prefs.any((p) => p['commodity_id'] == c.id)));
    }
    _isDataPopulated = true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditMode) {
      final editDataAsync = ref.watch(editProfileDataProvider);
      return editDataAsync.when(
        loading: () => Scaffold(appBar: AppBar(title: const Text("Setup Profile")), body: const Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(appBar: AppBar(title: const Text("Setup Profile")), body: Center(child: Text('Error: $err'))),
        data: (data) {
          _populateFields(data);
          return _buildForm();
        },
      );
    }
    return _buildForm();
  }

  Widget _buildForm() {
    final statesAsync = ref.watch(statesProvider);
    final districtsAsync = ref.watch(districtsProvider(_selectedState?.id));
    final cropsAsync = ref.watch(commoditiesProvider);
    
    // In EditMode, the dropdown items should be the ones from editProfileDataProvider if available,
    // otherwise fall back to the generic providers.
    
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditMode ? "Edit Profile" : "Setup Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.isEditMode ? "Update your profile details." : "Let's finish setting up your profile. You can always change these later."),
            const SizedBox(height: 20),
            
            // State Dropdown
            statesAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: $err'),
              data: (states) => FilterDropdownButton<StateModel>(
                hintText: 'Select State',
                items: states,
                value: _selectedState,
                itemToString: (state) => state.name,
                onChanged: (val) {
                  setState(() {
                    _selectedState = val;
                    _selectedDistrict = null; 
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            
            // District Dropdown
            _selectedState == null
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(24.0)),
                    child: const Text('District (Disabled)', style: TextStyle(color: Colors.grey)),
                  )
                : districtsAsync.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (err, stack) => Text('Error: $err'),
                    data: (districts) => FilterDropdownButton<District>(
                      hintText: 'Select District',
                      items: districts,
                      value: _selectedDistrict,
                      itemToString: (district) => district.name,
                      onChanged: (val) => setState(() => _selectedDistrict = val),
                    ),
                  ),
            const SizedBox(height: 10),
            
            // Language Dropdown
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              hint: const Text('Select Language'),
              items: _languages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
              onChanged: (val) => setState(() => _selectedLanguage = val),
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
            ),
            const SizedBox(height: 20),
            
            // Preferred Crops
            const Text("Preferred Crops", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Text("Choose up to 5 crops for personalized recommendations."),
            const SizedBox(height: 10),
            
            // Crop Multi-Select
            cropsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: $err'),
              data: (crops) => FilterDropdownButton<Commodity>(
                hintText: 'Select Crops',
                items: crops,
                value: null, // Multi-select doesn't map to a single value
                itemToString: (crop) => crop.name,
                onChanged: (val) {
                  if (val == null) return;
                  if (_selectedCrops.contains(val)) {
                    setState(() => _selectedCrops.remove(val));
                  } else if (_selectedCrops.length < 5) {
                    setState(() => _selectedCrops.add(val));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You can select a maximum of 5 preferred crops.")));
                  }
                },
              ),
            ),
            
            // Selected Crops Chips
            Wrap(
              spacing: 8.0,
              children: _selectedCrops.map((crop) => InputChip(
                label: Text(crop.name),
                onDeleted: () => setState(() => _selectedCrops.remove(crop)),
              )).toList(),
            ),
            
            const SizedBox(height: 30),
            
            Center(
              child: ElevatedButton(
                onPressed: (_selectedState != null && _selectedDistrict != null && _selectedLanguage != null)
                    ? () async {
                        try {
                          final authRepo = ref.read(authRepositoryProvider);
                          final user = await authRepo.getCurrentUser();
                          String languageCode;

                          switch (_selectedLanguage) {
                            case 'English':
                              languageCode = 'en';
                              break;

                            case 'Malayalam':
                              languageCode = 'ml';
                              break;

                            case 'Hindi':
                              languageCode = 'hi';
                              break;

                            default:
                              languageCode = 'en';
                          }
                          await authRepo.updateProfile({
                            "name": user?.name ?? 'User',
                            "state_id": _selectedState!.id,
                            "district_id": _selectedDistrict!.id,
                            "preferred_language": languageCode,
                          });
                          
                          // Save preferred crops
                          if (_selectedCrops.isNotEmpty) {
                             await authRepo.savePreferredCrops(_selectedCrops.map((c) => c.id).toList());
                          }
                          
                          if (mounted) {
                            if (widget.isEditMode) {
                              ref.invalidate(profileNotifierProvider);
                              ref.invalidate(preferredCropsNotifierProvider);
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
                            }
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
                        }
                      }
                    : null,
                child: Text(widget.isEditMode ? 'Save Changes' : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
