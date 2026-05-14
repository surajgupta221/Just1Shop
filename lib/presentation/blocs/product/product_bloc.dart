// lib/presentation/blocs/product/product_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/banner_model.dart';

// Events
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {}

class LoadCategories extends ProductEvent {}

class LoadBanners extends ProductEvent {}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadProductsByCategory extends ProductEvent {
  final String categoryId;

  const LoadProductsByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

// States
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final List<BannerModel> banners;

  const ProductLoaded(this.products, this.categories, this.banners);

  @override
  List<Object?> get props => [products, categories, banners];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductSearchResults extends ProductState {
  final List<ProductModel> products;

  const ProductSearchResults(this.products);

  @override
  List<Object?> get props => [products];
}

class CategoryProductsLoaded extends ProductState {
  final List<ProductModel> products;
  final CategoryModel category;

  const CategoryProductsLoaded(this.products, this.category);

  @override
  List<Object?> get props => [products, category];
}

// BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc(this._productRepository) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadCategories>(_onLoadCategories);
    on<LoadBanners>(_onLoadBanners);
    on<SearchProducts>(_onSearchProducts);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
  }

  void _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    try {
      await emit.forEach(
        _productRepository.getProducts(),
        onData: (List<ProductModel> products) {
          if (state is ProductLoaded) {
            final currentState = state as ProductLoaded;
            return ProductLoaded(
                products, currentState.categories, currentState.banners);
          }
          return ProductLoaded(products, [], []);
        },
        onError: (error, stackTrace) => ProductError(error.toString()),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onLoadCategories(
      LoadCategories event, Emitter<ProductState> emit) async {
    try {
      await emit.forEach(
        _productRepository.getCategories(),
        onData: (List<CategoryModel> categories) {
          if (state is ProductLoaded) {
            final currentState = state as ProductLoaded;
            return ProductLoaded(
                currentState.products, categories, currentState.banners);
          }
          return ProductLoaded([], categories, []);
        },
        onError: (error, stackTrace) => ProductError(error.toString()),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onLoadBanners(LoadBanners event, Emitter<ProductState> emit) async {
    try {
      await emit.forEach(
        _productRepository.getBanners(),
        onData: (List<BannerModel> banners) {
          if (state is ProductLoaded) {
            final currentState = state as ProductLoaded;
            return ProductLoaded(
                currentState.products, currentState.categories, banners);
          }
          return ProductLoaded([], [], banners);
        },
        onError: (error, stackTrace) => ProductError(error.toString()),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onSearchProducts(
      SearchProducts event, Emitter<ProductState> emit) async {
    if (event.query.isEmpty) {
      // If search query is empty, load all products
      add(LoadProducts());
      return;
    }

    emit(ProductLoading());
    try {
      await emit.forEach(
        _productRepository.searchProducts(event.query),
        onData: (List<ProductModel> products) => ProductSearchResults(products),
        onError: (error, stackTrace) => ProductError(error.toString()),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onLoadProductsByCategory(
      LoadProductsByCategory event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products =
          await _productRepository.getProductsByCategory(event.categoryId);
      final category = await _getCategoryById(event.categoryId);
      emit(CategoryProductsLoaded(products, category));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<CategoryModel> _getCategoryById(String categoryId) async {
    final categories = await _productRepository.getCategories().first;
    return categories.firstWhere((category) => category.id == categoryId);
  }
}
