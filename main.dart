import 'package:flutter/material.dart';

void main() {
  runApp(const FreshCartApp());
}

// ==================== APP ====================

class FreshCartApp extends StatelessWidget {
  const FreshCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FreshCart',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF7F8F7),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// ==================== PRODUCT MODEL ====================

class Product {
  final String id;
  final String name;
  final String category;
  final int price;
  final String unit;
  final String emoji;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.emoji,
  });
}

// ==================== PRODUCTS ====================

const List<Product> products = [
  Product(
    id: '1',
    name: 'Fresh Apples',
    category: 'Fruits',
    price: 120,
    unit: '1 kg',
    emoji: '🍎',
  ),
  Product(
    id: '2',
    name: 'Fresh Milk',
    category: 'Dairy',
    price: 60,
    unit: '1 litre',
    emoji: '🥛',
  ),
  Product(
    id: '3',
    name: 'Tomatoes',
    category: 'Vegetables',
    price: 50,
    unit: '1 kg',
    emoji: '🍅',
  ),
  Product(
    id: '4',
    name: 'Brown Bread',
    category: 'Bakery',
    price: 45,
    unit: '1 pack',
    emoji: '🍞',
  ),
  Product(
    id: '5',
    name: 'Bananas',
    category: 'Fruits',
    price: 60,
    unit: '1 dozen',
    emoji: '🍌',
  ),
  Product(
    id: '6',
    name: 'Potatoes',
    category: 'Vegetables',
    price: 40,
    unit: '1 kg',
    emoji: '🥔',
  ),
  Product(
    id: '7',
    name: 'Biscuits',
    category: 'Snacks',
    price: 30,
    unit: '1 pack',
    emoji: '🍪',
  ),
  Product(
    id: '8',
    name: 'Orange Juice',
    category: 'Drinks',
    price: 90,
    unit: '1 litre',
    emoji: '🧃',
  ),
];

// ==================== CATEGORIES ====================

const List<Map<String, String>> categories = [
  {'name': 'Fruits', 'emoji': '🍎'},
  {'name': 'Vegetables', 'emoji': '🥦'},
  {'name': 'Dairy', 'emoji': '🥛'},
  {'name': 'Bakery', 'emoji': '🍞'},
  {'name': 'Snacks', 'emoji': '🍪'},
  {'name': 'Drinks', 'emoji': '🥤'},
];

// ==================== MAIN SCREEN ====================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final Map<String, int> cart = {};
  final List<Map<String, dynamic>> orders = [];

  String selectedCategory = 'All';

  int get cartCount {
    return cart.values.fold(0, (sum, quantity) => sum + quantity);
  }

  int get cartTotal {
    int total = 0;

    for (final entry in cart.entries) {
      final product = products.firstWhere(
        (product) => product.id == entry.key,
      );

      total += product.price * entry.value;
    }

    return total;
  }

  void addToCart(Product product) {
    setState(() {
      cart[product.id] = (cart[product.id] ?? 0) + 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  void increaseQuantity(Product product) {
    setState(() {
      cart[product.id] = (cart[product.id] ?? 0) + 1;
    });
  }

  void decreaseQuantity(Product product) {
    setState(() {
      final quantity = cart[product.id] ?? 0;

      if (quantity <= 1) {
        cart.remove(product.id);
      } else {
        cart[product.id] = quantity - 1;
      }
    });
  }

  void placeOrder() {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
        ),
      );
      return;
    }

    final orderItems = Map<String, int>.from(cart);
    final total = cartTotal;

    setState(() {
      orders.insert(
        0,
        {
          'id': '#FC${DateTime.now().millisecondsSinceEpoch}',
          'items': orderItems,
          'total': total,
          'status': 'Order Confirmed',
          'date': DateTime.now().toString().substring(0, 16),
        },
      );

      cart.clear();
      currentIndex = 3;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order placed successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        cart: cart,
        selectedCategory: selectedCategory,
        onCategoryChanged: (category) {
          setState(() {
            selectedCategory = category;
          });
        },
        onAddToCart: addToCart,
        onOpenCategories: () {
          setState(() {
            currentIndex = 1;
          });
        },
      ),
      CategoriesPage(
        selectedCategory: selectedCategory,
        onCategoryChanged: (category) {
          setState(() {
            selectedCategory = category;
            currentIndex = 0;
          });
        },
      ),
      CartPage(
        cart: cart,
        cartTotal: cartTotal,
        onIncrease: increaseQuantity,
        onDecrease: decreaseQuantity,
        onCheckout: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CheckoutPage(
                total: cartTotal,
                onPlaceOrder: placeOrder,
              ),
            ),
          );
        },
      ),
      ProfilePage(
        orders: orders,
        onOrders: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrdersPage(orders: orders),
            ),
          );
        },
        onAddress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddressPage(),
            ),
          );
        },
        onHelp: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HelpPage(),
            ),
          );
        },
      ),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ==================== HOME PAGE ====================

class HomePage extends StatefulWidget {
  final Map<String, int> cart;
  final String selectedCategory;
  final Function(String) onCategoryChanged;
  final Function(Product) onAddToCart;
  final VoidCallback onOpenCategories;

