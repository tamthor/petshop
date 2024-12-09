import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final String base = 'http://192.168.1.7:8000/api/v1'; // Base API URL
final String apiAllBlogs = base + "/blogs"; // API lấy danh sách bài viết
final String apiBlogDetail = base + "/blogs/"; // API lấy chi tiết bài viết

class BlogPetPage extends StatefulWidget {
  @override
  _BlogPetPageState createState() => _BlogPetPageState();
}

class _BlogPetPageState extends State<BlogPetPage> {
  List<dynamic> blogs = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchBlogs();
  }

  Future<void> fetchBlogs() async {
    try {
      final response = await http.get(Uri.parse(apiAllBlogs));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          List<dynamic> jsonData = responseData['data'];
          setState(() {
            blogs = jsonData.map((json) {
              if (json['photo'] != null) {
                if (!json['photo'].startsWith('http')) {
                  json['photo'] = '$base/${json['photo']}'; // Ghép base URL với đường dẫn tương đối
                }
              }
              return json; // Trả về đối tượng blog đã được xử lý
            }).toList();
            isLoading = false;
          });
        } else {
          print('API returned success: false');
          setState(() {
            isError = true;
            isLoading = false;
          });
          throw Exception('API returned success: false');
        }
      } else {
        final errorMessage = json.decode(response.body)['message'] ?? 'Failed to load blogs';
        print('Error response: ${response.body}');
        setState(() {
          isError = true;
          isLoading = false;
        });
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error fetching blogs: $e');
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 106, 71, 194),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isError
              ? Center(child: Text('Lỗi khi tải bài viết. Vui lòng thử lại!'))
              : blogs.isEmpty
                  ? Center(child: Text('Không có bài viết nào để hiển thị.'))
                  : ListView.builder(
                      itemCount: blogs.length,
                      itemBuilder: (context, index) {
                        final blog = blogs[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            leading: blog['photo'] != null && blog['photo'].isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      blog['photo'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        print('Error loading image: $error');
                                        return Icon(Icons.broken_image,
                                            size: 50, color: Colors.grey);
                                      },
                                    ),
                                  )
                                : Icon(Icons.image, size: 50),
                            title: Text(blog['title'] ?? 'Không có tiêu đề'),
                            subtitle:
                                Text(blog['summary'] ?? 'Không có tóm tắt'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BlogDetailPage(blogId: blog['id']),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}

class BlogDetailPage extends StatelessWidget {
  final int blogId;

  BlogDetailPage({required this.blogId});

  Future<Map<String, dynamic>?> fetchBlogDetail() async {
    try {
      final response =
          await http.get(Uri.parse('$apiBlogDetail$blogId')); // Ghép ID vào URL
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data'];
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error fetching blog detail: $e');
    }
    return null;
  }

  String resolvePhotoUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return '';
    if (photoUrl.startsWith('http')) {
      return photoUrl; // Nếu là URL đầy đủ, trả về trực tiếp
    }
    return '$base$photoUrl'; // Ghép base URL với đường dẫn tương đối
  }

  String removeHtmlTags(String htmlString) {
    final document = RegExp(r'<[^>]*>'); // Regex để loại bỏ thẻ HTML
    return htmlString.replaceAll(document, '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết bài viết'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchBlogDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text('Lỗi khi tải bài viết.'));
          } else {
            final blog = snapshot.data!;
            final photoUrl = resolvePhotoUrl(blog['photo']);
            final content =
                removeHtmlTags(blog['content'] ?? 'Không có nội dung');
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    photoUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              photoUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.broken_image,
                                      size: 200, color: Colors.grey),
                            ),
                          )
                        : Icon(Icons.image, size: 200),
                    SizedBox(height: 16),
                    Text(
                      blog['title'] ?? 'Không có tiêu đề',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
