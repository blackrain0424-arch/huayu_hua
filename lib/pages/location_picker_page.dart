import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../widgets/common_widgets.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final MapController _mapController = MapController();
  LatLng _center = const LatLng(35.0, 105.0);
  String _address = '正在获取地址...';
  bool _loadingAddress = false;

  static const _gaodeKey = '536f1762af1a4c52a8b23d983a2be053';

  @override
  void initState() {
    super.initState();
    _reverseGeocode(_center);
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() => _loadingAddress = true);
    try {
      final url = Uri.parse(
        'https://restapi.amap.com/v3/geocode/regeo'
        '?key=$_gaodeKey'
        '&location=${pos.longitude},${pos.latitude}'
        '&radius=1000'
        '&extensions=base',
      );
      final resp = await http.get(url).timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['status'] == '1' && data['regeocode'] != null) {
          final addr = data['regeocode']['formatted_address'] as String? ?? '';
          setState(() => _address = addr.isNotEmpty ? addr : '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}');
        } else {
          setState(() => _address = '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}');
        }
      } else {
        setState(() => _address = '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}');
      }
    } catch (_) {
      setState(() => _address = '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}');
    }
    setState(() => _loadingAddress = false);
  }

  void _onMapMove(MapEvent event) {
    final newCenter = event.camera.center;
    if ((newCenter.latitude - _center.latitude).abs() > 0.001 ||
        (newCenter.longitude - _center.longitude).abs() > 0.001) {
      _center = newCenter;
      _reverseGeocode(newCenter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择拍摄地点'),
        backgroundColor: appGreen,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 14.0,
              onMapEvent: _onMapMove,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=7&x={x}&y={y}&z={z}',
              ),
              const RichAttributionWidget(
                attributions: [TextSourceAttribution('高德地图')],
              ),
            ],
          ),
          // 中心十字准星
          const Center(
            child: Icon(Icons.location_on, color: Colors.red, size: 42),
          ),
          // 底部信息栏
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: appPink, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _loadingAddress
                            ? const Text('获取地址中...', style: TextStyle(fontSize: 14))
                            : Text(_address, style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, {
                        'address': _address,
                        'latitude': _center.latitude,
                        'longitude': _center.longitude,
                      });
                    },
                    child: const Text('确认此位置', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
