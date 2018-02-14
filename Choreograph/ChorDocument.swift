//
//  ChorDocument.swift
//  Choreograph
//
//  Created by Karen McCarthy on 23/02/2017.
//  Copyright © 2017 Karen McCarthy. All rights reserved.
//

import Foundation
import UIKit

class ChoreographyDocument: UIDocument {
    var choreography = [CountSteps]()
   
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
                    if let chorData = contents as? Data {
                if let arr = NSKeyedUnarchiver.unarchiveObject(with: chorData) as? [CountSteps]{
                    self.choreography = arr
                    return
                }
            }
            throw NSError(domain: "No Data Domain", code: -1, userInfo: nil)
    }
    override func contents(forType typeName: String) throws -> Any {
        let docData = NSKeyedArchiver.archivedData(withRootObject: self.choreography)
        return docData
    }        
}

