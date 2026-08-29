import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  final SupabaseClient _supabase;

  ProductRemoteDataSource(this._supabase);

  Future<List<ProductModel>> getProducts({
    int limit = 10,
    int offset = 0,
    String? gender,
    String? tag,
  }) async {
    var query = _supabase.from('products').select();

    if (gender != null && gender.isNotEmpty) {
      query = query.eq('gender', gender);
    }

    if (tag != null && tag.isNotEmpty && tag != 'ALL') {
      query = query.eq('tag', tag);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  Future<ProductModel?> getProduct(String id) async {
    final response = await _supabase
        .from('products')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return ProductModel.fromJson(response);
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    final response = await _supabase
        .from('products')
        .insert(product.toJson())
        .select()
        .single();

    return ProductModel.fromJson(response);
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await _supabase
        .from('products')
        .update(product.toJson())
        .eq('id', product.id)
        .select()
        .single();

    return ProductModel.fromJson(response);
  }

  Future<void> deleteProduct(String id) async {
    await _supabase.from('products').delete().eq('id', id);
  }
}
