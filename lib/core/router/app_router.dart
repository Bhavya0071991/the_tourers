import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_paths.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/product_details_page.dart';
import '../../features/product/presentation/pages/category_page.dart';
import '../../features/home/presentation/pages/about_page.dart';
import '../../features/home/presentation/pages/ai_generator_page.dart';
import '../../features/portraits/presentation/pages/portrait_prints_page.dart';
import '../../features/portraits/presentation/pages/portrait_details_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/update_password_page.dart';
import '../../features/checkout/presentation/pages/address_page.dart';
import '../../features/checkout/presentation/pages/delivery_page.dart';
import '../../features/checkout/presentation/pages/payment_page.dart';
import '../../features/order/presentation/pages/order_success_page.dart';
import '../../features/order/presentation/pages/my_orders_page.dart';
import '../../features/order/presentation/pages/order_details_page.dart';
import '../../features/account/presentation/pages/account_page.dart';
import '../../features/account/presentation/pages/saved_addresses_page.dart';
import '../../features/account/presentation/pages/wishlist_page.dart';
import '../../features/account/presentation/pages/saved_designs_page.dart';
import '../../features/admin/presentation/pages/admin_layout.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_orders_page.dart';
import '../../features/admin/presentation/pages/admin_order_details_page.dart';
import '../../features/admin/presentation/pages/admin_customers_page.dart';
import '../../features/admin/presentation/pages/admin_customer_details_page.dart';
import '../../features/admin/presentation/pages/admin_settings_page.dart';
import '../../features/admin/presentation/pages/admin_login_page.dart';
import '../../features/admin/presentation/pages/admin_products_page.dart';
import '../../features/admin/presentation/pages/admin_add_product_page.dart';
import '../../features/admin/presentation/pages/admin_banners_page.dart';
import '../../features/admin/presentation/pages/admin_marquee_page.dart';
import '../../features/admin/presentation/pages/admin_collections_page.dart';
import '../../features/admin/providers/admin_auth_provider.dart';

/// Enum containing all the named routes in the app
enum AppRoute {
  home,
  category,
  product,
  portraits,
  portraitDetails,
  about,
  generator,
  cart,
  auth,
  updatePassword,
  account,
  checkoutAddress,
  checkoutDelivery,
  checkoutPayment,
  orderSuccess,
  orders,
  orderDetails,
  savedAddresses,
  wishlist,
  savedDesigns,
  adminLogin,
  adminDashboard,
  adminOrders,
  adminOrderDetails,
  adminProducts,
  adminBanners,
  adminMarquee,
  adminCollections,
  adminAddProduct,
  adminEditProduct,
  adminCustomers,
  adminCustomerDetails,
  adminSettings,
}

