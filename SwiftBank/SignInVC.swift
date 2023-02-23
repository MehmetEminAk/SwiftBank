//
//  ViewController.swift
//  Swift Bank App
//
//  Created by Macbook Air on 21.02.2023.
//

import UIKit
import FirebaseAuth

class SignInVC : UIViewController  {

    func toMainScreen(){
        let mainVC = MainVC()
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true)
    }
    
   
    private let emailTF : UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.returnKeyType = .continue
        tf.placeholder = NSLocalizedString("Username", comment: "Username tf placeholder")
        tf.backgroundColor = .darkGray
        
        return tf
        
    }()
    
    
    private let passwordTF : UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = .darkGray
        tf.returnKeyType = .go
        tf.placeholder = NSLocalizedString("Password", comment: "Password tf placeholder")
        
        return tf
        
    }()
    
    private let submitButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Sign In", comment: "Submit button title"), for: .normal)
        button.layer.cornerRadius = 5
        button.backgroundColor = .darkGray
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubViews()
        configureTextFields()
        submitButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        //Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(firstResponder), userInfo: nil, repeats: false)
    }
    
    
    override func viewDidLayoutSubviews() {
        layoutElements()
    }


}


extension SignInVC : UITextFieldDelegate  {
    
    
    
    
    func addSubViews(){
        view.addSubViews([emailTF,passwordTF,submitButton])
    }
    
    func configureTextFields(){
        emailTF.delegate = self
        passwordTF.delegate = self
        emailTF.addTarget(self, action: #selector(usernameChanged), for: .valueChanged)
        passwordTF.addTarget(self, action: #selector(passwordChanged), for: .valueChanged)
        
    }
    func layoutElements(){
        NSLayoutConstraint.activate([
            emailTF.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTF.centerYAnchor.constraint(equalTo: view.centerYAnchor , constant: -60),
            emailTF.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            passwordTF.topAnchor.constraint(equalTo: emailTF.bottomAnchor, constant: 20),
            passwordTF.leftAnchor.constraint(equalTo: emailTF.leftAnchor),
            passwordTF.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            submitButton.topAnchor.constraint(equalTo: passwordTF.bottomAnchor, constant: 20),
            submitButton.leftAnchor.constraint(equalTo: passwordTF.leftAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),

        ])
    }
    
    
    
}


extension SignInVC {
   
    @objc func usernameChanged(){
        if emailTF.text!.count < 6 && passwordTF.text!.count < 6 {
            submitButton.isEnabled = false
        }
        submitButton.isEnabled = true
    }
    @objc func passwordChanged(){
        if emailTF.text!.count < 6 && passwordTF.text!.count < 6 {
            submitButton.isEnabled = false
        }
        submitButton.isEnabled = true
    }
    @objc func signIn(){
        guard let email = emailTF.text , let password = passwordTF.text else{
            showAlert(title: NSLocalizedString("ERROR", comment: "Error message title"), message: NSLocalizedString("Please fill the all fields", comment: "Fill the all fields error"), style: .alert, okAction: true, otherActions: nil)
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { auth, error in
            guard let _ = auth , error == nil else {
                self.showAlert(title: NSLocalizedString("ERROR", comment: "Error message title"), message: error!.localizedDescription, style: .alert, okAction: true, otherActions: nil)
                return
            }
            self.toMainScreen()
        }
    }
}



extension SignInVC {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTF :
            passwordTF.becomeFirstResponder()
        case passwordTF :
            signIn()
        default:
            showAlert(title: NSLocalizedString("ERROR", comment: "Error message title"), message: NSLocalizedString("An unknown error occured ! Please try again", comment: "An unknown error message"), style: .alert, okAction: true, otherActions: nil)
        }
        return true
    }
}


