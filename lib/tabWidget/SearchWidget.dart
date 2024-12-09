import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:figma_squircle/figma_squircle.dart'; // Import Figma Squircle package
import '../constant/apilist.dart'; // Import file chứa các API
import '../constant/app_constants.dart'; // Import file chứa các API
import '../PetDetailPage.dart';
import '../model/pet.dart';



class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Pet> searchResults = [];
  bool isLoading = false;

  // Gọi API tìm kiếm
  Future<void> fetchSearchResults(String query) async {
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập từ khóa")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      searchResults.clear(); // Clear kết quả tìm kiếm cũ
    });

    try {
      final response = await http.post(
        Uri.parse(api_search), // Sử dụng api_search từ apilist.dart
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> petData = data['data'] ?? [];
        setState(() {
          searchResults = petData.map((json) {
            if (json['image'] != null) {
              if (!json['image'].startsWith('http')) {
                json['image'] = '$IMAGE_BASE_URL${json['image']}';
              }
            } else {
              // json['image'] = '$base/storage/photos/1731689098_1000032977.jpg';
            }
            return Pet.fromJson(json);
          }).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không thể tìm kiếm: ${response.statusCode}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Có lỗi xảy ra: $error")),
      );
    } finally {
      setState(() {
        isLoading = false; // Dừng loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Nhập từ khóa tìm kiếm",
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () => fetchSearchResults(_searchController.text),
              ),
            ),
          ),
        ),
        if (isLoading)
          Center(
              child:
                  CircularProgressIndicator()), // Hiển thị loading khi đang tìm kiếm
        if (!isLoading && searchResults.isEmpty)
          Expanded(
            child: Center(
              child: Text("Không có kết quả tìm kiếm"),
            ),
          ),
        if (!isLoading && searchResults.isNotEmpty)
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio:
                    0.75, // Điều chỉnh tỷ lệ chiều rộng và chiều cao của thẻ
              ),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final result = searchResults[index];

                return InkWell(
                  onTap: () {
                    // Tạo hành động khi người dùng nhấn vào kết quả tìm kiếm
                    print('Selected pet ID: ${result.id}');
                    // Bạn có thể chuyển tới trang chi tiết sản phẩm nếu cần
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetDetailPage(
                          petId: result.id,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // Đổ bóng xuống dưới
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Hình ảnh sản phẩm
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            result.image,
                            width: double.infinity,
                            height: 120.0,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: Icon(Icons.error, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 8.0),
                        // Tiêu đề sản phẩm
                        Text(
                          result.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4.0),
                        // Mô tả sản phẩm
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            result.description.length > 30
                                ? result.description.substring(0, 30) + '...'
                                : result.description,
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        // Giá sản phẩm
                        Text(
                          "Price: \$${result.price.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
