//
//  MainVC.swift
//  SwiftBank
//
//  Created by Macbook Air on 22.02.2023.
//

import UIKit

class MainVC: UITabBarController {

    var sendMoneyVC : SendMoneyVC!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backgroundColor = .black
        view.backgroundColor = .white
        let profileViewController = ProfileVC()
        sendMoneyVC = SendMoneyVC()
       
        setViewControllers([profileViewController,sendMoneyVC], animated: true)

        tabBar.backgroundColor = .darkGray
        
        
     
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sendMoneyVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Send Money", comment: "Tab icon title 1"), image: UIImage(systemName: "banknote"), tag: 1)
        if let tabBarItemView = sendMoneyVC.tabBarItem.value(forKey: "view") as? UIView {
            let presentActionSheetGest = UITapGestureRecognizer(target: self, action: #selector(presentActSheet))
            tabBarItemView.addGestureRecognizer(presentActionSheetGest)
        }
    }
    
    @objc func presentActSheet(){
        let sendMoney = UIAlertAction(title: NSLocalizedString("Para Gönder", comment: "First action"), style: .default) { _ in
            self.toSendOrRequestMoneyVC(type: .send)
        }
    
        let requestMoney = UIAlertAction(title: NSLocalizedString("Para iste", comment: "Second action"), style: .default) { _ in
            
            self.toSendOrRequestMoneyVC(type: .request)
        }
        let regularTranfer = UIAlertAction(title: NSLocalizedString("Düzenli para tranferi", comment: "Third action"), style: .default)
        

        
        showAlert(title: "", message: "", style: .actionSheet, okAction: true, otherActions: [sendMoney,requestMoney,regularTranfer])
    }
    


}




extension MainVC {
    func toSendOrRequestMoneyVC(type : SendOrRequest){
        let sendOrRequestMoneyVC  = SendOrRequestMoneyVC()
        sendOrRequestMoneyVC.modalPresentationStyle = .fullScreen
        if type == .send {
            sendOrRequestMoneyVC.type = .send
        }else {
            sendOrRequestMoneyVC.type = .request
        }
        self.present(sendOrRequestMoneyVC, animated: true)
    }
}

enum SendOrRequest {
    case send
    case request
}
