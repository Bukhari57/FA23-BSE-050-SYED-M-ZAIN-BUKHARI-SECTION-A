# Offline Mode Features

## 1. SQLite Storage

*   **Local Database:** Use the `sqflite` package to create a local SQLite database on the device.
*   **Data Models:** Replicate the data models (Product, Sale, Customer, etc.) as tables in the local database.
*   **DAO (Data Access Objects):** Create DAO classes to abstract the database operations (CRUD - Create, Read, Update, Delete) for each table.

## 2. Offline Sales

*   **Queue Sales:** When the device is offline, new sales transactions will be saved to a "pending sales" table in the local SQLite database.
*   **Local Stock Updates:** When a sale is made offline, the local product stock levels will be updated immediately.
*   **Receipt Generation:** Receipts for offline sales can be generated and printed/shared from the locally stored data.

## 3. Conflict Handling & Synchronization

*   **Sync Manager:** Create a `SyncManager` class responsible for synchronizing data between the local SQLite database and the remote backend (e.g., Firebase) when the device comes back online.
*   **Conflict Resolution Strategy:**
    *   **Timestamp-based:** The record with the latest timestamp wins. This is a simple strategy but might not be suitable for all cases.
    *   **First-in, First-out (FIFO):** Process the offline transactions in the order they were created.
    *   **Manual Resolution:** Flag conflicting transactions for manual review and resolution by the user.
*   **Sync Status:** Provide visual feedback to the user about the sync status (e.g., "All changes saved," "Syncing," "Offline").
*   **Periodic Sync:** Implement a mechanism to periodically check for an internet connection and trigger the sync process.
