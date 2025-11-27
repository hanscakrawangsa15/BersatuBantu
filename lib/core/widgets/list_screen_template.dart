import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import 'app_scaffold.dart';
import 'app-button.dart';
import 'feature_card.dart';
import 'action_card.dart';

/// Template Screen untuk List/Grid Fitur
/// Gunakan untuk halaman utama yang menampilkan berbagai fitur
class ListScreenTemplate extends StatelessWidget {
  const ListScreenTemplate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mockData = [
      {
        'title': 'Donasi Kami',
        'description': 'Kirimkan bantuan untuk yang membutuhkan',
        'icon': '🎁',
      },
      {
        'title': 'Aktivitas Sosial',
        'description': 'Ikuti kegiatan sosial di komunitas Anda',
        'icon': '👥',
      },
      {
        'title': 'Testimoni',
        'description': 'Baca kisah sukses dari pengguna lain',
        'icon': '⭐',
      },
      {
        'title': 'Bantuan',
        'description': 'Dapatkan bantuan dari komunitas',
        'icon': '🆘',
      },
    ];

    return AppScaffold(
      title: 'Fitur Utama',
      bodyPadding: const EdgeInsets.all(16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari fitur...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.borderLight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Grid/List of Features
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: mockData.length,
              itemBuilder: (context, index) {
                final item = mockData[index];
                return FeatureCard(
                  title: item['title'] as String,
                  description: item['description'] as String,
                  image: Center(
                    child: Text(
                      item['icon'] as String,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tapped: ${item['title']}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Template Screen untuk Detail View
/// Gunakan untuk menampilkan detail fitur/item tertentu
class DetailScreenTemplate extends StatelessWidget {
  const DetailScreenTemplate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Detail Item',
      bodyPadding: const EdgeInsets.all(16),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 240,
                color: AppColors.bgSecondary,
                child: const Center(
                  child: Text(
                    '🎁',
                    style: TextStyle(fontSize: 80),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header Info
            Text(
              'Judul Item',
              style: AppTextStyle.displaySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                AppBadge(
                  label: 'Status',
                  backgroundColor: AppColors.accentGreen,
                ),
                const SizedBox(width: 8),
                AppBadge(
                  label: 'Kategori',
                  backgroundColor: AppColors.primaryBlue,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              'Deskripsi Lengkap',
              style: AppTextStyle.headingMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Ini adalah deskripsi lengkap tentang item yang sedang ditampilkan. '
              'Anda dapat menambahkan informasi detail di sini untuk memberikan '
              'konteks yang lebih jelas kepada pengguna.',
              style: AppTextStyle.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Details List
            _DetailRow(
              label: 'Tanggal',
              value: '27 November 2024',
            ),
            _DetailRow(
              label: 'Lokasi',
              value: 'Jakarta, Indonesia',
            ),
            _DetailRow(
              label: 'Kontak',
              value: '0812-3456-7890',
            ),
            const SizedBox(height: 32),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  AppButton(
                    label: 'Ambil Aksi',
                    onPressed: () {},
                    size: ButtonSize.large,
                  ),
                  const SizedBox(height: 12),
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
      padding: const EdgeInsets.only(bottom: 16),
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
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}
