import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:sizer/sizer.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {

  final picker = ImagePicker();
  File? selectedImage;
  String? value;

  final formKey = GlobalKey<FormState>();

  TextEditingController itemPriceController = TextEditingController();
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemDetailController = TextEditingController();

  List<String> fooditems = ["Burger","Pizza","Soup","Wings","shakes"];

  bool isLoad = false;
  late String downloadUrl;// For tracking selected category
  // List of category names
  final spinkit = const SpinKitPulsingGrid(
    color: Colors.white,
    size: 30.0,
  );

  Future getImage() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        selectedImage = File(image.path);
      }else{
        const Center(
          child: Text("No Image Selected"),
        );
      }
    });
  }

  Future<void> uploadCategoryData() async {
    if (selectedImage == null ||
        itemNameController.text.isEmpty ||
        itemPriceController.text.isEmpty ||
        itemDetailController.text.isEmpty ||
        value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select an image"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoad = true;
    });

    try {
      // Firebase Storage Initialization
      FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: "gs://foodiesapp-6068c.firebasestorage.app");
      Reference storageRef = storage.ref();

      // Create a unique file reference
      String fileName = "category_${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference fileRef = storageRef.child("category_images/$fileName");

      // Upload the file
      UploadTask uploadTask = fileRef.putFile(selectedImage!);

      // Wait for upload to complete and fetch the download URL
      await uploadTask.whenComplete(() {});
      downloadUrl = await fileRef.getDownloadURL();
      if (kDebugMode) {
        print("File uploaded successfully. URL: $downloadUrl");
      }

      // Save the data to Firestore
      await FirebaseFirestore.instance.collection('categoryList').add({
        'itemName': itemNameController.text.trim(),
        'itemPrice': itemPriceController.text.trim(),
        'itemDetail': itemDetailController.text.trim(),
        'categoryFood': value,
        'imageUrl': downloadUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Category added successfully",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      // Clear fields after successful upload
      setState(() {
        isLoad = false;
        itemPriceController.clear();
        itemDetailController.clear();
        itemNameController.clear();
        selectedImage = null;
        value = null;
      });
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add category: $e"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoad = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 9.h,
        backgroundColor: Colors.black,
        title: Text(
          "Add Product",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Selector
            Padding(
              padding: EdgeInsets.only(left: 2.w),
              child: Text(
                "Add item picture",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
              ),
            ),
            SizedBox(height: 3.h),
            Center(
              child: GestureDetector(
                onTap: getImage,
                child: Container(
                  width: 40.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: selectedImage == null
                      ? const Icon(Icons.camera_alt)
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),

            // Item Name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: _buildTextField("Add item Name", "item Name", itemNameController, TextInputType.text),
            ),
            SizedBox(height: 3.h),

            // Item Price
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: _buildTextField("Add item Price", "item Price", itemPriceController, TextInputType.number),
            ),
            SizedBox(height: 3.h),

            // Item Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: _buildTextField(
                "Add item Description",
                "item Description",
                itemDetailController,
                TextInputType.text,
                maxLines: 6,
              ),
            ),
            SizedBox(height: 3.h),

            // Category Selector
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  items: fooditems
                      .map((item) => DropdownMenuItem(
                    child: Text(item),
                    value: item,
                  ))
                      .toList(),
                  onChanged: (String? value) {
                    setState(() {
                      this.value = value;
                    });
                  },
                  value: value,
                  hint: Text("Select Category"),
                ),
              ),
            ),
            SizedBox(height: 4.h),

            // Add Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: Size(40.w, 8.h),
                ),
                onPressed: uploadCategoryData,
                child: isLoad ? spinkit : Text("Add", style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, TextInputType keyboardType, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp)),
        SizedBox(height: 1.h),
        Container(
          width: MediaQuery.of(context).size.width,
          height: maxLines > 1 ? 12.h : 7.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
              keyboardType: keyboardType,
              controller: controller,
              maxLines: maxLines,
            ),
          ),
        ),
      ],
    );
  }
}
