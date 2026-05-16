import 'dart:ui';
import 'package:flutter/material.dart';

class helmet_manager_screen extends StatefulWidget {
  const helmet_manager_screen({super.key});

  @override
  State<helmet_manager_screen> createState() => _helmet_manager_screenState();
}

class _helmet_manager_screenState extends State<helmet_manager_screen> {
  final FocusNode searchFocus = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Starts empty — no data on first open
  final List<Map<String, dynamic>> _helmets = [];

  // ─── Filtered list based on search query ───────────────────────────────────

  List<Map<String, dynamic>> get _filteredHelmets {
    if (_searchQuery.isEmpty) return _helmets;
    return _helmets.where((h) {
      final name = (h['name'] as String).toLowerCase().replaceAll('\n', ' ');
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // ─── Add Helmet ─────────────────────────────────────────────────────────────

  void addHelmets() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    Color selectedBg = const Color(0xFF2C2C2E);
    Color selectedAccent = const Color(0xFFE8A020);

    final List<Map<String, Color>> colorOptions = [
      {'bg': const Color(0xFF2C2C2E), 'accent': const Color(0xFFE8A020)},
      {'bg': const Color(0xFF5C3A2E), 'accent': const Color(0xFFE53030)},
      {'bg': const Color(0xFF1A2C4E), 'accent': const Color(0xFF3A8EFF)},
      {'bg': const Color(0xFF1E3A2F), 'accent': const Color(0xFF34C76A)},
      {'bg': const Color(0xFF3A1A4E), 'accent': const Color(0xFFAA5CFF)},
    ];

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      barrierDismissible: true,
      // Let the dialog resize when keyboard appears
      useRootNavigator: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return GestureDetector(
              // Tap outside the card → close
              onTap: () => Navigator.of(ctx).pop(),
              behavior: HitTestBehavior.opaque,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    // Scroll away from the keyboard
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                      top: 24,
                    ),
                    child: GestureDetector(
                      // Prevent taps inside from closing
                      onTap: () {},
                      child: Material(
                        color: Colors.transparent,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.88,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.82),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title + close button
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Add New Helmet',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF1C1C1E),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.of(ctx).pop(),
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.08),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close,
                                              size: 16,
                                              color: Color(0xFF1C1C1E)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Helmet Name field
                                  _dialogLabel('Helmet Name'),
                                  const SizedBox(height: 6),
                                  _dialogField(
                                    controller: nameController,
                                    hint: 'e.g. YAMAHA CRASHGARD HELMET',
                                  ),
                                  const SizedBox(height: 14),

                                  // Price field
                                  _dialogLabel('Price'),
                                  const SizedBox(height: 6),
                                  _dialogField(
                                    controller: priceController,
                                    hint: 'e.g. 460.50',
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 18),

                                  // Card theme color picker
                                  _dialogLabel('Card Theme'),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: colorOptions.map((opt) {
                                      final isSelected =
                                          opt['bg'] == selectedBg &&
                                              opt['accent'] == selectedAccent;
                                      return GestureDetector(
                                        onTap: () => setModalState(() {
                                          selectedBg = opt['bg']!;
                                          selectedAccent = opt['accent']!;
                                        }),
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 180),
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: opt['accent'],
                                            border: isSelected
                                                ? Border.all(
                                                    color:
                                                        const Color(0xFF1C1C1E),
                                                    width: 2.5,
                                                  )
                                                : null,
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: opt['accent']!
                                                          .withOpacity(0.45),
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 3),
                                                    )
                                                  ]
                                                : [],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 24),

                                  // Save button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        final name = nameController.text
                                            .trim()
                                            .toUpperCase();
                                        final price =
                                            priceController.text.trim();
                                        if (name.isEmpty || price.isEmpty)
                                          return;

                                        setState(() {
                                          _helmets.add({
                                            'name': name,
                                            'price': price.startsWith('\$')
                                                ? price
                                                : '\$$price',
                                            'bgColor': selectedBg,
                                            'accentColor': selectedAccent,
                                          });
                                        });
                                        Navigator.of(ctx).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF1C1C1E),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'Save Helmet',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Delete Helmet ───────────────────────────────────────────────────────────

  void deleteHelmets(Map<String, dynamic> helmet) {
    setState(() {
      _helmets.remove(helmet);
    });
  }

  // ─── Dialog helpers ──────────────────────────────────────────────────────────

  Widget _dialogLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3C3C3E),
          letterSpacing: 0.1,
        ),
      );

  Widget _dialogField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1C1C1E),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.3),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  // ─── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredHelmets;

    return PopScope(
      canPop: !searchFocus.hasFocus,
      onPopInvokedWithResult: (didPop, result) {
        if (searchFocus.hasFocus) searchFocus.unfocus();
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        _buildHeader(),
                        const SizedBox(height: 16),
                        _buildSearchBar(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // ── Empty state (no helmets added yet) ──
                if (_helmets.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.no_photography_outlined,
                            size: 64,
                            color: Colors.black.withOpacity(0.12),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No helmets yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withOpacity(0.25),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap Add to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )

                // ── No search results ──
                else if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 56, color: Colors.black.withOpacity(0.12)),
                          const SizedBox(height: 12),
                          Text(
                            'No match for "$_searchQuery"',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black.withOpacity(0.25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )

                // ── Helmet cards ──
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final helmet = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildHelmetCard(helmet),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Gallery of Helmets',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1C1C1E),
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        ElevatedButton.icon(
          onPressed: addHelmets,
          icon: const Icon(Icons.add, size: 16),
          label: const Text(
            'Add',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1C1C1E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: searchFocus,
        onChanged: (val) => setState(() => _searchQuery = val.trim()),
        decoration: InputDecoration(
          hintText: 'Search helmets...',
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.35),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black.withOpacity(0.35),
            size: 20,
          ),
          // Clear button appears while typing
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    searchFocus.unfocus();
                  },
                  child: Icon(Icons.close,
                      size: 18, color: Colors.black.withOpacity(0.4)),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildHelmetCard(Map<String, dynamic> helmet) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: helmet['bgColor'] as Color,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Radial glow
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (helmet['accentColor'] as Color).withOpacity(0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Price tag
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: helmet['accentColor'] as Color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                helmet['price'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),

          // Helmet name
          Positioned(
            bottom: 16,
            left: 16,
            child: Text(
              helmet['name'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
                height: 1.25,
              ),
            ),
          ),

          // Delete button
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => deleteHelmets(helmet),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