CustomTransitionPage _buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Premium fade and subtle slide up transition
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
    _ref.listen(adminAuthProvider, (_, __) => notifyListeners());
    _ref.listen(requiresPasswordResetProvider, (_, __) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: AppPaths.home,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authStateAsync = ref.read(authProvider);
      final isUserLoggedIn =
          authStateAsync.value?.status == AuthStatus.authenticated;
      final role = authStateAsync.value?.role ?? 'user';
      final isAdminOrSuperAdmin = role == 'admin' || role == 'super_admin';

      final isGoingToAdmin = state.uri.path.startsWith('/admin');
      final isGoingToAdminLogin = state.uri.path == AppPaths.adminLogin;

      // 1. Admin Logic
      if (isGoingToAdmin && !isGoingToAdminLogin && !isAdminOrSuperAdmin) {
        return AppPaths.adminLogin;
      }
      if (isGoingToAdminLogin && isAdminOrSuperAdmin) {
        return AppPaths.adminDashboard;
      }

      // 2. Normal User Logic
      final isGoingToAuth = state.uri.path == AppPaths.auth;
      final isGoingToProtected =
          state.uri.path.startsWith('/account') ||
          state.uri.path.startsWith('/checkout') ||
          state.uri.path == AppPaths.orders;

      if (isGoingToProtected && !isUserLoggedIn) {
        return AppPaths.auth;
      }

      if (isGoingToAuth && isUserLoggedIn) {
        // If they navigate directly to /auth via URL while logged in, go home.
        // But if they were pushed here, we shouldn't force replace the stack.
        // We will handle navigation manually in AuthPage after successful login.
        // To prevent a user from seeing the auth page if they manually type the URL,
        // we could redirect, but checking if there are previous routes in GoRouter is hard here.
        // We will rely on AuthPage to redirect them if already logged in.
      }

      // Password Reset logic
      final requiresPasswordReset = ref.read(requiresPasswordResetProvider);
      final isGoingToUpdatePassword = state.uri.path == AppPaths.updatePassword;

      if (requiresPasswordReset && !isGoingToUpdatePassword) {
        return AppPaths.updatePassword;
      }

      if (!requiresPasswordReset && isGoingToUpdatePassword) {
        return AppPaths.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppPaths.home,
        name: AppRoute.home.name,
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: '${AppPaths.category}/:id',
        name: AppRoute.category.name,
        pageBuilder: (context, state) {
          final categoryId = state.pathParameters['id'] ?? 'mens';
          return _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: CategoryPage(category: categoryId),
          );
        },
      ),
      GoRoute(
        path: AppPaths.product,
        name: AppRoute.product.name,
        pageBuilder: (context, state) {
          final extra = state.extra as Map?;
          final product =
              extra?.map(
                (key, value) => MapEntry(key.toString(), value.toString()),
              ) ??
              {};
          return _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: ProductDetailsPage(product: product),
          );
        },
      ),
      GoRoute(
        path: AppPaths.portraits,
        name: AppRoute.portraits.name,
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const PortraitPrintsPage(),
        ),
      ),
      GoRoute(
        path: '${AppPaths.portraits}/:id',
        name: AppRoute.portraitDetails.name,
        pageBuilder: (context, state) {
          final portraitId = state.pathParameters['id'] ?? '';
          return _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: PortraitDetailsPage(portraitId: portraitId),
          );
        },
      ),
      GoRoute(
        path: AppPaths.about,
        name: AppRoute.about.name,
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const AboutUsPage(),
        ),
      ),
      GoRoute(
        path: AppPaths.generator,
        name: AppRoute.generator.name,
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const AIGeneratorPage(),
        ),
      ),
      GoRoute(
        path: AppPaths.cart,
        name: AppRoute.cart.name,
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const CartPage(),
        ),
      ),
      GoRoute(
        path: AppPaths.adminLogin,
        name: AppRoute.adminLogin.name,
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const AdminLoginPage(),
        ),
      ),
      GoRoute(
        path: AppPaths.auth,
        name: AppRoute.auth.name,
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const AuthPage(),
        ),
      ),
      GoRoute(
        path: AppPaths.updatePassword,
        name: AppRoute.updatePassword.name,
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const UpdatePasswordPage(),
        ),
      ),
      GoRoute(
        path: AppPaths.account,
        name: AppRoute.account.name,
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const AccountPage(),
        ),
      ),

      // Checkout flow
      GoRoute(
        path: AppPaths.checkoutAddress,
        name: AppRoute.checkoutAddress.name,
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const AddressPage(),
        ),
      ),
      GoRoute(
        path: AppPaths.checkoutDelivery,
        name: AppRoute.checkoutDelivery.name,
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const DeliveryPage(),
        ),
      ),
      GoRoute(
        path: AppPaths.checkoutPayment,
        name: AppRoute.checkoutPayment.name,
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const PaymentPage(),
        ),
      ),

      // Order success (replaces stack — back goes to home)
      GoRoute(
        path: AppPaths.orderSuccess,
        name: AppRoute.orderSuccess.name,
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const OrderSuccessPage(),
        ),
      ),

      // Order management
      GoRoute(
        path: AppPaths.orders,
        name: AppRoute.orders.name,
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const MyOrdersPage(),
        ),
      ),
      GoRoute(
        path: '${AppPaths.orders}/:id',
        name: AppRoute.orderDetails.name,
        pageBuilder: (context, state) {
          final orderId = state.pathParameters['id'] ?? '';
          return _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: OrderDetailsPage(orderId: orderId),
          );
        },
      ),

      // Account sub-pages
      GoRoute(
        path: AppPaths.savedAddresses,
        name: AppRoute.savedAddresses.name,
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const SavedAddressesPage(),
        ),
      ),
      GoRoute(
        path: AppPaths.wishlist,
        name: AppRoute.wishlist.name,
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const WishlistPage(),
        ),
      ),
      GoRoute(
        path: AppPaths.savedDesigns,
        name: AppRoute.savedDesigns.name,
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: const SavedDesignsPage(),
        ),
      ),

      // Admin routes
      GoRoute(
        path: '/admin',
        redirect: (context, state) => AppPaths.adminDashboard,
      ),
      ShellRoute(
        builder: (context, state, child) => AdminLayout(child: child),
        routes: [
          GoRoute(
            path: AppPaths.adminDashboard,
            name: AppRoute.adminDashboard.name,
            pageBuilder: (context, state) => _buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const AdminDashboardPage(),
            ),
          ),
          GoRoute(
            path: AppPaths.adminOrders,
            name: AppRoute.adminOrders.name,
            pageBuilder: (context, state) => _buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const AdminOrdersPage(),
            ),
          ),
          GoRoute(
            path: '${AppPaths.adminOrders}/:id',
            name: AppRoute.adminOrderDetails.name,
            pageBuilder: (context, state) {
              final orderId = state.pathParameters['id'] ?? '';
              return _buildPageWithDefaultTransition(
                context: context,
                state: state,
                child: AdminOrderDetailsPage(orderId: orderId),
              );
            },
          ),
          GoRoute(
            path: AppPaths.adminProducts,
            name: AppRoute.adminProducts.name,
            pageBuilder: (context, state) => _buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const AdminProductsPage(),
            ),
          ),
          GoRoute(
            path: AppPaths.adminBanners,
            name: AppRoute.adminBanners.name,
            pageBuilder: (context, state) => _buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const AdminBannersPage(),
            ),
          ),
          GoRoute(
            path: AppPaths.adminMarquee,
            name: AppRoute.adminMarquee.name,
            pageBuilder: (context, state) => _buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const AdminMarqueePage(),
            ),
          ),
          GoRoute(
            path: AppPaths.adminCollections,
            name: AppRoute.adminCollections.name,
            pageBuilder: (context, state) => _buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const AdminCollectionsPage(),
            ),
          ),
          GoRoute(
            path: AppPaths.adminAddProduct,
            name: AppRoute.adminAddProduct.name,
            pageBuilder: (context, state) => _buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const AdminAddProductPage(),
            ),
          ),
          GoRoute(
            path: '/admin/products/edit/:id',
            name: AppRoute.adminEditProduct.name,
            pageBuilder: (context, state) {
              final productId = state.pathParameters['id'];
              return _buildPageWithDefaultTransition(
                context: context,
                state: state,
                child: AdminAddProductPage(productId: productId),
              );
            },
          ),
          GoRoute(
            path: AppPaths.adminCustomers,
            name: AppRoute.adminCustomers.name,
            pageBuilder: (context, state) => _buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const AdminCustomersPage(),
            ),
          ),
          GoRoute(
            path: '${AppPaths.adminCustomers}/:id',
            name: AppRoute.adminCustomerDetails.name,
            pageBuilder: (context, state) {
              final customerId = state.pathParameters['id'] ?? '';
              return _buildPageWithDefaultTransition(
                context: context,
                state: state,
                child: AdminCustomerDetailsPage(customerId: customerId),
              );
            },
          ),
          GoRoute(
            path: AppPaths.adminSettings,
            name: AppRoute.adminSettings.name,
            pageBuilder: (context, state) => _buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const AdminSettingsPage(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri.toString()}')),
    ),
  );
});
