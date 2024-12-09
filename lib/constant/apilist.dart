import '../model/profile.dart';

// final String base = 'http://127.0.0.1:8000/api/v1';
// final String base = 'http://localhost:8000/api/v1';
// final String base = 'http://10.0.2.2:8000/api/v1';
// final String base = 'http://192.168.88.162:8000/api/v1';
final String base = 'http://192.168.1.7:8000/api/v1';
final String api_register = base + "/register";
final String api_profile = base + "/profile";
// Search
final String api_remove_from_cart = base + "/cart/remove";
final String api_search = base + "/search";
// Thay bằng API thật localhost:8000/api/v1/register
final String api_updateprofile = base +"/updateprofile"; // Thay bằng API thật localhost:8000/api/v1/register
// final String api_ge_product_list = base + "/getAllProductList"; //
final String api_login = base + "/login";
final String api_categories = base + "/categories";
// final String api_products_by_category = base + "/categories";
final String api_pets = base + "/getAllPets"; // Thêm endpoint mới cho pets
final String api_pet_detail = base + "/pets";
final String api_order = base + "/orders";
final String api_product_order = base + "/product_orders";
final String api_get_product_order = base + "/product_orders_show";
 // Thêm API để lấy sản phẩm
final String api_product = base + "/getAllproducts";
final String api_product_cat = base + "/getAllProductCat";
final String api_product_details = base + "/products";
final String api_pets_by_category = base + "/pets/category";
// Thêm API add to cart
final String api_add_to_cart = base + "/cart/add";
final String api_get_cart = base + "/cart";
 // Thêm API để lấy chi tiết của một pet
final String api_address = base + "/addresses";
// Blog API Endpoints
final String api_all_blogs = base + "/blogs"; // Lấy danh sách tất cả bài viết
final String api_blog_detail =
    base + "/blogs/"; // Lấy chi tiết bài viết theo ID
final String api_blog_categories =
    base + "/categories"; // Lấy danh sách danh mục
final String api_blog_search = base + "/blogs/search"; // Tìm kiếm bài viết
final String api_blog_tags = base + "/tags"; // Lấy danh sách thẻ bài viết // Thêm API để lấy chi tiết của một pet // Thêm API để lấy chi tiết của một pet
//notification
final String api_notification = base + "/notification";
final String api_get_notification = base + "/getnotification";

//Bình Luận
final String api_add_review = base + "/addReviews";
final String api_get_review = base + "/getReviews";
final String api_delete_review = base + "/deleteReviews";


String token = '';
Profile initialProfile = Profile(full_name: '', phone: '', address: '', photo: '', email: '', id: 0);
