//
//  RegistrationPage.swift
//  MyCloudNotes
//
//  Created by Jason Chang on 1/3/17.
//  Copyright © 2017 Jason Chang. All rights reserved.
//

import Foundation


import UIKit
import Parse

class RegistrationPage: UIViewController {
    
    // Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTwoTextField: UITextField!
    
    @IBAction func registerButton(_ sender: Any) {
        // Log out of user, in case user is still logged in
        PFUser.logOut()
        
        // End user interaction while registration process and show spinner
        stopUserInteraction()
        
        // Check registration fields
        if usernameTextField.text == "" || passwordTextField.text == "" || passwordTwoTextField.text == "" {
            // Check to make sure text fields are not empty
            
            displayAlert(title: "Error", message: "Fields cannot be left empty")
            resumeUserInteraction()
            
        } else if passwordTextField.text! != passwordTwoTextField.text! {
            // Check that password fields match
            
            displayAlert(title: "Error", message: "Passwords do not match")
            resumeUserInteraction()
            
        }
        else {
            // Main tests passed, begin signup process
            
            let user = PFUser()
            user.username = usernameTextField.text
            user.password = passwordTextField.text
            
            user.signUpInBackground { (success, error) in
                if error == nil {
                    // Registration successful
                    self.resumeUserInteraction()
                    print("registration success")
                    
                    let alert = UIAlertController(title: "Success", message: "Please return to login page to login", preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "Return to login page", style: .default, handler: { (action) in
                        //execute some code when this option is selected
                        self.performSegue(withIdentifier: "backToLoginPageSegue", sender: self)
                    }))
                    
                    PFUser.logOut()
                    self.present(alert, animated: true, completion: nil)
                    // Resume user interaction
                    self.resumeUserInteraction()
                    
                } else{
                    // Resume user interaction
                    self.resumeUserInteraction()
                    
                    // Error during registration
                    
                    var errorString = "There was an error. Please try again later."
                    if let errorMessage = (error! as NSError).userInfo["error"] as? String{
                        errorString = errorMessage
                    }
                    self.displayAlert(title: "Error", message: errorString)
                
                }
            }
        }
    }
    
    // Activity Indicator //
    var activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y:0, width: 50, height:50))
    
    func stopUserInteraction() {
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        view.isUserInteractionEnabled = false
    }
    
    func resumeUserInteraction() {
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            //execute some code when this option is selected
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //////////////////////////////
    
    override func viewDidLoad() {
        // Setup for spinner //
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.gray;
        activityIndicator.center = view.center;
        ///////////////////////
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Enables tap anywhere to disable keyboard
        self.hideKeyboardWhenTappedAround()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


// Extends UIVIew Controller so that tapping anywhere besides keyboard dismisses it
extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func displayAlert(title: String, message: String, buttonMessage: [String]){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for message in buttonMessage{
            alert.addAction(UIAlertAction(title: message, style: .default, handler: { (action) in
                //execute some code when this option is selected
                
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }
}
