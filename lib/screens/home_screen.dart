// ignore_for_file: empty_statements

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as Path;



class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePagestate createState() => _ProfilePagestate(imageUrl: '');
}

class _ProfilePagestate extends State<ProfilePage> {
   String imageUrl;
   _ProfilePagestate({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: Center(
      child: Card(
          elevation: 50,
          shadowColor: const Color.fromARGB(255, 127, 195, 228),
          color: const Color.fromARGB(209, 121, 175, 205),
          child: SizedBox(
            width: 300,
            height: 500,
            child: Padding(
              padding: const EdgeInsets.all(20.0),

              child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                    'Your Info',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ), //Textstyle
                  ), //Text
                  const SizedBox(
                    height: 10,
                  ), //SizedBox
          Container(
           margin: const EdgeInsets.only(top:30),
           padding: const EdgeInsets.only(left: 20),
           child: FlatButton(
           child: const Text("Upload Image"),
           color: Colors.blueGrey,
           textColor: Colors.white,
            onPressed: (){
            uploadImage();
           Image.network(
              imageUrl,
              width: 200,
              height: 100,);
                              },
                            ),
                          ),
    

              ]))))));
    
  }
  uploadImage() async {
    final _storage = FirebaseStorage.instance;
    final _picker = ImagePicker();
    PickedFile image;
    File _file = File("zz");

    var permissionStatus;


    //Check Permissions
    if(!kIsWeb){
      await Permission.photos.request();
   permissionStatus = await Permission.photos.status.isGranted;
    }else{
      permissionStatus=true;
    }
    
    

    if (!kIsWeb && permissionStatus){
      //Select Image
      // ignore: deprecated_member_use
      image = (await _picker.getImage(source: ImageSource.gallery))!;
      var file = File(image.path);

      if (image != null){
        //Upload to Firebase
        var onComplete;
        var snapshot = await _storage.ref()
        .child('folderName/imageName')
        .putFile(file);

        var downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          imageUrl = downloadUrl;
        });
      } else {
        print('No Path Received');
      }

    }// WEB
    else if (kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();

        
      

      Reference _reference = await _storage.ref()
        .child('images/${Path.basename(image.path)}');
    await _reference
        .putData(
      await image.readAsBytes(),
      SettableMetadata(contentType: 'image/jpeg'),
    )
        .whenComplete(() async {
      await _reference.getDownloadURL().then((value) {
        setState(() {
           imageUrl = value;
            print(imageUrl);
        });
       
      });
    });
      }
          //web code to be written

           /* if (image != null){
               var file = File(image.path);
        //Upload to Firebase
        var onComplete;
        var snapshot = await _storage.ref()
        .child('folderName/imageName')
        .putFile(file);

        var downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          imageUrl = downloadUrl;
        });
      } else {
        print('No Path Received');
      }*/
      } else {
      print('Grant Permissions and try again');
    }

    print(imageUrl);
  }

}