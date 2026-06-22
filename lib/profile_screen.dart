import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';
import 'api_constants.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'about_screen.dart';
import 'employee_screen.dart';
import 'animated_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Color primaryColor = const Color(0xFF0D6B58);
  Color secondaryColor = const Color(0xFFE2F3E8);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadLocalData();
      context.read<UserProvider>().fetchProfileData();
    });
  }

  Future<void> _handleLogout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    // التعديل هنا: دمجنا الشرطين مع بعض (مدير النظام أو موظف معتمد)
    bool showEmployeeDashboard = (userProvider.email == 'sagedryan775@gmail.com') ||
        (userProvider.isEmployee && userProvider.isApprovedEmployee);

    String displayName = userProvider.fullName.isNotEmpty ? userProvider.fullName : userProvider.userName;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: () async {
          await userProvider.fetchProfileData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Stack(
            children: [
              Container(
                height: 320,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white70,
                          backgroundImage: userProvider.profilePicUrl != null
                              ? NetworkImage('${ApiConstants.mediaUrl}${userProvider.profilePicUrl}')
                              : null,
                          child: userProvider.profilePicUrl == null
                              ? const Icon(Icons.person, size: 70, color: Colors.grey)
                              : null,
                        ),
                        if (userProvider.isOffline)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                            child: const Icon(Icons.cloud_off, color: Colors.white, size: 20),
                          )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      userProvider.email.isNotEmpty ? userProvider.email : 'ID: ECO-USER-12345',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 260, left: 20, right: 20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard(secondaryColor, primaryColor, Icons.military_tech_outlined, '${userProvider.currentBalance}', 'points'.tr()),
                          _buildStatCard(Colors.purple.shade50, Colors.purple.shade300, Icons.check_box_outlined, '${userProvider.deposits}', 'deposits'.tr()),
                          _buildStatCard(Colors.blue.shade50, Colors.blue.shade400, Icons.bolt_outlined, userProvider.totalWeight.toStringAsFixed(1), 'kg_recycled'.tr()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (showEmployeeDashboard) ...[
                      AnimatedButton(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const EmployeeScreen()));
                        },
                        child: _buildMenuOption(Icons.admin_panel_settings, 'employee_dashboard'.tr(), Colors.amber.shade50, Colors.amber.shade800, false),
                      ),
                      const SizedBox(height: 16),
                    ],
                    AnimatedButton(
                      onTap: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(
                          currentName: userProvider.fullName,
                          currentEmail: userProvider.email,
                          currentPhone: userProvider.phone,
                          currentAddress: userProvider.address,
                          profilePicUrl: userProvider.profilePicUrl,
                        )));
                        userProvider.fetchProfileData();
                      },
                      child: _buildMenuOption(Icons.person_outline, 'edit_profile'.tr(), Colors.grey.shade50, Colors.black87, false),
                    ),
                    const SizedBox(height: 16),
                    AnimatedButton(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
                      },
                      child: _buildMenuOption(Icons.info_outline, 'about_ecobin'.tr(), Colors.grey.shade50, Colors.black87, false),
                    ),
                    const SizedBox(height: 16),
                    AnimatedButton(
                      onTap: _handleLogout,
                      child: _buildMenuOption(Icons.logout, 'logout'.tr(), secondaryColor, primaryColor, true),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(Color backgroundColor, Color iconColor, IconData icon, String value, String title) {
    return Column(
      children: [
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: iconColor, size: 28)),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _buildMenuOption(IconData icon, String title, Color backgroundColor, Color textColor, bool isLogout) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: isLogout ? textColor : Colors.grey.shade600, size: 24)),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor))),
          if (!isLogout) const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black87),
        ],
      ),
    );
  }
}