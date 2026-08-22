import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/notification_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/notification_preferences_provider.dart';

const Color _bgColor = Color(0xFFFAF7EC);
const Color _appBarBgColor = Color(0xFFFFF0C3);
const Color _yellowAccent = Color(0xFFFFC814);
const Color _iconBgColor = Color(0xFFFFF3C4);
const Color _headerBannerBg = Color(0xFFFFF7DB);
const Color _goldHeaderTextColor = Color(0xFFB78103);
const Color _darkTextColor = Color(0xFF1E1E1E);
const Color _cardBorderColor = Color(0xFFF3E7C4);

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  NotificationPreferences? _localPreferences;
  NotificationPreferences? _initialPreferences;
  bool _isSaving = false;

  bool get _hasChanges =>
      _localPreferences != null &&
      _initialPreferences != null &&
      _localPreferences != _initialPreferences;

  Future<bool> _onWillPop() async {
    if (!_hasChanges || _isSaving) return true;

    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.unsavedChanges),
        content: Text(l10n.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.skip),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(notificationPreferencesNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: !_hasChanges && !_isSaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: AppBar(
          backgroundColor: _appBarBgColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _darkTextColor),
            onPressed: () async {
              if (_hasChanges && !_isSaving) {
                final shouldPop = await _onWillPop();
                if (shouldPop && context.mounted) {
                  Navigator.of(context).pop();
                }
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          centerTitle: true,
          title: Text(
            l10n.notificationSettings,
            style: const TextStyle(
              color: _darkTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: prefsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: _yellowAccent),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    l10n.errorWithDetails(err.toString().replaceAll('Exception: ', '')),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: _darkTextColor),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _yellowAccent,
                      foregroundColor: _darkTextColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retryLabel),
                    onPressed: () {
                      ref.invalidate(notificationPreferencesNotifierProvider);
                    },
                  ),
                ],
              ),
            ),
          ),
          data: (preferences) {
            if (_localPreferences == null) {
              _localPreferences = preferences;
              _initialPreferences = preferences;
            }

            final current = _localPreferences!;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAlertTypesCard(context, current, l10n),
                  const SizedBox(height: 20),
                  _buildDeliveryCard(context, current, l10n),
                  const SizedBox(height: 20),
                  _buildFrequencyCard(context, current, l10n),
                  const SizedBox(height: 36),
                  _buildSaveButton(context, l10n),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAlertTypesCard(
    BuildContext context,
    NotificationPreferences current,
    AppLocalizations l10n,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildToggleRow(
            icon: Icons.trending_down,
            title: l10n.priceDrop,
            value: current.priceDrop,
            onChanged: (val) {
              setState(() {
                _localPreferences = current.copyWith(priceDrop: val);
              });
            },
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF7F2E6)),
          _buildToggleRow(
            icon: Icons.trending_up,
            title: l10n.betterMarket,
            value: current.betterMarket,
            onChanged: (val) {
              setState(() {
                _localPreferences = current.copyWith(betterMarket: val);
              });
            },
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF7F2E6)),
          _buildToggleRow(
            icon: Icons.auto_awesome,
            title: l10n.aiRecommendation,
            value: current.aiRecommendation,
            onChanged: (val) {
              setState(() {
                _localPreferences = current.copyWith(aiRecommendation: val);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(
    BuildContext context,
    NotificationPreferences current,
    AppLocalizations l10n,
  ) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCardHeader(
            icon: Icons.near_me_outlined,
            title: l10n.delivery,
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF7F2E6)),
          _buildToggleRow(
            icon: Icons.notifications_none_outlined,
            title: l10n.inAppNotifications,
            value: current.deliveryInApp,
            onChanged: (val) {
              setState(() {
                _localPreferences = current.copyWith(deliveryInApp: val);
              });
            },
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF7F2E6)),
          _buildToggleRow(
            icon: Icons.smartphone_outlined,
            title: l10n.pushNotifications,
            value: current.deliveryPush,
            onChanged: (val) {
              setState(() {
                _localPreferences = current.copyWith(deliveryPush: val);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyCard(
    BuildContext context,
    NotificationPreferences current,
    AppLocalizations l10n,
  ) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCardHeader(
            icon: Icons.access_time_outlined,
            title: l10n.notificationFrequency,
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF7F2E6)),
          _buildRadioRow(
            title: l10n.instant,
            isSelected: current.frequency == 'instant',
            onTap: () {
              setState(() {
                _localPreferences = current.copyWith(frequency: 'instant');
              });
            },
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF7F2E6)),
          _buildRadioRow(
            title: l10n.dailySummary,
            isSelected: current.frequency == 'daily_summary',
            onTap: () {
              setState(() {
                _localPreferences = current.copyWith(frequency: 'daily_summary');
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader({
    required IconData icon,
    required String title,
  }) {
    return Container(
      width: double.infinity,
      color: _headerBannerBg,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, color: _goldHeaderTextColor, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _goldHeaderTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: _iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _darkTextColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _darkTextColor,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: _yellowAccent,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioRow({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _yellowAccent : Colors.grey.shade400,
                  width: isSelected ? 7 : 2,
                ),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _darkTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _hasChanges && !_isSaving
            ? [
                BoxShadow(
                  color: _yellowAccent.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _yellowAccent,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: _darkTextColor,
          disabledForegroundColor: Colors.grey.shade600,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: (_hasChanges && !_isSaving)
            ? () => _savePreferences(context)
            : null,
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: _darkTextColor,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_outlined, color: _darkTextColor, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    l10n.saveChanges,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _darkTextColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _savePreferences(BuildContext context) async {
    if (_localPreferences == null || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      final saved = await ref
          .read(notificationPreferencesNotifierProvider.notifier)
          .savePreferences(_localPreferences!);

      if (mounted) {
        setState(() {
          _localPreferences = saved;
          _initialPreferences = saved;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.savedSuccessfully),
            backgroundColor: _yellowAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.failedToSave(e.toString().replaceAll('Exception: ', '')),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
