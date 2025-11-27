/// Panduan Implementasi Template untuk Berbagai Fitur
/// 
/// File ini berisi contoh implementasi template untuk berbagai tipe fitur
/// dalam aplikasi BersatuBantu. Gunakan sebagai referensi ketika membuat
/// screen atau fitur baru.

// ============================================================================
// CONTOH 1: FITUR FORM (Donor Profile, Setor Bantuan, dll)
// ============================================================================

/*
import 'package:flutter/material.dart';
import 'package:bersatubantu/core/theme/app_colors.dart';
import 'package:bersatubantu/core/theme/app_text_style.dart';
import 'package:bersatubantu/core/widgets/app_scaffold.dart';
import 'package:bersatubantu/core/widgets/form_layout.dart';
import 'package:bersatubantu/core/widgets/app-button.dart';
import 'package:bersatubantu/core/widgets/app-text-field.dart';
import 'package:bersatubantu/core/widgets/app_dialog.dart';

class DonorProfileFormScreen extends StatefulWidget {
  @override
  State<DonorProfileFormScreen> createState() => _DonorProfileFormScreenState();
}

class _DonorProfileFormScreenState extends State<DonorProfileFormScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  String? _errorName;
  String? _errorPhone;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profil Donor',
      bodyPadding: const EdgeInsets.all(16),
      body: FormLayout(
        title: 'Lengkapi Profil Anda',
        subtitle: 'Informasi ini membantu kami menghubungi Anda',
        fields: [
          AppTextField(
            label: 'Nama Lengkap',
            hint: 'Masukkan nama Anda',
            controller: _nameController,
            errorText: _errorName,
            prefixIcon: Icon(Icons.person_outline),
            isRequired: true,
            onChanged: (_) => setState(() => _errorName = null),
          ),
          AppTextField(
            label: 'Nomor Telepon',
            hint: '0812-3456-7890',
            controller: _phoneController,
            errorText: _errorPhone,
            keyboardType: TextInputType.phone,
            prefixIcon: Icon(Icons.phone_outlined),
            isRequired: true,
            onChanged: (_) => setState(() => _errorPhone = null),
          ),
          AppTextField(
            label: 'Alamat',
            hint: 'Masukkan alamat lengkap',
            controller: _addressController,
            maxLines: 3,
            minLines: 3,
          ),
        ],
        submitButton: SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'Simpan Profil',
            onPressed: _handleSubmit,
            isLoading: _isLoading,
            size: ButtonSize.large,
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    // Validasi
    setState(() {
      _errorName = _nameController.text.isEmpty ? 'Nama tidak boleh kosong' : null;
      _errorPhone = _phoneController.text.isEmpty ? 'Nomor tidak boleh kosong' : null;
    });

    if (_errorName != null || _errorPhone != null) return;

    setState(() => _isLoading = true);

    // Simulasi submit ke backend
    Future.delayed(Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Profil berhasil disimpan!',
          type: SnackBarType.success,
        );
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
*/

// ============================================================================
// CONTOH 2: FITUR LIST VIEW (Daftar Donasi, Aktivitas, dll)
// ============================================================================

/*
import 'package:flutter/material.dart';
import 'package:bersatubantu/core/theme/app_colors.dart';
import 'package:bersatubantu/core/theme/app_text_style.dart';
import 'package:bersatubantu/core/widgets/app_scaffold.dart';
import 'package:bersatubantu/core/widgets/feature_card.dart';
import 'package:bersatubantu/core/widgets/action_card.dart';
import 'package:bersatubantu/core/widgets/app-button.dart';

class DonationListScreen extends StatefulWidget {
  @override
  State<DonationListScreen> createState() => _DonationListScreenState();
}

class _DonationListScreenState extends State<DonationListScreen> {
  // Mock data - ganti dengan data dari API
  final List<Map<String, dynamic>> donations = [
    {
      'id': '1',
      'title': 'Bantuan Gempa Bumi',
      'description': 'Donasi untuk korban gempa bumi di Jawa Tengah',
      'target': 100000000,
      'collected': 75000000,
      'icon': '🏚️',
      'category': 'Disaster Relief',
    },
    // ... more donations
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Donasi Aktif',
      bodyPadding: const EdgeInsets.all(16),
      body: Column(
        children: [
          // Search dan filter
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari donasi...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // List donasi
          Expanded(
            child: ListView.builder(
              itemCount: donations.length,
              itemBuilder: (context, index) {
                final donation = donations[index];
                final progress = (donation['collected'] / donation['target'])
                    .clamp(0.0, 1.0);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FeatureCard(
                    title: donation['title'],
                    description: donation['description'],
                    image: Center(
                      child: Text(
                        donation['icon'],
                        style: TextStyle(fontSize: 48),
                      ),
                    ),
                    topRightBadge: AppBadge(
                      label: donation['category'],
                      backgroundColor: AppColors.primaryBlue,
                    ),
                    actionButtons: [
                      AppButton(
                        label: 'Lihat Detail',
                        onPressed: () {
                          // Navigate ke detail screen
                        },
                        size: ButtonSize.small,
                      ),
                    ],
                    onTap: () {
                      // Navigate ke detail screen
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
*/

