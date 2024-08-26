import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageLoadException implements Exception {
  final String message;

  ImageLoadException(this.message);
}

class BreedDetails extends StatefulWidget {
  final dynamic breed;

  const BreedDetails(this.breed, {super.key});

  @override
  State<BreedDetails> createState() => _BreedDetailsState();
}

class _BreedDetailsState extends State<BreedDetails> {
  Future<Uint8List> _loadImage(String referenceImageId) async {
    List<String> extensions = [
      '.jpg',
      '.png',
      '.gif',
      '.bmp'
    ]; // Agrega más extensiones si es necesario
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
            title: Center(
              child: Text(widget.breed['name'],
                  style: const TextStyle(
                      fontFamily: 'MoreSugar',
                      fontSize: 38,
                      fontWeight: FontWeight.bold)),
            ),
            backgroundColor: Colors.transparent,
            actions: const [
              SizedBox(
                width: 56,
              )
            ],
          ),
          body: Column(
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.24,
                  width: double.infinity,
                  child: FutureBuilder(
                    future: widget.breed['reference_image_id'] != null
                        ? _loadImage(widget.breed['reference_image_id'])
                        : Future.error('Reference image ID is null'),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(snapshot.data ?? Uint8List(0));
                      } else if (snapshot.hasError) {
                        return Image.asset('assets/notfoundimageimage.png');
                      } else {
                        return const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                        );
                      }
                    },
                  )),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    if (widget.breed['weight'] != null &&
                        widget.breed['weight']['imperial'] != null)
                      Column(
                        children: [
                          Text('Weight: ${widget.breed['weight']['imperial']}.',
                              style: const TextStyle(
                                  fontFamily: 'MoreSugar', fontSize: 20)),
                          const SizedBox(height: 10),
                        ],
                      ),
                    if (widget.breed['life_span'] != null)
                      Column(
                        children: [
                          Text('Life Span: ${widget.breed['life_span']}.',
                              style: const TextStyle(
                                  fontFamily: 'MoreSugar', fontSize: 20)),
                          const SizedBox(height: 10),
                        ],
                      ),
                    if (widget.breed['country_code'] != null)
                      Column(
                        children: [
                          Text('Country Code: ${widget.breed['country_code']}.',
                              style: const TextStyle(
                                  fontFamily: 'MoreSugar', fontSize: 20)),
                          const SizedBox(height: 10),
                        ],
                      ),
                    if (widget.breed['country'] != null)
                      Column(
                        children: [
                          Text('Country: ${widget.breed['country']}.',
                              style: const TextStyle(
                                  fontFamily: 'MoreSugar', fontSize: 20)),
                          const SizedBox(height: 10),
                        ],
                      ),
                    if (widget.breed['origin'] != null)
                      Column(
                        children: [
                          Text('Origin: ${widget.breed['origin']}.',
                              style: const TextStyle(
                                  fontFamily: 'MoreSugar', fontSize: 20)),
                          const SizedBox(height: 10),
                        ],
                      ),
                    if (widget.breed['temperament'] != null)
                      Column(
                        children: [
                          Text('Temperament: ${widget.breed['temperament']}.',
                              style: const TextStyle(
                                  fontFamily: 'MoreSugar', fontSize: 20)),
                          const SizedBox(height: 10),
                        ],
                      ),
                    if (widget.breed['wikipedia_url'] != null)
                      Column(
                        children: [
                          Text(
                              'Wikipedia URL: ${widget.breed['wikipedia_url']}.',
                              style: const TextStyle(
                                  fontFamily: 'MoreSugar', fontSize: 20)),
                          const SizedBox(height: 10),
                        ],
                      ),
                    if (widget.breed['breed_group'] != null)
                      Column(
                        children: [
                          Text('Breed Group: ${widget.breed['breed_group']}.',
                              style: const TextStyle(
                                  fontFamily: 'MoreSugar', fontSize: 20)),
                          const SizedBox(height: 10),
                        ],
                      ),
                    if (widget.breed['bred_for'] != null)
                      Column(
                        children: [
                          Text('Breed for: ${widget.breed['bred_for']}.',
                              style: const TextStyle(
                                  fontFamily: 'MoreSugar', fontSize: 20)),
                          const SizedBox(height: 10),
                        ],
                      ),
                    if (widget.breed['description'] != null)
                      Column(
                        children: [
                          Text(widget.breed['description'],
                              style: const TextStyle(
                                  fontFamily: 'MoreSugar', fontSize: 20)),
                          const SizedBox(height: 10),
                        ],
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
