//
//  RegisterViewController.swift
//  business-chat-app
//
//  Created by Timofei Sopin on 2018-03-02.
//  Copyright © 2018 Brogrammers. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterScreenVC: UIViewController {
  
  @IBOutlet weak var usernameTextfield: UITextField!
  @IBOutlet weak var regButton: UIButton!
  @IBOutlet weak var emailTextfield: UITextField!
  @IBOutlet weak var passwordTextfield: UITextField!
  @IBOutlet weak var passwordConfirmTextfield: UITextField!
  
  let colors = Colors()
  let date = Date()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.setGradient(colors.colourMainBlue.cgColor, colors.colourMainGreen.cgColor)
    regButton.layer.cornerRadius = 5 
    self.hideKeyboardWhenTappedAround()
  }
  
  @IBAction func registerButtonPressed(_ sender: Any) {
    
    SVProgressHUD.show(withStatus: "Registration")
    let email = emailTextfield.text
    let userName = usernameTextfield.text
    let password = passwordTextfield.text
    let confirmPassword = passwordConfirmTextfield.text
    
    if  password == confirmPassword && userName != nil && email != nil  {
      
      userRegister(userCreationComplete: { (success, loginError) in
        if success {
          
          SVProgressHUD.dismiss()
          SVProgressHUD.show(withStatus: "Registration succeeded. \nSigning In.")
          
          Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
            if let error = error {
              SVProgressHUD.dismiss()
              self.alert(message: (error.localizedDescription))
              return
            }
            
            if user != nil {
              print("Log in Successfull for \(String(describing: user?.uid))!")
              UserServices.instance.saveTokens()
              SVProgressHUD.dismiss()
              self.presentStoryboard()
            }
          }
        } else {
          SVProgressHUD.dismiss()
          print(String(describing: loginError?.localizedDescription))
        }
      })
    }
    
    emailTextfield.resignFirstResponder()
    passwordTextfield.resignFirstResponder()
    
  }
  
  @IBAction func cancelBtn(_ sender: Any) {
    SVProgressHUD.dismiss()
    self.dismiss(animated: true, completion: nil)
    
  }
  
  func userRegister(userCreationComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
    let userName = usernameTextfield.text!
    let password = passwordTextfield.text!
    let email = emailTextfield.text!
    
    let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
    
    Auth.auth().createUser(withEmail: "\(email)", password: "\(password)") { (user, error) in
      if let error = error {
        self.alert(message: (error.localizedDescription))
        
      } else {
        let currentDate = Int64(self.date.millisecondsSince1970)
        
        let userData = ["username": trimmedName, "email": email, "avatar": false, "status": "offline", "lastOnline": currentDate ] as [String : Any]
        UserServices.instance.createDBUser(uid: (user?.uid)!, userData: userData)
        userCreationComplete(true, nil)
        
      }
    }
  }
}



