# Backup & Restore Features

## 1. Manual Backup

*   **Create Backup:** Allow the user to manually trigger a backup of the local SQLite database.
*   **Export Backup File:** Generate a `.db` file of the SQLite database.
*   **Save Location:** Let the user choose where to save the backup file on their device.

## 2. Automatic Backup

*   **Scheduled Backups:** Automatically create backups at regular intervals (e.g., daily).
*   **Background Service:** Use a background service to perform backups without interrupting the user.

## 3. Google Drive Integration

*   **Authentication:** Integrate Google Sign-In to allow users to connect their Google Drive.
*   **Upload to Drive:** Upload backup files to a dedicated app folder in the user's Google Drive.
*   **List Backups:** Display a list of available backups from Google Drive.
*   **Restore from Drive:** Allow users to select a backup from Google Drive to restore.

## 4. Manual Restore

*   **Import Backup File:** Allow the user to select a backup file from their device's storage.
*   **Restore Process:** Replace the current database with the selected backup, providing clear warnings to the user.
