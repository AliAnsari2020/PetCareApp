import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:userpanel/shelter/CloudinaryService.dart';

class SuccessStories extends StatefulWidget {
  const SuccessStories({Key? key}) : super(key: key);

  @override
  State<SuccessStories> createState() => _SuccessStoriesState();
}

class _SuccessStoriesState extends State<SuccessStories> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  File? imageFile;
  Uint8List? webImage;

  // ✅ Add or Update Story
  Future<void> _openStoryDialog({
    String? docId,
    Map<String, dynamic>? oldData,
  }) async {
    String adopterName = oldData?["adopterName"] ?? "";
    String story = oldData?["story"] ?? "";
    String? imageUrl = oldData?["imageUrl"];
    bool loading = false;

    imageFile = null;
    webImage = null;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                docId == null ? "Add Success Story" : "Update Success Story",
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: TextEditingController(text: adopterName),
                      decoration: const InputDecoration(
                        labelText: "Adopter Name",
                      ),
                      onChanged: (val) => adopterName = val,
                    ),
                    TextField(
                      controller: TextEditingController(text: story),
                      decoration: const InputDecoration(labelText: "Story"),
                      maxLines: 3,
                      onChanged: (val) => story = val,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text("Upload Pet Image"),
                      onPressed: () async {
                        final picked = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );

                        if (picked != null) {
                          if (kIsWeb) {
                            final bytes = await picked.readAsBytes();
                            setStateSB(() {
                              webImage = bytes;
                              imageFile = null;
                            });
                          } else {
                            setStateSB(() {
                              imageFile = File(picked.path);
                              webImage = null;
                            });
                          }
                        }
                      },
                    ),
                    if (kIsWeb && webImage != null)
                      Image.memory(webImage!, height: 80, fit: BoxFit.cover),
                    if (!kIsWeb && imageFile != null)
                      Image.file(imageFile!, height: 80, fit: BoxFit.cover),
                    if (imageUrl != null &&
                        webImage == null &&
                        imageFile == null)
                      Image.network(
                        imageUrl!, // ✅ non-null assertion
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                      ),
                    if (loading)
                      Lottie.asset("images/Trailloading.json", height: 60),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (adopterName.isEmpty || story.isEmpty) return;

                    setStateSB(() => loading = true);

                    // ✅ Upload new image if selected
                    if (kIsWeb && webImage != null) {
                      imageUrl = await CloudinaryService.uploadBytes(webImage!);
                    } else if (imageFile != null) {
                      imageUrl = await CloudinaryService.uploadImage(
                        imageFile!,
                      );
                    }

                    final data = {
                      "adopterName": adopterName,
                      "story": story,
                      "imageUrl": imageUrl,
                      "createdAt": FieldValue.serverTimestamp(),
                    };

                    if (docId == null) {
                      // Add new
                      await _firestore.collection("success_stories").add(data);
                    } else {
                      // Update existing
                      await _firestore
                          .collection("success_stories")
                          .doc(docId)
                          .update(data);
                    }

                    Navigator.pop(context);
                  },
                  child: Text(docId == null ? "Save" : "Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ✅ Delete Story
  Future<void> _deleteStory(String docId) async {
    final confirm = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Story"),
            content: const Text("Are you sure you want to delete this story?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _firestore.collection("success_stories").doc(docId).delete();
    }
  }

  // ✅ Show Full Story
  void _showStoryDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Image.network(
                    data["imageUrl"],
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data["adopterName"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Text(data["story"], style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Success Stories"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openStoryDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection("success_stories")
                .orderBy("createdAt", descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Lottie.asset("images/Trailloading.json", height: 120),
            );
          }

          final stories = snapshot.data!.docs;
          if (stories.isEmpty)
            return const Center(child: Text("No success stories yet."));

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final doc = stories[index];
              final data = doc.data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: () => _showStoryDialog(data),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              data["imageUrl"],
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data["adopterName"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  data["story"].length > 50
                                      ? "${data["story"].substring(0, 50)}..."
                                      : data["story"],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ✅ Edit/Delete buttons
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                              size: 20,
                            ),
                            onPressed:
                                () => _openStoryDialog(
                                  docId: doc.id,
                                  oldData: data,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () => _deleteStory(doc.id),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
