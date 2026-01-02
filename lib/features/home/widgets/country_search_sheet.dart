/// Country Search Sheet
/// Modal bottom sheet for searching and selecting a country
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/design_tokens.dart';

import '../../../../data/repositories/channel_repository.dart';
import '../providers/selected_country_provider.dart';

class CountrySearchSheet extends ConsumerStatefulWidget {
  const CountrySearchSheet({super.key});

  @override
  ConsumerState<CountrySearchSheet> createState() => _CountrySearchSheetState();
}

class _CountrySearchSheetState extends ConsumerState<CountrySearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableCountriesAsync = ref.watch(availableCountriesProvider);
    final selectedCountryCode = ref.read(selectedCountryProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Text(
                  'Select Country',
                  style: AppTypography.titleLarge,
                ),
                const Spacer(),
                if (selectedCountryCode != null)
                  TextButton(
                    onPressed: () {
                      ref.read(selectedCountryProvider.notifier).setCountry(null);
                      Navigator.pop(context);
                    },
                    child: const Text('Clear Filter'),
                  ),
              ],
            ),
          ),

          // Search configuration
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search country...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),

          // List
          Expanded(
            child: availableCountriesAsync.when(
              data: (countries) {
                // Filter countries based on search
                final filteredCountries = countries.where((c) {
                  if (_searchQuery.isEmpty) return true;
                  return c.name.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                if (filteredCountries.isEmpty) {
                  return const Center(
                    child: Text('No countries found', style: AppTypography.bodyMedium),
                  );
                }

                return ListView.builder(
                  itemCount: filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = filteredCountries[index];
                    final isSelected = country.code.toUpperCase() == selectedCountryCode;

                    return ListTile(
                      leading: Text(
                        country.flag ?? '🌍',
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        country.name,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : Colors.white,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected 
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                          : null,
                      onTap: () {
                        ref.read(selectedCountryProvider.notifier).setCountry(country.code.toUpperCase());
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
