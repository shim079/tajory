import 'package:flutter/material.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = Expense.standardCategories[0];
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _save() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount.')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }

    Navigator.of(context).pop({
      'amount': amount,
      'category': _selectedCategory,
      'description': _notesController.text.trim(),
      'source': 'manual',
      'date': _selectedDate.toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Add Expense',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              prefixIcon: const Icon(Icons.category_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: Expense.standardCategories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedCategory = v);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              hintText: 'e.g. 50',
              prefixIcon: const Icon(Icons.attach_money),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'e.g. Lunch with friends',
              prefixIcon: const Icon(Icons.notes),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save Expense',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
