//
//  SQFilesIntroViewController.swift
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
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
        
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        
        let filesAPI = SQFilesAPI.instance
        var defaultTextColor = UIColor.blackColor()
        
        if filesAPI.videoFileName != nil {   // we have video file
            defaultTextColor = UIColor.whiteColor()
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            self.view.backgroundColor = UIColor.blackColor()
            introLabel.textColor = UIColor.whiteColor()
            
        } else {    // we do not have video file
            grayView.backgroundColor = UIColor.clearColor()
        }
        
        // set up font title
        self.title = "Select a file"
        let titleFont = UIFont(name: "HelveticaNeue-Light", size: 19) ?? UIFont.systemFontOfSize(19)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: titleFont, NSForegroundColorAttributeName: defaultTextColor]
        
        // closeButton
        if filesAPI.closeButton {
            let closeButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: #selector(self.closeButtonPressed))
            self.navigationItem.setLeftBarButtonItem(closeButton, animated: true)
        }
        
        // infoButton
        let button = UIButton(type: .InfoLight)
        button.addTarget(self, action: #selector(self.showInfoPopover), forControlEvents: UIControlEvents.TouchUpInside)
        infoButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.setRightBarButtonItem(infoButton, animated: true)
        
        // myFiles button
        myFilesButton.layer.cornerRadius = 5
        myFilesButton.layer.masksToBounds = true
        
        let myFilesIconTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.myFilesButtonPressed))
        myFilesIconTapGesture.numberOfTapsRequired = 1
        myFilesIconTapGesture.delegate = self
        myFilesIcon.userInteractionEnabled = true
        myFilesIcon.addGestureRecognizer(myFilesIconTapGesture)
        
        let myFilesLabelTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.myFilesButtonPressed))
        myFilesLabelTapGesture.numberOfTapsRequired = 1
        myFilesLabelTapGesture.delegate = self
        myFilesLabel.userInteractionEnabled = true
        myFilesLabel.addGestureRecognizer(myFilesLabelTapGesture)
        
        // sampleFiles button
        sampleFilesButton.layer.cornerRadius = 5
        sampleFilesButton.layer.masksToBounds = true
        
        let sampleFilesIconTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.myFilesButtonPressed))
        sampleFilesIconTapGesture.numberOfTapsRequired = 1
        sampleFilesIconTapGesture.delegate = self
        sampleFilesIcon.userInteractionEnabled = true
        sampleFilesIcon.addGestureRecognizer(sampleFilesIconTapGesture)
        
        let sampleFilesLabelTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.myFilesButtonPressed))
        sampleFilesLabelTapGesture.numberOfTapsRequired = 1
        sampleFilesLabelTapGesture.delegate = self
        sampleFilesLabel.userInteractionEnabled = true
        sampleFilesLabel.addGestureRecognizer(sampleFilesLabelTapGesture)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if SQFilesAPI.instance.videoFileName != nil {
            self.initializeAndAddVideoToView()
            
            if self.isVideoWhite() {
                self.navigationController?.navigationBar.setBackgroundImage(self.greyTranspanentImage(), forBarMetrics: UIBarMetrics.Default)
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
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.pauseVideo()
        self.deallocateAndRemoveVideoFromView()
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.pauseVideo()
        self.deallocateAndRemoveVideoFromView()
    }
    
    
    
    // MARK: - Video Player Methods
    func initializeAndAddVideoToView() -> Void {
        if let fileName = SQFilesAPI.instance.videoFileName {   // set up videoPlayer with local video file
            let filepath = NSBundle.mainBundle().pathForResource(fileName as String, ofType: nil, inDirectory: "Video")
            if filepath != nil {
                let fileURL = NSURL.fileURLWithPath(filepath!)
                
                avPlayer = AVPlayer.init(URL: fileURL)
                avPlayer.actionAtItemEnd = .None
                
                // set up videoLayer that will include video player
                videoLayer = AVPlayerLayer.init(player: avPlayer)
                videoLayer.frame = self.view.bounds
                videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                // set up separate uiview in order to add it later to the back in views hierarchy
                videoPlayerView = UIView()
                videoPlayerView.layer.addSublayer(videoLayer)
                
                self.view.addSubview(videoPlayerView)
                self.view.sendSubviewToBack(videoPlayerView)
                
                avPlayer.play()
            }
        }
    }
    
    
    func deallocateAndRemoveVideoFromView() {
        avPlayer.pause()
        //avPlayer = nil
        videoPlayerView.removeFromSuperview()
    }
    
    
    func updateVideoLayerFrame() -> Void {
        videoLayer.frame = self.view.bounds
        videoLayer.setNeedsDisplay()
    }
    
    
    func itemDidFinishPlaying(notification: NSNotification) -> Void {
        if let player = notification.object as? AVPlayerItem {
            player.seekToTime(kCMTimeZero)
        }
    }
    
    
    func playVideo() -> Void {
        avPlayer.play()
    }
    
    func pauseVideo() -> Void {
        avPlayer.pause()
    }
    
    
    func addNotificationObserves() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.itemDidFinishPlaying(_:)),
                                                         name: AVPlayerItemDidPlayToEndTimeNotification,
                                                         object: avPlayer.currentItem)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.pauseVideo),
                                                         name: UIApplicationWillResignActiveNotification,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.playVideo),
                                                         name: UIApplicationDidBecomeActiveNotification,
                                                         object: nil)
    }
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if SQFilesAPI.instance.videoFileName != nil {
            return UIStatusBarStyle.LightContent
        } else {
            return UIStatusBarStyle.Default
        }
    }
    
    
    
    // MARK: - Action Methods
    func myFilesButtonPressed() -> Void {
        self.performSegueWithIdentifier(FILES_CONTROLLER_SEGUE_ID, sender: NSNumber(integer:0))
        
    }
    
    func sampleFilesButtonPressed() -> Void {
        self.performSegueWithIdentifier(FILES_CONTROLLER_SEGUE_ID, sender: NSNumber(integer:1))
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
        popoverContentController.preferredContentSize = CGSizeMake(self.view.bounds.size.width - 30, height)
        
        popoverContentController.modalPresentationStyle = UIModalPresentationStyle.Popover
        popoverContentController.popoverPresentationController?.delegate = self
        
        self.presentViewController(popoverContentController, animated: true, completion: nil)
    }
    
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection.Any
        popoverPresentationController.barButtonItem = infoButton
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueIdentifier = segue.identifier as NSString!
        if segueIdentifier.isEqual(self.FILES_CONTROLLER_SEGUE_ID) {
            let indexToShow = NSNumber(integer: sender as! Int)
            let tabBar = segue.destinationViewController as! UITabBarController
            tabBar.selectedIndex = indexToShow.integerValue
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
            if arrayOfVideoFilesWithWhiteBarInTheTop.containsObject(fileName) {
                videoFileIsWhite = true
            }
            
        }
        return videoFileIsWhite
    }
    
    
    func greyTranspanentImage() -> UIImage {
        var image = UIImage()
        let rect: CGRect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        if let context: CGContextRef = UIGraphicsGetCurrentContext() {
            let greyTranspanentColor: UIColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 0.6)
            CGContextSetFillColorWithColor(context, greyTranspanentColor.CGColor)
            CGContextFillRect(context, rect)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return image
    }
    
    
    
    // MARK: - Memory helper
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}
