import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KitchenSopsScreen extends StatefulWidget {
  const KitchenSopsScreen({super.key});

  @override
  State<KitchenSopsScreen> createState() => _KitchenSopsScreenState();
}

class _KitchenSopsScreenState extends State<KitchenSopsScreen> {
  static const String _storageKey = 'kitchenops_sops';

  List<Map<String, dynamic>> _sops = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Food Safety',
    'Kitchen Hygiene',
    'Food Preparation',
    'Cleaning',
    'Opening',
    'Closing',
    'Equipment',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadSops();
  }

  Future<void> _loadSops() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(_storageKey);

    if (data != null && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);

        if (decoded is List) {
          _sops = decoded
              .map(
                (item) => Map<String, dynamic>.from(item),
              )
              .toList();
        }
      } catch (_) {}
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveSops() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _storageKey,
      jsonEncode(_sops),
    );
  }

  List<Map<String, dynamic>> get _filteredSops {
    return _sops.where((sop) {
      final title =
          (sop['title'] ?? '').toString().toLowerCase();

      final description =
          (sop['description'] ?? '').toString().toLowerCase();

      final category =
          (sop['category'] ?? '').toString();

      final matchesSearch =
          title.contains(_searchQuery.toLowerCase()) ||
          description.contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'All' ||
          category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> _showSopForm({
    Map<String, dynamic>? existing,
  }) async {
    final titleController = TextEditingController(
      text: existing?['title'] ?? '',
    );

    final descriptionController = TextEditingController(
      text: existing?['description'] ?? '',
    );

    final stepsController = TextEditingController(
      text: existing?['steps'] ?? '',
    );

    final responsibleController = TextEditingController(
      text: existing?['responsible'] ?? '',
    );

    String selectedCategory =
        existing?['category'] ?? 'Food Safety';

    final formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1D5DB),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                existing == null
                                    ? 'Create SOP'
                                    : 'Edit SOP',
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            10,
                            20,
                            30,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _sectionLabel('SOP Information'),

                              const SizedBox(height: 12),

                              _inputField(
                                controller: titleController,
                                label: 'SOP Title',
                                hint:
                                    'e.g. Daily Kitchen Cleaning',
                                icon: Icons.menu_book_rounded,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Enter SOP title';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              DropdownButtonFormField<String>(
                                value: selectedCategory,
                                decoration:
                                    _inputDecoration(
                                  'Category',
                                  Icons.category_outlined,
                                ),
                                items: _categories
                                    .where(
                                      (category) =>
                                          category != 'All',
                                    )
                                    .map(
                                      (category) =>
                                          DropdownMenuItem(
                                        value: category,
                                        child: Text(category),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;

                                  setModalState(() {
                                    selectedCategory = value;
                                  });
                                },
                              ),

                              const SizedBox(height: 14),

                              _inputField(
                                controller:
                                    descriptionController,
                                label: 'Description',
                                hint:
                                    'Briefly describe this SOP',
                                icon:
                                    Icons.description_outlined,
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Enter a description';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              _inputField(
                                controller: stepsController,
                                label: 'Procedure / Steps',
                                hint:
                                    'Write each step clearly...\n\n1. ...\n2. ...\n3. ...',
                                icon:
                                    Icons.format_list_numbered_rounded,
                                maxLines: 8,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Enter procedure steps';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 14),

                              _inputField(
                                controller:
                                    responsibleController,
                                label: 'Responsible Role',
                                hint:
                                    'e.g. Kitchen Staff / Chef Master',
                                icon:
                                    Icons.person_outline_rounded,
                              ),

                              const SizedBox(height: 25),

                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (!formKey.currentState!
                                        .validate()) {
                                      return;
                                    }

                                    final now =
                                        DateTime.now()
                                            .toIso8601String();

                                    final sop = {
                                      'id': existing?['id'] ??
                                          DateTime.now()
                                              .millisecondsSinceEpoch,
                                      'title':
                                          titleController.text.trim(),
                                      'category':
                                          selectedCategory,
                                      'description':
                                          descriptionController
                                              .text
                                              .trim(),
                                      'steps':
                                          stepsController.text.trim(),
                                      'responsible':
                                          responsibleController
                                              .text
                                              .trim(),
                                      'createdAt':
                                          existing?['createdAt'] ??
                                              now,
                                      'updatedAt': now,
                                    };

                                    if (existing == null) {
                                      _sops.insert(0, sop);
                                    } else {
                                      final index =
                                          _sops.indexWhere(
                                        (item) =>
                                            item['id'] ==
                                            existing['id'],
                                      );

                                      if (index != -1) {
                                        _sops[index] = sop;
                                      }
                                    }

                                    Navigator.pop(
                                      context,
                                      true,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.save_rounded,
                                  ),
                                  label: Text(
                                    existing == null
                                        ? 'Save SOP'
                                        : 'Update SOP',
                                  ),
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFF59E0B),
                                    foregroundColor:
                                        Colors.white,
                                    elevation: 0,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        14,
                                      ),
                                    ),
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
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    stepsController.dispose();
    responsibleController.dispose();

    if (result == true) {
      await _saveSops();

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? 'SOP created successfully'
                : 'SOP updated successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteSop(Map<String, dynamic> sop) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete SOP?'),
          content: Text(
            'Are you sure you want to delete "${sop['title']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    _sops.removeWhere(
      (item) => item['id'] == sop['id'],
    );

    await _saveSops();

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOP deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openSopDetails(Map<String, dynamic> sop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.78,
          decoration: const BoxDecoration(
            color: Color(0xFFF9FAFB),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),

                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    18,
                    12,
                    12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          sop['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            sop['category'] ?? 'Other',
                            style: const TextStyle(
                              color: Color(0xFFB45309),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        _detailTitle('Description'),

                        const SizedBox(height: 7),

                        Text(
                          sop['description'] ?? '',
                          style: const TextStyle(
                            color: Color(0xFF4B5563),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 22),

                        _detailTitle('Procedure'),

                        const SizedBox(height: 7),

                        Text(
                          sop['steps'] ?? '',
                          style: const TextStyle(
                            color: Color(0xFF374151),
                            height: 1.6,
                          ),
                        ),

                        if ((sop['responsible'] ?? '')
                            .toString()
                            .isNotEmpty) ...[
                          const SizedBox(height: 22),
                          _detailTitle('Responsible Role'),
                          const SizedBox(height: 7),
                          Text(
                            sop['responsible'],
                            style: const TextStyle(
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ],

                        const SizedBox(height: 30),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showSopForm(
                                    existing: sop,
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit_outlined,
                                ),
                                label: const Text('Edit'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteSop(sop);
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                ),
                                label: const Text('Delete'),
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.red.shade600,
                                  foregroundColor:
                                      Colors.white,
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        title: const Text(
          'Kitchen SOPs',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showSopForm();
            },
            icon: const Icon(
              Icons.add_rounded,
              color: Color(0xFFF59E0B),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showSopForm();
        },
        backgroundColor: const Color(0xFFF59E0B),
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create SOP'),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF59E0B),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    4,
                    20,
                    10,
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search SOPs...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final selected =
                          category == _selectedCategory;

                      return Padding(
                        padding:
                            const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedColor:
                              const Color(0xFFFFEDD5),
                          labelStyle: TextStyle(
                            color: selected
                                ? const Color(0xFFB45309)
                                : const Color(0xFF6B7280),
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: _filteredSops.isEmpty
                      ? _emptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            8,
                            20,
                            100,
                          ),
                          itemCount: _filteredSops.length,
                          itemBuilder: (context, index) {
                            final sop =
                                _filteredSops[index];

                            return _sopCard(sop);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _sopCard(Map<String, dynamic> sop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _openSopDetails(sop);
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFFF59E0B),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      sop['title'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      sop['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      sop['category'] ?? 'Other',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB45309),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                size: 38,
                color: Color(0xFFF59E0B),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No SOPs found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Create your first kitchen SOP to standardize procedures and help your staff work consistently.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6B7280),
      ),
    );
  }

  Widget _detailTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: _inputDecoration(label, icon).copyWith(
        hintText: hint,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFF59E0B),
          width: 1.5,
        ),
      ),
    );
  }
}