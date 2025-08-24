# QR Code Inventory Management and Item Tracking System - Desktop Application

## **Overview**

The `desktop app` serves as the central system for managing inventory, purchase requests, and issuances, while also generating reports for the supply office. 

---

## **Features**

- **Dashboard**: Overview of inventory and requests summary.  
- **Inventory Management**: Register `supply` (consumables) and `inventory` (often issued or tracked manually, containing different properties e.g., serial no. for simplified tracking and management) items, generate QR codes, update item details, and view records.  
- **Purchase Request Management**: Track officers' requests, validate issuance by comparing items to be issued with the requested item, and streamline report generation by extracting information from purchase requests.  
- **Item Issuance Management**: View and initiate item issuances, and generate issuance reports like `ICS` (Inventory Custodian Slip (items below Php 50,000.00)), `PAR` (Property Acknowledgement Receipt (items above Php 50,000.00)), `RIS` (supply items or consumables), stickers to be attached to the items, and inventory document reports: `Report on the Physical Count of Inventories`, `Report on the Physical Count of Semi-Expendable Property`, and `Report on the Physical Count of Property, Plant, and Equipment`.  
- **Officer Management**: Manage officer records associated with purchase requests or item issuances.  
- **User Management**: Admin-specific tab that allows viewing desktop and mobile users, revoking user access, updating archive statuses, and approving pending mobile user requests.  
- **Archive Management**: Admin-specific tab to store and manage archived data securely.  


---

## **Technologies Used**  
Tools, language, and frameworks used in the project:  
- **Frameworks**: Flutter, Dart Frog 
- **Language**: Dart  
- **Database**: PostgreSQL  
- **Version Control**: Git & GitHub
- **State Management**: BLoC
- **IDE**: Android Studio / VS Code

---

## **Setup & Installation**  
A step-by-step instructions to set up and run the desktop project:

### **Prerequisites**  
- Flutter SDK: [Download Flutter SDK](https://flutter.dev/docs/get-started/install)  
- Dart: Pre-installed with Flutter
- Dart Frog: [Install dart_frog cli](https://dart-frog.dev/)  
- Code Editor: VSCode / Android Studio
- PostgreSQL (latest stable version recommended): [Download PostgreSQL](https://www.postgresql.org/download/)

### **Steps to Run the Project**  
1. Clone this repository:  
   ```bash
   git clone https://github.com/kal-i/qrims_desktop.git
   cd qrims_desktop
   ```  
2. Get Flutter dependencies:  
   ```bash
   flutter pub get
   ```  
3. Navigate to the api directory and get Dart dependencies:  
   ```bash
   cd api
   dart pub get
   ```
4. Create a `.env` file inside the `api` directory and fill in the following:
   ```bash
   HOST = ""
   DATABASE_NAME = ""
   USERNAME = ""
   PASSWOR = ""

   SENDER_EMAIL = ""
   APP_PASSWORD = ""
   ```
   > **Note**:
   >
   > * Database credentials (`HOST`, `DATABASE_NAME`, `USERNAME`, `PASSWORD`) are required to connect the API to PostgreSQL.
   > * Email credentials (`SENDER_EMAIL`, `APP_PASSWORD`) are used for sending OTPs (One-Time Passwords) to users during authentication flows.
   >
   >   * `SENDER_EMAIL` is the Gmail/SMTP sender address.
   >   * `APP_PASSWORD` is a generated app password (not your actual email password).
5. Start the Dart Frog server:  
   * For development (auto-reload on changes):

     ```bash
     dart_frog dev
     ```
   * For production (build and run optimized server):

     ```bash
     dart_frog build
     dart run build/bin/server.dart
     ```
6. Navigate back to the Flutter root project and run the application:  
   ```bash
   cd ..
   flutter run
   ```
   
---

### **How to Set Up the Database**

1. **Create a PostgreSQL Database**
   Open your PostgreSQL client (e.g., pgAdmin, DBeaver, or `psql` CLI) and create a new database:

   ```sql
   CREATE DATABASE qrims;
   ```

   You can use a different name, but make sure it matches the `DATABASE_NAME` you set in your `.env` file.

2. **Configure Database User and Credentials**

   * Create or use an existing PostgreSQL user.
   * Make sure the user has sufficient privileges (create, read, update, delete).
   * Save the username and password; you’ll need them for the `.env` file:

     ```env
     USERNAME = "your_postgres_username"
     PASSWORD = "your_postgres_password"
     HOST = "localhost"   # or your server's IP if deployed
     DATABASE_NAME = "qrims"
     ```

3. **Set Up Tables and Relationships**
   Inside this repo, go to the `database` directory.

   * Open the `qrims.sql` file.
   * Copy all its contents and execute it against the `qrims` database you just created.
   * This will create all the required tables, relationships, and initial setup.

   Example using `psql` CLI:

   ```bash
   psql -U your_postgres_username -d qrims -f database/qrims.sql
   ```

   Or paste the SQL script into your SQL editor (pgAdmin, DBeaver, etc.) and run it.

4. **Verify the Setup**
   After execution, check if the tables were created:

   ```sql
   \c qrims;       -- connect to database
   \dt;            -- list all tables
   ```

   You should see tables like `users`, `sessions`, etc.

---

## Screenshots  
![Desktop Dashboard View](https://raw.githubusercontent.com/kal-i/qrims_desktop/main/assets/images/dashboard-ui.png)

## 📦 This project is part of the **QR Code Inventory Management and Item Tracking System**  
- [QRIMS Mobile](https://github.com/kal-i/qrims_mobile)

## How to Use  
[Download User Manual (PDF)](https://github.com/kal-i/qrims_desktop/raw/main/UserManual.pdf)
