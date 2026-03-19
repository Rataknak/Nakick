import 'package:flutter/material.dart';
import 'product_detail_page.dart';
import 'models/shoe.dart';
import 'services/shoe_service.dart';
import 'favorite_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Shoe>> _shoesFuture;
  final ShoeService _shoeService = ShoeService();

  String? _selectedBrand;
  String? _selectedCategory;

  final List<String> _categories = ['All', 'Running', 'Casual', 'Sports', 'Sneakers'];
  final List<String> _brands = ['All', 'Nike', 'Adidas', 'Puma', 'New Balance'];

  @override
  void initState() {
    super.initState();
    _loadShoes();
  }

  void _loadShoes() {
    setState(() {
      final brand = (_selectedBrand == null || _selectedBrand == 'All') ? null : _selectedBrand;
      final category = (_selectedCategory == null || _selectedCategory == 'All') ? null : _selectedCategory;
      _shoesFuture = _shoeService.getShoes(brand: brand, category: category);
    });
  }

  void _refreshShoes() {
    _loadShoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 35,
            ),
            const SizedBox(width: 8),
            const Text(
              'NAKick',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey[800]),
            onPressed: _refreshShoes,
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey[800]),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: Colors.grey[800]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritePage()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[100]!, width: 1),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = (_selectedCategory ?? 'All') == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    _loadShoes();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    margin: const EdgeInsets.only(right: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.redAccent : Colors.grey[600],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            height: 3,
                            width: 20,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                        else
                          const SizedBox(height: 7),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshShoes(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Section
              Container(
                margin: const EdgeInsets.all(16),
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.redAccent, Colors.red.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 20,
                      top: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'New Collection',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Up to 50% OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Shop Now',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: -10,
                      bottom: 0,
                      child: Icon(
                        Icons.directions_run,
                        size: 150,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),

              // Brands Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Popular Brands',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _brands.length,
                  itemBuilder: (context, index) {
                    final brand = _brands[index];
                    final isSelected = (_selectedBrand ?? 'All') == brand;
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text(brand),
                        selected: isSelected,
                        selectedColor: Colors.redAccent,
                        backgroundColor: Colors.grey[200],
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedBrand = brand;
                          });
                          _loadShoes();
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Featured Products Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Shoes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    TextButton(
                      onPressed: _refreshShoes,
                      child: const Text(
                        'See All',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Shoe>>(
                future: _shoesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: Colors.redAccent),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          ElevatedButton(
                            onPressed: _refreshShoes,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text('No shoes found.'),
                      ),
                    );
                  }

                  final shoes = snapshot.data!;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: shoes.length,
                    itemBuilder: (context, index) {
                      return _buildShoeCard(shoes[index]);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShoeCard(Shoe shoe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: shoe.toLegacyMap()..addAll({'id': shoe.id, 'brand': shoe.brand, 'model': shoe.model, 'description': shoe.description, 'category': shoe.category})),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: shoe.imageUrl.startsWith('http') || shoe.imageUrl.startsWith('/')
                        ? Image.network(
                            shoe.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading image (${shoe.imageUrl}): $error');
                              return Center(
                                child: Icon(
                                  Icons.directions_run,
                                  size: 60,
                                  color: Colors.redAccent.withValues(alpha: 0.5),
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/sh1.png',
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
              ),
            ),
            // Details Section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${shoe.brand} ${shoe.model}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 13, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        '4.5', // Default rating
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(120 reviews)',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${shoe.basePrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to cart!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
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
