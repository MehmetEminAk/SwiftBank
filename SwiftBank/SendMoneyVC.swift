//
//  SendMoneyVC.swift
//  SwiftBank
//
//  Created by Macbook Air on 22.02.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SendMoneyVC: UIViewController {

    public var user : AppUsersFromContacts!
    
    private var userBalance : Double?
    
    private let label : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private let sendMoneyButton  : DisableableButton = {
        
        let button = DisableableButton()
        button.disabledBackgroundColor = .gray
        button.setTitle("SEND MONEY", for: .normal)
        button.enabledBackgroundColor = .systemBlue
        button.disabledBackgroundColor = .systemGray
        button.backgroundColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let textField : UITextField = {
        let tf  = UITextField()
        tf.placeholder = "Please type the amount"
        tf.returnKeyType = .send
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.layer.cornerRadius = 5
        tf.borderStyle = .line
        tf.keyboardType = .numberPad
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = Auth.auth().currentUser  else {
            return
        }
        
        
        view.backgroundColor = .white
        view.addSubViews([label,textField,sendMoneyButton])
        
        
        tfSettings()
        
        
        fetchAccountBalance(user: Auth.auth().currentUser!, completionHandler: { balance in
            self.userBalance = balance
            self.label.text = "Your balance is \(balance) $"
        })
        
        self.dissKeyboard()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
            self.textField.becomeFirstResponder()
        })
        
    }
    override func viewDidLayoutSubviews() {
            configureLayouts()
    }
    

}
extension SendMoneyVC : UITextFieldDelegate {
    
    func tfSettings(){
        textField.delegate = self
        textField.addTarget(self, action: #selector(tfBalanceControl), for: .editingChanged)
        sendMoneyButton.addTarget(self, action: #selector(sendMoney), for: .touchUpInside)
    }
    
    
    //Most important function in this view controller
    @objc private func sendMoney(){
        guard let text = textField.text else {
            return
        }
        
        let action = UIAlertAction(title: "MAIN PAGE", style: .default) { action in
            let backVC = MainVC()
            backVC.modalPresentationStyle = .fullScreen
            self.present(backVC, animated: true)
            
        }
        
        scanDatabase(collectionName: .Users, type: .email, value: Auth.auth().currentUser!.email!) { result in
            switch result {
            case .success(let snapshots):
                for doc in snapshots{
                    var docData = doc.data()!
                    let balance = docData["balance"] as! Double
                    docData["balance"] = balance - (text as NSString).doubleValue
                    doc.reference.setData(docData)
                }
                        
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        scanDatabase(collectionName: .Users, type: .phoneNumber, value: user.phoneNumber) { result in
            switch result {
            case .success(let snapshots) :
                snapshots.forEach { snapshot in
                    var docData = snapshot.data()!
                    let balance = docData["balance"] as! Double
                    docData["balance"] = balance + (text as NSString).doubleValue
                    snapshot.reference.setData(docData)
                }
                self.showAlert(title: "Succesfull", message: "Your transation has been completed successfully!", style: .alert, okAction: false, otherActions: [action])
            case .failure(let error) :
                print(error.localizedDescription)
            }
        }
     
        
        
    }
    
    @objc private func tfBalanceControl(){
        guard let text = textField.text else{
                return
        }
        if (text as NSString).doubleValue > self.userBalance! {
            self.sendMoneyButton.isEnabled = false
            showAlert(title: "ERROR!", message: "You can not send more money from your balance", style: .alert, okAction: true, otherActions: nil)
            
        }
        else {
            self.sendMoneyButton.isEnabled = true
        }
        
    }
    
    
    
    func configureLayouts(){
        NSLayoutConstraint.activate([
            
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor , constant: -50),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.bottomAnchor.constraint(equalTo: textField.topAnchor , constant: -20),
            label.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            sendMoneyButton.leftAnchor.constraint(equalTo: textField.leftAnchor),
            sendMoneyButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            sendMoneyButton.topAnchor.constraint(equalTo: textField.bottomAnchor , constant: 40)
        ])
    }
    
}


