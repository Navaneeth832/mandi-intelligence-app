import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_intelligence_app/core/providers/providers.dart';
import 'package:mandi_intelligence_app/data/models/commodity_model.dart';
import 'package:mandi_intelligence_app/features/auth/providers/auth_provider.dart';
import 'package:mandi_intelligence_app/features/auth/providers/profile_notifier.dart';
import 'package:mandi_intelligence_app/features/mandi_prices/providers/mandi_prices_provider.dart';
import 'package:mandi_intelligence_app/features/auth/screens/onboarding_screen.dart';
import 'package:mandi_intelligence_app/features/auth/screens/login_screen.dart';

const Color _primaryGreen = Color.fromARGB(255, 26, 152, 9);
const Color _backgroundColor = Color(0xFFF8F9FA);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final prefsAsync = ref.watch(preferredCropsNotifierProvider);
    final cropsAsync = ref.watch(commoditiesProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.person_outline, color: _primaryGreen),
            SizedBox(width: 8),
            Text(
              'Profile',
              style: TextStyle(
                color: _primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _primaryGreen)),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (user) {
          final String name = user?.name ?? '';
          final String email = user?.email ?? '';
          final String initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';

          final languageCode = user?.preferredLanguage;
          final String language = {
                'en': 'English',
                'ml': 'Malayalam',
                'hi': 'Hindi',
              }[languageCode] ??
              languageCode ??
              'English';

          final String stateIdStr = user?.stateId?.toString() ?? '-';
          final String districtIdStr = user?.districtId?.toString() ?? '-';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: _primaryGreen,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 44,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: _backgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: _primaryGreen,
                        child: Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  name.isNotEmpty ? name : 'User',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                const SizedBox(height: 32),
                _buildPersonalInfoCard(stateIdStr, districtIdStr, language),
                const SizedBox(height: 16),
                _buildPreferredCropsCard(prefsAsync, cropsAsync),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OnboardingScreen(isEditMode: true),
                      ),
                    );
                  },
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.2),
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red),
                  ),
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalInfoCard(String state, String district, String language) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.contact_page_outlined, color: _primaryGreen),
                SizedBox(width: 8),
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(Icons.public, 'State', state),
            const Divider(height: 32, thickness: 1, color: Color(0xFFF0F0F0)),
            _buildInfoRow(Icons.location_city, 'District', district),
            const Divider(height: 32, thickness: 1, color: Color(0xFFF0F0F0)),
            _buildInfoRow(Icons.translate, 'Language', language),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFF2F4F2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black87, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPreferredCropsCard(
  AsyncValue<List<Map<String, dynamic>>> prefsAsync,
  AsyncValue<List<Commodity>> cropsAsync,
) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Preferred Crops',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            prefsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: _primaryGreen)),
              error: (err, stack) => Text('Error: $err'),
              data: (prefs) {
                return cropsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: _primaryGreen)),
                  error: (err, stack) => Text('Error: $err'),
                  data: (List<Commodity> allCrops) {
                    final selectedCrops = allCrops.where(
                        (Commodity c) =>
                            prefs.any((Map<String, dynamic> p) => p['commodity_id'] == c.id),
                      ).toList();
                    if (selectedCrops.isEmpty) {
                      return const Text('No preferred crops selected.', style: TextStyle(color: Colors.grey));
                    }
                    return Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: selectedCrops.map((c) => _buildCropChip(c.name)).toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.grass, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              color: _primaryGreen,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}