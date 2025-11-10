import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/firestore_service.dart';
import '../models/word.dart';

class EditVideoScreen extends StatefulWidget {
  const EditVideoScreen({super.key});

  @override
  State<EditVideoScreen> createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends State<EditVideoScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Videos'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: StreamBuilder<List<VideoData>>(
        stream: _firestoreService.getVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final videos = snapshot.data ?? [];
          if (videos.isEmpty) {
            return const Center(child: Text('No videos to edit'));
          }
          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final videoData = videos[index];
              return ListTile(
                leading: const Icon(Icons.video_library, color: Colors.blue),
                title: Text(videoData.title),
                subtitle: Text(videoData.description),
                onTap: () => _showEditDialog(videoData),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(VideoData videoData) {
    final TextEditingController _titleController = TextEditingController(text: videoData.title);
    final TextEditingController _descriptionController = TextEditingController(text: videoData.description);
    dynamic _thumbnailFile;
    dynamic _videoFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Video "${videoData.title}"'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
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
                  },
                  child: const Text('Pick New Thumbnail Image'),
                ),
                if (_thumbnailFile != null) Text('Selected: ${kIsWeb ? 'Image selected' : _thumbnailFile!.path.split('/').last}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
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
                  },
                  child: const Text('Pick New Video File'),
                ),
                if (_videoFile != null) Text('Selected: ${kIsWeb ? 'Video selected' : _videoFile!.path.split('/').last}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  String thumbnailUrl = videoData.thumbnailUrl;
                  String videoUrl = videoData.videoUrl;

                  // Upload new thumbnail if selected
                  if (_thumbnailFile != null) {
                    thumbnailUrl = await _firestoreService.uploadFile(_thumbnailFile!, 'thumbnails/${DateTime.now().millisecondsSinceEpoch}.jpg');
                  }

                  // Upload new video if selected
                  if (_videoFile != null) {
                    videoUrl = await _firestoreService.uploadFile(_videoFile!, 'videos/${DateTime.now().millisecondsSinceEpoch}.mp4');
                  }

                  await _firestoreService.updateVideo(
                    videoData.id,
                    _titleController.text,
                    _descriptionController.text,
                    thumbnailUrl,
                    videoUrl,
                  );

                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Video updated successfully!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating video: $e')),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
