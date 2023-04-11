
import 'dart:developer';
import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../helpers/navigation_helpers.dart';
import '../helpers/snackbar.dart';

class STImageProvider extends ChangeNotifier{
  
    File? images;
    bool isloading = false;
    String url = '';

        //! pick image
  Future<File> pickImages() async {
   // List<File> images = [];

    try {
      var files = await FilePicker.platform.pickFiles(
        type: FileType.image,
       //  allowMultiple: true,
      );
      if (files != null && files.files.isNotEmpty) {
        for (int i = 0; i < files.files.length; i++) {
         // images.add(File(files.files[i].path!));
         images = File(files.files[0].path!);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return images!;
  }
     //! upload to cloud
  uploadImageToCloud(context) async {
   try{
     final cloudinary = CloudinaryPublic('diqwddfh0', 'aoqa0dog');
   // List<String> imageUrl = [];
    if (images ==null) {
      return showSnackBar(context, "Image is empty");
    }
  
      isloading = true;
      notifyListeners();

      CloudinaryResponse res =
          await cloudinary.uploadFile(CloudinaryFile.fromFile(
        images!.path,
        folder: "test",
      ));
      
     
      url = res.secureUrl;
      log("image : $url");
      notifyListeners();
      
      showSnackBar(context, "upload success");
      
      
      isloading = false;
      // showModalBottomSheet(context: context, builder:(context) {
      //   return const SizedBox(height: 200,);
      // }, );
      
      notifyListeners();
    
  } catch(e){
    log(e.toString());
    isloading = false;
    showSnackBar(context, "image Size is Too large");
    notifyListeners();
  }
   }
}