import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Product>> getProducts({
    int limit = 10,
    int offset = 0,
    String? gender,
    String? tag,
    String? category,
  }) async {
    return await _remoteDataSource.getProducts(
      limit: limit,
      offset: offset,
      gender: gender,
      tag: tag,
      category: category,
    );
  }

  @override
  Future<bool> hasNewProducts({String? category, int days = 7}) async {
    return await _remoteDataSource.hasNewProducts(category: category, days: days);
  }

  @override
  Future<Product?> getProduct(String id) async {
    return await _remoteDataSource.getProduct(id);
  }

  @override
  Future<Product> addProduct(Product product) async {
    final model = ProductModel(
      id: product.id,
      name: product.name,
      price: product.price,
      originalPrice: product.originalPrice,
      description: product.description,
      image: product.image,
      images: product.images,
      colorImages: product.colorImages,
      colorDesignImages: product.colorDesignImages,
      mockup: product.mockup,
      tag: product.tag,
      gender: product.gender,
      category: product.category,
    );
    return await _remoteDataSource.addProduct(model);
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final model = ProductModel(
      id: product.id,
      name: product.name,
      price: product.price,
      originalPrice: product.originalPrice,
      description: product.description,
      image: product.image,
      images: product.images,
      colorImages: product.colorImages,
      colorDesignImages: product.colorDesignImages,
      mockup: product.mockup,
      tag: product.tag,
      gender: product.gender,
      category: product.category,
    );
    return await _remoteDataSource.updateProduct(model);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _remoteDataSource.deleteProduct(id);
  }
}
