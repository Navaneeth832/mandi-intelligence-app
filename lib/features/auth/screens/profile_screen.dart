import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_intelligence_app/core/providers/locale_provider.dart';
import 'package:mandi_intelligence_app/data/models/commodity_model.dart';
import 'package:mandi_intelligence_app/features/auth/providers/auth_provider.dart';
import 'package:mandi_intelligence_app/features/auth/providers/profile_notifier.dart';
import 'package:mandi_intelligence_app/features/mandi_prices/providers/mandi_prices_provider.dart';
import 'package:mandi_intelligence_app/features/auth/screens/onboarding_screen.dart';
import 'package:mandi_intelligence_app/features/auth/screens/notification_settings_screen.dart';
import 'package:mandi_intelligence_app/features/auth/screens/login_screen.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';

const Color _primaryGreen = Color.fromARGB(255, 26, 152, 9);
const Color _backgroundColor = Color(0xFFF8F9FA);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final prefsAsync = ref.watch(preferredCropsNotifierProvider);
    final cropsAsync = ref.watch(allCommoditiesProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(Icons.person_outline, color: _primaryGreen),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.profile,
              style: TextStyle(
                color: _primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: const [],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _primaryGreen)),
        error: (err, stack) => Center(child: Text(AppLocalizations.of(context)!.errorWithDetails(err.toString()))),
        data: (user) {
          final String name = user?.name ?? '';
          final String email = user?.email ?? '';
          final String initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';

          final languageCode = user?.preferredLanguage;
          String language = 'English';
          if (languageCode == 'en') {
            language = AppLocalizations.of(context)!.english;
          } else if (languageCode == 'ml') {
            language = AppLocalizations.of(context)!.malayalam;
          } else if (languageCode == 'hi') {
            language = AppLocalizations.of(context)!.hindi;
          }

          final String stateName = user?.stateName ?? '-';
          final String districtName = user?.districtName ?? '-';
          final String marketName = user?.preferredMarketName ?? '-';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                Text(
                  name.isNotEmpty ? name : AppLocalizations.of(context)!.user,
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
                _buildPersonalInfoCard(
                  context,
                  stateName,
                  districtName,
                  marketName,
                  language,
                ),
                const SizedBox(height: 16),
                _buildPreferredCropsCard(context, prefsAsync, cropsAsync, locale),
                const SizedBox(height: 16),
                _buildNotificationSettingsCard(context),
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
                  child: Text(
                    AppLocalizations.of(context)!.editProfile,
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
                  label: Text(
                    AppLocalizations.of(context)!.logout,
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

 Widget _buildPersonalInfoCard(
  BuildContext context,
  String state,
  String district,
  String market,
  String language,
) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_page_outlined, color: _primaryGreen),
                SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.personalInformation,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(context,Icons.public, AppLocalizations.of(context)!.state, state),
            const Divider(height: 32, thickness: 1, color: Color(0xFFF0F0F0)),
            _buildInfoRow(context,Icons.location_city, AppLocalizations.of(context)!.district, district),
            const Divider(height: 32, thickness: 1, color: Color(0xFFF0F0F0)),
            _buildInfoRow(
              context,
              Icons.store_mall_directory_outlined,
              "Preferred Market",
              market,
              isTappable: true,
            ),
            const Divider(height: 32, thickness: 1, color: Color(0xFFF0F0F0)),
            _buildInfoRow(context,Icons.translate, AppLocalizations.of(context)!.language, language),
          ],
        ),
      ),
    );
  }

  void _showMarketNameDialog(BuildContext context, String title, String fullName) {
    if (fullName.trim().isEmpty || fullName == '-') return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        content: Text(
          fullName,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Close',
              style: TextStyle(
                color: _primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isTappable = false,
  }) {
    final bool canTap = isTappable && value.trim().isNotEmpty && value != '-';

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
        const SizedBox(width: 12),
        Expanded(
          child: canTap
              ? InkWell(
                  onTap: () => _showMarketNameDialog(context, label, value),
                  borderRadius: BorderRadius.circular(4),
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                )
              : Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
        ),
      ],
    );
  }

Widget _buildPreferredCropsCard(
  BuildContext context,
  AsyncValue<List<Map<String, dynamic>>> prefsAsync,
  AsyncValue<List<Commodity>> cropsAsync,
  Locale locale,
){
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
            Text(
              AppLocalizations.of(context)!.preferredCrops,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            prefsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: _primaryGreen)),
              error: (err, stack) => Text(AppLocalizations.of(context)!.errorWithDetails(err.toString())),
              data: (prefs) {
                return cropsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: _primaryGreen)),
                  error: (err, stack) => Text(AppLocalizations.of(context)!.errorWithDetails(err.toString())),
                  data: (List<Commodity> allCrops) {
                    final selectedCrops = allCrops.where(
                        (Commodity c) =>
                            prefs.any((Map<String, dynamic> p) => p['commodity_id'] == c.id),
                      ).toList();
                    if (selectedCrops.isEmpty) {
                      return Text(AppLocalizations.of(context)!.noPreferredCropsSelected, style: const TextStyle(color: Colors.grey));
                    }
                    return Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: selectedCrops.map((c) => _buildCropChip(c.getDisplayName(locale.languageCode))).toList(),
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
        color: _primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.grass, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                color: _primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettingsCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NotificationSettingsScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F4F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: _primaryGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.notificationSettings,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context)!.notificationSettingsSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
