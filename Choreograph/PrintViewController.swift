//
//  PrintViewController.swift
//  Choreograph
//
//  Created by Karen McCarthy on 30/05/2017.
//  Copyright © 2017 Karen McCarthy. All rights reserved.
//

import UIKit

class PrintViewController: UIViewController, UITextViewDelegate {
    var fileText: NSMutableAttributedString?
    var keyboardShowing = false
    
    override func viewDidLoad() {
                // Do any additional setup after loading the view.
        super.viewDidLoad()
        self.choreographyText.attributedText = fileText
        self.choreographyText.adjustsFontForContentSizeCategory = true
        self.choreographyText.isEditable = false
        self.choreographyText.isScrollEnabled = true
    }
    


    @IBOutlet weak var choreographyText: UITextView! {
        didSet{
            choreographyText.sizeToFit()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func printMyText(_ sender: UIBarButtonItem) {
        // 1
        let printController = UIPrintInteractionController.shared
        printController.delegate = self as? UIPrintInteractionControllerDelegate
    
        // 2
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.grayscale
        printInfo.jobName = "Choregraph print Job"
        printController.printInfo = printInfo
        
        // 3
        let formatter:UIViewPrintFormatter =  choreographyText.viewPrintFormatter()
        formatter.perPageContentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
        printController.printFormatter = formatter
        
        // 4
        func completionHandler( printController: UIPrintInteractionController, completed: Bool, error: NSError?){
            if(!completed && error != nil ) {
                print("Printing not completed because of error: \(error!)")
            }
        }
        printController.present(from: sender, animated: true, completionHandler: completionHandler as? UIPrintInteractionCompletionHandler)
    }
}
