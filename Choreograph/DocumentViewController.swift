//
//  DocumentViewController.swift
//  Choreograph
//
//  Created by Karen McCarthy on 03/12/2016.
//  Copyright © 2016 Karen McCarthy. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer

class DocumentViewController: UITableViewController,MPMediaPickerControllerDelegate, UITextFieldDelegate {
// MARK properties for choreography file handling
    var documentURL: URL?
    var danceDoc: ChoreographyDocument?
    var choreography: [CountSteps] = [] {
        didSet {
            danceDoc?.choreography = choreography
            if danceDoc?.choreography != nil {
                danceDoc?.updateChangeCount(.done)
            }
            tableView.reloadData()
        }
    }
    var myIndexPathRow: NSInteger?
    var myCell: ChoreoCell!
    // MARK: Disable automatic keyboard dismissal
    override var disablesAutomaticKeyboardDismissal: Bool {
        return true
    }
    
        // MARK: View Controller Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // open the chosen file
        danceDoc?.open { success in
            if success {
                self.choreography = (self.danceDoc?.choreography)!
                self.title = self.danceDoc?.localizedName
            } else  {
                print("Error opening a file")
//***put in message to user!!!!
                fatalError()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
        
    
        
        checkForMusicLibraryAccess()

        tableView.rowHeight = 50
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    // set up a timer
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
        self.timer?.tolerance = 0.05
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
// MARK: Constants
    
    private struct Storyboard {
        static let CellIdentifier = "ChoreographyCell"
        static let InitialRows = 10
    }
    private struct TitlesForButtons {
//        static let font = UIFont.preferredFont(forTextStyle: .headline).withSize(20.0)
        static let playCharacter: [Character] = ["▶️"]
        static let playString = String(playCharacter)
//        static let playString: NSAttributedString = pString.attributedString(withTextStyle: .headline, ofSize: 24.0)
        static let pauseCharacter: [Character] = ["⏸"]
        static let pauseString = String(pauseCharacter)
        static let musicCharacter: [Character] = ["🎵"]
        static let musicString = String(musicCharacter)
        
    }

// MARK: UITableViewDataSource
    
   override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = self.choreography.count
        if (rows > 0) {
            return rows
        } else {
            return Storyboard.InitialRows
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell( withIdentifier:Storyboard.CellIdentifier, for: indexPath) as? ChoreoCell
        if (self.choreography.count == 0 ) {
            let myCountSteps = CountSteps(counts:" ", steps:" " )
            for _ in 0...Storyboard.InitialRows-1 {
                self.choreography.append(myCountSteps)
            }
        }
        cell?.countText.text = self.choreography[indexPath.row].counts
        cell?.stepText.text = self.choreography[indexPath.row].steps
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath:IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            let ct = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
            if ct-1 == indexPath.row {
                return .insert
            }
            return .delete
        }
        return tableView.isEditing ? .delete : .none
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        tableView.endEditing(true)
        if editingStyle == .insert {
            let myCountSteps = CountSteps(counts:" ", steps:" " )
            self.choreography.append(myCountSteps)
            self.danceDoc?.choreography.append(myCountSteps)
            self.danceDoc?.updateChangeCount(.done)
        }
        if editingStyle == .delete {
            self.choreography.remove(at: indexPath.row)
            self.danceDoc?.choreography.remove(at: indexPath.row)
            self.danceDoc?.updateChangeCount(.done)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            tableView.endUpdates()
        }
    }
// UITableView delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.myIndexPathRow = indexPath.row
        self.myCell = tableView.cellForRow(at: indexPath) as? ChoreoCell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Counts\t\tSteps"
    }
    
// Mark ChoreoCell data entry by the user

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard var txt : String = textField.text else {
            return
        }
        if (txt == "") {
            txt = " "
        }
        var v:UIView = textField
        repeat { v = v.superview!} while !(v is UITableViewCell)
        let cell = v as! ChoreoCell
        let ip = self.tableView.indexPath(for: cell)!
        switch (textField) {
        case cell.countText:
            let myCountSteps = CountSteps(counts:txt, steps:cell.stepText.text! )
            self.choreography[ip.row] = myCountSteps
        case cell.stepText:
            let myCountSteps = CountSteps(counts:cell.countText.text!, steps:txt )
            self.choreography[ip.row] = myCountSteps
        default:
            print ("Unexpected textField case")
        }
        self.danceDoc?.choreography[ip.row] = self.choreography[ip.row]
        self.danceDoc?.updateChangeCount(.done)
        return
    }
    
