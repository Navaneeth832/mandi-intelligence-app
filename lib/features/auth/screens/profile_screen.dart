import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_intelligence_app/core/providers/providers.dart';
import 'package:mandi_intelligence_app/features/auth/providers/auth_provider.dart';
import 'package:mandi_intelligence_app/features/auth/providers/profile_notifier.dart';
import 'package:mandi_intelligence_app/features/mandi_prices/providers/mandi_prices_provider.dart';
import 'package:mandi_intelligence_app/features/auth/screens/onboarding_screen.dart';
import 'package:mandi_intelligence_app/features/auth/screens/login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final prefsAsync = ref.watch(preferredCropsNotifierProvider);
    final cropsAsync = ref.watch(commoditiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (user) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${user?.name}', style: const TextStyle(fontSize: 18)),
                Text('Email: ${user?.email}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Language: ${{
                  'en': 'English',
                  'ml': 'Malayalam',
                  'hi': 'Hindi',
                }[user?.preferredLanguage] ?? user?.preferredLanguage}', style: const TextStyle(fontSize: 16)),
                Text('State ID: ${user?.stateId?.toString() ?? '-'}'),
                Text('District ID: ${user?.districtId?.toString() ?? '-'}'),
                const SizedBox(height: 20),
                const Text('Preferred Crops:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                prefsAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (err, stack) => Text('Error: $err'),
                  data: (prefs) {
                    return cropsAsync.when(
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => Text('Error: $err'),
                      data: (allCrops) {
                        final selectedCrops = allCrops.where((c) => prefs.any((p) => p['commodity_id'] == c.id)).toList();
                        return Wrap(
                          spacing: 8.0,
                          children: selectedCrops.map((c) => Chip(label: Text(c.name))).toList(),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 30),
                Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const OnboardingScreen(isEditMode: true)));
                        },
                        child: const Text('Edit Profile'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
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
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
