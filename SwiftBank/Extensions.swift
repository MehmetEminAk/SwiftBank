//
//  Extensions.swift
//  SwiftBank
//
//  Created by Macbook Air on 22.02.2023.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth



extension UIView {
    
    
    func addSubViews(_ views : [UIView]?){
        guard let views = views else { return }
        views.forEach { view in
            self.addSubview(view)
        }
    }
}

extension UIViewController {
    func showAlert(title : String , message : String ,style : UIAlertController.Style , okAction : Bool? , otherActions : [UIAlertAction]?){
        let alert = UIAlertController(title: title, message: message , preferredStyle: style)
        
        if let okAction = okAction , okAction == true {
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(okAction)
        }
        if let otherActions = otherActions {
            for action in otherActions {
                alert.addAction(action)
            }
        }
        self.present(alert, animated: true)
    }
    
    
    
    func dissKeyboard(){
        let dismissAct = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(dismissAct)
        
    }
    
    
    @objc private func dismissKeyboard(){
        view.endEditing(true)
    }
}



extension UIViewController {
    func scanDatabase(collectionName : Collections ,type : UsersScaningType ,  value : String , completionHandler : @escaping (Result<[DocumentSnapshot],Error>) -> Void){
        
        
        Firestore.firestore().collection(collectionName.rawValue).whereField(type.rawValue, isEqualTo: value).getDocuments { snapshot, error in
            guard let snapshot = snapshot , error == nil  else{
                completionHandler(.failure(error!))
                return
            }
            completionHandler(.success(snapshot.documents))

        }
        
    }
    
    enum UsersScaningType : String {
        case phoneNumber
        case email
        
    }
    enum Collections : String {
        case Users
    }
}


extension UIViewController {
    
    
    
    func fetchAccountBalance(user : User ,completionHandler : @escaping (Double) -> Void)  {
        
        scanDatabase(collectionName: .Users, type: .email, value: user.email!) { fetchResult in
            switch fetchResult {
            case .success(let snapshots):
                snapshots.forEach { snapshot in
                    let result = snapshot.data()!["balance"] as? Double
                    completionHandler(result!)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
       
    }
}


