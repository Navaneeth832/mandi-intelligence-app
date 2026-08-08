import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/notification_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/notification_preferences_provider.dart';

const Color _primaryGreen = Color.fromARGB(255, 26, 152, 9);
const Color _backgroundColor = Color(0xFFF8F9FA);

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
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
          title: Text(
            l10n.notificationSettings,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: prefsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: _primaryGreen),
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
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGreen,
                      foregroundColor: Colors.white,
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAlertTypesCard(context, current, l10n),
                  const SizedBox(height: 16),
                  _buildDeliveryCard(context, current, l10n),
                  const SizedBox(height: 16),
                  _buildFrequencyCard(context, current, l10n),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _hasChanges ? _primaryGreen : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
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
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            l10n.saveChanges,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
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
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_outlined, color: _primaryGreen),
                  const SizedBox(width: 8),
                  Text(
                    l10n.alertTypes,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFF0F0F0)),
            SwitchListTile(
              activeColor: _primaryGreen,
              title: Text(
                l10n.priceIncrease,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              value: current.priceIncrease,
              onChanged: (val) {
                setState(() {
                  _localPreferences = current.copyWith(priceIncrease: val);
                });
              },
            ),
            SwitchListTile(
              activeColor: _primaryGreen,
              title: Text(
                l10n.priceDrop,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              value: current.priceDrop,
              onChanged: (val) {
                setState(() {
                  _localPreferences = current.copyWith(priceDrop: val);
                });
              },
            ),
            SwitchListTile(
              activeColor: _primaryGreen,
              title: Text(
                l10n.betterMarket,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              value: current.betterMarket,
              onChanged: (val) {
                setState(() {
                  _localPreferences = current.copyWith(betterMarket: val);
                });
              },
            ),
            SwitchListTile(
              activeColor: _primaryGreen,
              title: Text(
                l10n.marketGlut,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              value: current.marketGlut,
              onChanged: (val) {
                setState(() {
                  _localPreferences = current.copyWith(marketGlut: val);
                });
              },
            ),
            SwitchListTile(
              activeColor: _primaryGreen,
              title: Text(
                l10n.aiRecommendation,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              value: current.aiRecommendation,
              onChanged: (val) {
                setState(() {
                  _localPreferences = current.copyWith(aiRecommendation: val);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(
    BuildContext context,
    NotificationPreferences current,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.send_outlined, color: _primaryGreen),
                  const SizedBox(width: 8),
                  Text(
                    l10n.delivery,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFF0F0F0)),
            SwitchListTile(
              activeColor: _primaryGreen,
              title: Text(
                l10n.inAppNotifications,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              value: current.deliveryInApp,
              onChanged: (val) {
                setState(() {
                  _localPreferences = current.copyWith(deliveryInApp: val);
                });
              },
            ),
            SwitchListTile(
              title: Row(
                children: [
                  Text(
                    l10n.smsNotifications,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildBadge(l10n.comingSoon),
                ],
              ),
              value: false,
              onChanged: null,
            ),
            SwitchListTile(
              title: Row(
                children: [
                  Text(
                    l10n.pushNotifications,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildBadge(l10n.comingSoon),
                ],
              ),
              value: false,
              onChanged: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyCard(
    BuildContext context,
    NotificationPreferences current,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.access_time_outlined, color: _primaryGreen),
                  const SizedBox(width: 8),
                  Text(
                    l10n.notificationFrequency,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFF0F0F0)),
            RadioListTile<String>(
              activeColor: _primaryGreen,
              title: Text(
                l10n.instant,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              value: 'instant',
              groupValue: current.frequency,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _localPreferences = current.copyWith(frequency: val);
                  });
                }
              },
            ),
            RadioListTile<String>(
              activeColor: _primaryGreen,
              title: Text(
                l10n.dailySummary,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              value: 'daily_summary',
              groupValue: current.frequency,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _localPreferences = current.copyWith(frequency: val);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
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
            backgroundColor: _primaryGreen,
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
