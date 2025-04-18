import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../API/API.dart';

class PromptDetailsDialog extends StatefulWidget {
  final String id;
  final String token;
  final int categoryId;
  final Function(String) onPromptSelected;

  const PromptDetailsDialog({
    Key? key,
    required this.id,
    required this.token,
    required this.categoryId,
    required this.onPromptSelected,
  }) : super(key: key);

  @override
  State<PromptDetailsDialog> createState() => _PromptDetailsDialogState();
}

class _PromptDetailsDialogState extends State<PromptDetailsDialog> {
  final TextEditingController searchController = TextEditingController();
  final AuthService authService = AuthService();

  List<String> filteredItems = [];
  Timer? debounce;
  bool isLoading = true;

  int currentPage = 1;
  final int itemsPerPage = 10;
  bool hasMoreItems = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData({bool isNextPage = false}) async {
    if (!isNextPage) setState(() => isLoading = true);
    try {
      final response = await authService.getPromptSubCategories(
        token: widget.token,
        categoryId: widget.categoryId,
        searchQuery: searchController.text,
        start: (currentPage - 1) * itemsPerPage,
        limit: itemsPerPage,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<String> fetchedItems = (responseBody['data'] as List)
            .map((item) => item['name'] as String)
            .toList();

        setState(() {
          filteredItems = fetchedItems;
          hasMoreItems = fetchedItems.length == itemsPerPage;
        });
      }
    } catch (e) {
      debugPrint('Error fetching prompt details: $e');
    } finally {
      if (!isNextPage) setState(() => isLoading = false);
    }
  }

  void onSearchChanged(String query) {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => currentPage = 1);
      fetchData();
    });
  }

  void nextPage() {
    if (hasMoreItems) {
      setState(() => currentPage++);
      fetchData();
    }
  }

  void previousPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
      fetchData();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2A2A40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "📄 ${widget.id}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Prompt",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.purple[300],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search inside prompt...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF2A2A40),
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
                          : filteredItems.isEmpty
                          ? const Center(
                        child: Text('No results found.', style: TextStyle(color: Colors.white54)),
                      )
                          : Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: filteredItems.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return InkWell(
                                  onTap: () {
                                    widget.onPromptSelected(item);
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3A3A52),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(item, style: const TextStyle(color: Colors.white)),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3A3A52),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.deepPurpleAccent, width: 1.5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Previous Button
                                  ElevatedButton.icon(
                                    onPressed: currentPage > 1 && !isLoading ? previousPage : null, // Disable if loading
                                    icon: isLoading
                                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                        : const Icon(Icons.arrow_back),
                                    label: const Text("Previous"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple[300],
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.grey[700],
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Page $currentPage',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  // Next Button
                                  ElevatedButton.icon(
                                    onPressed: hasMoreItems && !isLoading ? nextPage : null,
                                    icon: isLoading
                                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                        : const Icon(Icons.arrow_forward),
                                    label: const Text("Next"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple[300],
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.grey[700],
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                        child: const Text("Close"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
