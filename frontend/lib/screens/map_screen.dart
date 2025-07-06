import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/services/auth_service.dart';
import 'add_place_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final AuthService _authService = AuthService();
  Set<Marker> _markers = {};
  final String _apiUrl = 'http://localhost:3000/api/places';

  static const CameraPosition _kAnkara = CameraPosition(
    target: LatLng(39.925533, 32.866287),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  void _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _fetchPlaces() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> places = json.decode(utf8.decode(response.bodyBytes));
        if (!mounted) return;
        setState(() {
          _markers.clear();
          for (var place in places) {
            final double lat = place['latitude'];
            final double lng = place['longitude'];
            final String title = place['ad'];
            final String snippet = place['aciklama'] ?? '';
            final int mekanId = place['id'];

            _markers.add(
              Marker(
                markerId: MarkerId(mekanId.toString()),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(
                  title: title,
                  snippet: snippet,
                ),
                onTap: () => _showPlaceDetails(context, mekanId),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              ),
            );
          }
        });
      } else {
        print('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching places: $e');
    }
  }

  Future<void> _showPlaceDetails(BuildContext context, int mekanId) async {
    try {
      final response = await http.get(Uri.parse('$_apiUrl/$mekanId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> placeDetails = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> medya = placeDetails['medya'] ?? [];

        if (!mounted) return;
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    placeDetails['ad'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    placeDetails['aciklama'] ?? 'Açıklama yok.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  if (medya.isNotEmpty) ...[
                    const Text(
                      'Resimler:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: medya.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.network(
                              medya[index]['medya_url'],
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 150,
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      } else {
        print('Failed to load place details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching place details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeşil Yol Haritası'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Çıkış Yap',
          )
        ],
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kAnkara,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlaceScreen()),
          );
        },
        tooltip: 'Yeni Yer Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }
}
