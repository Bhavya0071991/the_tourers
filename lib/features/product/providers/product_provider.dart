import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../domain/entities/product.dart';
import 'product_dependency_providers.dart';

class ProductFilter extends Equatable {
  final String? gender;
  final String? tag;

  const ProductFilter({this.gender, this.tag});

  @override
  List<Object?> get props => [gender, tag];
}

class PaginatedProductsState {
  final List<Product> products;
  final bool isLoadingMore;
  final bool hasMore;

  PaginatedProductsState({
    required this.products,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  PaginatedProductsState copyWith({
    List<Product>? products,
    bool? isLoadingMore,
    bool? hasMore,
  }) {
    return PaginatedProductsState(
      products: products ?? this.products,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class PaginatedProductsNotifier extends AsyncNotifier<PaginatedProductsState> {
  static const int _limit = 10;
  int _offset = 0;

  final ProductFilter filter;
  PaginatedProductsNotifier(this.filter);

  @override
  FutureOr<PaginatedProductsState> build() async {
    _offset = 0;
    final repository = ref.watch(productRepositoryProvider);
    final products = await repository.getProducts(
      limit: _limit,
      offset: _offset,
      gender: filter.gender,
      tag: filter.tag,
    );
    return PaginatedProductsState(
      products: products,
      hasMore: products.length == _limit,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      _offset += _limit;
      final repository = ref.watch(productRepositoryProvider);
      final newProducts = await repository.getProducts(
        limit: _limit,
        offset: _offset,
        gender: filter.gender,
        tag: filter.tag,
      );

      state = AsyncData(
        currentState.copyWith(
          products: [...currentState.products, ...newProducts],
          isLoadingMore: false,
          hasMore: newProducts.length == _limit,
        ),
      );
    } catch (e) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
    }
  }
}

final paginatedProductsProvider = AsyncNotifierProvider.autoDispose
    .family<PaginatedProductsNotifier, PaginatedProductsState, ProductFilter>(
      PaginatedProductsNotifier.new,
    );

class ProductOperationsNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addProduct(Product product) async {
    final repository = ref.read(productRepositoryProvider);
    await repository.addProduct(product);
    ref.invalidate(paginatedProductsProvider);
  }

  Future<void> updateProduct(Product updatedProduct) async {
    final repository = ref.read(productRepositoryProvider);
    await repository.updateProduct(updatedProduct);
    ref.invalidate(paginatedProductsProvider);
  }

  Future<void> deleteProduct(String id) async {
    final repository = ref.read(productRepositoryProvider);
    await repository.deleteProduct(id);
    ref.invalidate(paginatedProductsProvider);
  }
}

final productOperationsProvider =
    NotifierProvider<ProductOperationsNotifier, void>(
      ProductOperationsNotifier.new,
    );

final productByIdProvider = FutureProvider.autoDispose.family<Product?, String>(
  (ref, id) async {
    final repository = ref.read(productRepositoryProvider);
    return await repository.getProduct(id);
  },
);
