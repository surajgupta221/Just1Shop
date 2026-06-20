import 'package:flutter/material.dart';
import '../../../core/constants/ui_constants.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({Key? key}) : super(key: key);

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _pincodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        title: Text('Add Address', style: UITextStyles.headlineLarge),
        backgroundColor: UIConstants.surfaceColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.paddingM),
        child: Container(
          padding: const EdgeInsets.all(UIConstants.paddingL),
          decoration: BoxDecoration(
            color: UIConstants.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: UIConstants.dividerColor),
            boxShadow: UIConstants.shadowsM,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _field(_nameController, 'Name'),
                const SizedBox(height: UIConstants.paddingM),
                _field(
                  _phoneController,
                  'Phone Number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: UIConstants.paddingM),
                _field(
                  _addressController,
                  'Full Address',
                  maxLines: 3,
                ),
                const SizedBox(height: UIConstants.paddingM),
                _field(_landmarkController, 'Landmark'),
                const SizedBox(height: UIConstants.paddingM),
                _field(
                  _pincodeController,
                  'Pincode',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: UIConstants.paddingL),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: UIConstants.actionGradient,
                      borderRadius: BorderRadius.circular(UIConstants.radiusL),
                    ),
                    child: ElevatedButton(
                      onPressed: _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        'Save Address',
                        style: UITextStyles.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }

  void _saveAddress() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Address form saved locally. Backend sync next.'),
      ),
    );
    Navigator.of(context).pop();
  }
}
