//
//  Note.swift
//  MyCloudNotes
//
//  Created by Jason Chang on 1/8/17.
//  Copyright © 2017 Jason Chang. All rights reserved.
//

import Foundation

struct Note{
    var objectId: String
    var userId: String
    var note: String
    
    init(objectId: String, userId: String, note: String){
        self.objectId = objectId
        self.userId = userId
        self.note = note
    }
}