  const HomePage({
    super.key,
    required this.cart,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onAddToCart,
    required this.onOpenCategories,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchText = '';

  List<Product> get filteredProducts {
    return products.where((product) {
      final matchesCategory = widget.selectedCategory == 'All' ||
          product.category == widget.selectedCategory;

      final matchesSearch =
          product.name.toLowerCase().contains(searchText.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FreshCart',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  'Fresh groceries delivered fast',
                  style: TextStyle(fontSize: 11),
                ),
              ],
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddressPage(),
                            ),
                          );
                        },
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Search
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search groceries',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Banner
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
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Delivered to your doorstep',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onOpenCategories,
                        child: const Text('View All'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 105,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final name = category['name']!;

                        return GestureDetector(
                          onTap: () {
                            widget.onCategoryChanged(name);
                          },
                          child: Container(
                            width: 90,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: widget.selectedCategory == name
                                  ? Colors.green.shade100
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: widget.selectedCategory == name
                                    ? Colors.green
                                    : Colors.transparent,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  category['emoji']!,
                                  style: const TextStyle(fontSize: 34),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  name,
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

                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.selectedCategory == 'All'
                            ? 'Popular Products'
                            : widget.selectedCategory,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.selectedCategory != 'All')
                        TextButton(
                          onPressed: () {
                            widget.onCategoryChanged('All');
                          },
                          child: const Text('Show All'),
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          if (filteredProducts.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    'No products found',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = filteredProducts[index];
                    final quantity = widget.cart[product.id] ?? 0;

                    return ProductCard(
                      product: product,
                      quantity: quantity,
                      onAdd: () {
                        widget.onAddToCart(product);
                      },
                    );
                  },
                  childCount: filteredProducts.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }
}

// ==================== PRODUCT CARD ====================

class ProductCard extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
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
                style: const TextStyle(fontSize: 62),
              ),
            ),
          ),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.unit,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${product.price}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              InkWell(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== CATEGORIES PAGE ====================

class CategoriesPage extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategoriesPage({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Categories',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            final name = category['name']!;

            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                onCategoryChanged(name);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$name selected'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category['emoji']!,
                      style: const TextStyle(fontSize: 55),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ==================== CART PAGE ====================

class CartPage extends StatelessWidget {
  final Map<String, int> cart;
  final int cartTotal;
  final Function(Product) onIncrease;
  final Function(Product) onDecrease;
  final VoidCallback onCheckout;

  const CartPage({
    super.key,
    required this.cart,
    required this.cartTotal,
    required this.onIncrease,
    required this.onDecrease,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final cartProducts = products
        .where((product) => cart.containsKey(product.id))
        .toList();

    if (cartProducts.isEmpty) {
      return const SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 15),
                Text(
                  'Your cart is empty',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text('Add products to your cart'),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Cart',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartProducts.length,
                itemBuilder: (context, index) {
                  final product = cartProducts[index];
                  final quantity = cart[product.id]!;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(
                          product.emoji,
                          style: const TextStyle(fontSize: 45),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(product.unit),
                              const SizedBox(height: 5),
                              Text(
                                '₹${product.price}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => onDecrease(product),
                              icon: const Icon(
                                Icons.remove_circle_outline,
                              ),
                            ),
                            Text(
                              '$quantity',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              onPressed: () => onIncrease(product),
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹$cartTotal',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: onCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

// ==================== CHECKOUT PAGE ====================

class CheckoutPage extends StatelessWidget {
  final int total;
  final VoidCallback onPlaceOrder;

  const CheckoutPage({
    super.key,
    required this.total,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.green,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Home\n560034',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    color: Colors.green,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Cash on Delivery',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Total',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹$total',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onPlaceOrder();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Place Order',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PROFILE PAGE ====================

class ProfilePage extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final VoidCallback onOrders;
  final VoidCallback onAddress;
  final VoidCallback onHelp;

  const ProfilePage({
    super.key,
    required this.orders,
    required this.onOrders,
    required this.onAddress,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 38,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FreshCart Customer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Welcome to FreshCart',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ProfileTile(
              icon: Icons.location_on_outlined,
              title: 'Delivery Address',
              subtitle: 'Home',
              onTap: onAddress,
            ),

            ProfileTile(
              icon: Icons.receipt_long_outlined,
              title: 'My Orders',
              subtitle: '${orders.length} orders',
              onTap: onOrders,
            ),

            ProfileTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help with your orders',
              onTap: onHelp,
            ),

            ProfileTile(
              icon: Icons.info_outline,
              title: 'About FreshCart',
              subtitle: 'Version 1.0.0',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'FreshCart',
                  applicationVersion: '1.0.0',
                  applicationLegalese: 'Fresh groceries delivered fast.',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PROFILE TILE ====================

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(
            icon,
            color: Colors.green,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ==================== ORDERS PAGE ====================

class OrdersPage extends StatelessWidget {
  final List<Map<String, dynamic>> orders;

  const OrdersPage({
    super.key,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: orders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text('Your orders will appear here'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'Order ${order['id']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${order['status']}\n${order['date']}',
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      '₹${order['total']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ==================== ADDRESS PAGE ====================

class AddressPage extends StatelessWidget {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delivery Address',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.home,
                  color: Colors.green,
                ),
                title: const Text(
                  'Home',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text('560034'),
                trailing: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Address editing is ready to connect'),
                    ),
                  );
                },
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Add New Address'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HELP PAGE ====================

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'How can we help you?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.local_shipping_outlined,
                color: Colors.green,
              ),
              title: const Text('Track My Order'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order tracking will appear here'),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.cancel_outlined,
                color: Colors.green,
              ),
              title: const Text('Cancel an Order'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order cancellation support'),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.chat_outlined,
                color: Colors.green,
              ),
              title: const Text('Contact Support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Customer Support'),
                      content: const Text(
                        'Our support team is available to help you with your order.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
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
