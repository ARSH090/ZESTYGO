import 'package:common_models/common_models.dart';

/// Central repository providing sample restaurants and accurate rich menus.
class RestaurantRepository {
  static const List<Restaurant> sampleRestaurants = [
    Restaurant(
      id: 'res_001',
      name: 'The Royal Biryani Darbar',
      imageUrl:
          'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800',
      cuisines: ['Hyderabadi', 'Awadhi', 'Biryani', 'Kebabs'],
      rating: 4.8,
      reviewCount: 1420,
      deliveryTimeMinutes: 22,
      distanceKm: 2.1,
      priceForTwo: Money(45000), // ₹450
      isPureVeg: false,
      offers: ['FLAT ₹100 OFF', 'FREE DELIVERY'],
      address: '100ft Road, Indiranagar, Bengaluru',
    ),
    Restaurant(
      id: 'res_002',
      name: 'Truffle & Brioche Burger Co.',
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800',
      cuisines: ['Gourmet Burgers', 'Burger', 'Shakes', 'Fries'],
      rating: 4.7,
      reviewCount: 980,
      deliveryTimeMinutes: 18,
      distanceKm: 1.6,
      priceForTwo: Money(50000), // ₹500
      isPureVeg: false,
      offers: ['20% OFF UP TO ₹80', 'ZESTY GOLD EXCLUSIVE'],
      address: '12th Main, HAL 2nd Stage, Bengaluru',
    ),
    Restaurant(
      id: 'res_003',
      name: 'Artisan Woodfire Pizzeria',
      imageUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800',
      cuisines: ['Neapolitan Pizza', 'Pizza', 'Pasta', 'Italian'],
      rating: 4.9,
      reviewCount: 2150,
      deliveryTimeMinutes: 25,
      distanceKm: 3.2,
      priceForTwo: Money(65000), // ₹650
      isPureVeg: false,
      offers: ['FREE GARLIC BREAD', 'FLAT ₹125 OFF'],
      address: 'CMH Road, Indiranagar, Bengaluru',
    ),
    Restaurant(
      id: 'res_004',
      name: 'Shree Krishna Shuddh Shakahari',
      imageUrl:
          'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800',
      cuisines: ['South Indian', 'North Indian', 'Healthy', 'Thali'],
      rating: 4.6,
      reviewCount: 3100,
      deliveryTimeMinutes: 15,
      distanceKm: 1.2,
      priceForTwo: Money(25000), // ₹250
      isPureVeg: true,
      offers: ['PURE VEG SPECIAL', '10% CASHBACK'],
      address: 'Double Road, Domlur, Bengaluru',
    ),
  ];

