//
//  CountSteps.swift
//  ChoroMusic
//
//  Created by Karen McCarthy on 23/02/2017.
//  Copyright © 2017 Karen McCarthy. All rights reserved.
//

import Foundation

class CountSteps: NSObject, NSCoding {
    var counts: String
    var steps: String
    override var description: String {
        return self.counts + "\t" + self.steps
    }
    init(counts: String, steps: String){
        self.counts = counts
        self.steps = steps
        super.init()
    }
    override init() {
        self.counts = " "
        self.steps = " "
        super.init()
    }

    func encode(with coder: NSCoder) {
            coder.encode(self.counts, forKey: "counts")
            coder.encode(self.steps, forKey: "steps")
    }
    required init(coder:NSCoder){
        self.counts = coder.decodeObject( forKey: "counts") as! String
        self.steps = coder.decodeObject( forKey: "steps") as! String
        super.init()
    }
}
