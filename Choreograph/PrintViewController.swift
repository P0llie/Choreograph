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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.choreographyText.attributedText = fileText
        self.choreographyText.adjustsFontForContentSizeCategory = true

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var choreographyText: UITextView! {
        didSet{
            choreographyText.sizeToFit()
            choreographyText.isEditable = true
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
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "print Job"
        printController.printInfo = printInfo
        
        // 3
        let formatter:UIViewPrintFormatter =  choreographyText.viewPrintFormatter()
        formatter.perPageContentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
        printController.printFormatter = formatter
        
        // 4
        printController.present(animated: true, completionHandler: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
