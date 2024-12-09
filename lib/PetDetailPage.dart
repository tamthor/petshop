// import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_pet_shop/utils/Constant.dart';
// import 'package:flutter_pet_shop/utils/CustomWidget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'model/pet.dart';
import 'providers/pet_provider.dart';
import 'providers/profile_provider.dart';
// import 'AddToCartPage.dart';
import '../model/pet.dart';
import 'CheckAddressPage.dart';

class PetDetailPage extends ConsumerWidget {
  final String petId;

  const PetDetailPage({Key? key, required this.petId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petDetail = ref.watch(petDetailProvider(petId));
    final relatedPets = ref.watch(relatedPetsProvider);

    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Color(0xFFF8F8F8),
        elevation: 0,
        title: Text(
          "Details Pet",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: petDetail.when(
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
        data: (pet) => Column(
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
                            tag: 'pet-${pet.id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                              ),
                              child: Image.network(
                                pet.image,
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
                                  pet.name,
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
                                  '${pet.price} vnđ',
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
                          
                          // Type
                          Row(
                            children: [
                              _buildInfoCard(Icons.pets, 'Type', pet.type),
                              SizedBox(width: 16),
                              _buildInfoCard(Icons.calendar_today, 'Age', '2 years'),
                              SizedBox(width: 16),
                              _buildInfoCard(Icons.male, 'Gender', 'Male'),
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
                            pet.description,
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
                          relatedPets.when(
                            loading: () => Center(child: CircularProgressIndicator()),
                            error: (err, stack) => Center(child: Text('Error: $err')),
                            data: (pets) => SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: pets.map((relatedPet) {
                                  if (relatedPet.id == pet.id) return Container(); // Skip the current pet
                                  return _buildRelatedPetCard(context, relatedPet);
                                }).toList(),
                              ),
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        child: Text('Adopt Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 127, 87, 213),
                          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                          padding: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
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
                              builder: (context) => CheckAddressPage(pet: pet),
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
  Widget _buildRelatedPetCard(BuildContext context, Pet pet) {
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
              pet.image,
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
                  pet.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${pet.price} vnđ',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color.fromARGB(255, 109, 80, 203),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetDetailPage(petId: pet.id),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
