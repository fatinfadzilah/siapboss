import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:siapbos/Model/LocationSuggestionModel.dart';
import 'package:siapbos/Model/debouncerModel.dart';
import 'package:siapbos/api/LocationApi.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();
  final LatLng _initialLocation = const LatLng(1.5466496, 103.7172736);
  final PopupController popupController = PopupController();
  final TextEditingController searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  List<Marker> markers = [];
  List<LocationSuggestion> _suggestions = [];

  LatLng? _selectedLatLng;
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Location",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 11, 34, 74),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color.fromARGB(255, 11, 34, 74),
        actions: [
          if (_selectedLatLng != null && _selectedAddress != null)
            IconButton(
              icon: const Icon(Icons.check, color: Color.fromARGB(255, 11, 34, 74)),
              tooltip: 'Sahkan Lokasi',
              onPressed: () {
                _returnSelectedLocation(_selectedLatLng!, _selectedAddress!);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: _initialLocation,
              initialZoom: 16.0,
              onTap: (tapPosition, latlng) {},
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.hackathon.siapbos",
              ),
              MarkerLayer(markers: markers),
              PopupMarkerLayer(
                options: PopupMarkerLayerOptions(
                  popupController: popupController,
                  markers: markers,
                  popupDisplayOptions: PopupDisplayOptions(
                    builder: (context, marker) => FutureBuilder<String>(
                      future: _getAddressFromLatLng(marker.point),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else {
                          return popupMarker(marker, snapshot.data ?? "Unknown location");
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(10),
                  child: TextFormField(
                    controller: searchController,
                    onChanged: (value) {
                      if (value.length >= 3) {
                        _debouncer.run(() async {
                          final results = await LocationApi.fetchAISuggestions(value);
                          if (mounted) {
                            setState(() {
                              _suggestions = results;
                            });
                          }
                        });
                      } else {
                        setState(() {
                          _suggestions = [];
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Search location',
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _searchLocation,
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                searchController.clear();
                                setState(() {
                                  _suggestions = [];
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.location_on, color: Color(0xFF0B224A)),
                          title: Text(
                            suggestion.name,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            searchController.text = suggestion.name;
                            _suggestions.clear();
                            final location = Location(
                              latitude: suggestion.lat,
                              longitude: suggestion.lon,
                              timestamp: DateTime.now(),
                            );
                            _moveToLocation(location);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 11, 34, 74),
        child: const Icon(Icons.my_location, color: Colors.white),
        onPressed: _initCurrentLocation,
      ),
    );
  }

  void _initCurrentLocation() async {
    try {
      final position = await _determinePosition();
      final current = LatLng(position.latitude, position.longitude);
      final address = await _getAddressFromLatLng(current);

      setState(() {
        _selectedLatLng = current;
        _selectedAddress = address;
        markers = [
          Marker(
            point: current,
            width: 40,
            height: 40,
            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
          ),
        ];
        popupController.showPopupsOnlyFor([markers.first]);
      });

      mapController.move(current, 16.0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
      }
    } catch (_) {}
    return "Unknown location";
  }

  void _searchLocation() async {
    try {
      List<Location> results = await locationFromAddress(searchController.text);
      if (results.isNotEmpty) {
        _moveToLocation(results.first);
      } else {
        await _searchAISuggestions(searchController.text);
      }
    } catch (_) {
      await _searchAISuggestions(searchController.text);
    }
  }

  void _moveToLocation(Location location) async {
    LatLng target = LatLng(location.latitude, location.longitude);
    String address = await _getAddressFromLatLng(target);

    setState(() {
      _selectedLatLng = target;
      _selectedAddress = address;
      markers = [
        Marker(
          point: target,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
        ),
      ];
      popupController.showPopupsOnlyFor([markers.first]);
    });

    mapController.move(target, 16.0);
  }

  Future<void> _searchAISuggestions(String query) async {
    final suggestions = await LocationApi.fetchAISuggestions(query);
    if (suggestions.isEmpty) {
      _showNotFoundDialog();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Did you mean:'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: suggestions.map((s) {
            return ListTile(
              title: Text(s.name),
              onTap: () {
                Navigator.pop(context);
                searchController.text = s.name;
                final loc = Location(
                  latitude: s.lat,
                  longitude: s.lon,
                  timestamp: DateTime.now(),
                );
                _moveToLocation(loc);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showNotFoundDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Location not found'),
        content: const Text('No results found for your query.'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget popupMarker(Marker marker, String address) {
    return SizedBox(
      width: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Current Location', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(address, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  void _returnSelectedLocation(LatLng latlng, String address) {
    Navigator.pop(context, {
      'lat': latlng.latitude,
      'lng': latlng.longitude,
      'address': address,
    });
  }
}
