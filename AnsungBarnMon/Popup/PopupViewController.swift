//
//  PopupViewController.swift
//  AnsungBarnMon
//
//  Created by 센코 on 10/31/23.
//

import UIKit

class PopupViewController: UIViewController {
    
    var temp: (()->Void)?
    
    var response:PhoneResponse!
        
    @IBOutlet weak var lBlPhoneNum: UITextField!
    
    @IBAction func btnConfirm(_ sender: Any) {
        let phone = "010"+lBlPhoneNum.text!
        let _: () = request("user", "https://livestock.kr/be/appAuthUser.do?user_phone="+phone, "GET", completionHandler: {(success, data) in self.response = data as? PhoneResponse
            print("<<<<<Phone Result :", self.response.msg)
            if self.response.msg == "Y" {
                let id: String = self.response.result!.dt_op_user_id
                Util().saveUserID(userID:id)
                
                DispatchQueue.main.async { [self] in
                    self.dismiss(animated: false, completion: nil)
                    temp!()
                }
                
            } else {
                DispatchQueue.main.async { [self] in
                    self.dismiss(animated: false, completion: nil)
                    temp!()
                }
            }
        })
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
       
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // 키보드 내리면서 동작
        textField.resignFirstResponder()
        return true
    }
}
