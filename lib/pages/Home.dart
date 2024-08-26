import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Breed_Details.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class ImageLoadException implements Exception {
  final String message;

  ImageLoadException(this.message);
}

class _HomeState extends State<Home> {
  List<dynamic> _breeds = [];
  List<dynamic> _searchResults = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchBreeds();
  }

  Future<void> _fetchBreeds() async {
    final response = await http.get(
      Uri.parse('https://api.thecatapi.com/v1/breeds'),
      headers: {
        'x-api-key':
            'ive_99Qe4Ppj34NdplyLW67xCV7Ds0oSLKGgcWWYnSzMJY9C0QOu0HUR4azYxWkyW2nr2',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        _breeds = jsonData;
      });
    } else {
      throw Exception('Failed to load breeds');
    }
  }

  Future<Uint8List> _loadImage(String referenceImageId) async {
    List<String> extensions = [
      '.jpg',
      '.png',
      '.gif',
      '.bmp'
    ]; // Agrega More extensiones si es necesario
    int retryCount = 0;
    int timeout =
        10; // Límite de tiempo para los intentos de carga (10 segundos)
    DateTime startTime = DateTime.now();

    for (String extension in extensions) {
      String url =
          'https://cdn2.thecatapi.com/images/$referenceImageId$extension';
      while (retryCount < 3) {
        try {
          final response = await http
              .get(Uri.parse(url))
              .timeout(Duration(seconds: timeout));
          if (response.statusCode == 200) {
            return response.bodyBytes;
          } else {
            throw ImageLoadException('Failed to load image');
          }
        } catch (e) {
          retryCount++;
          await Future.delayed(const Duration(seconds: 1));
          if (DateTime.now().difference(startTime).inSeconds > timeout) {
            throw ImageLoadException(
                'Failed to load image after $timeout seconds');
          }
        }
      }
      retryCount =
          0; // Resetear el contador de reintentos para la próxima extensión
    }
    throw ImageLoadException(
        'Failed to load image after trying all extensions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/background.png'),
          fit: BoxFit.cover,
        )),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Center(
                  child: Text(
                'Catbreeds',
                style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'MoreSugar',
                    fontWeight: FontWeight.bold),
              )),
              backgroundColor: Colors.transparent,
            ),
            body: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      filled: true,
                      fillColor: Color.fromARGB(255, 245, 245, 245),
                      labelStyle: TextStyle(color: Colors.transparent),
                      suffixIcon: Icon(Icons.search, color: Colors.black),
                    ),
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                        _searchResults = _breeds
                            .where((breed) => breed['name']
                                .toLowerCase()
                                .startsWith(query.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _searchQuery.isEmpty
                      ? ListView.builder(
                          itemCount: _breeds.length,
                          itemBuilder: (context, index) {
                            final breed = _breeds[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, bottom: 20),
                              child: Card(
                                color: const Color.fromARGB(255, 245, 245, 245),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Name: ${breed['name']}',
                                              style: const TextStyle(
                                                fontFamily: 'MoreSugar',
                                              )),
                                          ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all(
                                                      const Color.fromARGB(
                                                          255, 255, 255, 255)),
                                            ),
                                            onPressed: () {
                                              // Navegar a otra pantalla con More información
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BreedDetails(breed),
                                                ),
                                              );
                                            },
                                            child: const Text('More...',
                                                style: TextStyle(
                                                    fontFamily: 'MoreSugar',
                                                    color: Colors.black)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                          height:
                                              200, // Tamaño fijo para la imagen
                                          width: double.infinity,
                                          child: FutureBuilder(
                                            future: breed[
                                                        'reference_image_id'] !=
                                                    null
                                                ? _loadImage(
                                                    breed['reference_image_id'])
                                                : Future.error(
                                                    'Reference image ID is null'),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Image.memory(
                                                    snapshot.data ??
                                                        Uint8List(0));
                                              } else if (snapshot.hasError) {
                                                return Image.asset(
                                                    'assets/notfoundimage.png'); // Mostrar imagen local por defecto
                                              } else {
                                                return const Center(
                                                  child: SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ); // Mostrar círculo de carga mientras se carga la imagen
                                              }
                                            },
                                          )),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Origin: ${breed['origin']}',
                                              style: const TextStyle(
                                                fontFamily: 'MoreSugar',
                                              )),
                                          Text(
                                              'Intelligence: ${breed['intelligence']}',
                                              style: const TextStyle(
                                                fontFamily: 'MoreSugar',
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : _searchResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/notfound.png'),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final breed = _searchResults[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, bottom: 20),
                                  child: Card(
                                    color: const Color.fromARGB(
                                        255, 245, 245, 245),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Name: ${breed['name']}',
                                                  style: const TextStyle(
                                                    fontFamily: 'MoreSugar',
                                                  )),
                                              ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStateProperty.all(
                                                          const Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255)),
                                                ),
                                                onPressed: () {
                                                  // Navegar a otra pantalla con More información
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          BreedDetails(breed),
                                                    ),
                                                  );
                                                },
                                                child: const Text('More...',
                                                    style: TextStyle(
                                                        fontFamily: 'MoreSugar',
                                                        color: Colors.black)),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                              height:
                                                  200, // Tamaño fijo para la imagen
                                              width: double.infinity,
                                              child: FutureBuilder(
                                                future: breed[
                                                            'reference_image_id'] !=
                                                        null
                                                    ? _loadImage(breed[
                                                        'reference_image_id'])
                                                    : Future.error(
                                                        'Reference image ID is null'),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    return Image.memory(
                                                        snapshot.data ??
                                                            Uint8List(0));
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Image.asset(
                                                        'assets/notfoundimage.png'); // Mostrar imagen local por defecto
                                                  } else {
                                                    return const Center(
                                                      child: SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child:
                                                            CircularProgressIndicator(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ); // Mostrar círculo de carga mientras se carga la imagen
                                                  }
                                                },
                                              )),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('Origin: ${breed['origin']}',
                                                  style: const TextStyle(
                                                    fontFamily: 'MoreSugar',
                                                  )),
                                              Text(
                                                  'Intelligence: ${breed['intelligence']}',
                                                  style: const TextStyle(
                                                    fontFamily: 'MoreSugar',
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                )
              ],
            )),
      ),
    );
  }
}
