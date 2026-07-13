import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/flower_spot.dart';
import '../data/flower_data.dart';
import '../data/city_flower_data.dart';
import '../widgets/common_widgets.dart';
import 'flower_detail_page.dart';
import 'upload_form_page.dart';

class MapHomePage extends StatefulWidget {
  const MapHomePage({super.key});

  @override
  State<MapHomePage> createState() => _MapHomePageState();
}

class _SearchResult {
  final String title;
  final String subtitle;
  final double lat;
  final double lng;
  final String? flower; // city flower if applicable

  const _SearchResult({
    required this.title,
    required this.subtitle,
    required this.lat,
    required this.lng,
    this.flower,
  });
}

class _MapHomePageState extends State<MapHomePage> {
  final MapController mapController = MapController();
  LatLng? currentPosition;
  bool isLoading = false;
  bool _showSearch = false;

  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  List<_SearchResult> _searchResults = [];
  bool _searchingLocal = false;

  static const _gaodeKey = '536f1762af1a4c52a8b23d983a2be053';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ==================== Location ====================

  Future<void> _getCurrentLocation() async {
    setState(() => isLoading = true);

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要定位权限才能显示你的位置')),
        );
        setState(() => isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('定位权限被永久拒绝，请到系统设置中开启'),
          action: SnackBarAction(
            label: '去设置',
            onPressed: () => Geolocator.openAppSettings(),
          ),
        ),
      );
      setState(() => isLoading = false);
      return;
    }

    // Try last known position first (instant, avoids spinner)
    try {
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null && mounted) {
        setState(() {
          currentPosition = LatLng(lastPos.latitude, lastPos.longitude);
        });
        mapController.move(currentPosition!, 12.0);
      }
    } catch (_) {}

    // Get fresh position — platform-specific settings
    try {
      final settings = Platform.isAndroid
          ? AndroidSettings(
              accuracy: LocationAccuracy.medium,
              forceLocationManager: true,
              distanceFilter: 0,
            )
          : AppleSettings(
              accuracy: LocationAccuracy.medium,
              distanceFilter: 0,
            );

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: settings,
      ).timeout(const Duration(seconds: 12));

      if (!mounted) return;

      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
      });
      mapController.move(currentPosition!, 14.0);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已定位到你的位置 🌸')),
      );
    } catch (e) {
      if (!mounted) return;
      if (currentPosition != null) return; // last known position suffices

      final errStr = e.toString().toLowerCase();
      if (errStr.contains('service') && errStr.contains('disable')) {
        _showLocationServiceDialog();
      } else if (errStr.contains('timeout')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('定位超时，请确保在室外或窗边再试'),
            action: SnackBarAction(label: '重试', onPressed: _getCurrentLocation),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('定位失败: $e'),
            action: SnackBarAction(label: '重试', onPressed: _getCurrentLocation),
          ),
        );
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange, size: 26),
            SizedBox(width: 10),
            Text('定位服务未开启', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          '需要开启手机的"位置服务/GPS"才能获取你的当前位置。\n\n请在系统设置中打开定位服务开关，然后返回重试。',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Geolocator.openLocationSettings();
            },
            child: const Text('去开启定位'),
          ),
        ],
      ),
    );
  }

  // ==================== Search ====================

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    // 1. Search local city flower data
    final q = query.trim();
    final localResults = <_SearchResult>[];

    for (final city in cityFlowers) {
      if (city.city.contains(q) || city.province.contains(q) || city.flower.contains(q)) {
        localResults.add(_SearchResult(
          title: '${city.city}${city.flower.isNotEmpty ? ' — ${city.flower}' : ''}',
          subtitle: '${city.province} · 市花：${city.flower}',
          lat: city.latitude,
          lng: city.longitude,
          flower: city.flower,
        ));
      }
      if (localResults.length >= 8) break;
    }

    // Also search flower spots
    for (final spot in flowerSpots) {
      if (spot.name.contains(q) || spot.flowers.any((f) => f.contains(q))) {
        final already = localResults.any((r) =>
            (r.lat - spot.latitude).abs() < 0.01 && (r.lng - spot.longitude).abs() < 0.01);
        if (!already) {
          localResults.add(_SearchResult(
            title: '${spot.name} — ${spot.flowers.join("、")}',
            subtitle: '最佳花期：${spot.bestSeason}',
            lat: spot.latitude,
            lng: spot.longitude,
            flower: spot.flowers.first,
          ));
        }
      }
    }

    setState(() => _searchResults = localResults);

    // 2. AMap geocode search for precise coordinates (debounced)
    if (localResults.isEmpty && q.length >= 2) {
      _searchAmap(q);
    }
  }

  Future<void> _searchAmap(String query) async {
    if (_searchingLocal) return;
    _searchingLocal = true;

    try {
      final url = Uri.parse(
        'https://restapi.amap.com/v3/assistant/inputtips'
        '?key=$_gaodeKey'
        '&keywords=${Uri.encodeComponent(query)}'
        '&city=全国',
      );
      final resp = await http.get(url).timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final tips = data['tips'] as List? ?? [];
        final amapResults = <_SearchResult>[];

        for (final tip in tips.take(6)) {
          final name = tip['name'] as String? ?? '';
          final district = tip['district'] as String? ?? '';
          final location = tip['location'] as String?;
          if (location == null || location.isEmpty) continue;

          final parts = location.split(',');
          if (parts.length != 2) continue;
          final lng = double.tryParse(parts[0]);
          final lat = double.tryParse(parts[1]);
          if (lat == null || lng == null) continue;

          // Check if the result matches a city flower
          String? flower;
          for (final city in cityFlowers) {
            if (name.contains(city.city) || district.contains(city.city)) {
              flower = city.flower;
              break;
            }
          }

          amapResults.add(_SearchResult(
            title: name,
            subtitle: district.isEmpty ? '高德地图搜索结果' : district,
            lat: lat,
            lng: lng,
            flower: flower,
          ));
        }

        if (mounted) setState(() => _searchResults = amapResults);
      }
    } catch (_) {
      // AMap search failed — user still sees local results or empty
    } finally {
      _searchingLocal = false;
    }
  }

  void _onResultSelected(_SearchResult result) {
    _searchFocus.unfocus();
    setState(() {
      _showSearch = false;
      _searchResults = [];
    });
    _searchController.clear();

    mapController.move(LatLng(result.lat, result.lng), 12.0);

    // Show city flower bottom sheet
    _showCityFlowerSheet(result);
  }

  void _showCityFlowerSheet(_SearchResult result) {
    // Find full city flower data
    CityFlower? cityData;
    for (final city in cityFlowers) {
      if ((city.latitude - result.lat).abs() < 0.1 &&
          (city.longitude - result.lng).abs() < 0.1) {
        cityData = city;
        break;
      }
    }

    // Find nearby flower spots
    final nearby = flowerSpots.where((spot) {
      final dist = _haversine(result.lat, result.lng, spot.latitude, spot.longitude);
      return dist < 300; // within 300 km
    }).take(5).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42, height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              // Title
              Row(
                children: [
                  const Text('🌸', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      result.title,
                      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              if (result.subtitle.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(result.subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              ],
              // City flower info
              if (cityData != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: appWarmBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: appBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_florist, color: appPink, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${cityData.city}市花：${cityData.flower}',
                            style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: appGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cityData.description,
                        style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ] else if (result.flower != null) ...[
                const SizedBox(height: 12),
                Chip(
                  label: Text('市花：${result.flower}'),
                  backgroundColor: appLightPink,
                  labelStyle: const TextStyle(color: appPink, fontWeight: FontWeight.w500),
                ),
              ],
              // Nearby flower spots
              if (nearby.isNotEmpty) ...[
                const SizedBox(height: 18),
                const Text('📍 附近赏花地点', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...nearby.map((spot) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.park, color: appGreen, size: 20),
                  title: Text(spot.name, style: const TextStyle(fontSize: 14)),
                  subtitle: Text('${spot.flowers.join("、")} · ${spot.bestSeason}',
                      style: const TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    mapController.move(LatLng(spot.latitude, spot.longitude), 12.0);
                    _showFlowerDetail(spot);
                  },
                )),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  // ==================== Flower detail sheet ====================

  void _showFlowerDetail(FlowerSpot spot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42, height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Row(
                children: [
                  const Text('🌸', style: TextStyle(fontSize: 30)),
                  const SizedBox(width: 10),
                  Text(spot.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: spot.flowers.map((flower) {
                  return Chip(
                    label: Text(flower),
                    backgroundColor: appLightPink,
                    labelStyle: const TextStyle(color: appPink, fontWeight: FontWeight.w500),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 19, color: Colors.pink),
                  const SizedBox(width: 6),
                  Text('最佳花期：${spot.bestSeason}', style: const TextStyle(fontSize: 15)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                spot.description,
                style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity, height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FlowerDetailPage(spot: spot)),
                    );
                  },
                  child: const Text('查看详情'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== Build ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: '搜索城市、地名或花卉...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged,
                onSubmitted: (v) {
                  if (_searchResults.isNotEmpty) _onResultSelected(_searchResults.first);
                },
              )
            : const Text('华语花 · 寻芳中国'),
        backgroundColor: appGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  _searchResults = [];
                  _searchFocus.unfocus();
                }
              });
            },
          ),
          IconButton(
            icon: isLoading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            onPressed: isLoading ? null : _getCurrentLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentPosition ?? const LatLng(35.0, 105.0),
              initialZoom: currentPosition != null ? 12.0 : 4.8,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=7&x={x}&y={y}&z={z}',
              ),
              MarkerLayer(
                markers: flowerSpots.map((spot) {
                  return Marker(
                    point: LatLng(spot.latitude, spot.longitude),
                    width: 90, height: 80,
                    child: GestureDetector(
                      onTap: () => _showFlowerDetail(spot),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.pink, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text('🌸', style: TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              spot.name,
                              style: const TextStyle(
                                fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentPosition!,
                      width: 50, height: 50,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 50),
                    ),
                  ],
                ),
              const RichAttributionWidget(
                attributions: [TextSourceAttribution('高德地图')],
              ),
            ],
          ),

          // Search results dropdown
          if (_showSearch && _searchResults.isNotEmpty)
            Positioned(
              top: 0, left: 12, right: 12,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 360),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final r = _searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: appLightPink,
                          child: Text(
                            r.flower != null ? '🌸' : '📍',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(r.subtitle, style: const TextStyle(fontSize: 12)),
                        onTap: () => _onResultSelected(r),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: appGreen,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadFormPage()),
          );
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
