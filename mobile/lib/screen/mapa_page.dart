import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  // Coordenadas aproximadas del centro de Querétaro.
  final LatLng centroQueretaro = LatLng(20.5888, -100.3899);

  // Muestra información cuando el usuario toca un marcador.
  void _mostrarInformacion(String titulo, String descripcion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(descripcion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lugares de mi comunidad')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: centroQueretaro,
          initialZoom: 14,
          minZoom: 3,
          maxZoom: 19,
        ),
        children: [
          // Capa que descarga y muestra los mosaicos de OpenStreetMap.
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          // Capa de marcadores.
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(20.5888, -100.3899),
                width: 50,
                height: 60,
                child: GestureDetector(
                  onTap: () => _mostrarInformacion(
                    'Centro de Querétaro',
                    'Ubicación de referencia para la práctica.',
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
              Marker(
                point: LatLng(20.6173, -100.3910),
                width: 50,
                height: 60,
                child: GestureDetector(
                  onTap: () => _mostrarInformacion(
                    'Punto de interés 2',
                    'Segundo marcador de ejemplo.',
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color.fromARGB(255, 72, 243, 33),
                    size: 40,
                  ),
                ),
              ),
              Marker(
                point: LatLng(20.5790, -100.4000),
                width: 50,
                height: 60,
                child: GestureDetector(
                  onTap: () => _mostrarInformacion(
                    'Punto de interés 3',
                    'Tercer marcador de ejemplo.',
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color.fromARGB(255, 4, 175, 166),
                    size: 40,
                  ),
                ),
              ),
              Marker(
                point: LatLng(20.653710, -100.405522),
                width: 50,
                height: 60,
                child: GestureDetector(
                  onTap: () => _mostrarInformacion(
                    'Punto de interés 4',
                    'Cuarto marcador de ejemplo. UTEQ',
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color.fromARGB(255, 255, 244, 94),
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
          // Atribución obligatoria del mapa.
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Datos del mapa'),
                      content: const Text(
                        'Los datos cartográficos son proporcionados por © OpenStreetMap contributors '
                        'bajo la licencia Open Database License (ODbL).\n\n'
                        'Más información en: openstreetmap.org/copyright',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
