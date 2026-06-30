import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_intelligence_app/core/providers/locale_provider.dart';
import 'package:mandi_intelligence_app/core/providers/providers.dart';
import 'package:mandi_intelligence_app/data/models/commodity_model.dart';
import 'package:mandi_intelligence_app/data/models/district_model.dart';
import 'package:mandi_intelligence_app/data/models/state_model.dart';
import 'package:mandi_intelligence_app/features/auth/providers/profile_notifier.dart';
import 'package:mandi_intelligence_app/features/auth/providers/edit_profile_data_provider.dart';
import 'package:mandi_intelligence_app/features/mandi_prices/providers/mandi_prices_provider.dart';
import 'package:mandi_intelligence_app/features/mandi_prices/widgets/filter_dropdown.dart';
import 'package:mandi_intelligence_app/main_screen.dart';

const Color _primaryGreen = Color.fromARGB(255, 26, 152, 9);
const Color _bgColor = Color(0xFFF8F9FA);

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
      _selectedCrops.addAll(data.allCrops.where((Commodity c) => data.prefs.any((Map<String, dynamic> p) => p['commodity_id'] == c.id)));
    }
    _isDataPopulated = true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditMode) {
      final editDataAsync = ref.watch(editProfileDataProvider);
      return editDataAsync.when(
        loading: () => Scaffold(
          backgroundColor: _bgColor,
          appBar: _buildAppBar(),
          body: const Center(child: CircularProgressIndicator(color: _primaryGreen)),
        ),
        error: (err, stack) => Scaffold(
          backgroundColor: _bgColor,
          appBar: _buildAppBar(),
          body: Center(child: Text('Error: $err')),
        ),
        data: (data) {
          _populateFields(data);
          return _buildForm();
        },
      );
    }
    return _buildForm();
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _bgColor,
      elevation: 0,
      centerTitle: true,
      leading: const BackButton(color: Colors.black87),
      title: Text(
        widget.isEditMode ? "Edit Profile" : "Setup Profile",
        style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      actions: widget.isEditMode
          ? null
          : [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
                },
                child: const Text('Skip', style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(width: 8),
            ],
    );
  }

  Widget _buildForm() {
    final statesAsync = ref.watch(statesProvider);
    final districtsAsync = ref.watch(districtsProvider(_selectedState?.id));
    final cropsAsync = ref.watch(commoditiesProvider);
    
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://images.unsplash.com/photo-1500937386664-56d1dfef3854',
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.isEditMode ? "Update Your Profile" : "Finish Setting Up Your Profile",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              "Complete your profile to receive personalized mandi prices, crop recommendations, and market alerts.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.3),
            ),
            const SizedBox(height: 16),
            
            _buildPersonalInfoCard(statesAsync, districtsAsync),
            const SizedBox(height: 12),
            
            _buildPreferredCropsCard(cropsAsync),
            const SizedBox(height: 24),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
              ),
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
                        ref.read(localeProvider.notifier).setLocale(languageCode);
                        
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
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
                        }
                      }
                    }
                  : null,
              child: Text(
                widget.isEditMode ? 'Save Changes' : 'Continue',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(AsyncValue statesAsync, AsyncValue districtsAsync) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Personal Information",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _primaryGreen),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildLabel("📍 State")),
                const SizedBox(width: 12),
                Expanded(child: _buildLabel("🏙 District")),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: statesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: _primaryGreen)),
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _selectedState == null
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Text('Select District', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        )
                      : districtsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: _primaryGreen)),
                          error: (err, stack) => Text('Error: $err'),
                          data: (districts) => FilterDropdownButton<District>(
                            hintText: 'Select District',
                            items: districts,
                            value: _selectedDistrict,
                            itemToString: (district) => district.name,
                            onChanged: (val) => setState(() => _selectedDistrict = val),
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildLabel("🌐 Preferred Language"),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              hint: const Text('Select Language', style: TextStyle(fontSize: 14)),
              isDense: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items: _languages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: (val) => setState(() => _selectedLanguage = val),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primaryGreen)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferredCropsCard(AsyncValue cropsAsync) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Preferred Crops",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _primaryGreen),
            ),
            const SizedBox(height: 4),
            Text(
              "Choose up to 5 crops.",
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            
            cropsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: _primaryGreen)),
              error: (err, stack) => Text('Error: $err'),
              data: (crops) => FilterDropdownButton<Commodity>(
                hintText: 'Search crops...',
                items: crops,
                value: null,
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
            const SizedBox(height: 120),
            if (_selectedCrops.isNotEmpty) ...[
               Transform.translate(
                  offset: const Offset(0, -108),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: -4,
                    children: _selectedCrops.map((crop) => Chip(
                        label: Text(
                          '🌾 ${crop.name}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                        ),
                        backgroundColor: _bgColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16, color: Colors.grey),
                        onDeleted: () => setState(() => _selectedCrops.remove(crop)),
                      )).toList(),
                  ),
                ),
              const SizedBox(height: 12),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[800]),
      ),
    );
  }
}