  static const Map<String, List<MenuItem>> _menus = {
    'res_001': [
      MenuItem(
        id: 'm1_01',
        restaurantId: 'res_001',
        name: 'Dum Gosht Hyderabadi Biryani',
        description:
            'Slow-cooked mutton layered with fragrant aged basmati rice, saffron, and aromatic spices. Served with Mirchi ka Salan.',
        price: Money(49900),
        isVeg: false,
        category: 'Biryani Specials',
        isBestseller: true,
        rating: 4.9,
        ratingCount: 820,
        imageUrl:
            'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500',
      ),
      MenuItem(
        id: 'm1_02',
        restaurantId: 'res_001',
        name: 'Paneer Subz Dum Biryani',
        description:
            'Charred cottage cheese cubes & garden greens dum-cooked in brass handi with fried onions and mint.',
        price: Money(34900),
        isVeg: true,
        category: 'Biryani Specials',
        isBestseller: true,
        rating: 4.8,
        ratingCount: 540,
        imageUrl:
            'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=500',
      ),
      MenuItem(
        id: 'm1_03',
        restaurantId: 'res_001',
        name: 'Galouti Kebab Melt (4 pcs)',
        description:
            'Melt-in-mouth smoked lamb patties infused with 24 royal potli spices, served on mini saffron sheermals.',
        price: Money(39900),
        isVeg: false,
        category: 'Starters & Kebabs',
        isBestseller: false,
        rating: 4.7,
        ratingCount: 310,
      ),
      MenuItem(
        id: 'm1_04',
        restaurantId: 'res_001',
        name: 'Dahi Ke Kebab (4 pcs)',
        description:
            'Crispy golden exterior with creamy spiced hung curd, bell peppers, and fresh mint chutney.',
        price: Money(28900),
        isVeg: true,
        category: 'Starters & Kebabs',
        isBestseller: false,
        rating: 4.6,
        ratingCount: 220,
      ),
      MenuItem(
        id: 'm1_05',
        restaurantId: 'res_001',
        name: 'Murgh Malai Tikka (6 pcs)',
        description:
            'Tender chicken cubes marinated in rich clotted cream, cardamom, and green chilies charred in clay tandoor.',
        price: Money(36900),
        isVeg: false,
        category: 'Starters & Kebabs',
        isBestseller: true,
        rating: 4.8,
        ratingCount: 410,
      ),
      MenuItem(
        id: 'm1_06',
        restaurantId: 'res_001',
        name: 'Zafrani Shahi Phirni',
        description:
            'Creamy ground rice pudding infused with Kashmiri saffron, cardamom, and silver leaf in traditional clay matka.',
        price: Money(14900),
        isVeg: true,
        category: 'Desserts & Drinks',
        isBestseller: true,
        rating: 4.9,
        ratingCount: 460,
      ),
    ],
    'res_002': [
      MenuItem(
        id: 'm2_01',
        restaurantId: 'res_002',
        name: 'Truffle Beast Wagyu-Style Burger',
        description:
            'Smoked tender patty, black truffle aioli, aged English cheddar, caramelized shallots on toasted golden brioche.',
        price: Money(44900),
        isVeg: false,
        category: 'Signature Burgers',
        isBestseller: true,
        rating: 4.9,
        ratingCount: 710,
        imageUrl:
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
      ),
      MenuItem(
        id: 'm2_02',
        restaurantId: 'res_002',
        name: 'Crispy Peri Peri Chicken Burger',
        description:
            'Buttermilk brined crunchy fried chicken breast, fiery peri-peri glaze, house slaw, and pickled gherkins.',
        price: Money(32900),
        isVeg: false,
        category: 'Signature Burgers',
        isBestseller: true,
        rating: 4.8,
        ratingCount: 650,
      ),
      MenuItem(
        id: 'm2_03',
        restaurantId: 'res_002',
        name: 'Charred Paneer & Guacamole Burger',
        description:
            'Spice-crusted cottage cheese steak, fresh Hass avocado guacamole, chipotle mayo, and wild rocket.',
        price: Money(29900),
        isVeg: true,
        category: 'Signature Burgers',
        isBestseller: false,
        rating: 4.7,
        ratingCount: 380,
      ),
      MenuItem(
        id: 'm2_04',
        restaurantId: 'res_002',
        name: 'Truffle Parmesan Hand-Cut Fries',
        description:
            'Double-fried russet potatoes tossed in white truffle oil, grated 24-month Grana Padano, and chives.',
        price: Money(19900),
        isVeg: true,
        category: 'Sides & Wings',
        isBestseller: true,
        rating: 4.9,
        ratingCount: 920,
      ),
      MenuItem(
        id: 'm2_05',
        restaurantId: 'res_002',
        name: 'Smokey Hickory Chicken Wings (6 pcs)',
        description:
            'Crisp wings tossed in slow-cooked bourbon hickory sauce served with cool sour cream dip.',
        price: Money(27900),
        isVeg: false,
        category: 'Sides & Wings',
        isBestseller: false,
        rating: 4.6,
        ratingCount: 290,
      ),
      MenuItem(
        id: 'm2_06',
        restaurantId: 'res_002',
        name: 'Belgian Dark Chocolate Thickshake',
        description:
            '70% Callebaut chocolate ganache blended with house gelato, topped with dark cocoa nibs.',
        price: Money(21900),
        isVeg: true,
        category: 'Shakes & Drinks',
        isBestseller: true,
        rating: 4.9,
        ratingCount: 540,
      ),
    ],
    'res_003': [
      MenuItem(
        id: 'm3_01',
        restaurantId: 'res_003',
        name: 'Neapolitan Margherita D.O.P.',
        description:
            '48-hour fermented sourdough crust, San Marzano tomato sauce, fresh buffalo mozzarella, basil, EVOO.',
        price: Money(42900),
        isVeg: true,
        category: 'Woodfire Pizzas',
        isBestseller: true,
        rating: 4.9,
        ratingCount: 1100,
        imageUrl:
            'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500',
      ),
      MenuItem(
        id: 'm3_02',
        restaurantId: 'res_003',
        name: 'Burrata & Truffle Pesto Sourdough',
        description:
            'Whole artisanal burrata bomb, genovese basil pesto, roasted cherry tomatoes, and black truffle drizzle.',
        price: Money(54900),
        isVeg: true,
        category: 'Woodfire Pizzas',
        isBestseller: true,
        rating: 4.9,
        ratingCount: 840,
      ),
      MenuItem(
        id: 'm3_03',
        restaurantId: 'res_003',
        name: 'Spicy Diavola Pepperoni Pizza',
        description:
            'Smoked pork pepperoni crisped under woodfire flame, Calabrian hot honey, fior di latte cheese.',
        price: Money(58900),
        isVeg: false,
        category: 'Woodfire Pizzas',
        isBestseller: true,
        rating: 4.8,
        ratingCount: 620,
      ),
      MenuItem(
        id: 'm3_04',
        restaurantId: 'res_003',
        name: 'Cheesy Garlic Sourdough Bread',
        description:
            'Stone-baked sourdough pull-apart loaf stuffed with roasted garlic confit, rosemary butter, and smoked provolone.',
        price: Money(21900),
        isVeg: true,
        category: 'Appetizers',
        isBestseller: true,
        rating: 4.8,
        ratingCount: 780,
      ),
      MenuItem(
        id: 'm3_05',
        restaurantId: 'res_003',
        name: 'Creamy Wild Mushroom Fettuccine',
        description:
            'Handmade bronze-cut fettuccine tossed in porcini butter, white wine, thyme, and parmigiano cream.',
        price: Money(38900),
        isVeg: true,
        category: 'Fresh Pastas',
        isBestseller: false,
        rating: 4.7,
        ratingCount: 340,
      ),
      MenuItem(
        id: 'm3_06',
        restaurantId: 'res_003',
        name: 'Classic Sicilian Tiramisu',
        description:
            'Espresso-soaked savoiardi ladyfingers layered with whipped mascarpone cream and Valrhona cocoa.',
        price: Money(24900),
        isVeg: true,
        category: 'Desserts',
        isBestseller: true,
        rating: 4.9,
        ratingCount: 890,
      ),
    ],
    'res_004': [
      MenuItem(
        id: 'm4_01',
        restaurantId: 'res_004',
        name: 'Maharaja Royal Deluxe Thali',
        description:
            'Paneer Butter Masala, Dal Makhani, Seasonal Subz, Jeera Rice, 2 Butter Naan, Raita, Salad & Matka Gulab Jamun.',
        price: Money(29900),
        isVeg: true,
        category: 'Thali & Combos',
        isBestseller: true,
        rating: 4.9,
        ratingCount: 1450,
        imageUrl:
            'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=500',
      ),
      MenuItem(
        id: 'm4_02',
        restaurantId: 'res_004',
        name: 'Paneer Tikka Butter Masala',
        description:
            'Tandoor-charred cottage cheese cubes simmered in velvety tomato gravy with cashew butter and fenugreek leaves.',
        price: Money(26900),
        isVeg: true,
        category: 'Main Curries',
        isBestseller: true,
        rating: 4.8,
        ratingCount: 920,
      ),
      MenuItem(
        id: 'm4_03',
        restaurantId: 'res_004',
        name: 'Dal Makhani Slow Handi',
        description:
            'Black lentils simmered overnight for 16 hours with clarified butter, cream, and ginger juliennes.',
        price: Money(21900),
        isVeg: true,
        category: 'Main Curries',
        isBestseller: true,
        rating: 4.9,
        ratingCount: 1200,
      ),
      MenuItem(
        id: 'm4_04',
        restaurantId: 'res_004',
        name: 'Mysore Masala Butter Dosa',
        description:
            'Crisp fermented golden crepe smeared with spicy red chili garlic chutney, potato bhaji, coconut chutney & sambar.',
        price: Money(13900),
        isVeg: true,
        category: 'South Indian Specials',
        isBestseller: true,
        rating: 4.7,
        ratingCount: 850,
      ),
      MenuItem(
        id: 'm4_05',
        restaurantId: 'res_004',
        name: 'Garlic Butter Naan (2 pcs)',
        description:
            'Refined flour bread charred in tandoor, brushed with garlic confit and churned white butter.',
        price: Money(8900),
        isVeg: true,
        category: 'Breads & Rice',
        isBestseller: false,
        rating: 4.6,
        ratingCount: 610,
      ),
      MenuItem(
        id: 'm4_06',
        restaurantId: 'res_004',
        name: 'Matka Gulab Jamun (2 pcs)',
        description:
            'Soft fried milk-solid dumplings soaked in rose and green cardamom sugar syrup in earthen pot.',
        price: Money(9900),
        isVeg: true,
        category: 'Desserts',
        isBestseller: true,
        rating: 4.8,
        ratingCount: 780,
      ),
    ],
  };