// MARK Save the file to the user's Documents directory
    
     func saveEdits(_ sender: UIBarButtonItem? = nil) {
        func reportSuccess(_ success:Bool) {
            if !success {
                
                print ("writing to the file was UNsuccessful")
            }
        }
        self.danceDoc?.choreography = self.choreography
        self.danceDoc?.save(to: self.documentURL!, for: .forOverwriting, completionHandler: reportSuccess)
    }
// MARK Dismiss the currently chosen file and save it
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        if danceDoc?.choreography != nil {
           danceDoc?.thumbnail = self.view.snapshot
        }
        saveEdits()
        // tidy up music player, etc
        self.player.stop()
        self.playPauseButton.title  = TitlesForButtons.playString
        self.trackStartLabel.title = " 0:00"
        self.startTimeSlider.value = 0.0
        self.trackInfoLabel.title =  " "
        self.trackLengthLabel.title = "Track Length: 0.00"
        self.timer?.invalidate()
        dismiss(animated: true) {
            self.danceDoc?.close()
        }
    }
    
// MARK properties for music file handling
    
    var myURL:URL? = nil
    var myLabelText: String = ""
    var trackTime = 0.0
    var startTime = 0.0
    var mediaItemCollection:MPMediaItemCollection? = nil
    let player = MPMusicPlayerController.applicationMusicPlayer
    weak var timer: Timer?
    
// MARK Outlets
    
    @IBOutlet weak var startTimeSlider: UISlider!
    @IBOutlet weak var playPauseButton: UIBarButtonItem!
    @IBOutlet weak var trackStartLabel: UIBarButtonItem!
    @IBOutlet weak var trackLengthLabel: UIBarButtonItem!
    @IBOutlet weak var trackInfoLabel: UIBarButtonItem!
// MARK: View Controller Lifecycle
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
// MARK: unwind from the print view controller
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        
    }
