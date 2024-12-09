// providers/review_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/review_reponsitory.dart';
import '../model/ReviewModel.dart';

final reviewProvider = StreamProvider.family<List<ReviewModel>, String>((ref, productId) {
  final reviewRepository = ReviewReponsitory();
  return reviewRepository.watchReviews(int.parse(productId));
});