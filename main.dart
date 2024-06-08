import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  bool _loading = true;
  final ImagePicker picker = ImagePicker();
  File? image;
  List? output;

  chooseImage() async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        image = File(file.path);
      });
    }
    if (image != null) {
      classifyImage(image!);
    }
  }

  captureImage() async {
    final XFile? file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      setState(() {
        image = File(file.path);
      });
    }
    if (image != null) {
      classifyImage(image!);
    }
  }

  classifyImage(File img) async {
    var result =
        await Tflite.runModelOnImage(path: img.path, numResults: 2, threshold: 0.5, imageMean: 127.5, imageStd: 127.5);
    setState(() {
      output = result;
      print(output);
      _loading = false;
    });
  }

  loadModel() async {
    await Tflite.loadModel(model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A P P   B A R
      appBar: AppBar(
        title: Text(
          "Plant Disease Classification",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),

      // B O D Y
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (image == null) Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Capture / Upload Image Of Diseased Plant',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Text(
                    "Please upload image of only those \ndiseased plants the model is trained on",
                    style: TextStyle(color: Colors.green.shade400),
                    textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 30),
            Center(
              child: _loading
                  ? Container()
                  : SizedBox(
                      child: Column(children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade400, width: 4),
                            boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black54, offset: Offset(3, 3))],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(image!),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        output != null
                            ? Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade400,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${output![0]['label']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 50,
                        ),
                      ]),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (image != null) FloatingActionButton(
            onPressed: () => setState(() {
              image = null;
              _loading = true;
            }),
            backgroundColor: Colors.green.shade400,
            child: Icon(Icons.delete, color: Colors.white),
            tooltip: "Deselect Image",
          ),
          SizedBox(width: 20),
          FloatingActionButton(
            onPressed: captureImage,
            backgroundColor: Colors.green.shade400,
            child: Icon(Icons.camera_alt, color: Colors.white),
            tooltip: "Capture Image",
          ),
          SizedBox(width: 20),
          FloatingActionButton(
            onPressed: chooseImage,
            backgroundColor: Colors.green.shade400,
            child: Icon(Icons.photo_library, color: Colors.white),
            tooltip: "Pick Image",
          ),
          SizedBox(width: 20),
        ],
      ),
    );
  }
}