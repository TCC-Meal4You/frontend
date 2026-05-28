import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal4you_app/services/restaurant_info/restaurant_info_service.dart';

class MapRouteScreen extends StatefulWidget {
  final String? address;
  final int? restaurantId;
  final String? restaurantName;

  const MapRouteScreen({
    super.key,
    this.address,
    this.restaurantId,
    this.restaurantName,
  });

  @override
  State<MapRouteScreen> createState() => _MapRouteScreenState();
}

class _MapRouteScreenState extends State<MapRouteScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  String? _query;
  String? _error;
  static const MethodChannel _launcherChannel = MethodChannel(
    'meal4you_app/google_maps_launcher',
  );
  AnimationController? _pulseController;

  Animation<double> get _pulseAnimation =>
      _pulseController ?? kAlwaysDismissedAnimation;

  Animation<double> get _floatAnimation =>
      _pulseController ?? kAlwaysDismissedAnimation;

  Animation<double> get _lineAnimation =>
      _pulseController ?? kAlwaysDismissedAnimation;

  List<String> _nonEmptyParts(Iterable<dynamic> values) {
    return values
        .map((value) => value?.toString().trim())
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toList();
  }

  String? _queryFromAddressMap(dynamic value) {
    if (value is! Map) return null;
    final parts = _nonEmptyParts([
      value['logradouro'],
      value['numero'],
      value['complemento'],
      value['bairro'],
      value['cidade'],
      value['uf'],
      value['cep'],
      'Brasil',
    ]);
    if (parts.isNotEmpty) {
      return parts.join(', ');
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseController!.repeat(reverse: true);
    _prepareQuery();
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  Future<String?> _buildQuery() async {
    if (widget.restaurantId != null) {
      final data = await RestaurantInfoService.getById(widget.restaurantId!);
      if (data != null) {
        final candidates = [
          _queryFromAddressMap(data['endereco']),
          _queryFromAddressMap(data['address']),
          _queryFromAddressMap(data['enderecoRestaurante']),
          _nonEmptyParts([
            data['logradouro'],
            data['numero'],
            data['complemento'],
            data['bairro'],
            data['cidade'],
            data['uf'],
            data['cep'],
            'Brasil',
          ]).join(', '),
        ];

        for (final candidate in candidates) {
          if (candidate != null && candidate.trim().isNotEmpty) {
            return candidate.trim();
          }
        }
      }
    }

    if (widget.address != null && widget.address!.trim().isNotEmpty) {
      return widget.address!.trim();
    }

    return null;
  }

  Future<bool> _openGoogleMaps(String query) async {
    try {
      final result = await _launcherChannel.invokeMethod<bool>('open', {
        'query': query,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      _error = e.message ?? e.code;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> _prepareQuery() async {
    setState(() {
      _loading = true;
      _error = null;
      _query = null;
    });

    try {
      final query = await _buildQuery();
      if (query == null || query.trim().isEmpty) {
        throw Exception('Não foi possível montar a consulta do restaurante.');
      }

      _query = query;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openRoute() async {
    if (_loading) return;

    if (_query == null || _query!.trim().isEmpty) {
      await _prepareQuery();
    }

    if (_query == null || _query!.trim().isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final opened = await _openGoogleMaps(_query!);
    if (!opened && mounted) {
      setState(() {
        _loading = false;
      });
      return;
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.restaurantName ?? 'Google Maps';
    final subtitle =
        widget.address ?? _query ?? 'Selecione a rota para continuar';

    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF061B2A), Color(0xFF0B3B5A), Color(0xFFF4F7FA)],
              stops: [0.0, 0.58, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: -40,
                  right: -30,
                  child: _GlowBlob(
                    size: 180,
                    color: const Color(0xFF0FE687).withOpacity(0.18),
                  ),
                ),
                Positioned(
                  top: 140,
                  left: -55,
                  child: _GlowBlob(
                    size: 140,
                    color: const Color(0xFF9D00FF).withOpacity(0.14),
                  ),
                ),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, _) {
                    final pulseValue = _pulseAnimation.value;
                    final floatValue = _floatAnimation.value;
                    final lineValue = _lineAnimation.value;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                12,
                                20,
                                24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.16,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.15,
                                                ),
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.explore_outlined,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Como chegar',
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.96),
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.72),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (_loading)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF0FE687,
                                                ).withOpacity(0.18),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFF0FE687,
                                                  ).withOpacity(0.4),
                                                ),
                                              ),
                                              child: const Text(
                                                'Abrindo',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      _AnimatedMapCard(
                                        pulse: pulseValue,
                                        floatValue: floatValue,
                                        lineValue: lineValue,
                                        destinationLabel: title,
                                        addressLabel: subtitle,
                                        loading: _loading,
                                        opened:
                                            _error == null &&
                                            _query != null &&
                                            !_loading,
                                      ),
                                      const SizedBox(height: 18),
                                      _buildStatusCard(context),
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: _openRoute,
                                              icon: const Icon(
                                                Icons.navigation_outlined,
                                                color: Colors.white,
                                              ),
                                              label: const Text(
                                                'Abrir rota',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                      255,
                                                      157,
                                                      0,
                                                      255,
                                                    ),
                                                foregroundColor: const Color(
                                                  0xFF0A1F16,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.of(
                                                  context,
                                                ).maybePop();
                                              },
                                              icon: const Icon(Icons.close),
                                              label: const Text('Cancelar'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF163A4D,
                                                ),
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                side: BorderSide(
                                                  color: Colors.white
                                                      .withOpacity(0.18),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final routeReady = _error == null && _query != null && !_loading;
    final title = _loading
        ? 'Calculando rota'
        : routeReady
        ? 'Google Maps pronto'
        : 'Pronto para abrir';
    final subtitle = _loading
        ? 'Estamos montando o endereço completo do restaurante.'
        : routeReady
        ? 'Você já pode verificar a rota no Google Maps.'
        : 'Toque em "Abrir rota" quando quiser verificar o Google Maps.';

    final color = routeReady
        ? const Color(0xFF0FE687)
        : _loading
        ? const Color(0xFFFFD166)
        : const Color(0xFF7AA4B8);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              routeReady
                  ? Icons.check_circle_outline
                  : _loading
                  ? Icons.hourglass_top
                  : Icons.navigation_outlined,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
                if (_query != null && routeReady) ...[
                  const SizedBox(height: 10),
                  Text(
                    _query!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.56),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedMapCard extends StatelessWidget {
  final double pulse;
  final double floatValue;
  final double lineValue;
  final String destinationLabel;
  final String addressLabel;
  final bool loading;
  final bool opened;

  const _AnimatedMapCard({
    required this.pulse,
    required this.floatValue,
    required this.lineValue,
    required this.destinationLabel,
    required this.addressLabel,
    required this.loading,
    required this.opened,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            CustomPaint(
              size: const Size(double.infinity, 360),
              painter: _MapBackdropPainter(
                pulse: pulse,
                lineValue: lineValue,
                opened: opened,
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: _MapMiniChip(
                icon: Icons.navigation_outlined,
                label: loading ? 'Rota em preparo' : 'Destino pronto',
              ),
            ),
            Positioned(
              right: 18,
              top: 116,
              child: Transform.translate(
                offset: Offset(0, -10 * math.sin(floatValue * math.pi)),
                child: _PinCluster(
                  pulse: pulse,
                  opened: opened,
                  loading: loading,
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: _RouteCaption(
                destinationLabel: destinationLabel,
                addressLabel: addressLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapBackdropPainter extends CustomPainter {
  final double pulse;
  final double lineValue;
  final bool opened;

  _MapBackdropPainter({
    required this.pulse,
    required this.lineValue,
    required this.opened,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEBF2F7), Color(0xFFD7E6EE), Color(0xFFB7D0DE)],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final gridPaint = Paint()
      ..color = const Color(0xFF7AA4B8).withOpacity(0.18)
      ..strokeWidth = 1;

    for (var x = 0.0; x <= size.width; x += 34) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y <= size.height; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final roadPaint = Paint()
      ..color = const Color(0xFF7B98A8).withOpacity(0.7)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 16;

    canvas.drawLine(
      Offset(size.width * 0.14, size.height * 0.26),
      Offset(size.width * 0.75, size.height * 0.26),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.6),
      Offset(size.width * 0.8, size.height * 0.6),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.58, size.height * 0.12),
      Offset(size.width * 0.58, size.height * 0.86),
      roadPaint,
    );

    final routePaint = Paint()
      ..color = opened
          ? const Color(0xFF0FE687)
          : const Color(0xFF9D00FF).withOpacity(0.9)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;

    final routePath = Path()
      ..moveTo(size.width * 0.14, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.36,
        size.height * 0.08,
        size.width * 0.5,
        size.height * 0.26,
      )
      ..quadraticBezierTo(
        size.width * 0.67,
        size.height * 0.44,
        size.width * 0.83,
        size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height * 0.31,
        size.width * 0.9,
        size.height * 0.55,
      );

    final metrics = routePath.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final metric = metrics.first;
      final extracted = metric.extractPath(
        0,
        metric.length * (0.3 + 0.7 * lineValue),
      );
      canvas.drawPath(extracted, routePaint);
    }

    final routeGlowPaint = Paint()
      ..color = routePaint.color.withOpacity(0.16 + pulse * 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;
    if (metrics.isNotEmpty) {
      canvas.drawPath(routePath, routeGlowPaint);
    }

    final landmarkPaint = Paint()..color = Colors.white.withOpacity(0.95);
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.76),
      11 + pulse * 3,
      landmarkPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.18),
      8 + pulse * 2,
      landmarkPaint,
    );

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08 + pulse * 0.04)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.32),
      20,
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MapBackdropPainter oldDelegate) {
    return oldDelegate.pulse != pulse ||
        oldDelegate.lineValue != lineValue ||
        oldDelegate.opened != opened;
  }
}

class _PinCluster extends StatelessWidget {
  final double pulse;
  final bool opened;
  final bool loading;

  const _PinCluster({
    required this.pulse,
    required this.opened,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = opened
        ? const Color(0xFF0FE687)
        : loading
        ? const Color(0xFFFFC857)
        : const Color(0xFFFF7B7B);

    return SizedBox(
      width: 132,
      height: 164,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 28,
            child: Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    baseColor.withOpacity(0.36 + pulse * 0.16),
                    baseColor.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 52,
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.92),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(Icons.place_rounded, color: baseColor, size: 34),
            ),
          ),
          Positioned(
            bottom: 2,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: baseColor.withOpacity(0.3 + pulse * 0.22),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteCaption extends StatelessWidget {
  final String destinationLabel;
  final String addressLabel;

  const _RouteCaption({
    required this.destinationLabel,
    required this.addressLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF0FE687),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Destino selecionado',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B3B5A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            destinationLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            addressLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.3,
              color: Color(0xFF486581),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapMiniChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MapMiniChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0B3B5A)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0B3B5A),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
