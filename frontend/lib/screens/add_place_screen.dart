import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:frontend/services/place_service.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placeService = PlaceService();

  // Form verilerini tutacak değişkenler
  final _nameController = TextEditingController();
  final _commentController = TextEditingController();
  Position? _currentPosition;
  bool _isLoading = false;
  bool _hasRamp = false;
  bool _hasAccessibleToilet = false;
  bool _isToiletUnisex = false; // Sadece _hasAccessibleToilet true ise gösterilecek
  bool _isWheelchairFriendly = false;

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konum izni reddedildi.')),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konum izni kalıcı olarak reddedildi, lütfen ayarlardan açın.')),
          );
        return;
      }
      _currentPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Konum alınamadı: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
       if (_currentPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen konum bilgisini ekleyin.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final placeData = {
        'ad': _nameController.text,
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'aciklama': _commentController.text,
        'ozellikler': {
          'rampa': _hasRamp,
          'engelli_tuvaleti': _hasAccessibleToilet,
          'unisex_tuvalet': _isToiletUnisex,
          'tekerlekli_sandalye_uygun': _isWheelchairFriendly,
        }
      };

      try {
        await _placeService.addPlace(placeData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mekan başarıyla eklendi! İncelendikten sonra yayınlanacaktır.')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mekan eklenemedi: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Erişilebilir Yer Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Mekan Adı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.storefront),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Lütfen mekan adını girin' : null,
              ),
              const SizedBox(height: 20),
              if (_currentPosition != null)
                Text(
                  'Konum: (${_currentPosition!.latitude.toStringAsFixed(5)}, ${_currentPosition!.longitude.toStringAsFixed(5)})',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _getCurrentLocation,
                icon: const Icon(Icons.location_on),
                label: const Text('Mevcut Konumumu Kullan'),
              ),
              const SizedBox(height: 24),
              Text('Erişilebilirlik Özellikleri', style: Theme.of(context).textTheme.titleLarge),
              const Divider(),
              SwitchListTile(
                title: const Text('Rampa Var mı?'),
                value: _hasRamp,
                onChanged: (bool value) => setState(() => _hasRamp = value),
              ),
              SwitchListTile(
                title: const Text('Engelli Tuvaleti Var mı?'),
                value: _hasAccessibleToilet,
                onChanged: (bool value) => setState(() {
                  _hasAccessibleToilet = value;
                  if (!value) {
                    _isToiletUnisex = false; // Engelli tuvaleti yoksa, unisex seçeneğini de sıfırla
                  }
                }),
              ),
              if (_hasAccessibleToilet) // Sadece engelli tuvaleti varsa bu soruyu göster
                SwitchListTile(
                  title: const Text('  Kadın ve Erkek için Ayrı mı?'),
                  subtitle: const Text('(Kapalıysa ortak kullanım demektir)'),
                  value: _isToiletUnisex,
                  onChanged: (bool value) => setState(() => _isToiletUnisex = value),
                ),
              SwitchListTile(
                title: const Text('Ortam Tekerlekli Sandalye İçin Uygun mu?'),
                value: _isWheelchairFriendly,
                onChanged: (bool value) => setState(() => _isWheelchairFriendly = value),
              ),
              const SizedBox(height: 20),
               TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Yorumunuz (İsteğe Bağlı)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.comment),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.add_location_alt),
                      onPressed: _submitForm,
                      label: const Text('Mekanı Ekle'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
