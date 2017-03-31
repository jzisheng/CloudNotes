//
//  NotesTableViewPage.swift
//  MyCloudNotes
//
//  Created by Jason Chang on 1/8/17.
//  Copyright © 2017 Jason Chang. All rights reserved.
//

import UIKit
import Parse

class NotesTableViewPage: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Custom array of all notes
    var notes = [Note]()
    
    // Variable that contains the refresher
    var refresher: UIRefreshControl!
    
    @IBOutlet weak var noteTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func logoutButton(_ sender: Any) {
        // Logout user, and preform segue back to login page
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            // Preform segue back to loginpage, and logout user
            PFUser.logOut()
            self.performSegue(withIdentifier: "logoutSegue", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            // User doesn't want to logout, cancel action
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        // Maximum of 30 characters
        stopUserInteraction()
        if noteTextField.text! == " " || noteTextField.text! == "" {
            resumeUserInteraction()
            // Check to make sure notes field is not empty
            displayAlert(title: "Error", message: "Note field cannot be left emtpy", buttonMessage: ["OK"])
        }
        /*else if noteTextField.text!.characters.count > 38{
            resumeUserInteraction()
            // Note can't be longer than 38 characters
            displayAlert(title: "Error", message: "Note cannot be greater than 38 characters", buttonMessage: ["OK"])
        }*/
        else{
            // Note is valid, continue to save note
            
            // Get the current user
            let currentUser = PFUser.current()
            
            // Make sure a user is logged in, otherwise bad things could happen
            if currentUser != nil{
                // Create new note to append to list, fetches notText and userId
                let noteText = noteTextField.text!
                let noteUser = (currentUser?.objectId)! as String
                
                // Save note to Parse
                let parseNote = PFObject(className:"Cloudnotes")
                parseNote["note"] = noteText
                parseNote["userId"] = noteUser
                parseNote.saveInBackground(block: { (success, error) in
                    if (success){
                        // Clear notes text field
                        self.noteTextField.text = ""
                        
                        // Get objectId value
                        let noteObjectId = parseNote.objectId! as String
                        
                        // Append note
                        let note = Note(objectId: noteObjectId, userId: noteUser, note: noteText)
                        self.notes.append(note)
                        self.resumeUserInteraction()
                        
                        // Reload tableview
                        self.tableView.reloadData()
                        
                        
                    } else{
                        // Error uploading the note, display error message
                        self.resumeUserInteraction()
                        var displayErrorMessage = "Please try again later"
                        if let errorMessage = (error! as NSError).userInfo["error"] as? String{
                            displayErrorMessage = errorMessage
                        }
                        self.displayAlert(title: "Error", message: displayErrorMessage, buttonMessage: ["OK"])
                    }
                })
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
    
    
    // Fetch notes //
    func refreshNotes(){
        stopUserInteraction()
        // Get current user
        let currentUser = PFUser.current()
        
        // Purge current notes
        notes.removeAll()
        
        // Make sure a user is logged in, otherwise bad things could happen
        if currentUser != nil{
            let currentUserId = (currentUser?.objectId)! as String
            let query = PFQuery(className:"Cloudnotes")
            query.whereKey("userId", equalTo:currentUserId)
            query.findObjectsInBackground(block: { (objects, error) in
                if error == nil{
                    // Query success
                    if let objects = objects{
                        for object in objects{
                            print(object.objectId!)
                            
                            // Prepare note object
                            let noteText = object["note"] as! String
                            let noteUser = object["userId"] as! String
                            // Append note
                            let note = Note(objectId: object.objectId!, userId: noteUser, note: noteText)
                            self.notes.append(note)
                        }
                        self.tableView.reloadData()
                        self.resumeUserInteraction()
                        self.refresher.endRefreshing()
                    }
                } else{
                    self.resumeUserInteraction()
                    self.refresher.endRefreshing()
                    var displayErrorMessage = "Please try again later"
                    if let errorMessage = (error! as NSError).userInfo["error"] as? String{
                        displayErrorMessage = errorMessage
                    }
                    self.displayAlert(title: "Error", message: displayErrorMessage, buttonMessage: ["OK"])
                }
            })
        }
    }
    
    //////////////////////////////
    
    override func viewDidLoad() {
        // Setup for spinner //
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.gray;
        activityIndicator.center = view.center;
        ///////////////////////
        super.viewDidLoad()
        
        // Enables tap anywhere to disable keyboard
        self.hideKeyboardWhenTappedAround()
        
        refreshNotes()
        
        // Adds pull to refresh functionality
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh notes")
        refresher.addTarget(self, action: #selector(NotesTableViewPage.refreshNotes), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.textLabel?.text = notes[indexPath.row].note
        
        // Enable multiple lines in TableView
        cell.textLabel?.numberOfLines = 2;
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        
        // Change padding in TableView
        //self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 10);
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            
            // Let user confirm their decision
            // Logout user, and preform segue back to login page
            let alert = UIAlertController(title: "Delete Note", message: "Are you sure you want to delete this note?", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.stopUserInteraction()
                // Delete note from Parse
                let query = PFQuery(className:"Cloudnotes")
                query.whereKey("objectId", equalTo: self.notes[indexPath.row].objectId)
                query.findObjectsInBackground(block: { (objects, error) in
                    if(error == nil){
                        if let objectsQuery = objects{
                            for object in objectsQuery{
                                object.deleteEventually()
                                // Remove notes from table
                                self.notes.remove(at: indexPath.row)
                                tableView.reloadData()
                                self.resumeUserInteraction()
                            }
                        }
                    } else{
                        
                        // Error uploading the note, display error message
                        var displayErrorMessage = "Please try again later"
                        if let errorMessage = (error! as NSError).userInfo["error"] as? String{
                            displayErrorMessage = errorMessage
                        }
                        self.resumeUserInteraction()
                        self.displayAlert(title: "Error", message: displayErrorMessage, buttonMessage: ["OK"])
                        
                    }
                })
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action) in
                // User doesn't want to logout, cancel action
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            
        }
    }
}
