import 'package:flutter/material.dart';
import '../models/ngo_organization.dart';
import '../services/ngo_repository.dart';
import '../widgets/approval_status_banner.dart';

/// Screen displaying NGO organization profile, credentials, and verification status.
class NgoProfileScreen extends StatefulWidget {
  const NgoProfileScreen({super.key});

  @override
  State<NgoProfileScreen> createState() => _NgoProfileScreenState();
}

class _NgoProfileScreenState extends State<NgoProfileScreen> {
  final NgoRepository _repo = NgoRepository();
  List<Map<String, dynamic>> _ngoImages = [];
  bool _isLoadingImages = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => _isLoadingImages = true);
    final imgs = await _repo.fetchNgoImages();
    if (mounted) {
      setState(() {
        _ngoImages = imgs;
        _isLoadingImages = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final org = _repo.organization;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Profile & Verification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              ApprovalStatusBanner(status: org.approvalStatus),
              const SizedBox(height: 20),

              // Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0xFF2E7D32),
                            child: Icon(Icons.church,
                                color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  org.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: org.approvalStatus ==
                                            NgoApprovalStatus.approved
                                        ? Colors.green.shade100
                                        : (org.approvalStatus ==
                                                NgoApprovalStatus.pending
                                            ? Colors.amber.shade100
                                            : Colors.red.shade100),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    org.approvalStatus.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: org.approvalStatus ==
                                              NgoApprovalStatus.approved
                                          ? Colors.green.shade900
                                          : (org.approvalStatus ==
                                                  NgoApprovalStatus.pending
                                              ? Colors.amber.shade900
                                              : Colors.red.shade900),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _buildDetailRow(Icons.verified, 'Registration No.',
                          org.registrationNo),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                          Icons.person, 'Contact Person', org.contactPerson),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.phone, 'Phone Number', org.phone),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.email, 'Email Address', org.email),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                          Icons.category, 'Primary Seva', org.primaryCategory),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // NGO Gallery Section
              const Text(
                'NGO Gallery & Verification Photos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (_isLoadingImages)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  ),
                )
              else if (_ngoImages.isNotEmpty)
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _ngoImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = _ngoImages[index];
                      final url = item['image_url']?.toString() ?? '';
                      final fullUrl = url.startsWith('http')
                          ? url
                          : 'https://fjnhsaxuwyairfgrciyf.supabase.co/storage/v1/object/public/$url';
                      final caption = item['caption']?.toString() ?? 'Gallery';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 160,
                              height: 100,
                              child: Image.network(
                                fullUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 160,
                            child: Text(
                              caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.black87),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.photo_library_outlined,
                          color: Colors.grey, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No public gallery photos uploaded yet.',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              const Text(
                'Submitted User Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (_repo.reports.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    'No user reports submitted for your services yet.',
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _repo.reports.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final rep = _repo.reports[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                rep.reasonLabel,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                              Text(
                                '${rep.timestamp.hour}:${rep.timestamp.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Service: ${rep.serviceName}',
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('Comments: "${rep.comments}"',
                              style: const TextStyle(
                                  fontSize: 13, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
          ],
        ),
      ],
    );
  }
}
