import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/sound_service.dart';

class NotificationSoundScreen extends StatefulWidget {
  const NotificationSoundScreen({super.key});

  @override
  State<NotificationSoundScreen> createState() => _NotificationSoundScreenState();
}

class _NotificationSoundScreenState extends State<NotificationSoundScreen> {
  final SoundService _soundService = SoundService.instance;
  String _selectedSound = SoundService.defaultSound;
  String? _customSoundFileName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSelectedSound();
  }

  Future<void> _loadSelectedSound() async {
    final sound = await _soundService.getSelectedSound();
    String? customFileName;
    
    if (sound == SoundService.customSound) {
      final customPath = await _soundService.getCustomSoundPath();
      if (customPath != null) {
        customFileName = customPath.split('/').last;
      }
    }
    
    setState(() {
      _selectedSound = sound;
      _customSoundFileName = customFileName;
      _isLoading = false;
    });
  }

  Future<void> _selectSound(String soundId) async {
    if (soundId == SoundService.customSound) {
      // Pick custom sound file
      await _pickCustomSound();
    } else {
      setState(() => _selectedSound = soundId);
      await _soundService.setSelectedSound(soundId);
      
      // Show feedback that sound was selected
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification sound changed to: ${_getSoundName(soundId)}'),
            duration: const Duration(seconds: 1),
            backgroundColor: const Color(0xFF00BCD4),
          ),
        );
      }
    }
  }

  Future<void> _pickCustomSound() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        
        // Copy file to app's documents directory for persistent access
        final appDir = await getApplicationDocumentsDirectory();
        final soundDir = Directory('${appDir.path}/notification_sounds');
        if (!await soundDir.exists()) {
          await soundDir.create(recursive: true);
        }
        
        final destFile = File('${soundDir.path}/$fileName');
        final sourceFile = File(filePath);
        await sourceFile.copy(destFile.path);
        
        // For Android, we need to use file:// URI
        final androidUri = 'file://${destFile.path}';
        
        setState(() {
          _selectedSound = SoundService.customSound;
          _customSoundFileName = fileName;
        });
        
        await _soundService.setSelectedSound(SoundService.customSound);
        await _soundService.setCustomSoundPath(androidUri);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Custom sound selected: $fileName'),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF00BCD4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting sound: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getSoundName(String soundId) {
    final sounds = SoundService.getAvailableSounds();
    return sounds.firstWhere((s) => s['id'] == soundId)['name'] ?? soundId;
  }

  String _getSoundDescription(String soundId) {
    final sounds = SoundService.getAvailableSounds();
    return sounds.firstWhere((s) => s['id'] == soundId)['description'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final sounds = SoundService.getAvailableSounds();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notification Sound'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: sounds.length,
              itemBuilder: (context, index) {
                final sound = sounds[index];
                final soundId = sound['id']!;
                final isSelected = _selectedSound == soundId;

                final isCustom = soundId == SoundService.customSound;
                final hasCustomFile = isCustom && _customSoundFileName != null;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: isSelected
                      ? const Color(0xFF00BCD4).withValues(alpha: 0.1)
                      : null,
                  child: ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSelected ? const Color(0xFF00BCD4) : null,
                      size: 24,
                    ),
                    title: Text(
                      sound['name']!,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sound['description']!),
                        if (hasCustomFile)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Selected: $_customSoundFileName',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF00BCD4),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: isCustom
                        ? IconButton(
                            icon: Icon(
                              hasCustomFile ? Icons.music_note : Icons.folder_open,
                              color: const Color(0xFF00BCD4),
                            ),
                            onPressed: () => _selectSound(soundId),
                            tooltip: hasCustomFile ? 'Change custom sound' : 'Select custom sound',
                          )
                        : IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            onPressed: () => _selectSound(soundId),
                            tooltip: 'Select sound',
                          ),
                    onTap: () => _selectSound(soundId),
                  ),
                );
              },
            ),
    );
  }
}

