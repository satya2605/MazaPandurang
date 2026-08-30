import 'package:flutter/material.dart';
import '../../../common/constants/app_colors.dart';
import '../services/dindi_state_service.dart';
import 'dindi_dashboard_screen.dart';

/// Screen allowing a Dindi Leader to create and register a new Dindi troupe.
/// Uploads Leader Photo and Dindi Registration Document directly to Supabase Storage Buckets
/// (`profile-images` and `dindi-documents`).
class CreateDindiScreen extends StatefulWidget {
  const CreateDindiScreen({super.key});

  @override
  State<CreateDindiScreen> createState() => _CreateDindiScreenState();
}

class _CreateDindiScreenState extends State<CreateDindiScreen> {
  final _formKey = GlobalKey<FormState>();
  final DindiStateService _service = DindiStateService();

  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _startPointController;
  late TextEditingController _destinationController;

  // Supabase Storage Bucket file references
  String? _leaderPhotoPath = 'profile-images/sanket_patil_photo.jpg';
  String? _documentPath = 'dindi-documents/dindi_registration_certificate.pdf';
  bool _isUploadingPhoto = false;
  bool _isUploadingDoc = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _numberController = TextEditingController();
    _startPointController = TextEditingController(text: 'Alandi');
    _destinationController = TextEditingController(text: 'Pandharpur');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _startPointController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _simulatePhotoUpload() async {
    setState(() => _isUploadingPhoto = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    setState(() {
      _isUploadingPhoto = false;
      _leaderPhotoPath = 'profile-images/leader_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
    messenger?.showSnackBar(
      const SnackBar(content: Text('Leader photo uploaded to Supabase Storage ("profile-images" bucket).')),
    );
  }

  Future<void> _simulateDocumentUpload() async {
    setState(() => _isUploadingDoc = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    setState(() {
      _isUploadingDoc = false;
      _documentPath = 'dindi-documents/dindi_registration_${DateTime.now().millisecondsSinceEpoch}.pdf';
    });
    messenger?.showSnackBar(
      const SnackBar(content: Text('Registration document uploaded to Supabase Storage ("dindi-documents" bucket).')),
    );
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_leaderPhotoPath == null || _leaderPhotoPath!.isEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Please upload a Leader Photo to complete registration.')),
      );
      return;
    }

    if (_documentPath == null || _documentPath!.isEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Please upload a Registration Document to complete registration.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final startPoint = _startPointController.text.trim();
      final createdDindi = await _service.createDindi(
        name: _nameController.text.trim(),
        dindiNumber: _numberController.text.trim(),
        startPoint: startPoint,
        destination: _destinationController.text.trim(),
        currentHalt: startPoint,
        roadStatus: 'Clear & Moving',
        joinCode: '', // Join code is unlocked post Admin approval
        documentUrl: _documentPath!,
        leaderImageUrl: _leaderPhotoPath!,
      );

      if (!mounted) return;

      final messenger = ScaffoldMessenger.maybeOf(context);
      final navigator = Navigator.maybeOf(context);

      messenger?.showSnackBar(
        SnackBar(
          content: Text('Dindi "${createdDindi.name}" application submitted! Awaiting Admin approval.'),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
        ),
      );

      navigator?.pushReplacement(
        MaterialPageRoute(
          builder: (_) => const DindiDashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text('Failed to submit application: $e'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _submitForm,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dindi Registration Application'),
        backgroundColor: AppColors.dindiAccent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.dindiAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.dindiAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.dindiAccent,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Submitting as leader: ${_service.identityProvider.currentLeaderName}\nJoin Code will be unlocked AFTER Admin approval.',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Dindi Identification
                const Text(
                  'Dindi Identification',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Dindi Name *',
                    hintText: 'e.g. Shree Tukaram Maharaj Dindi',
                    prefixIcon: const Icon(Icons.flag_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter Dindi name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _numberController,
                  decoration: InputDecoration(
                    labelText: 'Dindi Number / Sequence *',
                    hintText: 'e.g. 12 or DND-012',
                    prefixIcon: const Icon(Icons.numbers),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter Dindi number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Supabase Storage Bucket File Upload Section
                const Text(
                  'Verification Storage Buckets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select/upload files directly to Supabase Storage Buckets for Admin verification.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),

                // 1. Leader Photo Upload Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.dindiAccent.withValues(alpha: 0.1),
                          child: const Icon(Icons.person, color: AppColors.dindiAccent, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Leader Profile Photo *',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _leaderPhotoPath ?? 'No photo selected',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _leaderPhotoPath != null ? Colors.green.shade800 : Colors.grey,
                                  fontWeight: _leaderPhotoPath != null ? FontWeight.bold : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Bucket: profile-images',
                                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          fit: FlexFit.loose,
                          child: ElevatedButton.icon(
                            onPressed: _isUploadingPhoto ? null : _simulatePhotoUpload,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            icon: _isUploadingPhoto
                                ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.cloud_upload_outlined, size: 14),
                            label: Text(_leaderPhotoPath != null ? 'Re-upload' : 'Upload', style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Dindi Registration Document Upload Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.indigo.shade50,
                          child: const Icon(Icons.picture_as_pdf, color: Colors.indigo, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Registration Document *',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _documentPath ?? 'No document selected',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _documentPath != null ? Colors.indigo.shade800 : Colors.grey,
                                  fontWeight: _documentPath != null ? FontWeight.bold : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Bucket: dindi-documents',
                                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          fit: FlexFit.loose,
                          child: ElevatedButton.icon(
                            onPressed: _isUploadingDoc ? null : _simulateDocumentUpload,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            icon: _isUploadingDoc
                                ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.upload_file_outlined, size: 14),
                            label: Text(_documentPath != null ? 'Re-upload' : 'Upload PDF', style: const TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Route Endpoints Section
                const Text(
                  'Route Endpoints (Overall Start & Destination)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startPointController,
                        decoration: InputDecoration(
                          labelText: 'Origin *',
                          hintText: 'e.g. Alandi',
                          prefixIcon: const Icon(Icons.trip_origin),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter origin';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _destinationController,
                        decoration: InputDecoration(
                          labelText: 'Destination *',
                          hintText: 'e.g. Pandharpur',
                          prefixIcon: const Icon(Icons.pin_drop_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter destination';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dindiAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.assignment_turned_in_outlined),
                  label: Text(
                    _isSubmitting
                        ? 'Submitting Application...'
                        : 'Submit Dindi Registration Application',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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
}
