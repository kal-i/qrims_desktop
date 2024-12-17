# QR-Based Inventory Management System (QRIMS)

## **Description**

The QR-Based Inventory Management System is comprised of two systems: **desktop** and **mobile applications**. The primary objective of these systems is to address inefficiencies in tracking stocks and generating reports, as well as ensuring the security of records faced by the **DepEd Legazpi Division Supply Office**.

---

## **Features**

### **Desktop Application**

- [x] **Dashboard**: Generate QR codes for each item to simplify tracking.
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
Specify the tools, languages, and frameworks used in the project. For example:  
- **Framework**: Flutter  
- **Language**: Dart  
- **Database**: SQLite / Firebase / PostgreSQL  
- **Version Control**: Git  
- **Others**: State Management (e.g., Provider, BLoC), APIs (if applicable)

---

## **Setup & Installation**  
Provide step-by-step instructions to set up and run your project. For example:

### **Prerequisites**  
- Flutter SDK: [Download Flutter SDK](https://flutter.dev/docs/get-started/install)  
- Dart: Pre-installed with Flutter  
- Code Editor: VSCode / Android Studio  

### **Steps to Run the Project**  
1. Clone this repository:  
   ```bash
   git clone https://github.com/yourusername/your-capstone-project.git
   cd your-capstone-project
   ```  
2. Get Flutter dependencies:  
   ```bash
   flutter pub get
   ```  
3. Run the project:  
   ```bash
   flutter run
   ```  
4. For desktop builds, enable desktop support:  
   ```bash
   flutter config --enable-macos-desktop
   flutter run -d macos
   ```

---

## **Screenshots**  
Add visual screenshots of your app to give users an idea of the interface. You can embed images like this:  
```markdown
![Dashboard Screenshot](assets/screenshots/dashboard.png)
```

---

## **How to Use**  
Explain how the app works. If applicable, add:  
- Step-by-step usage instructions.  
- Video demo or GIF animations.

---

## **Future Improvements**  
List features you plan to add later. For example:  
- Payroll integration with banking APIs.  
- Employee attendance tracking.  
- Notifications for payroll reminders.  

---

## **Contributing** *(Optional)*  
If you'd like others to contribute:  
1. Fork the project.  
2. Create a new branch:  
   ```bash
   git checkout -b new-feature
   ```  
3. Commit changes and push:  
   ```bash
   git commit -m "Add new feature"
   git push origin new-feature
   ```  
4. Create a pull request.

---

## **License**  
State the license for your project. Common licenses include MIT, GPL, or Apache.  
Example:  
"This project is licensed under the MIT License. See `LICENSE` for more details."

---

## Screenshots  
![Dashboard](assets/screenshots/dashboard.png)  

## How to Use  
[Download User Manual (PDF)](https://link-to-your-pdf-file.com)

## License  
This project is licensed under the MIT License.  
