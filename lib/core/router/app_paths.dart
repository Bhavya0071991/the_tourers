class AppPaths {
  static const String home = '/';
  static const String category = '/category';
  static const String product = '/product';
  static const String about = '/about';
  static const String generator = '/generator';
  static const String cart = '/cart';
  static const String adminLogin = '/admin-login';
  static const String auth = '/auth';
  static const String updatePassword = '/update-password';
  static const String account = '/account';
  static const String checkoutAddress = '/checkout/address';
  static const String checkoutDelivery = '/checkout/delivery';
  static const String checkoutPayment = '/checkout/payment';
  static const String orderSuccess = '/order-success';
  static const String orders = '/orders';
  static const String savedAddresses = '/account/addresses';
  static const String wishlist = '/account/wishlist';
  static const String savedDesigns = '/account/designs';
  static const String portraits = '/portraits';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminOrders = '/admin/orders';
  static const String adminProducts = '/admin/products';
  static const String adminBanners = '/admin/banners';
  static const String adminMarquee = '/admin/marquee';
  static const String adminCollections = '/admin/collections';
  static const String adminAddProduct = '/admin/products/add';
  static String adminEditProduct(String id) => '/admin/products/edit/$id';
  static const String adminCustomers = '/admin/customers';
  static const String adminSettings = '/admin/settings';

  static String categoryId(String id) => '/category/$id';
  static String orderDetails(String id) => '/orders/$id';
  static String adminOrderDetails(String id) => '/admin/orders/$id';
  static String adminCustomerDetails(String id) => '/admin/customers/$id';
  static String portraitDetails(String id) => '/portraits/$id';
}
