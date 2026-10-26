import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/api_exception.dart';
import '../core/app_theme.dart';
import '../modelos/producto.dart';
import '../services/producto_service.dart';
import 'widgets/app_drawer.dart';
import 'widgets/stat_card.dart';
import 'widgets/stock_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = ProductoService();
  List<Producto> _productos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final data = await _service.listar();
      if (!mounted) return;
      setState(() => _productos = data);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalProductos = _productos.length;
    final totalUnidades = _productos.fold<int>(0, (s, p) => s + p.cantidad);
    final valorTotal =
        _productos.fold<double>(0, (s, p) => s + p.precio * p.cantidad);
    final bajoStock = _productos.where((p) => p.cantidad <= 25).toList()
      ..sort((a, b) => a.cantidad.compareTo(b.cantidad));
    final moneda =
        NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard de Inventario')),
      drawer: const AppDrawer(),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off,
                            size: 48, color: AppTheme.rojo),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _cargar,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Valor del inventario (tarjeta principal)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.verde,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Valor del inventario',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              moneda.format(valorTotal),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Productos y unidades
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              titulo: 'Productos',
                              valor: '$totalProductos',
                              icono: Icons.inventory_2_outlined,
                              color: AppTheme.verde,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              titulo: 'Unidades',
                              valor: '$totalUnidades',
                              icono: Icons.layers_outlined,
                              color: AppTheme.ambar,
                            ),
                          ),
                        ],
                      ),

                      // Productos por reponer
                      if (bajoStock.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Para reponer',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Column(
                            children: [
                              for (final p in bajoStock.take(4))
                                ListTile(
                                  title: Text(
                                    p.nombre,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  trailing: StockBadge(cantidad: p.cantidad),
                                ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => context.go('/productos'),
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Gestionar productos'),
                      ),
                    ],
                  ),
                ),
    );
  }
}