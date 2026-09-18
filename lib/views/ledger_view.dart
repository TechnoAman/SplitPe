import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import '../models/ledger_entry.dart';
import '../models/tranche.dart';
import '../services/ledger_share_service.dart';
import '../services/session_ledger_service.dart';
import '../services/upi_phone_extractor.dart';
import '../theme/app_theme.dart';

class LedgerView extends StatefulWidget {
  const LedgerView({super.key});

  @override
  State<LedgerView> createState() => _LedgerViewState();
}

class _LedgerViewState extends State<LedgerView> {
  TrancheStatus? _selectedStatusFilter;

  Color _getStatusColor(TrancheStatus status) {
    switch (status) {
      case TrancheStatus.inProgress:
        return AppColors.primaryBlue;
      case TrancheStatus.paid:
        return const Color(0xFF10B981);
      case TrancheStatus.failed:
        return const Color(0xFFEF4444);
      case TrancheStatus.pending:
        return const Color(0xFFF59E0B);
    }
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear Session Ledger?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.text(context),
          ),
        ),
        content: Text(
          'This will clear all in-memory transaction entries from this session. Remember that session records are never stored to disk.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSub(context),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSub(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              SessionLedgerService.instance.clear();
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Clear Ledger', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDark(context);

    return ListenableBuilder(
      listenable: SessionLedgerService.instance,
      builder: (context, _) {
        final allEntries = SessionLedgerService.instance.entries;
        final filteredEntries = SessionLedgerService.instance.getFilteredEntries(
          statusFilter: _selectedStatusFilter,
        );
        final totalVolume = SessionLedgerService.instance.totalVolume;
        final totalCount = SessionLedgerService.instance.count;

        // Determine if any receiver in current entries has a phone number
        String? merchantPhoneReceiver;
        for (final entry in filteredEntries) {
          if (extractPhoneFromUpiId(entry.receiverUpiId) != null) {
            merchantPhoneReceiver = entry.receiverUpiId;
            break;
          }
        }

        return Scaffold(
          backgroundColor: AppColors.bg(context),
          body: CustomScrollView(
            slivers: [
              // 1. Session Header & Overview
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Session Notice & Clear Button
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withAlpha(isDark ? 35 : 20),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.primaryBlue.withAlpha(120),
                                width: 0.8,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.memory_rounded, size: 11, color: AppColors.primaryBlue),
                                SizedBox(width: 4),
                                Text(
                                  'IN-MEMORY SESSION ONLY',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (totalCount > 0)
                            TextButton.icon(
                              onPressed: _showClearConfirmDialog,
                              icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFEF4444)),
                              label: const Text(
                                'Clear',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Metrics Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.card(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF262833) : const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SESSION VOLUME',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                      color: AppColors.textSub(context),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${totalVolume.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.text(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 32,
                              width: 1,
                              color: isDark ? const Color(0xFF2B2E3B) : const Color(0xFFE2E8F0),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TRANCHES LAUNCHED',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.6,
                                        color: AppColors.textSub(context),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$totalCount tranches',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.text(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Export & Share Bar
                      if (allEntries.isNotEmpty) ...[
                        Row(
                          children: [
                            Expanded(
                              child: NeoPopButton(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                                border: Border.all(
                                  color: AppColors.primaryBlue.withAlpha(150),
                                  width: 1.2,
                                ),
                                depth: 2,
                                onTapUp: () => LedgerShareService.instance.shareCsv(allEntries),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.table_chart_rounded, size: 14, color: AppColors.primaryBlue),
                                      SizedBox(width: 6),
                                      Text(
                                        'EXPORT CSV',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: NeoPopButton(
                                color: AppColors.primaryBlue,
                                border: Border.all(color: Colors.black, width: 1.2),
                                depth: 2,
                                onTapUp: () => LedgerShareService.instance.shareSummary(allEntries),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.share_rounded, size: 14, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text(
                                        'SHARE SUMMARY',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Additional Merchant SMS button if phone is extractable
                        if (merchantPhoneReceiver != null) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: NeoPopButton(
                              color: const Color(0xFF10B981),
                              border: Border.all(color: Colors.black, width: 1.2),
                              depth: 2,
                              onTapUp: () {
                                LedgerShareService.instance.shareToMerchantViaSms(
                                  receiverUpiId: merchantPhoneReceiver!,
                                  entries: filteredEntries,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.sms_rounded, size: 14, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Text(
                                      'SHARE TO MERCHANT VIA SMS (${extractPhoneFromUpiId(merchantPhoneReceiver)!})',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                      ],

                      // Status Filters Bar
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              label: 'ALL (${allEntries.length})',
                              isSelected: _selectedStatusFilter == null,
                              onTap: () => setState(() => _selectedStatusFilter = null),
                              color: AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 6),
                            _buildFilterChip(
                              label: 'LAUNCHED (${allEntries.where((e) => e.status == TrancheStatus.inProgress).length})',
                              isSelected: _selectedStatusFilter == TrancheStatus.inProgress,
                              onTap: () => setState(() => _selectedStatusFilter = TrancheStatus.inProgress),
                              color: AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 6),
                            _buildFilterChip(
                              label: 'PAID (${allEntries.where((e) => e.status == TrancheStatus.paid).length})',
                              isSelected: _selectedStatusFilter == TrancheStatus.paid,
                              onTap: () => setState(() => _selectedStatusFilter = TrancheStatus.paid),
                              color: const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 6),
                            _buildFilterChip(
                              label: 'FAILED (${allEntries.where((e) => e.status == TrancheStatus.failed).length})',
                              isSelected: _selectedStatusFilter == TrancheStatus.failed,
                              onTap: () => setState(() => _selectedStatusFilter = TrancheStatus.failed),
                              color: const Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 6),
                            _buildFilterChip(
                              label: 'PENDING (${allEntries.where((e) => e.status == TrancheStatus.pending).length})',
                              isSelected: _selectedStatusFilter == TrancheStatus.pending,
                              onTap: () => setState(() => _selectedStatusFilter = TrancheStatus.pending),
                              color: const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // 2. Entries List (Newest first) or Empty State
              if (filteredEntries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: AppColors.textSub(context).withAlpha(120),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            allEntries.isEmpty
                                ? 'No Session Transactions'
                                : 'No Matching Transactions',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            allEntries.isEmpty
                                ? 'Payments launched via POS Split or Group Bill will appear here. All records stay in-memory for this session.'
                                : 'Try selecting another status filter above.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSub(context),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = filteredEntries[index];
                        return _buildLedgerCard(entry, isDark);
                      },
                      childCount: filteredEntries.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    final isDark = ThemeController.isDark(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha(isDark ? 50 : 25)
              : (isDark ? const Color(0xFF16171E) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : (isDark ? const Color(0xFF262833) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? color : AppColors.textSub(context),
          ),
        ),
      ),
    );
  }

  Widget _buildLedgerCard(LedgerEntry entry, bool isDark) {
    final statusColor = _getStatusColor(entry.status);
    final phone = extractPhoneFromUpiId(entry.receiverUpiId);
    final timeStr =
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}';
    final dateStr =
        '${entry.timestamp.day.toString().padLeft(2, '0')}/${entry.timestamp.month.toString().padLeft(2, '0')}/${entry.timestamp.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF262833) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Amount & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${entry.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text(context),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(isDark ? 40 : 20),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withAlpha(120), width: 0.8),
                ),
                child: Text(
                  entry.statusLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Row 2: Sender -> Receiver
          Row(
            children: [
              Expanded(
                child: Text(
                  '${entry.senderUpiId} ➔ ${entry.receiverUpiId}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSub(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Row 3: Timestamp & Note / Tranche Index
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$dateStr · $timeStr',
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textSub(context).withAlpha(160),
                ),
              ),
              if (entry.note != null && entry.note!.trim().isNotEmpty)
                Text(
                  entry.note!.trim(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSub(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else if (entry.trancheIndex != null)
                Text(
                  'Tranche #${entry.trancheIndex! + 1}',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSub(context),
                  ),
                ),
            ],
          ),

          // Row 4: Share via SMS to merchant if 10-digit phone exists
          if (phone != null) ...[
            const SizedBox(height: 8),
            Divider(
              height: 1,
              color: isDark ? const Color(0xFF22242C) : const Color(0xFFF1F5F9),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  LedgerShareService.instance.shareEntryToMerchantViaSms(entry);
                },
                icon: const Icon(Icons.sms_outlined, size: 13, color: Color(0xFF10B981)),
                label: Text(
                  'SMS Merchant ($phone)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
