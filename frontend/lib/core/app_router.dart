import 'package:go_router/go_router.dart';
import '../screens/dashboard_screen.dart';
import '../screens/productos_screen.dart';
import '../screens/producto_detalle_screen.dart';
import '../screens/producto_form_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
    GoRoute(path: '/productos', builder: (_, __) => const ProductosScreen()),
    GoRoute(path: '/productos/nuevo', builder: (_, __) => const ProductoFormScreen()),
    GoRoute(
      path: '/productos/:id',
      builder: (_, s) => ProductoDetalleScreen(id: int.parse(s.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/productos/:id/editar',
      builder: (_, s) => ProductoFormScreen(id: int.parse(s.pathParameters['id']!)),
    ),
  ],
);