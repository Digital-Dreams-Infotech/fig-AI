import 'package:flutter/material.dart';

import '../Models/PromptCategory.dart';

class PromptSearchDialog extends StatefulWidget {
  final List<PromptCategory> categories;

  const PromptSearchDialog({super.key, required this.categories});

  @override
  State<PromptSearchDialog> createState() => _PromptSearchDialogState();
}

class _PromptSearchDialogState extends State<PromptSearchDialog> {
  late final TextEditingController _searchController;
  late List<PromptCategory> _filteredCategories;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCategories = widget.categories;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged(String query) {
    setState(() {
      _filteredCategories = widget.categories.where((category) {
        return category.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _onCategorySelected(PromptCategory category) {
    Navigator.of(context).pop(category);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 600,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search Prompts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _onSearchTextChanged,
              ),
              const SizedBox(height: 16),

              // Categories List
              Expanded(
                child: _filteredCategories.isEmpty
                    ? Center(
                  child: Text(
                    'No categories found',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                )
                    : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _filteredCategories.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: Colors.white12,
                  ),
                  itemBuilder: (context, index) {
                    final category = _filteredCategories[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      leading: const Icon(
                        Icons.category,
                        color: Colors.deepPurpleAccent,
                      ),
                      title: Text(
                        category.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () => _onCategorySelected(category),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
