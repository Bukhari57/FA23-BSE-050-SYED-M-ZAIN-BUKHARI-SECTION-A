import 'package:flutter/material.dart';
import 'sync_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool isSyncing = false;
  String lastBackupDate = "January 04, 2026";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF004e92),
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Data Protection",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 1. Cloud Banner
          _buildCloudBanner(),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Service Status",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Modern Status Card
                  _buildModernStatusCard(),

                  const SizedBox(height: 24),
                  const Text(
                    "Cloud Sync ensures your business data is never lost. You can restore your data on any new device using your Google account.",
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(),

                  // 3. Action Buttons
                  _buildActionButtons(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF004e92),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_done_outlined,
            size: 60,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(height: 15),
          const Text(
            "Google Drive Sync",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Linked to your business account",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: const Icon(Icons.storage, color: Color(0xFF004e92)),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Last Sync Date",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                lastBackupDate,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004e92),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: isSyncing ? null : () => _startBackup(),
            icon: isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.upload_rounded, color: Colors.white),
            label: Text(
              isSyncing ? "SYNCING..." : "BACKUP TO CLOUD",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF004e92), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => _startRestore(),
            icon: const Icon(Icons.download_rounded, color: Color(0xFF004e92)),
            label: const Text(
              "RESTORE DATA",
              style: TextStyle(
                color: Color(0xFF004e92),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Logic remains the same, UI updated to support context-safe messages
  void _startBackup() async {
    setState(() => isSyncing = true);
    try {
      await SyncService().fullSync();
      setState(() {
        isSyncing = false;
        lastBackupDate = "Just now";
      });
      _showSnack("Backup Successful", Colors.green);
    } catch (e) {
      setState(() => isSyncing = false);
      _showSnack("Sync Failed: $e", Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startRestore() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Restore?"),
        content: const Text(
          "This replaces all local data with your Cloud Backup. This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isSyncing = true);
              try {
                await SyncService().restoreEverything();
                setState(() => isSyncing = false);
                _showSnack("Restore Complete!", Colors.green);
              } catch (e) {
                setState(() => isSyncing = false);
                _showSnack("Error: $e", Colors.red);
              }
            },
            child: const Text(
              "RESTORE NOW",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
