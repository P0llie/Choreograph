//
//  DocumentBrowserViewController.swift
//  Choreograph
//
//  Created by Karen Worgan on 21/01/2018.
//  Copyright © 2018 Karen Worgan. All rights reserved.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        delegate = self
        allowsPickingMultipleItems = false
        allowsDocumentCreation = false
        templateURL = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Untitled.choreograph")
        
        if templateURL != nil {
         let docData = NSKeyedArchiver.archivedData(withRootObject: self.chorArray)
            allowsDocumentCreation = FileManager.default.createFile(atPath: templateURL!.path, contents: docData, attributes: nil) 
//            allowsDocumentCreation = true
            print ("allows Document creation = \(allowsDocumentCreation)")
            print ("created url at \( templateURL!.path)")
            
        }
        
        // Update the style of the UIDocumentBrowserViewController
         browserUserInterfaceStyle = .dark
         view.tintColor = .purple
        
        // Specify the allowed content types of your application via the Info.plist.
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    // Mark: new file template
    
    var templateURL: URL?
    var chorArray: [CountSteps] = Array(repeating: Constants.MyCS, count: Constants.InitialRows)
//    var chorArray = [CountSteps]()
    private struct Constants {
        static let MyCS = CountSteps(counts:" ", steps:" " )
        static let InitialRows = 10
    }
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        
            importHandler(templateURL, .copy)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        
        print ("Failed to import document at \(documentURL). Error code \(error!)")
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let documentVC = storyBoard.instantiateViewController(withIdentifier: "DocumentMVC") 
        if let documentViewController = documentVC.contents as? DocumentViewController {
            func setInitialText(_ success:Bool) {
                if success {
                    print ("initialised a new file ")
                } else {
                    print ( "File Initialisation failed")
                }
            }
            documentViewController.danceDoc = ChoreographyDocument(fileURL: documentURL)
            documentViewController.danceDoc?.save(to:(documentViewController.danceDoc?.fileURL)!, for: .forCreating, completionHandler: setInitialText)
            
            documentViewController.documentURL = documentURL
            print ("Document URL = \( documentURL)")
        }
        present(documentVC, animated: true, completion: nil)
    }
}

