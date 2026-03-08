import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/referee_license.dart';
import '../models/sport.dart';
import '../utils/atl_colors.dart';

class RefereeLicenseWidget extends StatelessWidget {
  final RefereeLicense license;
  final Sport? sport;
  final VoidCallback? onLongPress;

  const RefereeLicenseWidget({
    super.key,
    required this.license,
    required this.sport,
    this.onLongPress,
  });

  Color _statusColor(LicenseStatus status) {
    switch (status) {
      case LicenseStatus.active:
        return ATLColors.footballGreen;
      case LicenseStatus.notVerified:
        return Colors.orange;
      case LicenseStatus.suspended:
        return Colors.deepOrange;
      case LicenseStatus.revoked:
        return Colors.red;
    }
  }

  String _statusLabel(LicenseStatus status) {
    switch (status) {
      case LicenseStatus.active:
        return 'Active';
      case LicenseStatus.notVerified:
        return 'Not Verified';
      case LicenseStatus.suspended:
        return 'Suspended';
      case LicenseStatus.revoked:
        return 'Revoked';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sportCategory = sport?.category;
    final primaryColor = sportCategory != null
        ? ATLColors.getPrimaryColor(sportCategory)
        : ATLColors.darkBlue;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: primaryColor, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: sport name + status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sport?.name ?? 'Sport #${license.sportId}',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(license.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel(license.status),
                      style: TextStyle(
                        color: _statusColor(license.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // License ID
              _infoRow(Icons.badge_outlined, 'ID', license.id),
              const SizedBox(height: 6),
              // Issued at
              _infoRow(
                Icons.calendar_today_outlined,
                'Issued',
                dateFormat.format(license.issuedAt),
              ),
              const SizedBox(height: 6),
              // Created at
              _infoRow(
                Icons.access_time_outlined,
                'Submitted',
                dateFormat.format(license.createdAt),
              ),
              if (license.verifiedAt != null) ...[
                const SizedBox(height: 6),
                _infoRow(
                  Icons.verified_outlined,
                  'Verified',
                  dateFormat.format(license.verifiedAt!),
                  color: ATLColors.footballGreen,
                ),
              ],
              if (license.revokedAt != null) ...[
                const SizedBox(height: 6),
                _infoRow(
                  Icons.cancel_outlined,
                  'Revoked',
                  dateFormat.format(license.revokedAt!),
                  color: Colors.red,
                ),
              ],
              if (license.status == LicenseStatus.notVerified) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      size: 14,
                      color: ATLColors.subtext.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hold to delete',
                      style: TextStyle(
                        color: ATLColors.subtext.withOpacity(0.5),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? ATLColors.subtext),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: ATLColors.subtext,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: color ?? ATLColors.subtext,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
