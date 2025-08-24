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
- Code Editor: VSCode / Android Studio  

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
3. Navigate to the api directory:  
   ```bash
   cd api
   ```  
4. Start the Dart Frog server:  
   ```bash
   dart_frog dev
   ```
5. Run the project:  
   ```bash
   flutter run
   ```
   
---

### **How to Set Up the Local Server for Mobile App**

1. **Find Your Computer's IP Address**  
   - Open the **Command Prompt** (press `Win + R`, type `cmd`, and press Enter).
   - Run this command:  
     ```bash
     ipconfig
     ```
   - Look for **IPv4 Address** (e.g., `192.168.1.22`).

2. **Update `.env` File**  
   - Open the `.env` file in your project.
   - Add or update the following line with your IP address:
     ```dotenv
     IPv4_ADDRESS = '192.168.1.22'
     ```
   - Use this IP in your base URL:
     ```dotenv
     BASE_URL = 'http://${IPv4_ADDRESS}:your-port-here'
     ```

3. **Ensure Devices Are on the Same Network**  
   - Make sure your computer (server) and mobile device are connected to the **same Wi-Fi network**.

4. **Run the Server and Mobile App**  
   - Run the mobile app:
     ```bash
     flutter run
     ```

---

## Screenshots  
![Desktop Dashboard View](https://raw.githubusercontent.com/kal-i/qrims_desktop/main/assets/images/dashboard-ui.png)
![Mobile Home View](https://raw.githubusercontent.com/kal-i/qrims_desktop/main/assets/images/home.jpg) 

📦 This project is part of the **QR Code Inventory Management and Item Tracking System**  
- [QRIMS Mobile](https://github.com/kal-i/qrims_mobile)

## How to Use  
[Download User Manual (PDF)](https://github.com/kal-i/qrims_desktop/raw/main/UserManual.pdf)
