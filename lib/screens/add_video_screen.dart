import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/firestore_service.dart';

class AddVideoScreen extends StatefulWidget {
  const AddVideoScreen({super.key});

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  // Removed URL controllers as we use file pickers now
  final FirestoreService _firestoreService = FirestoreService();
  dynamic _thumbnailFile;
  dynamic _videoFile;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickThumbnail() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _thumbnailFile = bytes;
        });
      } else {
        setState(() {
          _thumbnailFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.isNotEmpty) {
      if (kIsWeb) {
        final bytes = result.files.single.bytes;
        if (bytes != null) {
          setState(() {
            _videoFile = bytes;
          });
        }
      } else {
        final path = result.files.single.path;
        if (path != null) {
          setState(() {
            _videoFile = File(path);
          });
        }
      }
    }
  }

  Future<void> _addVideo() async {
    if (_formKey.currentState!.validate()) {
      try {
        String thumbnailUrl = '';
        String videoUrl = '';

        // Upload thumbnail if file selected
        if (_thumbnailFile != null) {
          thumbnailUrl = await _firestoreService.uploadFile(_thumbnailFile!, 'thumbnails/${DateTime.now().millisecondsSinceEpoch}.jpg');
        }

        // Upload video if file selected
        if (_videoFile != null) {
          videoUrl = await _firestoreService.uploadFile(_videoFile!, 'videos/${DateTime.now().millisecondsSinceEpoch}.mp4');
        }

        await _firestoreService.addVideo(
          _titleController.text,
          _descriptionController.text,
          thumbnailUrl,
          videoUrl,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video added successfully!')),
        );
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _thumbnailFile = null;
          _videoFile = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding video: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Video'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickThumbnail,
                  child: const Text('Pick Thumbnail Image'),
                ),
                if (_thumbnailFile != null) Text('Selected: ${kIsWeb ? 'Image selected' : _thumbnailFile!.path.split('/').last}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickVideo,
                  child: const Text('Pick Video File'),
                ),
                if (_videoFile != null) Text('Selected: ${kIsWeb ? 'Video selected' : _videoFile!.path.split('/').last}'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _addVideo,
                  child: const Text('Add Video'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
