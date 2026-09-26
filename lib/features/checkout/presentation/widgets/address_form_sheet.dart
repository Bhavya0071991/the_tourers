import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../../../core/widgets/app_field_labeled.dart';
import '../../../../core/widgets/app_text.dart';
import '../../models/address_model.dart';

class AddressFormSheet extends StatefulWidget {
  final Address? existingAddress;
  final ValueChanged<Address> onSave;

  const AddressFormSheet({
    super.key,
    this.existingAddress,
    required this.onSave,
  });

  @override
  State<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _landmarkController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _pincodeController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final a = widget.existingAddress;
    _nameController = TextEditingController(text: a?.fullName ?? '');
    _phoneController = TextEditingController(text: a?.phone ?? '');
    _addressController = TextEditingController(text: a?.addressLine ?? '');
    _landmarkController = TextEditingController(text: a?.landmark ?? '');
    _cityController = TextEditingController(text: a?.city ?? '');
    _stateController = TextEditingController(text: a?.state ?? '');
    _pincodeController = TextEditingController(text: a?.pincode ?? '');
    _isDefault = a?.isDefault ?? false;

    _pincodeController.addListener(_onPincodeChanged);
  }

  bool _isFetchingLocation = false;
  String? _inlineMessage;
  bool _isInlineError = false;

  void _showInlineMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _inlineMessage = message;
      _isInlineError = isError;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _inlineMessage == message) {
        setState(() => _inlineMessage = null);
      }
    });
  }

  Future<void> _onPincodeChanged() async {
    final text = _pincodeController.text;
    // Only fetch if it's exactly 6 digits and we aren't already fetching
    if (text.length == 6 && !_isFetchingLocation) {
      setState(() => _isFetchingLocation = true);

      try {
        final response = await http.get(
          Uri.parse('https://api.postalpincode.in/pincode/$text'),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data.isNotEmpty && data[0]['Status'] == 'Success') {
            final postOffice = data[0]['PostOffice'][0];

            // The API returns District/Block and State
            final district =
                postOffice['District'] ?? postOffice['Block'] ?? '';
            final state = postOffice['State'] ?? '';

            if (mounted) {
              setState(() {
                _cityController.text = district;
                _stateController.text = state;
              });
              _showInlineMessage('LOCATION AUTO-FILLED SUCESSFULLY');
            }
          }
        }
      } catch (e) {
        // If it fails, fail silently and let user type manually
      } finally {
        if (mounted) setState(() => _isFetchingLocation = false);
      }
    }
  }

  @override
  void dispose() {
    _pincodeController.removeListener(_onPincodeChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _stateController.text.trim().isEmpty ||
        _pincodeController.text.trim().isEmpty) {
      _showInlineMessage('ALL REQUIRED FIELDS MUST BE FILLED', isError: true);
      return;
    }

    final address = Address(
      id:
          widget.existingAddress?.id ??
          'addr_${const Uuid().v4().substring(0, 8)}',
      fullName: _nameController.text.trim().toUpperCase(),
      phone: _phoneController.text.trim(),
      addressLine: _addressController.text.trim(),
      landmark: _landmarkController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      isDefault: _isDefault,
    );

    widget.onSave(address);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final isEditing = widget.existingAddress != null;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: textColor, width: 3)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              AppText.bebas(
                isEditing ? 'EDIT ADDRESS' : 'ADD NEW ADDRESS',
                fontSize: 28,
                letterSpacing: 1.5,
              ),
              const SizedBox(height: 4),
              AppText.spaceMono(
                '/// ${isEditing ? "MODIFY" : "REGISTER"} DELIVERY COORDINATES',
                fontSize: 10,
                color: textColor.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 24),

              AppFieldLabeled(
                label: 'Full Name *',
                hintText: 'JOHN DOE',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: 16),

              AppFieldLabeled(
                label: 'Phone Number *',
                hintText: '+91 98765 43210',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                ],
              ),
              const SizedBox(height: 16),

              AppFieldLabeled(
                label: 'Address Line *',
                hintText: 'Street, Building, Floor',
                controller: _addressController,
                maxLines: 2,
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              const SizedBox(height: 16),

              AppFieldLabeled(
                label: 'Landmark',
                hintText: 'Near Metro Station, etc.',
                controller: _landmarkController,
                prefixIcon: const Icon(Icons.near_me_outlined),
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: AppFieldLabeled(
                      label: 'Pincode *',
                      hintText: '560034',
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      prefixIcon: const Icon(Icons.pin_outlined),
                    ),
                  ),
                  if (_isFetchingLocation)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        bottom: 24,
                      ), // Align with input
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: textColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppFieldLabeled(
                      label: 'City *',
                      hintText: 'Bengaluru',
                      controller: _cityController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppFieldLabeled(
                      label: 'State *',
                      hintText: 'Karnataka',
                      controller: _stateController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Inline Message Display
              if (_inlineMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _isInlineError
                        ? Colors.redAccent
                        : Colors.greenAccent,
                    border: Border.all(color: textColor, width: 2),
                  ),
                  child: AppText.spaceMono(
                    _inlineMessage!,
                    color: _isInlineError ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    textAlign: TextAlign.center,
                  ),
                ),

              // Default toggle
              GestureDetector(
                onTap: () => setState(() => _isDefault = !_isDefault),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _isDefault ? textColor : Colors.transparent,
                        border: Border.all(color: textColor, width: 2),
                      ),
                      child: _isDefault
                          ? Icon(Icons.check, size: 14, color: surfaceColor)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    AppText.spaceMono(
                      'SET AS DEFAULT ADDRESS',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: textColor,
                    foregroundColor: surfaceColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: AppText.bebas(
                    isEditing ? 'UPDATE ADDRESS ↗' : 'SAVE ADDRESS ↗',
                    fontSize: 18,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
