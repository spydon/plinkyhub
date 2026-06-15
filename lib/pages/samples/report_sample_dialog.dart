import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plinkyhub/providers/authentication_notifier.dart';
import 'package:plinkyhub/widgets/copyable_error_message.dart';
import 'package:plinkyhub/widgets/plinky_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ReportReason {
  copyrightInfringement('copyright_infringement', 'Copyright infringement'),
  other('other', 'Other');

  const ReportReason(this.value, this.label);

  final String value;
  final String label;
}

class ReportSampleDialog extends ConsumerStatefulWidget {
  const ReportSampleDialog({required this.sampleId, super.key});

  final String sampleId;

  @override
  ConsumerState<ReportSampleDialog> createState() => _ReportSampleDialogState();
}

class _ReportSampleDialogState extends ConsumerState<ReportSampleDialog> {
  ReportReason _reason = ReportReason.copyrightInfringement;
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final userId = ref.read(authenticationProvider).user?.id;
    if (userId == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.from('reports').insert({
        'reporter_id': userId,
        'sample_id': widget.sampleId,
        'reason': _reason.value,
        'description': _descriptionController.text.trim(),
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted. Thank you.'),
          ),
        );
      }
    } on Exception catch (error) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report sample'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<ReportReason>(
              initialValue: _reason,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              items: ReportReason.values
                  .map(
                    (reason) => DropdownMenuItem(
                      value: reason,
                      child: Text(reason.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _reason = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Please describe the issue...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              CopyableErrorMessage(
                message: _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        PlinkyButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          icon: Icons.close,
          label: 'Cancel',
        ),
        PlinkyButton(
          onPressed: _isSubmitting ? null : _submit,
          icon: _isSubmitting ? Icons.hourglass_empty : Icons.flag,
          label: _isSubmitting ? 'Submitting...' : 'Submit',
        ),
      ],
    );
  }
}
