import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/organization_verification_provider.dart';
import '../../core/widgets/file_upload_widget.dart';

class OrganizationVerificationForm extends StatelessWidget {
  const OrganizationVerificationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrganizationVerificationProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Organization Verification')),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: _FormBody(),
        ),
      ),
    );
  }
}

class _FormBody extends StatefulWidget {
  const _FormBody({Key? key}) : super(key: key);

  @override
  State<_FormBody> createState() => _FormBodyState();
}

class _FormBodyState extends State<_FormBody> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrganizationVerificationProvider>(context);
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Owner Information
            const SizedBox(height: 8),
            const Text('Owner Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Owner ID'),
              onChanged: (v) => provider.setField('ownerId', v),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Owner Name'),
              onChanged: (v) => provider.setField('ownerName', v),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Owner NIK'),
              onChanged: (v) => provider.setField('ownerNik', v),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Owner Address'),
              minLines: 2,
              maxLines: 3,
              onChanged: (v) => provider.setField('ownerAddress', v),
            ),
            // Organization Information
            const SizedBox(height: 16),
            const Text('Organization Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Organization ID'),
              keyboardType: TextInputType.number,
              onChanged: (v) => provider.setField('organizationId', v),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Organization Legal Name'),
              onChanged: (v) => provider.setField('orgLegalName', v),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Organization NPWP'),
              onChanged: (v) => provider.setField('orgNpwp', v),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Organization Registration No'),
              onChanged: (v) => provider.setField('orgRegistrationNo', v),
            ),
            // Proof Files
            const SizedBox(height: 16),
            const Text('Supporting Documents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            FileUploadWidget(
              fileType: 'akta',
              label: 'Upload Akta (Legal Document)',
              onPicked: (path, bytes, name) => provider.setProofFile('akta', path, bytes),
            ),
            const SizedBox(height: 12),
            FileUploadWidget(
              fileType: 'npwp',
              label: 'Upload NPWP Proof',
              onPicked: (path, bytes, name) => provider.setProofFile('npwp', path, bytes),
            ),
            const SizedBox(height: 12),
            FileUploadWidget(
              fileType: 'other',
              label: 'Upload Other Proof (Optional)',
              onPicked: (path, bytes, name) => provider.setProofFile('other', path, bytes),
            ),
            const SizedBox(height: 24),
            provider.isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final ok = await provider.submitRequest();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.lastMessage ?? (ok ? 'Submitted' : 'Failed'))));
                          if (ok) Navigator.of(context).pop();
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('Submit Verification Request'),
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
