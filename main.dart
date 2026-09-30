import 'package:flutter/material.dart';

void main() {
  runApp(const FreshCartApp());
}

class FreshCartApp extends StatelessWidget {
  const FreshCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FreshCart',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: const Color(0xFFF7F8F7),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class Product {
  final String name;
  final String category;
  final int price;
  final String unit;
  final String emoji;

  const Product({
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.emoji,
  });
}

const products = [
  Product(
    name: 'Fresh Apples',
    category: 'Fruits',
    price: 120,
    unit: '1 kg',
    emoji: '🍎',
  ),
  Product(
    name: 'Bananas',
    category: 'Fruits',
    price: 60,
    unit: '1 kg',
    emoji: '🍌',
  ),
  Product(
    name: 'Tomatoes',
    category: 'Vegetables',
    price: 50,
    unit: '1 kg',
    emoji: '🍅',
  ),
  Product(
    name: 'Potatoes',
    category: 'Vegetables',
    price: 45,
    unit: '1 kg',
    emoji: '🥔',
  ),
  Product(
    name: 'Fresh Milk',
    category: 'Dairy',
    price: 60,
    unit: '1 litre',
    emoji: '🥛',
  ),
  Product(
    name: 'Brown Bread',
    category: 'Bakery',
    price: 45,
    unit: '1 pack',
    emoji: '🍞',
  ),
  Product(
    name: 'Biscuits',
    category: 'Snacks',
    price: 40,
    unit: '1 pack',
    emoji: '🍪',
  ),
  Product(
    name: 'Orange Juice',
    category: 'Drinks',
    price: 90,
    unit: '1 litre',
    emoji: '🥤',
  ),
];

const categories = [
  {'name': 'Fruits', 'emoji': '🍎'},
  {'name': 'Vegetables', 'emoji': '🥦'},
  {'name': 'Dairy', 'emoji': '🥛'},
  {'name': 'Bakery', 'emoji': '🍞'},
  {'name': 'Snacks', 'emoji': '🍪'},
  {'name': 'Drinks', 'emoji': '🥤'},
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  String selectedCategory = 'All';
  String searchText = '';

  final Map<String, int> cart = {};

  int get cartCount => cart.values.fold(0, (a, b) => a + b);

  int get cartTotal {
    int total = 0;

    for (final product in products) {
      total += (cart[product.name] ?? 0) * product.price;
    }

    return total;
  }

  List<Product> get filteredProducts {
    return products.where((product) {
      final categoryMatch = selectedCategory == 'All' ||
          product.category == selectedCategory;

      final searchMatch = searchText.isEmpty ||
          product.name.toLowerCase().contains(searchText.toLowerCase());

      return categoryMatch && searchMatch;
    }).toList();
  }

  void addToCart(Product product) {
    setState(() {
      cart[product.name] = (cart[product.name] ?? 0) + 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void removeFromCart(Product product) {
    setState(() {
      final count = cart[product.name] ?? 0;

      if (count <= 1) {
        cart.remove(product.name);
      } else {
        cart[product.name] = count - 1;
      }
    });
  }

  void openSearch() {
    showSearch(
      context: context,
      delegate: GrocerySearchDelegate(
        products: products,
        onAdd: addToCart,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      buildHome(),
      buildCategories(),
      buildCart(),
      buildProfile(),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget buildHome() {
    final visibleProducts = filteredProducts;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            pinned: true,
            expandedHeight: 125,
            title: const Text(
              'FreshCart',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: openSearch,
                icon: const Icon(Icons.search),
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        currentIndex = 2;
                      });
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.red,
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
            flexibleSpace: const FlexibleSpaceBar(
              background: Padding(
                padding: EdgeInsets.only(top: 75, left: 16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Your groceries, delivered in 15 mins',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Deliver to: Home',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Address selection coming soon'),
                            ),
                          );
                        },
                        child: const Text('Change'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: openSearch,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 10),
                          Text(
                            'Search groceries...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fresh groceries',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Delivered to your doorstep',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 14),
                        Text(
                          'FREE DELIVERY ON FIRST ORDER',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 105,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory =
                                  category['name']!;
                              currentIndex = 1;
                            });
                          },
                          child: Container(
                            width: 90,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  category['emoji']!,
                                  style:
                                      const TextStyle(fontSize: 35),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  category['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Popular Products',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedCategory = 'All';
                            currentIndex = 1;
                          });
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: visibleProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: .72,
                    ),
                    itemBuilder: (context, index) {
                      return productCard(visibleProducts[index]);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget productCard(Product product) {
    final count = cart[product.name] ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Text(
                product.emoji,
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
          Text(
            product.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          Text(
            product.unit,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${product.price}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              if (count == 0)
                IconButton(
                  onPressed: () => addToCart(product),
                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.green,
                  ),
                )
              else
                Row(
                  children: [
                    IconButton(
                      onPressed: () => removeFromCart(product),
                      icon: const Icon(Icons.remove_circle),
                    ),
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => addToCart(product),
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCategories() {
    final categoryProducts = selectedCategory == 'All'
        ? products
        : products
            .where((p) => p.category == selectedCategory)
            .toList();

    return SafeArea(
      child: Column(
        children: [
          AppBar(
            title: const Text('Categories'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              children: [
                categoryButton('All', '🛒'),
                ...categories.map(
                  (c) => categoryButton(
                    c['name']!,
                    c['emoji']!,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categoryProducts.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: .72,
              ),
              itemBuilder: (context, index) {
                return productCard(categoryProducts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryButton(String name, String emoji) {
    final selected = selectedCategory == name;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = name;
        });
      },
      child: Container(
        width: 85,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
            Text(
              name,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCart() {
    final cartProducts = products
        .where((product) => cart.containsKey(product.name))
        .toList();

    return SafeArea(
      child: Column(
        children: [
          AppBar(
            title: const Text('My Cart'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          Expanded(
            child: cartProducts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...cartProducts.map(
                        (product) {
                          final count =
                              cart[product.name] ?? 0;

                          return Card(
                            child: ListTile(
                              leading: Text(
                                product.emoji,
                                style:
                                    const TextStyle(fontSize: 35),
                              ),
                              title: Text(product.name),
                              subtitle: Text(
                                '₹${product.price} × $count',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        removeFromCart(product),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                  Text('$count'),
                                  IconButton(
                                    onPressed: () =>
                                        addToCart(product),
                                    icon: const Icon(
                                      Icons.add_circle,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Total: ₹$cartTotal',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Order checkout started'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                        ),
                        child: const Text('Proceed to Checkout'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildProfile() {
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            title: const Text('Profile'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 25),
          const CircleAvatar(
            radius: 45,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 12),
          const Text(
            'FreshCart Customer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Delivery Address'),
            subtitle: const Text('Home'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('My Orders'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class GrocerySearchDelegate extends SearchDelegate<Product?> {
  final List<Product> products;
  final void Function(Product) onAdd;

  GrocerySearchDelegate({
    required this.products,
    required this.onAdd,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = products.where(
      (product) =>
          product.name.toLowerCase().contains(
                query.toLowerCase(),
              ),
    );

    return ListView(
      children: results.map((product) {
        return ListTile(
          leading: Text(
            product.emoji,
            style: const TextStyle(fontSize: 35),
          ),
          title: Text(product.name),
          subtitle: Text(
            '₹${product.price} • ${product.unit}',
          ),
          trailing: IconButton(
            onPressed: () {
              onAdd(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('${product.name} added to cart'),
                ),
              );
            },
            icon: const Icon(
              Icons.add_shopping_cart,
              color: Colors.green,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
