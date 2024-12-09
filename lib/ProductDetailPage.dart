// import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_pet_shop/utils/Constant.dart';
// import 'package:flutter_pet_shop/utils/CustomWidget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'model/pet.dart';
import 'providers/product_providers.dart';
import 'providers/profile_provider.dart';
import 'providers/add_to_cart_provider.dart';
// import 'AddToCartPage.dart';
import '../model/PetProductModel.dart';
// import '../utils/conversion_utils.dart'; // Import the utility file

import 'ProductCheckAddressPage.dart';
import 'WriteReviewPage.dart';
// Thêm import cho ReviewReponsitory
import 'providers/review_provider.dart'; // Thêm import cho ReviewProvider

class ProductDetailPage extends ConsumerWidget {
  
  final String productId;
  const ProductDetailPage({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petproductDetail = ref.watch(petproductDetailProvider(productId));
    final relatedPetproducts = ref.watch(petproductListProvider);

    // Lấy danh sách đánh giá cho sản phẩm
    final reviews = ref.watch(reviewProvider(productId));

    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Color(0xFFF8F8F8),
        elevation: 0,
        title: Text(
          "Details Product",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: petproductDetail.when(
        loading: () => Center(
          child: CircularProgressIndicator(
            color: Colors.purple,
          )
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text('Error: $err', style: TextStyle(color: Colors.red)),
            ],
          )
        ),
        data: (petproducts) => Column(
          children: [
            // Main content - Scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image and back button
                    Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.45,
                          width: double.infinity,
                          child: Hero(
                            tag: 'pet-${petproducts.id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                              ),
                              child: Image.network(
                                petproducts.photo,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(child: CircularProgressIndicator());
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name and Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  petproducts.title,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${petproducts.price} vnđ',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(255, 114, 74, 178),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Type and Sales
                          Row(
                            children: [
                              _buildInfoCard(Icons.inventory, 'Stock', petproducts.stock),
                              SizedBox(width: 16),
                              SizedBox(width: 16),
                              _buildInfoCard(Icons.sell, 'Sales', petproducts.sold.toString()),
                            ],
                          ),
                          
                          SizedBox(height: 32),
                          
                          // Product Rating Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Xếp hạng & nhận xét',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '4.5',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '/5',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '73 xếp hạng',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < 4 ? Icons.star : Icons.star_border, // Full star for 4, empty for 1
                                    color: const Color.fromARGB(255, 200, 200, 0),
                                  );
                                }),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 32),
                          
                          // Description
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            petproducts.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              height: 1.6,
                              letterSpacing: 0.3,
                            ),
                          ),

                          SizedBox(height: 32),

                          // Related Pets
                          Text(
                            'Có thể bạn cũng quan tâm',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 12),
                          relatedPetproducts.when(
                            loading: () => Center(child: CircularProgressIndicator()),
                            error: (err, stack) => Center(child: Text('Error: $err')),
                            data: (relatedProducts) => SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: relatedProducts.map((relatedProduct) {
                                  if (relatedProduct.id == petproducts.id) return Container();
                                  return _buildRelatedPetCard(context, relatedProduct);
                                }).toList(),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          // Hiển thị danh sách đánh giá
                          SizedBox(height: 32),
                          Text(
                            'Đánh giá sản phẩm',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 12),
                          reviews.when(
                            loading: () => Center(child: CircularProgressIndicator()),
                            error: (err, stack) => Center(child: Text('Error: $err')),
                            data: (reviewList) => ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: reviewList.length,
                              itemBuilder: (context, index) {
                                final review = reviewList[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(width: 8),
                                                  // Hiển thị đánh giá bằng sao
                                                  Row(
                                                    children: List.generate(5, (starIndex) {
                                                      return Icon(
                                                        starIndex < (review.rating ?? 0) ? Icons.star : Icons.star_border,
                                                        color: Colors.amber,
                                                        size: 16,
                                                      );
                                                    }),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                review.comment.toString(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Buttons - Fixed
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Add to Cart Button
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.shopping_cart),
                        label: Text('Add to Cart'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 119, 76, 184),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          // Lấy ref từ Riverpod để gọi provider
                          final addToCartNotifier = ref.read(addToCartProvider.notifier);
                          
                          // Gọi hàm thêm sản phẩm vào giỏ hàng
                          final status = await addToCartNotifier.addProductToCart(petproducts.id);
                          if(status == "200"){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.green),
                                      SizedBox(width: 10),
                                      Text("Thành công!", style: TextStyle(color: Colors.green)),
                                    ],
                                  ),
                                  content: Text("Sản phẩm đã được thêm vào giỏ hàng.", style: TextStyle(fontSize: 16)),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK", style: TextStyle(color: Colors.green)),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else if (status == "400"){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: const Color.fromARGB(255, 175, 120, 76)),
                                      SizedBox(width: 10),
                                      Text("Thất bại!", style: TextStyle(color: const Color.fromARGB(255, 175, 106, 76))),
                                    ],
                                  ),
                                  content: Text("Sản phẩm đã có sẵn giỏ hàng.", style: TextStyle(fontSize: 16)),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK", style: TextStyle(color: Colors.green)),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.red),
                                      SizedBox(width: 10),
                                      Text("Thông báo!", style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                  content: Text("Không thể thêm sản phẩm vào giỏ hàng.", style: TextStyle(fontSize: 16)),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Thoát", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                          // Chuyển hướng đến trang giỏ hàng sau khi thêm thành công
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => AddToCartPage(),
                          //   ),
                          // );
                        },
                      ),
                    ),
                    
                    SizedBox(width: 16),
                    
                    // Floating Action Button for Review
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WriteReviewPage(petProduct: petproducts),
                        ),
                      );
                    },
                    child: Icon(Icons.message), // Icon for the button
                    backgroundColor: Colors.purple,
                  ),
                  
                  SizedBox(width: 16),
                    
                    // Adopt Now Button
                    Expanded(
                      child: ElevatedButton(
                        child: Text('Buy Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 127, 87, 213),
                          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                           // Fetch the updated profile before navigating
                          ref.read(profileProvider.notifier).fetchProfile();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductCheckAddressPage(petProducts: [petproducts]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget cho thông tin chi tiết
  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.purple),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for related pet card
  Widget _buildRelatedPetCard(BuildContext context, PetProduct productId) {
    return Container(
      width: 160,
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              productId.photo,
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productId.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${productId.price} vnđ',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color.fromARGB(255, 109, 80, 203),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(productId: productId.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 114, 81, 203),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Mua ngay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4), // Add some space between buttons
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
