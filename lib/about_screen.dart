import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Color primaryColor = const Color(0xFF0D6B58);
    Color secondaryColor = const Color(0xFFE2F3E8);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20), onPressed: () => Navigator.pop(context)),
                  Expanded(
                    child: Column(
                      children: [
                        Text('ecobin_app'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('version'.tr(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('developer_team'.tr(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: secondaryColor, shape: BoxShape.circle), child: Icon(Icons.track_changes, color: primaryColor, size: 24)),
                        const SizedBox(width: 16),
                        Text('our_mission'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('mission_desc'.tr(), style: const TextStyle(height: 1.6, color: Colors.black87, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Text('how_it_works'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    _buildStep(secondaryColor, primaryColor, '1', 'create_account'.tr(), 'create_account_desc'.tr()),
                    const SizedBox(height: 24),
                    _buildStep(secondaryColor, primaryColor, '2', 'find_smart_bin'.tr(), 'find_smart_bin_desc'.tr()),
                    const SizedBox(height: 24),
                    _buildStep(secondaryColor, primaryColor, '3', 'scan_deposit'.tr(), 'scan_deposit_desc'.tr()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildStep(Color backgroundColor, Color textColor, String stepNumber, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(backgroundColor: backgroundColor, radius: 18, child: Text(stepNumber, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16))),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Text(description, style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}