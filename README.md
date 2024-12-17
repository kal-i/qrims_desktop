# QR-Based Inventory Management System (QRIMS)

## **Description**

The QR-Based Inventory Management System is comprised of two systems: **desktop** and **mobile applications**. The primary objective of these systems is to address inefficiencies in tracking stocks and generating reports, as well as ensuring the security of records faced by the **DepEd Legazpi Division Supply Office**.

---

## **Features**

### **Desktop Application**

- [x] **Dashboard**: Overview of inventory and requests summary.
- [x] **Inventory Management**: Generate QR codes for each item to simplify tracking.
- [x] **Purchase Request Management**: Track requests from officers and streamline report generation by extracting information from purchase requests. 
- [x] **Item Issuance Management**: View and initiate item issuances, and generate issuance reports like **ICS**, **PAR**, **RIS**, and stickers to be attached to the items.
- [x] **Officer Management**: Manage officer records associated with purchase requests or item issuances.
- [x] **User Management**: Admin-specific tab that allows viewing desktop and mobile users, revoking user access, updating archive statuses, and approving pending mobile user requests.
- [x] **Archive Management**: Admin-specific tab to store and manage archived data securely.

### **Mobile Application**

- [x] **Purchase Request Overview**: View summary information of purchase requests, including ongoing and historical records.
- [x] **Notifications**: Receive notifications when the supply custodian registers, issues, or cancels a user's request.
- [x] **QR Code Scanning for Issuance**: Scan QR codes attached to issuance documents to view and receive items. This action notifies the supply custodian and updates the issuance's received status.
- [x] **QR Code Scanning for Items**: Scan QR codes attached to items to view detailed information about the item.

---

## **Technologies Used**  
Tools, language, and frameworks used in the project:  
- **Framework**: Flutter / Dart Frog 
- **Language**: Dart  
- **Database**: PostgreSQL  
- **Version Control**: Git  
- **State Management**: BLoC

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
![Desktop Dashboard View](https://raw.githubusercontent.com/kal-i/qrims_desktop/main/assets/images/dashboard.png)
![Mobile Home View](https://raw.githubusercontent.com/kal-i/qrims_desktop/main/assets/images/home.jpg) 

## How to Use  
[Download User Manual (PDF)](https://github.com/kal-i/qrims_desktop/raw/main/UserManual.pdf)
