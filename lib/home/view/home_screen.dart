import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text(
            'ScreenShot Package',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  buildImage(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      await controller.capture().then(
                        (bytes) {
                          if (bytes != null) {
                            saveImage(bytes);
                            saveAndShare(bytes);
                          }
                        },
                      ).catchError(
                        (onError) {
                          debugPrint(onError);
                        },
                      );
                    },
                    child: const Text('Take Screenshot'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await controller.captureFromWidget(buildImage()).then(
                        (bytes) {
                          saveImage(bytes);
                          saveAndShare(bytes);
                        },
                      ).catchError(
                        (onError) {
                          debugPrint(onError);
                        },
                      );
                    },
                    child: const Text('Capture Widget'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final time = DateTime.now().toIso8601String().replaceAll('.', '-').replaceAll(':', '-');

  Future<void> saveAndShare(Uint8List bytes) async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory() // Android
        : await getApplicationDocumentsDirectory(); // iOS
    final image = File('${directory!.path}/$time.png');
    image.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(image.path)]);
  }

  Future<void> saveImage(Uint8List bytes) async {
    final name = 'screenshot_$time';
    await Permission.storage.request();
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    debugPrint('result: $result');
  }

  Widget buildImage() {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 600,
          child: Image.asset(
            'assets/images/exam_chuu.jpeg',
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/exam_food.png',
              width: 30,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          child: Image.asset(
            'assets/images/exam_banner.png',
          ),
        ),
      ],
    );
  }
}
