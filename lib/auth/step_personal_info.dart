import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'registration_data.dart';

class StepPersonalInfo extends StatefulWidget {
  final RegistrationData data;
  final VoidCallback onNext;

  const StepPersonalInfo({
    super.key,
    required this.data,
    required this.onNext,
  });

  @override
  State<StepPersonalInfo> createState() => _StepPersonalInfoState();
}

class _StepPersonalInfoState extends State<StepPersonalInfo> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _incomeController;
  late TextEditingController _salaryDateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data.fullName);
    _incomeController = TextEditingController(
      text: widget.data.monthlyIncome > 0
          ? widget.data.monthlyIncome.toString()
          : '',
    );
    _salaryDateController = TextEditingController(text: widget.data.salaryDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _incomeController.dispose();
    _salaryDateController.dispose();
    super.dispose();
  }

  void _pickSalaryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      final formatted = '${picked.day} ${months[picked.month - 1]}';
      setState(() => _salaryDateController.text = formatted);
    }
  }

  void _pickBankStatement() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          widget.data.bankStatement = File(result.files.single.path!);
        });
      }
    } catch (e) {
      debugPrint('File picker error: $e');
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.data.fullName = _nameController.text.trim();
    widget.data.monthlyIncome = double.parse(_incomeController.text.trim());
    widget.data.salaryDate = _salaryDateController.text.trim();

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padH = MediaQuery.of(context).size.width * 0.062;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padH),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              'المعلومات الشخصية',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أخبرنا عن نفسك لنخصص تجربتك.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'الاسم الكامل',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال اسمك الكامل.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: r'الدخل الشهري (SAR)',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال دخلك الشهري.';
                }
                final v = double.tryParse(value.trim());
                if (v == null || v <= 0) {
                  return 'يرجى إدخال مبلغ صحيح أكبر من 0.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickSalaryDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'تاريخ الراتب',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  _salaryDateController.text.isEmpty
                      ? 'اختر تاريخ راتبك'
                      : _salaryDateController.text,
                  style: TextStyle(
                    color: _salaryDateController.text.isEmpty
                        ? theme.colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _pickBankStatement,
              icon: const Icon(Icons.upload_file),
              label: const Text('تحميل كشف الحساب البنكي (اختياري)'),
            ),
            if (widget.data.bankStatement != null) ...[
              const SizedBox(height: 8),
              Text(
                'البيان المحدد',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  disabledBackgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'التالي',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
