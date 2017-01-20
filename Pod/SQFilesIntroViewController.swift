//
//  SQFilesIntroViewController.swift
//  Copyright © 2017 Sequencing.com. All rights reserved
//


import UIKit
import AVFoundation
import QuartzCore


class SQFilesIntroViewController: UIViewController, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var introLabel: UILabel!
    
    @IBOutlet weak var myFilesButton: UIView!
    @IBOutlet weak var myFilesIcon: UIImageView!
    @IBOutlet weak var myFilesLabel: UILabel!
    
    @IBOutlet weak var sampleFilesButton: UIView!
    @IBOutlet weak var sampleFilesIcon: UIImageView!
    @IBOutlet weak var sampleFilesLabel: UILabel!
    
    var infoButton = UIBarButtonItem()
    let FILES_CONTROLLER_SEGUE_ID = "SHOW_FILES_SEGUE_ID"
    
    // properties for videoPlayer
    var avPlayer        = AVPlayer()
    var videoPlayerView = UIView()
    var videoLayer      = AVPlayerLayer()
    
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        let filesAPI = SQFilesAPI.instance
        var defaultTextColor = UIColor.black
        
        if filesAPI.videoFileName != nil {   // we have video file
            defaultTextColor = UIColor.white
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.view.backgroundColor = UIColor.black
            introLabel.textColor = UIColor.white
            
        } else {    // we do not have video file
            grayView.backgroundColor = UIColor.clear
        }
        
        // set up font title
        self.title = "Select a file"
        let titleFont = UIFont(name: "HelveticaNeue-Light", size: 19) ?? UIFont.systemFont(ofSize: 19)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: titleFont,
                                                                        NSForegroundColorAttributeName: defaultTextColor]
        
        // closeButton
        if filesAPI.closeButton {
            let closeButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.stop,
                                                   target: self,
                                                   action: #selector(self.closeButtonPressed))
            self.navigationItem.setLeftBarButton(closeButton, animated: true)
        }
        
        // infoButton
        let button = UIButton(type: .infoLight)
        button.addTarget(self, action: #selector(self.showInfoPopover), for: UIControlEvents.touchUpInside)
        infoButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.setRightBarButton(infoButton, animated: true)
        
        // myFiles button
        myFilesButton.layer.cornerRadius = 5
        myFilesButton.layer.masksToBounds = true
        
        let myFilesIconTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.myFilesButtonPressed))
        myFilesIconTapGesture.numberOfTapsRequired = 1
        myFilesIconTapGesture.delegate = self
        myFilesIcon.isUserInteractionEnabled = true
        myFilesIcon.addGestureRecognizer(myFilesIconTapGesture)
        
        let myFilesLabelTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.myFilesButtonPressed))
        myFilesLabelTapGesture.numberOfTapsRequired = 1
        myFilesLabelTapGesture.delegate = self
        myFilesLabel.isUserInteractionEnabled = true
        myFilesLabel.addGestureRecognizer(myFilesLabelTapGesture)
        
        // sampleFiles button
        sampleFilesButton.layer.cornerRadius = 5
        sampleFilesButton.layer.masksToBounds = true
        
        let sampleFilesIconTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.myFilesButtonPressed))
        sampleFilesIconTapGesture.numberOfTapsRequired = 1
        sampleFilesIconTapGesture.delegate = self
        sampleFilesIcon.isUserInteractionEnabled = true
        sampleFilesIcon.addGestureRecognizer(sampleFilesIconTapGesture)
        
        let sampleFilesLabelTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.myFilesButtonPressed))
        sampleFilesLabelTapGesture.numberOfTapsRequired = 1
        sampleFilesLabelTapGesture.delegate = self
        sampleFilesLabel.isUserInteractionEnabled = true
        sampleFilesLabel.addGestureRecognizer(sampleFilesLabelTapGesture)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if SQFilesAPI.instance.videoFileName != nil {
            self.initializeAndAddVideoToView()
            
            if self.isVideoWhite() {
                self.navigationController?.navigationBar.setBackgroundImage(self.greyTranspanentImage(), for: UIBarMetrics.default)
            }
            
            // video
            self.playVideo()
            self.addNotificationObserves()
        }
    }
    
    
    override func viewDidLayoutSubviews() -> Void {
        super.viewDidLayoutSubviews()
        self.updateVideoLayerFrame()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        self.pauseVideo()
        self.deallocateAndRemoveVideoFromView()
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.pauseVideo()
        self.deallocateAndRemoveVideoFromView()
    }
    
    
    
    // MARK: - Video Player Methods
    func initializeAndAddVideoToView() -> Void {
        if let fileName = SQFilesAPI.instance.videoFileName {   // set up videoPlayer with local video file
            
            let filepath = Bundle.main.path(forResource: fileName as String, ofType: nil, inDirectory: "Video")
            if filepath != nil {
                let fileURL = URL(fileURLWithPath: filepath!)
                
                avPlayer = AVPlayer.init(url: fileURL)
                avPlayer.actionAtItemEnd = .none
                
                // set up videoLayer that will include video player
                videoLayer = AVPlayerLayer.init(player: avPlayer)
                videoLayer.frame = self.view.bounds
                videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                // set up separate uiview in order to add it later to the back in views hierarchy
                videoPlayerView = UIView()
                videoPlayerView.layer.addSublayer(videoLayer)
                
                self.view.addSubview(videoPlayerView)
                self.view.sendSubview(toBack: videoPlayerView)
                
                avPlayer.play()
            }
        }
    }
    
    
    func deallocateAndRemoveVideoFromView() {
        avPlayer.pause()
        videoPlayerView.removeFromSuperview()
    }
    
    
    func updateVideoLayerFrame() -> Void {
        videoLayer.frame = self.view.bounds
        videoLayer.setNeedsDisplay()
    }
    
    
    func itemDidFinishPlaying(_ notification: Notification) -> Void {
        if let player = notification.object as? AVPlayerItem {
            player.seek(to: kCMTimeZero)
        }
    }
    
    
    func playVideo() -> Void {
        avPlayer.play()
    }
    
    func pauseVideo() -> Void {
        avPlayer.pause()
    }
    
    
    func addNotificationObserves() -> Void {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.itemDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.pauseVideo),
                                               name: NSNotification.Name.UIApplicationWillResignActive,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playVideo),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
    }
    
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if SQFilesAPI.instance.videoFileName != nil {
            return UIStatusBarStyle.lightContent
        } else {
            return UIStatusBarStyle.default
        }
    }
    
    
    
    // MARK: - Action Methods
    func myFilesButtonPressed() -> Void {
        self.performSegue(withIdentifier: FILES_CONTROLLER_SEGUE_ID, sender: NSNumber(value: 0 as Int))
        
    }
    
    func sampleFilesButtonPressed() -> Void {
        self.performSegue(withIdentifier: FILES_CONTROLLER_SEGUE_ID, sender: NSNumber(value: 1 as Int))
    }
    
    
    // close button tapped
    func closeButtonPressed() -> Void {
        SQFilesAPI.instance.selectedFileID = nil
        SQFilesAPI.instance.selectedFileDelegate?.closeButtonPressed?()
    }
    
    
    
    // MARK: - UIPopoverPresentationControllerDelegate
    func showInfoPopover() -> Void {
        let popoverContentController = UIViewController.init(nibName: "SQFilesPopoverInfoViewController", bundle: nil)
        
        let height = SQFilesPopoverInfoViewController.heightForPopoverWidth(self.view.bounds.size.width - 30)
        popoverContentController.preferredContentSize = CGSize(width: self.view.bounds.size.width - 30, height: height)
        
        popoverContentController.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverContentController.popoverPresentationController?.delegate = self
        
        self.present(popoverContentController, animated: true, completion: nil)
    }
    
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.any
        popoverPresentationController.barButtonItem = infoButton
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueIdentifier = segue.identifier as NSString!
        if (segueIdentifier?.isEqual(self.FILES_CONTROLLER_SEGUE_ID))! {
            let indexToShow = NSNumber(value: sender as! Int as Int)
            let tabBar = segue.destination as! UITabBarController
            tabBar.selectedIndex = indexToShow.intValue
        }
    }
    
    
    
    
    // MARK: - White Vide Helper
    func isVideoWhite() -> Bool {
        var videoFileIsWhite: Bool = false
        let filesAPI = SQFilesAPI.instance
        let arrayOfVideoFilesWithWhiteBarInTheTop: NSArray = ["shutterstock_v120847.mp4",
                                                              "shutterstock_v1126162.mp4",
                                                              "shutterstock_v3036661.mp4",
                                                              "shutterstock_v4314167.mp4",
                                                              "shutterstock_v3753200.mp4",
                                                              "shutterstock_v4627466.mp4",
                                                              "shutterstock_v5468858.mp4"]
        if let fileName = filesAPI.videoFileName {
            if arrayOfVideoFilesWithWhiteBarInTheTop.contains(fileName) {
                videoFileIsWhite = true
            }
            
        }
        return videoFileIsWhite
    }
    
    
    func greyTranspanentImage() -> UIImage {
        var image = UIImage()
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        if let context: CGContext = UIGraphicsGetCurrentContext() {
            let greyTranspanentColor: UIColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 0.6)
            context.setFillColor(greyTranspanentColor.cgColor)
            context.fill(rect)
            image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        return image
    }
    
    

}
