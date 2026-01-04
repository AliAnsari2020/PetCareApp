import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class ManagePetListings extends StatefulWidget {
  const ManagePetListings({Key? key}) : super(key: key);

  @override
  _ManagePetListingsState createState() => _ManagePetListingsState();
}

class _ManagePetListingsState extends State<ManagePetListings> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String? petId;
  String? name,
      type,
      age,
      breed,
      gender,
      healthStatus,
      vaccination,
      description;
  File? imageFile;
  Uint8List? webImage;
  bool isLoading = false;

  final String cloudName = "dlbnwaj7c";
  final String uploadPreset = "PawfectCare";

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          webImage = bytes;
          imageFile = null;
        });
      } else {
        setState(() {
          imageFile = File(pickedFile.path);
          webImage = null;
        });
      }
    }
  }

  Future<String?> uploadImage() async {
    try {
      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );
      final request = http.MultipartRequest("POST", url);
      request.fields["upload_preset"] = uploadPreset;

      if (kIsWeb && webImage != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            "file",
            webImage!,
            filename: "upload.jpg",
          ),
        );
      } else if (!kIsWeb && imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath("file", imageFile!.path),
        );
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        final resData = await response.stream.bytesToString();
        return jsonDecode(resData)["secure_url"];
      }
    } catch (e) {
      debugPrint("Image Upload Error: $e");
    }
    return null;
  }

  Future<void> savePet() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isLoading = true);

    String? imageUrl;
    if (webImage != null || imageFile != null) {
      imageUrl = await uploadImage();
    }

    if (petId == null) {
      // Add new pet
      await _firestore.collection("pets").add({
        "name": name,
        "type": type,
        "age": age,
        "breed": breed,
        "gender": gender,
        "healthStatus": healthStatus,
        "vaccination": vaccination,
        "description": description,
        "image": imageUrl ?? "",
        "status": "Available",
        "createdAt": FieldValue.serverTimestamp(),
      });
    } else {
      // Update existing pet
      await _firestore.collection("pets").doc(petId).update({
        "name": name,
        "type": type,
        "age": age,
        "breed": breed,
        "gender": gender,
        "healthStatus": healthStatus,
        "vaccination": vaccination,
        "description": description,
        if (imageUrl != null) "image": imageUrl,
      });
    }

    setState(() {
      isLoading = false;
      petId = null;
      imageFile = null;
      webImage = null;
    });
    Navigator.pop(context);
  }

  Future<void> deletePet(String id) async {
    await _firestore.collection("pets").doc(id).delete();
  }

  void showPetForm([DocumentSnapshot? doc]) {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      petId = doc.id;
      name = data["name"] ?? "";
      type = data["type"] ?? "";
      age = data["age"] ?? "";
      breed = data["breed"] ?? "";
      gender = data["gender"] ?? "";
      healthStatus = data["healthStatus"] ?? "";
      vaccination = data["vaccination"] ?? "";
      description = data["description"] ?? "";
    } else {
      petId = null;
      name = type = age = breed = gender = healthStatus = vaccination =
          description = null;
      webImage = null;
      imageFile = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  petId == null ? "Add Pet" : "Edit Pet",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: "Name"),
                  onSaved: (v) => name = v,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  initialValue: type,
                  decoration: const InputDecoration(
                    labelText: "Type (Dog/Cat/Rabbit)",
                  ),
                  onSaved: (v) => type = v,
                ),
                TextFormField(
                  initialValue: age,
                  decoration: const InputDecoration(labelText: "Age"),
                  onSaved: (v) => age = v,
                ),
                TextFormField(
                  initialValue: gender,
                  decoration: const InputDecoration(labelText: "Gender"),
                  onSaved: (v) => gender = v,
                ),
                TextFormField(
                  initialValue: healthStatus,
                  decoration: const InputDecoration(labelText: "Health Status"),
                  onSaved: (v) => healthStatus = v,
                ),
                TextFormField(
                  initialValue: breed,
                  decoration: const InputDecoration(labelText: "Breed"),
                  onSaved: (v) => breed = v,
                ),
                TextFormField(
                  initialValue: vaccination,
                  decoration: const InputDecoration(labelText: "Vaccination"),
                  onSaved: (v) => vaccination = v,
                ),
                TextFormField(
                  initialValue: description,
                  decoration: const InputDecoration(labelText: "Description"),
                  onSaved: (v) => description = v,
                ),
                const SizedBox(height: 10),
                if (webImage != null)
                  Image.memory(webImage!, height: 120, fit: BoxFit.cover)
                else if (imageFile != null)
                  Image.file(imageFile!, height: 120, fit: BoxFit.cover)
                else if (petId != null &&
                    (doc?.get("image") ?? "").toString().isNotEmpty)
                  Image.network(
                    doc?.get("image"),
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                TextButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Pick Image"),
                ),
                const SizedBox(height: 10),
                isLoading
                    ? Lottie.asset("images/Trailloading.json", height: 80)
                    : ElevatedButton(
                        onPressed: savePet,
                        child: Text(petId == null ? "Add Pet" : "Update Pet"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void openPetDetails(DocumentSnapshot pet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PetDetailsPage(
          pet: pet,
          onEdit: () => showPetForm(pet),
          onDelete: () => deletePet(pet.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Pet Listings"),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showPetForm(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("pets")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Lottie.asset("images/Trailloading.json", height: 100),
            );
          }

          final pets = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              final data = pet.data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () => openPetDetails(pet),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: (data["image"] ?? "").toString().isNotEmpty
                            ? ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: Image.network(
                                  data["image"],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(color: Colors.grey[200]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              data["name"] ?? "No Name",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${data["type"] ?? "Unknown"}, ${data["age"] ?? "N/A"}",
                            ),
                            Text("Status: ${data["status"] ?? "N/A"}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PetDetailsPage extends StatelessWidget {
  final DocumentSnapshot pet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PetDetailsPage({
    Key? key,
    required this.pet,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = pet.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text(data["name"] ?? "Pet")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            (data["image"] ?? "").toString().isNotEmpty
                ? Image.network(
                    data["image"],
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  )
                : Container(height: 250, color: Colors.grey[300]),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data["name"] ?? "No Name",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Type: ${data["type"] ?? "Not set"}"),
                  Text("Breed: ${data["breed"] ?? "Not set"}"),
                  Text("Age: ${data["age"] ?? "N/A"}"),
                  Text("Gender: ${data["gender"] ?? "Not set"}"),
                  Text("Health Status: ${data["healthStatus"] ?? "Not set"}"),
                  Text("Vaccination: ${data["vaccination"] ?? "Not set"}"),
                  const SizedBox(height: 10),
                  Text(
                    "Description:",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(data["description"] ?? ""),
                  const SizedBox(height: 20),
                  Text(
                    "Status: ${data["status"] ?? "N/A"}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: (data["status"] ?? "Available") == "Available"
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit),
                        label: const Text("Edit"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          onDelete();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        label: const Text("Delete"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}