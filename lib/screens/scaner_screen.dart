import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  XFile? capturedImage;
  bool isProcessing = false;
  double opacityLevel = 0.0;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      XFile image = await _cameraController!.takePicture();
      setState(() {
        capturedImage = image;
        isProcessing = true;
      });

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          isProcessing = false;
        });
      });

      showResultsPanel();
    } catch (e) {
      print("Error al capturar la imagen: $e");
    }
  }

  void showResultsPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(0, 33, 33, 33),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOutQuad,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Resultados",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: capturedImage != null
                            ? Image.file(
                                File(capturedImage!.path),
                                height: 200,
                                fit: BoxFit.cover,
                              )
                            : Container(),
                      ),
                      SizedBox(height: 10),
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 600),
                        opacity: isProcessing ? 0.0 : 1.0,
                        child: Column(
                          children: [
                            Text(
                              "Objeto detectado: Producto X",
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              "Descripción: Esto es una descripción simulada con más detalles para probar el desplazamiento...",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Detalles adicionales:\n- Peso: 500g\n- Color: Rojo\n- Precio: \$19.99\n- Código: XYZ123",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      isProcessing ? CircularProgressIndicator() : Container(),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSvgIcon(String assetName) {
    return SvgPicture.asset(
      assetName,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Esto hace que el fondo se muestre debajo de la barra de estado
            body: Stack(
        children: [
          // Vista previa de la cámara
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: _cameraController != null &&
                      _cameraController!.value.isInitialized
                  ? CameraPreview(_cameraController!)
                  : Container(color: Colors.black),
            ),
          ),

          // Botón de ayuda
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: _buildSvgIcon('assets/icons/info-circle.svg'),
              onPressed: () {},
            ),
          ),

          // Botón de historial
          Positioned(
            bottom: 50,
            left: 30,
            child: IconButton(
              icon: _buildSvgIcon('assets/icons/history.svg'),
              onPressed: () {},
            ),
          ),

          // Botón de seleccionar imagen
          Positioned(
            bottom: 50,
            right: 30,
            child: IconButton(
              icon: _buildSvgIcon('assets/icons/picture-rounded.svg'),
              onPressed: () {},
            ),
          ),

          // Botón de captura
          Positioned(
            bottom: 70,
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/scanner.svg',
                width: 44,
                height: 44,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              onPressed: captureImage,
            ),
          ),
        ],
      ),
    );
  }
}
