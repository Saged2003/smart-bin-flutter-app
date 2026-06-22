import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:easy_localization/easy_localization.dart';
import 'api_constants.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final String currentPhone;
  final String currentAddress;
  final String? profilePicUrl;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentEmail,
    required this.currentPhone,
    required this.currentAddress,
    this.profilePicUrl,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // هنا الخانات بتتملي بالبيانات الحالية تلقائياً
    nameController = TextEditingController(text: widget.currentName);
    emailController = TextEditingController(text: widget.currentEmail);
    phoneController = TextEditingController(text: widget.currentPhone);
    addressController = TextEditingController(text: widget.currentAddress);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? username = prefs.getString('username');

    try {
      var uri = Uri.parse('${ApiConstants.baseUrl}/update-profile/');
      var request = http.MultipartRequest('PUT', uri);
      request.headers.addAll({"Authorization": "Token $token"});

      request.fields['username'] = username ?? '';
      
      // نأخذ البيانات الموجودة حالياً داخل الخانات سواء عدلتها أو سبتها زي ما هي
      request.fields['full_name'] = nameController.text.trim();
      request.fields['email'] = emailController.text.trim();
      request.fields['phone'] = phoneController.text.trim();
      request.fields['address'] = addressController.text.trim();

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_picture',
          _selectedImage!.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var response = await request.send().timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        var data = jsonDecode(respStr);
        await prefs.setString('full_name', nameController.text.trim());
        await prefs.setString('phone', phoneController.text.trim());
        await prefs.setString('address', addressController.text.trim());
        
        if (data['profile_picture'] != null) {
          await prefs.setString('profile_picture', data['profile_picture']);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('changes_saved'.tr()), backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('update_failed'.tr()), backgroundColor: Colors.red));
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('network_error'.tr()), backgroundColor: Colors.orange));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = const Color(0xFF0D6B58);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                ],
              ),
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFE2F3E8),
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (widget.profilePicUrl != null ? NetworkImage('${ApiConstants.mediaUrl}${widget.profilePicUrl}') as ImageProvider : null),
                      child: _selectedImage == null && widget.profilePicUrl == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Color(0xFF0D6B58), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  children: [
                    _buildTextField(Icons.person_outline, 'full_name'.tr(), nameController),
                    const SizedBox(height: 16),
                    _buildTextField(Icons.mail_outline, 'email_address'.tr(), emailController),
                    const SizedBox(height: 16),
                    _buildTextField(Icons.phone_outlined, 'phone_number'.tr(), phoneController),
                    const SizedBox(height: 16),
                    _buildTextField(Icons.location_on_outlined, 'address'.tr(), addressController),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? CircularProgressIndicator(color: primaryColor)
                  : Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                            child: Text('save_changes'.tr(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade100, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                            child: Text('cancel'.tr(), style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 45,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D6B58))),
            ),
          ),
        ),
      ],
    );
  }
}