// MARK: Prepare for printing to an Airprint printer
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     
    var destinationvc = segue.destination
    if let navcon = destinationvc as? UINavigationController {
        destinationvc = navcon.visibleViewController ?? destinationvc
    }
        let danceText: String = self.navigationItem.title! + "\n Counts \tSteps \n"
        let myTitle: UIFont = .preferredFont(forTextStyle: .headline)
        let myBody: UIFont = .preferredFont(forTextStyle: .body)
        let content = NSMutableAttributedString(string: danceText, attributes: [NSAttributedStringKey.font: myTitle] )
        let pStyle1 = NSMutableParagraphStyle()
        pStyle1.firstLineHeadIndent = 10
        pStyle1.headIndent = 80
        pStyle1.alignment = .left
        pStyle1.paragraphSpacing = 5
        pStyle1.tabStops = []
        let tab1 = NSTextTab(textAlignment: .left, location: 80 )
        pStyle1.tabStops.append(tab1)
        content.addAttribute(NSAttributedStringKey.paragraphStyle, value: pStyle1, range: NSMakeRange(0,1))
        for i in 0...self.choreography.count-1 {
            let countsteps = self.choreography[i]
            let content1 = NSMutableAttributedString(string: countsteps.counts, attributes:[ NSAttributedStringKey.font: myBody, NSAttributedStringKey.paragraphStyle: pStyle1])
            content.append(content1)
            let content2 = NSMutableAttributedString(string: "\t" + countsteps.steps + "\n" , attributes:[ NSAttributedStringKey.font: myBody, NSAttributedStringKey.paragraphStyle: pStyle1])
            content.append(content2)
        }        
    if let printvc = destinationvc as? PrintViewController {
        if  segue.identifier == "PrintFile"{
            printvc.fileText = content
            printvc.title = self.navigationItem.title
        }
    }
}
    // MARK: User Music Library Access
    
    func checkForMusicLibraryAccess() {
        let status = MPMediaLibrary.authorizationStatus()
        switch status {
        case .authorized:
            break
        case .notDetermined:
            MPMediaLibrary.requestAuthorization() { status in
                if status == .authorized {
                    DispatchQueue.main.async {
                        print("OK to choose music")
                    }
                }
            }
        case .restricted:
            break
        case .denied:
            break
        }
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let myItem =  mediaItemCollection.items[0]
        if let title = myItem.title {
            self.myLabelText = title
        }else {self.myLabelText = "Untitled" }
        self.trackInfoLabel.title = self.myLabelText
        let url = myItem.assetURL!
        self.myURL = url
        self.trackTime = myItem.playbackDuration
        let timeLabel = "Track Length:"
        self.trackLengthLabel.title = convertSeceondsToMinutes(myItem.playbackDuration, label: timeLabel)
        self.mediaItemCollection = mediaItemCollection
        self.player.setQueue(with:self.mediaItemCollection!)
        self.player.repeatMode = .one  //automatically repeat
        self.player.stop()
        self.dismiss(animated: true)
    }

    @objc func timerFired(_: Any) {
        let player = MPMusicPlayerController.applicationMusicPlayer
        guard let item = player.nowPlayingItem, player.playbackState != .stopped else {
            return
        }
        let current = player.currentPlaybackTime
        let total = item.playbackDuration
//        let timeLeft = total - current
        self.startTimeSlider.value = Float(current/total)
//        self.trackLengthLabel.title = convertSeceondsToMinutes(timeLeft, label: " ")
        self.trackStartLabel.title = convertSeceondsToMinutes(current, label: " ")
    }
    
    func convertSeceondsToMinutes(_ time: (Double), label: (String)) ->  String?{
        let minutes = String( format: "%d",Int(time/60.0))
        let newTime = Int(time) - Int(time/60.0)*60
        let seconds = String( format: "%d", newTime)
        if newTime < 10 {
            return label+minutes+":0"+seconds
        }
        return label+minutes+":"+seconds
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController){
        self.dismiss(animated: true)
    }
    @IBAction func chooseStartPosition(_ sender: UISlider) {
        self.player.pause()
        self.playPauseButton.title = TitlesForButtons.pauseString
        self.player.currentPlaybackTime = Double(self.startTimeSlider.value)*self.trackTime
        let startLabel = " "
        self.trackStartLabel.title = convertSeceondsToMinutes(self.player.currentPlaybackTime, label: startLabel)
//        let timeLeft = self.trackTime - self.player.currentPlaybackTime
//        self.trackLengthLabel.title = convertSeceondsToMinutes(timeLeft, label: " ")
        self.playPauseButton.title = TitlesForButtons.playString
    }
// MARK bar button actions
    @IBAction func startMusic(_ sender: UIBarButtonItem) {
        if (sender.title  == TitlesForButtons.playString || sender.title  == TitlesForButtons.pauseString ){
            switch self.player.playbackState {
            case .stopped:
                self.player.prepareToPlay()
                self.player.play()
                sender.title  = TitlesForButtons.pauseString
            case .playing:
                self.player.pause()
                sender.title  = TitlesForButtons.playString
            case .paused:
                self.player.play()
                sender.title  = TitlesForButtons.pauseString
            case .interrupted:
                self.player.pause()
                sender.title  = TitlesForButtons.playString
            default:
                break
            }
        }
    }
    
    @IBAction func chooseMusic(_ sender: UIBarButtonItem) {
        self.player.stop()
        self.playPauseButton.title  = TitlesForButtons.playString
        self.trackStartLabel.title = " 0:00"
        self.startTimeSlider.setValue(Float(0.0), animated: true)
        self.trackInfoLabel.title =  " "
        self.trackLengthLabel.title = "Track Length:0.00"
        let picker = MPMediaPickerController(mediaTypes: .music)
        picker.delegate = self
        picker.allowsPickingMultipleItems = false
        picker.showsCloudItems = false
        self.present(picker, animated: true)
    }
}

