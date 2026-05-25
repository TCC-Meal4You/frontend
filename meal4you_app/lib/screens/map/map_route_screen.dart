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

class _MapRouteScreenState extends State<MapRouteScreen> {
  bool _loading = true;
  String? _query;
  String? _error;
  bool _autoOpened = false;
  static const MethodChannel _launcherChannel = MethodChannel(
    'meal4you_app/google_maps_launcher',
  );

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
    _prepareAndOpen();
  }

  Future<String?> _buildQuery() async {
    if (widget.address != null && widget.address!.trim().isNotEmpty) {
      return widget.address!.trim();
    }

    if (widget.restaurantId != null) {
      final data = await RestaurantInfoService.getById(widget.restaurantId!);
      if (data != null) {
        final endereco =
            _queryFromAddressMap(data['endereco']) ??
            _queryFromAddressMap(data['address']) ??
            _queryFromAddressMap(data['enderecoRestaurante']);
        if (endereco != null) {
          return endereco;
        }

        final parts = _nonEmptyParts([
          data['logradouro'],
          data['numero'],
          data['complemento'],
          data['bairro'],
          data['cidade'],
          data['uf'],
          data['cep'],
          'Brasil',
        ]);
        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }
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

  Future<void> _prepareAndOpen() async {
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
      final opened = await _openGoogleMaps(query);
      if (!opened) {
        throw Exception('Não foi possível abrir o Google Maps.');
      }

      _autoOpened = true;
    } catch (e) {
      _error = e.toString();
      // ignore: avoid_print
      print('[MapRouteScreen] erro ao abrir Google Maps: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openManually() async {
    if (_query == null || _query!.trim().isEmpty) return;
    final opened = await _openGoogleMaps(_query!);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.restaurantName ?? 'Google Maps';

    return Scaffold(
      appBar: AppBar(title: Text('Como chegar — $title')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error == null && _autoOpened
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Abrindo o Google Maps...',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (_query != null)
                      Text(
                        _query!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: _openManually,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Abrir novamente'),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      _error ?? 'Não foi possível abrir o Google Maps.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    if (_query != null)
                      Text(
                        'Consulta: $_query',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _prepareAndOpen,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
