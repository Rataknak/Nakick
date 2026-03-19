import 'package:flutter/material.dart';
import 'product_detail_page.dart';
import 'models/shoe.dart';
import 'services/shoe_service.dart';
import 'favorite_page.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<Shoe>> _shoesFuture;
  final ShoeService _shoeService = ShoeService();

  String? _selectedBrand;
  String _selectedCategory = 'Running'; // Default to first category

  final List<String> _categories = [
    'Running', 'Casual', 'Sports', 'Sneakers', 'Formal', 'Basketball', 'Training', 'Hiking'
  ];
  final List<String> _brands = ['All', 'Nike', 'Adidas', 'Puma', 'New Balance'];

  @override
  void initState() {
    super.initState();
    _loadShoes();
  }

  void _loadShoes() {
    setState(() {
      final brand = (_selectedBrand == null || _selectedBrand == 'All') ? null : _selectedBrand;
      _shoesFuture = _shoeService.getShoes(brand: brand, category: _selectedCategory);
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
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
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
      ),
      body: Row(
        children: [
          // Left Sidebar - Categories
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(right: BorderSide(color: Colors.grey[200]!)),
            ),
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                      _selectedBrand = 'All'; // Reset brand on category change
                    });
                    _loadShoes();
                  },
                  child: Container(
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      border: isSelected 
                        ? const Border(left: BorderSide(color: Colors.redAccent, width: 4))
                        : null,
                    ),
                    child: Text(
                      category,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.redAccent : Colors.grey[600],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Right Content - Brands and Shoes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Selection
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _brands.length,
                    itemBuilder: (context, index) {
                      final brand = _brands[index];
                      final isSelected = (_selectedBrand ?? 'All') == brand;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(brand, style: const TextStyle(fontSize: 12)),
                          selected: isSelected,
                          selectedColor: Colors.redAccent,
                          backgroundColor: Colors.grey[100],
                          padding: EdgeInsets.zero,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[800],
                          ),
                          onSelected: (selected) {
                            setState(() => _selectedBrand = brand);
                            _loadShoes();
                          },
                        ),
                      );
                    },
                  ),
                ),
                
                // Shoe Grid
                Expanded(
                  child: FutureBuilder<List<Shoe>>(
                    future: _shoesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(fontSize: 12)));
                      }
                      final shoes = snapshot.data ?? [];
                      if (shoes.isEmpty) {
                        return const Center(child: Text('No shoes found.'));
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: shoes.length,
                        itemBuilder: (context, index) => _buildMiniShoeCard(shoes[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniShoeCard(Shoe shoe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: shoe.toLegacyMap()..addAll({'id': shoe.id})),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  color: Colors.grey[50],
                  width: double.infinity,
                  child: shoe.imageUrl.startsWith('http')
                      ? Image.network(shoe.imageUrl, fit: BoxFit.contain)
                      : Image.asset('assets/images/sh1.png', fit: BoxFit.contain),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${shoe.brand} ${shoe.model}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${shoe.basePrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.bold),
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