// ============================================================================
// CONTOH 3: FITUR DETAIL VIEW (Detail Donasi, Detail Aktivitas, dll)
// ============================================================================

/*
import 'package:flutter/material.dart';
import 'package:bersatubantu/core/theme/app_colors.dart';
import 'package:bersatubantu/core/theme/app_text_style.dart';
import 'package:bersatubantu/core/widgets/app_scaffold.dart';
import 'package:bersatubantu/core/widgets/feature_card.dart';
import 'package:bersatubantu/core/widgets/app-button.dart';
import 'package:bersatubantu/core/widgets/action_card.dart';
import 'package:bersatubantu/core/widgets/app_dialog.dart';

class DonationDetailScreen extends StatefulWidget {
  final String donationId;

  const DonationDetailScreen({required this.donationId});

  @override
  State<DonationDetailScreen> createState() => _DonationDetailScreenState();
}

class _DonationDetailScreenState extends State<DonationDetailScreen> {
  // Mock data - ganti dengan data dari API
  late Map<String, dynamic> donation = {
    'title': 'Bantuan Gempa Bumi',
    'description': 'Gempa bumi yang mengguncang Jawa Tengah mengakibatkan kerusakan parah. Mari bersama membantu para korban.',
    'target': 100000000,
    'collected': 75000000,
    'donors': 234,
    'location': 'Jawa Tengah',
    'date': '27 November 2024',
    'status': 'Aktif',
  };

  @override
  Widget build(BuildContext context) {
    final progress = (donation['collected'] / donation['target'])
        .clamp(0.0, 1.0);
    
    return AppScaffold(
      title: 'Detail Donasi',
      bodyPadding: const EdgeInsets.all(16),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 240,
                color: AppColors.bgSecondary,
                child: Center(
                  child: Text('🏚️', style: TextStyle(fontSize: 80)),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Status badge
            AppBadge(
              label: donation['status'],
              backgroundColor: AppColors.accentGreen,
            ),
            SizedBox(height: 12),

            // Title
            Text(
              donation['title'],
              style: AppTextStyle.displaySmall,
            ),
            SizedBox(height: 16),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Terkumpul',
                      style: AppTextStyle.labelMedium,
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: AppTextStyle.labelMedium.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.bgSecondary,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryBlue,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${donation['collected']}',
                      style: AppTextStyle.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'dari Rp ${donation['target']}',
                      style: AppTextStyle.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),

            // Donor count
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.people_outline, color: AppColors.primaryBlue),
                  SizedBox(width: 8),
                  Text(
                    '${donation['donors']} orang telah berkontribusi',
                    style: AppTextStyle.bodyMedium,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Description
            Text(
              'Tentang Donasi Ini',
              style: AppTextStyle.headingMedium,
            ),
            SizedBox(height: 8),
            Text(
              donation['description'],
              style: AppTextStyle.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24),

            // Details
            _DetailRow(label: 'Lokasi', value: donation['location']),
            _DetailRow(label: 'Tanggal Buat', value: donation['date']),
            SizedBox(height: 32),

            // Action buttons
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  AppButton(
                    label: 'Donasi Sekarang',
                    onPressed: () => _handleDonate(),
                    size: ButtonSize.large,
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: 'Bagikan',
                      onPressed: () {},
                      variant: ButtonVariant.outline,
                      size: ButtonSize.large,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDonate() {
    // Implement donation flow
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyle.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyle.bodyMedium,
          ),
        ],
      ),
    );
  }
}
*/

