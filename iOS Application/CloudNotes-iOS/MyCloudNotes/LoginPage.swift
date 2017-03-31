//
//  ViewController.swift
//  MyCloudNotes
//
//  Created by Jason Chang on 1/2/17.
//  Copyright © 2017 Jason Chang. All rights reserved.
//

import UIKit
import Parse

class LoginPage: UIViewController {
    
    // Activity Indicator
    var activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y:0, width: 50, height:50))
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func LoginButton(_ sender: Any) {
        
        // Stop user interaction and spinner
        stopUserInteraction()
        
        print("logging in")

        let loginUsername = loginTextField.text
        let loginPassword = passwordTextField.text
        
        if loginUsername == "" || loginPassword == "" {
            // Check that the fields are not empty
            resumeUserInteraction()
            displayAlert(title: "Error", message: "Please enter a username and password")
        } else{
            PFUser.logInWithUsername(inBackground: loginUsername!, password: loginPassword!, block: { (user, error) in
                if error != nil{
                    // Signin error
                    var displayErrorMessage = "Please try again later"
                    if let errorMessage = (error! as NSError).userInfo["error"] as? String{
                        displayErrorMessage = errorMessage
                    }
                    self.resumeUserInteraction()
                    self.displayAlert(title: "Error signing in", message: displayErrorMessage)
                }else{
                    // Signin success
                    self.resumeUserInteraction()
                    let currentUser = PFUser.current()
                    if currentUser != nil{
                        // Success logging in, pass current user
                        print(currentUser?.username ?? String())
                        // Perform Segue to TableView
                        print("Logged in")
                        self.performSegue(withIdentifier:"showNotesTableView", sender: self)
                    } else {
                        // There was some error
                    }
                }
                
            })
        }
    }
    
    override func viewDidLoad() {
        // Setup for spinner
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.gray;
        activityIndicator.center = view.center;
        // Loaded view
        super.viewDidLoad()
        // Enables tap anywhere to disable keyboard
        self.hideKeyboardWhenTappedAround()
        
        //Check to see if user is already logged in
        stopUserInteraction()
        
        let currentUser = PFUser.current()
        if currentUser != nil{
            // User has already logged in
            print(currentUser?.username ?? String())
            // Perform Segue to TableView
            print("Logged in")
            resumeUserInteraction()
            OperationQueue.main.addOperation {
                [weak self] in
                self?.performSegue(withIdentifier: "loginSuccess", sender: self)
            
                //performSegue(withIdentifier:"showNotesTableView", sender: self)
            }
        } else {
            // User not logged in already, do nothing
            resumeUserInteraction()
        }
    }
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

