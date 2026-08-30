import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({int limit = 10, int offset = 0, String? gender, String? tag, String? category});
  Future<bool> hasNewProducts({String? category, int days = 7});
  Future<Product?> getProduct(String id);
  Future<Product> addProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}
