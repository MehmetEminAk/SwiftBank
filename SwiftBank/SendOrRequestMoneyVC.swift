//
//  SendOrRequestMoneyVC.swift
//  SwiftBank
//
//  Created by Macbook Air on 22.02.2023.
//

import UIKit
import Contacts
import FirebaseFirestore




class SendOrRequestMoneyVC: UINavigationController {
    
    private var store : CNContactStore!
    
    
    private var appUsersFromContacts : [AppUsersFromContacts] = []
    
    private let usersTable : UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let segmentedControl : UISegmentedControl = {
        let control = UISegmentedControl(items: [NSLocalizedString("With Phone Number", comment: "For segmented control"),NSLocalizedString("With IBAN", comment: "For segmented control")])
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private var contentView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var type : SendOrRequest!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationBar.backgroundColor = .green
        configureNavBar()
        view.addSubViews([segmentedControl,contentView])
        phoneNumberView()
       configureSegmentedControl()
        requestForContacts()
        configureTableView()
        
    }
    
    override func viewDidLayoutSubviews() {
        segmentedControlLayout()
        viewControlLayout()
        
    }
    
}


// This extension is about navigation bar configuration
extension SendOrRequestMoneyVC {
    
    func configureNavBar(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "x.circle"), style: .plain, target: self, action: #selector(dismissVC))
        navigationController?.navigationBar.topItem?.largeTitleDisplayMode = .always
        if type == .request {
            navigationItem.title = NSLocalizedString("Request Money", comment: "request money nav bar title")
        }else {
            navigationItem.title = NSLocalizedString("Send Money", comment: "request money nav bar title")
        }
    }
    
    
    
    @objc func dismissVC(){
        self.dismiss(animated: true)
    }
    
    
}

// This extension is about segmented control configuration
extension SendOrRequestMoneyVC {
     
    func configureSegmentedControl(){
        
        segmentedControl.addTarget(self, action: #selector(switchView), for: .valueChanged)
    
    }
    
    @objc func switchView(){
        if segmentedControl.selectedSegmentIndex == 0 {
            phoneNumberView()
        }else {
            IBANView()
        }
    }
    
    func segmentedControlLayout(){
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            segmentedControl.leftAnchor.constraint(equalTo: view.leftAnchor),
            segmentedControl.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        ])
    }
    
}

//This extension is about content view configuration
extension SendOrRequestMoneyVC {
    func viewControlLayout(){
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            contentView.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            contentView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height - segmentedControl.frame.height - navigationBar.frame.height)
        ])
    }
    
    func phoneNumberView(){
        contentView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        view.backgroundColor = .white
        configureTableView()
        
    }
    func IBANView(){
        contentView.subviews.forEach { view in
            view.removeFromSuperview()
        }
        view.backgroundColor = .brown

        let label = UILabel(frame: CGRect(x: 20, y: 20, width: 100, height: 100))
        label.text = "IBAN View"
        contentView.addSubview(label)
    }
    
    
    
}

//This extensions about other operations

extension SendOrRequestMoneyVC {

    
    func requestForContacts(){
        store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            if granted {
                self.fetchContacts()
            }else {
                let openAppSettings = UIAlertAction(title: NSLocalizedString("Settings", comment: "err"), style: .default) { _ in
                    if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
                    }
                }
                
                self.showAlert(title: NSLocalizedString("ERROR!", comment: "err"), message: NSLocalizedString("If you want to see the persons who is using this bank app from your contacts you must give the contacts access permission", comment: "err"), style: .alert, okAction: true, otherActions: [openAppSettings])
            }
        }
    }
    
    func fetchContacts(){
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        var contacts = [CNContact]()
        let bgQueue = DispatchQueue(label: "com.SwiftBank")
        bgQueue.async {
            do {
                try self.store.enumerateContacts(with: request) { contact, stop in
                contacts.append(contact)
            }
        } catch {
            self.showAlert(title: "ERROR!", message: error.localizedDescription, style: .alert, okAction: true, otherActions: nil)
        }
            
            for contact in contacts {
                contact.phoneNumbers.forEach { phone in
                    self.scanDatabase(collectionName: .Users, type: .phoneNumber, value: phone.value.stringValue) { result in
                        switch result {
                        case .success(let snapshotArray):
                            
                            if !snapshotArray.isEmpty {
                                
                                snapshotArray.forEach { snapshot in
                                    self.appUsersFromContacts.append(AppUsersFromContacts(name: snapshot.data()!["name"]! as! String, surname: snapshot.data()!["surname"]! as! String, phoneNumber: snapshot.data()!["phoneNumber"] as! String))
                                }
                                self.usersTable.reloadData()
                                
                            }
                        case .failure(let error) :
                            self.showAlert(title: "Error!", message: error.localizedDescription, style: .alert, okAction: true, otherActions: nil)
                        }
                    }
                }
                
                
            }
            
        }
                
            
       
        
    }
}



extension SendOrRequestMoneyVC  :  UITableViewDelegate , UITableViewDataSource {
    func configureTableView(){
        usersTable.delegate = self
        usersTable.dataSource = self
        contentView.addSubview(usersTable)
        
        usersTable.register(UITableViewCell.self, forCellReuseIdentifier: "AppUsersCell")
        NSLayoutConstraint.activate([
            usersTable.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            usersTable.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            usersTable.leftAnchor.constraint(equalTo: view.leftAnchor),
            usersTable.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.6)
        ])
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appUsersFromContacts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = usersTable.dequeueReusableCell(withIdentifier: "AppUsersCell")
        var content = cell?.defaultContentConfiguration()
        content?.text = "\(appUsersFromContacts[indexPath.row].name)  \(appUsersFromContacts[indexPath.row].surname)"
        content?.secondaryText = "\(appUsersFromContacts[indexPath.row].phoneNumber)"
        content?.image = UIImage(systemName: "person")
        cell?.contentConfiguration = content
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sendMoneyVC = SendMoneyVC()
        sendMoneyVC.user = appUsersFromContacts[indexPath.row]
        
        sendMoneyVC.modalPresentationStyle = .fullScreen
        self.present(sendMoneyVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Swiftbank Users", comment: "info")
        
    }
    
}