// ============================================================================
// CONTOH 4: FITUR DENGAN GRID VIEW (Dashboard, Gallery, dll)
// ============================================================================

/*
import 'package:flutter/material.dart';
import 'package:bersatubantu/core/theme/app_colors.dart';
import 'package:bersatubantu/core/theme/app_text_style.dart';
import 'package:bersatubantu/core/widgets/app_scaffold.dart';
import 'package:bersatubantu/core/widgets/feature_card.dart';

class FeatureGridScreen extends StatelessWidget {
  final features = [
    {
      'title': 'Donasi',
      'icon': '💝',
      'description': 'Berikan bantuan',
    },
    {
      'title': 'Aktivitas',
      'icon': '📋',
      'description': 'Kegiatan sosial',
    },
    {
      'title': 'Testimoni',
      'icon': '⭐',
      'description': 'Kisah sukses',
    },
    {
      'title': 'Bantuan',
      'icon': '🆘',
      'description': 'Dapatkan bantuan',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Fitur Utama',
      bodyPadding: const EdgeInsets.all(16),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return FeatureCard(
            title: feature['title'] as String,
            description: feature['description'] as String,
            image: Center(
              child: Text(
                feature['icon'] as String,
                style: TextStyle(fontSize: 48),
              ),
            ),
            onTap: () {
              // Navigate ke fitur
            },
          );
        },
      ),
    );
  }
}
*/

// ============================================================================
// CONTOH 5: FITUR DENGAN TABBED INTERFACE
// ============================================================================

/*
import 'package:flutter/material.dart';
import 'package:bersatubantu/core/theme/app_colors.dart';
import 'package:bersatubantu/core/widgets/app_scaffold.dart';

class TabbedFeatureScreen extends StatefulWidget {
  @override
  State<TabbedFeatureScreen> createState() => _TabbedFeatureScreenState();
}

class _TabbedFeatureScreenState extends State<TabbedFeatureScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Donasi',
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryBlue,
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Aktif'),
              Tab(text: 'Selesai'),
              Tab(text: 'Draft'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Aktif
                _buildTabContent('Donasi Aktif'),
                
                // Tab 2: Selesai
                _buildTabContent('Donasi Selesai'),
                
                // Tab 3: Draft
                _buildTabContent('Draft Donasi'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String title) {
    return Center(
      child: Text(title),
    );
  }
}
*/

// ============================================================================
// TIPS & TRICKS
// ============================================================================

/**
 * TIPS IMPLEMENTASI:
 * 
 * 1. LOADING STATE:
 *    - Gunakan `isLoading` property di AppButton
 *    - Disable input fields saat loading
 *    - Tampilkan loading indicator jika operasi lama
 * 
 * 2. ERROR HANDLING:
 *    - Validasi input sebelum submit
 *    - Tampilkan error message di AppTextField.errorText
 *    - Gunakan AppSnackBar untuk error yang tidak terkait input
 * 
 * 3. NAVIGATION:
 *    - Gunakan named routes untuk navigate
 *    - Pass data melalui constructor parameter
 *    - Pop dengan hasil jika perlu return value
 * 
 * 4. ASYNC OPERATIONS:
 *    - Gunakan Future.delayed untuk simulasi
 *    - Gunakan try-catch untuk error handling
 *    - Check mounted sebelum setState
 * 
 * 5. RESPONSIVE DESIGN:
 *    - Gunakan MediaQuery untuk responsive layout
 *    - Gunakan maxWidth constraints untuk card/container
 *    - Test di berbagai ukuran screen
 * 
 * 6. PERFORMANCE:
 *    - Dispose controller di onDispose
 *    - Gunakan const constructor
 *    - Lazy load data dengan pagination
 * 
 * 7. ACCESSIBILITY:
 *    - Gunakan meaningful label untuk input
 *    - Pastikan contrast ratio terpenuhi
 *    - Gunakan semanticLabel untuk icon
 */
