//
//  SQFilesPopoverInfoViewController.swift
//  Copyright © 2017 Sequencing.com. All rights reserved
//


import UIKit


class SQFilesPopoverInfoViewController: UIViewController {
    
    
    class func heightForPopoverWidth(_ width: CGFloat) -> CGFloat {
        let text: NSString = "RTP = Real-Time Personalization®\nRTP is as easy as 1, 2, 3...\n\n1) Choose whether you want to use a sample file or your own file.\nIf you want to use your own file, you will be able to select from a list of files stored in your Sequencing.com account.\n\n2) Wait a moment for the list of files to appear and then select a file.\nThis app's Real-Time Personalization® will then be powered by the genetic data in the file you select.\n\n3) Press continue."
        
        let font = UIFont.systemFont(ofSize: 14)
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: -1)
        shadow.shadowBlurRadius = 0.5
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraph.alignment = NSTextAlignment.left
        
        let size = CGSize(width: width - 30, height:CGFloat.greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        
        let rect: CGRect = text.boundingRect(with: size,
                                             options: options,
                                             attributes: [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraph, NSShadowAttributeName: shadow],
                                             context: nil)
        return rect.height + 180
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    
}