  static String resolveCanonicalId(String id) {
    final lower = id.toLowerCase();
    if (lower == '1' || lower == 'res_001' || lower.contains('biryani')) {
      return 'res_001';
    }
    if (lower == '2' || lower == 'res_002' || lower.contains('burger') || lower.contains('truffle')) {
      return 'res_002';
    }
    if (lower == '3' || lower == 'res_003' || lower.contains('pizza') || lower.contains('woodfire')) {
      return 'res_003';
    }
    if (lower == '4' || lower == 'res_004' || lower.contains('krishna') || lower.contains('shree')) {
      return 'res_004';
    }
    return id;
  }

  static Restaurant getRestaurantById(String id) {
    final canonicalId = resolveCanonicalId(id);
    try {
      return sampleRestaurants.firstWhere((r) => r.id == canonicalId);
    } catch (_) {
      // Fallback restaurant
      return Restaurant(
        id: id,
        name: 'Gourmet Kitchen $id',
        imageUrl:
            'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800',
        cuisines: ['Multi-Cuisine', 'Continental', 'Beverages'],
        rating: 4.7,
        reviewCount: 450,
        deliveryTimeMinutes: 20,
        distanceKm: 2.0,
        priceForTwo: const Money(40000),
        isPureVeg: false,
        offers: ['FLAT ₹100 OFF'],
        address: 'Indiranagar 100ft Road, Bengaluru',
      );
    }
  }

  static List<MenuItem> getMenuForRestaurant(String restaurantId) {
    final canonicalId = resolveCanonicalId(restaurantId);
    if (_menus.containsKey(canonicalId)) {
      return _menus[canonicalId]!;
    }
    // Return sample default menu
    return _menus['res_001']!;
  }
}
