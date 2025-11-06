import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qit/core/app_helper.dart';
import 'package:qit/presentations/screens/product/widget/image_carousal.dart';
import 'package:qit/presentations/screens/product/widget/product_info.dart';
import 'package:qit/presentations/screens/product/widget/similar_product_section.dart';
import 'package:qit/presentations/widgets/gradient_bar.dart';

import '../../../data/model/product_model.dart';

class ProductDetailsPage extends StatefulWidget {
  final String? productId;

  const ProductDetailsPage({super.key, this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {

  late Future<Product> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _fetchProduct();
  }

  Future<Product> _fetchProduct() async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();

    if (!doc.exists) {
      throw Exception("Product not found");
    }

    return Product.fromDoc(doc);
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade700,
        flexibleSpace: const GradientBar(),
        title: const Text("Product Details"),
      ),
      body: SafeArea(
        child: FutureBuilder<Product>(
          future: _productFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data==null) {
              return const Center(child: Text("Product not found"));
            }

            final productItem = snapshot.data!;

            // 🧱 Layout for web vs mobile
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: isWeb
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 📸 Left Side — Product Images
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ImageCarousel(
                                  imageList: productItem.imageUrls,
                                  productId: productItem.id,
                                ),
                              ),
                            ),

                            const SizedBox(width: 32),

                            // 🛍️ Middle — Product Info
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ProductInfoSection(product: productItem),
                              ),
                            ),

                            const SizedBox(width: 32),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SimilarProductsSection(
                            currentProduct: productItem,
                            axis: Axis.vertical,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ImageCarousel(
                                imageList: productItem.imageUrls,
                                productId: productItem.id,
                              ),
                              const SizedBox(height: 16),
                              ProductInfoSection(product: productItem),
                            ],
                          ),
                        ),
                        const Divider(thickness: 3),
                        SimilarProductsSection(currentProduct: productItem),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
