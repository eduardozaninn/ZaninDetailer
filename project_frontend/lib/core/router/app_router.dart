import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../utils/jwt_utils.dart';
import '../../di/injection_container.dart' as di;
import '../../features/client_booking/data/models/service_model.dart';
import '../../features/admin_panel/data/models/admin_service_model.dart';
import '../../features/admin_panel/data/models/admin_brand_model.dart';
import '../../features/client_booking/presentation/pages/welcome_page.dart';
import '../../features/client_booking/presentation/pages/service_selection_page.dart';
import '../../features/client_booking/presentation/pages/booking_page.dart';
import '../../features/admin_panel/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin_panel/presentation/pages/user_management_page.dart';
import '../../features/admin_panel/presentation/pages/admin_services_list_page.dart';
import '../../features/admin_panel/presentation/pages/admin_new_service_page.dart';
import '../../features/admin_panel/presentation/pages/admin_edit_service_page.dart';
import '../../features/admin_panel/presentation/pages/admin_brands_list_page.dart';
import '../../features/admin_panel/presentation/pages/admin_new_brand_page.dart';
import '../../features/admin_panel/presentation/pages/admin_edit_brand_page.dart';
import '../../features/admin_panel/presentation/pages/admin_showcases_page.dart';
import '../../features/auth/presentation/pages/password_update_page.dart';
import '../../features/client_booking/presentation/providers/booking_provider.dart';
import '../../features/admin_panel/presentation/providers/admin_provider.dart';
import '../../features/admin_panel/presentation/providers/admin_service_provider.dart';
import '../../features/admin_panel/presentation/providers/user_management_provider.dart';
import '../../features/admin_panel/presentation/providers/admin_brand_provider.dart';

class AppRouter {
  static const String home = '/';
  static const String services = '/services';
  static const String booking = '/booking';
  static const String passwordUpdate = '/password-update';

  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';

  static const String adminServicesList = '/admin/services';
  static const String adminNewService = '/admin/new-service';
  static const String adminEditService = '/admin/edit-service';

  static const String adminBrandsList = '/admin/brands';
  static const String adminNewBrand = '/admin/new-brand';
  static const String adminEditBrand = '/admin/edit-brands';

  static const String adminShowcases = '/admin/showcases';

  static final router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: services,
        builder: (context, state) => const ServiceSelectionPage(),
      ),
      GoRoute(
        path: booking,
        redirect: (context, state) {
          if (state.extra == null) return services;
          return null;
        },
        builder: (context, state) {
          final service = state.extra as ServiceModel;
          return ChangeNotifierProvider(
            create: (_) => di.sl<BookingProvider>(),
            child: BookingPage(service: service),
          );
        },
      ),
      GoRoute(
        path: passwordUpdate,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return PasswordUpdatePage(resetToken: token);
        },
      ),
      GoRoute(
        path: admin,
        redirect: (context, state) async {
          final storage = di.sl<FlutterSecureStorage>();
          final token = await storage.read(key: StoreKeys.accessToken);

          if (token == null || token.isEmpty || JwtUtils.isExpired(token)) {
            return services;
          }
          return null;
        },
        builder: (context, state) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => di.sl<AdminProvider>()),
            ChangeNotifierProvider(
                create: (_) => di.sl<AdminServiceProvider>()),
            ChangeNotifierProvider(create: (_) => di.sl<AdminBrandProvider>()),
          ],
          child: const AdminDashboardPage(),
        ),
        routes: [
          GoRoute(
            path: 'users',
            builder: (context, state) => ChangeNotifierProvider(
              create: (_) => di.sl<UserManagementProvider>(),
              child: const UserManagementPage(),
            ),
          ),
          GoRoute(
            path: 'services',
            builder: (context, state) => const AdminServicesListPage(),
          ),
          GoRoute(
            path: 'edit-service',
            redirect: (context, state) {
              if (state.extra == null) return adminServicesList;
              return null;
            },
            builder: (context, state) {
              final service = state.extra as AdminServiceModel;
              return AdminEditServicePage(service: service);
            },
          ),
          GoRoute(
            path: 'new-service',
            pageBuilder: (context, state) => _slideUpTransitionPage(
              key: state.pageKey,
              child: const AdminNewServicePage(),
            ),
          ),
          GoRoute(
            path: 'brands',
            builder: (context, state) => const AdminBrandsListPage(),
          ),
          GoRoute(
            path: 'edit-brands',
            redirect: (context, state) {
              if (state.extra == null) return adminBrandsList;
              return null;
            },
            builder: (context, state) {
              final brand = state.extra as AdminBrandModel;
              return AdminEditBrandPage(brand: brand);
            },
          ),
          GoRoute(
            path: 'new-brand',
            pageBuilder: (context, state) => _slideUpTransitionPage(
              key: state.pageKey,
              child: const AdminNewBrandPage(),
            ),
          ),
          GoRoute(
            path: 'showcases',
            builder: (context, state) => const AdminShowcasesPage(),
          ),
        ],
      ),
    ],
  );
}

CustomTransitionPage<void> _slideUpTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeOutQuart;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
