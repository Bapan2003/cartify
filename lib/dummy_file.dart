/*
Future<void> deleteAll() async {
  final collection = FirebaseFirestore.instance.collection('products');
  final snapshots = await collection.get();
  for (var doc in snapshots.docs) {
    await doc.reference.delete();
  }
}

Future<void> uploadDummyProducts(
    BuildContext context,
    void Function(void Function()) setState, {
      required void Function(String) onStatusUpdate,
      required void Function(bool) onUploading,
    }) async {
  try {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
      debugPrint("✅ Signed in anonymously: ${auth.currentUser!.uid}");
    }

    onUploading(true);
    onStatusUpdate("🚀 Starting upload of dummy products...");

    final firestore = FirebaseFirestore.instance;
    final random = Random();

    // ✅ Product names & categories
    final List<String> productNames = [
      "Realme 6", "Samsung Galaxy S21", "iPhone 13", "Redmi Note 12", "Vivo Y20",
      "Oppo F19", "OnePlus Nord CE 2", "Motorola G60", "POCO X3 Pro", "Nokia G20",
      "Infinix Note 10", "iQOO Z6", "Nothing Phone 1", "Realme Narzo 60", "Samsung A14",
      "iPhone SE", "Redmi 10", "Oppo Reno 8", "Vivo V27", "OnePlus 10R",
      "Realme C55", "POCO M5", "Motorola Edge 30", "Nokia C32", "Samsung M14",
      "Infinix Hot 12", "iQOO Neo 7", "Nothing Phone 2", "Realme 11 Pro", "Vivo T2x",
      "Oppo A78", "OnePlus Nord 3", "Redmi K50i", "Samsung S23 Ultra", "iPhone 14 Pro",
      "Realme 10", "Vivo Y100", "Oppo F21 Pro", "Motorola G84", "POCO X5 Pro",
      "Nokia X30", "Infinix Zero 5G", "iQOO 11", "Realme GT Neo 3", "Samsung M54",
      "iPhone 12 Mini", "Vivo V25", "Oppo Reno 10", "OnePlus 11", "Redmi 12",
      "MacBook Air M2", "HP Pavilion 15", "Dell Inspiron 14", "ASUS Vivobook 16",
      "Lenovo IdeaPad Slim 5", "Acer Aspire 7", "Microsoft Surface Go 3",
      "iPad 10th Gen", "Samsung Galaxy Tab S9", "Xiaomi Pad 6",

      // 🔹 Headphones & Audio
      "Sony WH-1000XM5", "JBL Tune 760NC", "boAt Rockerz 450", "Noise One Wireless",
      "Apple AirPods Pro", "OnePlus Buds Z2", "Realme Buds Air 5", "Samsung Galaxy Buds 2",

      // 🔹 Smartwatches & Fitness
      "Apple Watch Series 9", "Noise ColorFit Pro 4", "boAt Wave Edge", "Fire-Boltt Quantum",
      "Samsung Galaxy Watch 6", "Fitbit Versa 4", "Amazfit GTS 4",

      // 🔹 Home & Kitchen
      "Philips Mixer Grinder", "Prestige Electric Kettle", "Pigeon Induction Cooktop",
      "Kent RO Water Purifier", "Havells Ceiling Fan", "Bajaj Microwave Oven",
      "LG Refrigerator 260L", "Whirlpool Washing Machine", "Butterfly Gas Stove",

      // 🔹 Fashion
      "Adidas Running Shoes", "Nike Air Max", "Puma T-shirt", "Levi’s Jeans",
      "H&M Hoodie", "Zara Denim Jacket", "U.S. Polo Cap", "Allen Solly Shirt",

      // 🔹 Accessories
      "Fastrack Analog Watch", "Titan Smartwatch", "WildHorn Leather Wallet",
      "American Tourister Backpack", "Mi Power Bank 10000mAh", "Sandisk 128GB Pendrive",
      "Logitech Wireless Mouse", "HP Keyboard Combo", "Sony Bluetooth Speaker",

      // 🔹 Home Decor & Furniture
      "Ikea Study Table", "Nilkamal Plastic Chair", "Sleepwell Memory Foam Mattress",
      "Philips LED Bulb Set", "AmazonBasics Curtain Set", "Godrej Steel Almirah",
      "Urban Ladder Bookshelf", "Cello Plastic Storage Box",

      // 🔹 Appliances
      "Dyson V11 Vacuum Cleaner", "Bosch Dishwasher", "Crompton Air Cooler",
      "Panasonic Smart TV 43 inch", "LG Soundbar 300W", "Voltas Air Conditioner 1.5 Ton"

    ];

    final Map<String, List<String>> categoryMap = {
      // 🔹 Electronics & Gadgets
      "Electronics": [
        "Smartphones",
        "Laptops",
        "Tablets",
        "Smartwatches",
        "Headphones",
        "Cameras",
        "Gaming Consoles",
        "Drones",
        "Accessories",
      ],

      // 🔹 Home & Kitchen
      "Home & Kitchen": [
        "Home Appliances",
        "Cookware",
        "Lighting",
        "Furniture",
        "Decor",
        "Storage & Organization",
        "Cleaning Essentials",
      ],

      // 🔹 Fashion & Lifestyle
      "Fashion": [
        "Men's Clothing",
        "Women's Clothing",
        "Footwear",
        "Watches",
        "Bags & Wallets",
        "Jewelry",
        "Eyewear",
      ],

      // 🔹 Health & Fitness
      "Health & Fitness": [
        "Fitness Equipment",
        "Supplements",
        "Beauty & Grooming",
        "Healthcare Devices",
        "Personal Care",
      ],

      // 🔹 Automotive
      "Automotive": [
        "Car Accessories",
        "Bike Accessories",
        "Lubricants & Oils",
        "Helmets",
        "Cleaning Kits",
      ],

      // 🔹 Books & Stationery
      "Books & Stationery": [
        "Books",
        "Notebooks",
        "Art Supplies",
        "Office Essentials",
        "Educational Material",
      ],

      // 🔹 Grocery & Essentials
      "Grocery": [
        "Beverages",
        "Snacks",
        "Dairy Products",
        "Personal Hygiene",
        "Baby Care",
        "Pet Supplies",
      ],
    };


    final List<String> brands = [
      "Realme", "Samsung", "Apple", "Redmi", "Vivo", "Oppo", "OnePlus",
      "Motorola", "POCO", "Nokia", "Infinix", "iQOO", "Nothing"
    ];

    final List<String> returnPolicies = [
      "7 days return policy",
      "10 days replacement only",
      "15 days return policy",
      "Non-returnable item",
    ];

    final List<String> imageUrls = [
      "https://darlingretail.com/cdn/shop/products/1_7b64958c-304b-43bd-b759-c5366bfa9914_600x.jpg?v=1661581431",
      "https://kaydeeelectronics.in/cdn/shop/files/untitled-design-38-676e816dae24b.webp?v=1735295362&width=1946",
      "https://encrypted-tbn2.gstatic.com/shopping?q=tbn:ANd9GcSaFnfRgEBryO__pcEAo7gXaah_xItcJaGNDpZ0_2fPGZ4aIr0LOXHBYl3QJJA",
      "https://www.shutterstock.com/image-photo/set-different-cooking-utensils-isolated-260nw-2566051791.jpg",
      "https://static1.industrybuying.com/products/automotive-maintenance-and-lubricants/2-wheeler-accessories/bike-accessories/AUT.BIK.528143823_1733486740951.webp",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQhDwO1ofDIAUbf5wd-RgHznr7kP-KV0cNhxQ&s"
    ];

    // ✅ Create dummy products
    final List<Map<String, dynamic>> products = List.generate(100, (index) {
      final name = productNames[index % productNames.length];
      final retail = 10000 + random.nextInt(30000);
      final discount = retail - (random.nextInt(3000) + 1000);
      final categoryKeys = categoryMap.keys.toList();
      final randomCategory = categoryKeys[random.nextInt(categoryKeys.length)];
      final subcategories = categoryMap[randomCategory]!;
      final randomSubCategory = subcategories[random.nextInt(subcategories.length)];
      final brand = brands[random.nextInt(brands.length)];
      final rating = (random.nextDouble() * 4 + 1).toStringAsFixed(1);
      final reviews = random.nextInt(1000);
      final totalBuy = random.nextInt(5000);
      final shippingType = random.nextBool() ? "Free" : "Paid";
      final returnPolicy = returnPolicies[random.nextInt(returnPolicies.length)];
      final productImages = List.generate(
        3,
            (_) => imageUrls[random.nextInt(imageUrls.length)],
      );

      final specifications = {
        "Display": "${5 + random.nextInt(3)}.${random.nextInt(10)} inch AMOLED",
        "Battery": "${4000 + random.nextInt(2000)} mAh",
        "Processor": random.nextBool() ? "Snapdragon" : "MediaTek",
        "Camera": "${random.nextInt(100)} MP",
        "RAM": "${4 + random.nextInt(4)} GB",
        "Storage": "${64 + random.nextInt(192)} GB",
      };

      return {
        "product_name": name,
        "brand": brand,
        "retail_price": retail.toDouble(),
        "discounted_price": discount.toDouble(),
        "description": "Buy $name with amazing performance, battery, and camera.",
        "category": randomCategory,
        "subCategory": randomSubCategory,
        "images": productImages,
        "specifications": specifications,
        "rating": double.parse(rating),
        "review_count": reviews,
        "total_buy": totalBuy,
        "shipping_type": shippingType,
        "return_policy": returnPolicy,
        "createdAt": FieldValue.serverTimestamp(),
        "stock": random.nextInt(50) + 1,
      };
    });

    // ✅ Upload to Firestore in batches
    const int batchLimit = 500;
    int uploadedCount = 0;

    for (int start = 0; start < products.length; start += batchLimit) {
      final batch = firestore.batch();
      final end = (start + batchLimit < products.length)
          ? start + batchLimit
          : products.length;

      for (int i = start; i < end; i++) {
        final docRef = firestore.collection("products").doc();
        batch.set(docRef, products[i]);
      }

      await batch.commit();
      uploadedCount += (end - start);
      final progress = (uploadedCount / products.length * 100).toStringAsFixed(1);
      onStatusUpdate("✅ Uploaded $uploadedCount / ${products.length} ($progress%)");
    }

    onUploading(false);
    onStatusUpdate("🎉 Dummy product upload completed successfully!");
  } catch (e) {
    onUploading(false);
    onStatusUpdate("❌ Error: $e");
    debugPrint("Upload error: $e");
  }
}*/