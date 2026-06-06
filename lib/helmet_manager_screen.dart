import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class helmet_manager_screen extends StatefulWidget {
  const helmet_manager_screen({super.key});

  @override
  State<helmet_manager_screen> createState() => _helmet_manager_screenState();
}

class _helmet_manager_screenState extends State<helmet_manager_screen> {
  final FocusNode searchFocus = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  // Starts empty — no data on first open
  List<Map<String, dynamic>> _helmets = [];
  bool _isLoading = true;
  // Init Function to Call The Api and Get The Data
  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response =
          await http.get(Uri.parse("https://api.pixora.one/products.php"));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        setState(() {
          _helmets = List<Map<String, dynamic>>.from(jsonData["data"]);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error message if API call fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Failed to load helmets Internet error. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
    final imageURLController = TextEditingController();

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
                                  _dialogLabel('Image URL'),
                                  const SizedBox(height: 6),
                                  _dialogField(
                                    controller: imageURLController,
                                    hint: 'link to helmet image',
                                    keyboardType: TextInputType.url,
                                  ),
                                  const SizedBox(height: 18),

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
                                            'price': price.startsWith('৳')
                                                ? price
                                                : '৳$price',
                                            'image':
                                                imageURLController.text.trim(),
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

  // ─── Delete Helmet
  void deleteHelmets(Map<String, dynamic> helmet) {
    setState(() {
      _helmets.remove(helmet);
    });
  }

  void backToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  // ─── Sort Helmets
  void sortList() {
    setState(() {
      _helmets.sort((a, b) {
        int priceA = a['price'];
        int priceB = b['price'];
        return priceA.compareTo(priceB);
      });
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

//--Designing the UI of the Helmet Manager Screen
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
          floatingActionButton: FloatingActionButton(
            onPressed: backToTop,
            backgroundColor: Colors.black,
            child: const Icon(Icons.arrow_upward, color: Colors.white),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: SafeArea(
            child: CustomScrollView(
              controller: _scrollController,
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
                _isLoading
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.red,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Loading helmets...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black.withOpacity(0.25),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _helmets.isEmpty
                        ? SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.not_interested,
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
                                    'Tap + Add to get started',
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
                        : filtered.isEmpty
                            ? SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.search_off_rounded,
                                          size: 56,
                                          color:
                                              Colors.black.withOpacity(0.12)),
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

                            : SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final helmet = filtered[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16.0),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
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
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          searchFocus.unfocus();
                        },
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: sortList,
          child: const Icon(Icons.sort_sharp, size: 16),
        ),
      ],
    );
  }

  Widget _buildHelmetCard(Map<String, dynamic> helmet) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF6B2F23),
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
                    (const Color(0xFFE53030)).withOpacity(0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 10,
            child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    helmet['image'] as String,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 120,
                      height: 120,
                      color: Colors.white.withOpacity(0.15),
                      child: const Icon(Icons.broken_image_rounded,
                          size: 28, color: Colors.white),
                    ),
                  ),
                )),
          ),

          // Price tag
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF5C1A2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '৳ ${helmet['price']}',
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
