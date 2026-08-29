import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
  }

  @override
  void dispose() {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ALL REQUIRED FIELDS MUST BE FILLED',
            style: GoogleFonts.spaceMono(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final address = Address(
      id: widget.existingAddress?.id ??
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
              const SizedBox(height: 16),

              AppFieldLabeled(
                label: 'Pincode *',
                hintText: '560034',
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefixIcon: const Icon(Icons.pin_outlined),
              ),
              const SizedBox(height: 20),

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
