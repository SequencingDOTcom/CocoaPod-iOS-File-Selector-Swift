//
//  SQFilesPopoverMyFilesViewController.swift
//  Copyright © 2017 Sequencing.com. All rights reserved
//


import UIKit


class SQFilesPopoverMyFilesViewController: UIViewController {
    
    
    class func heightForPopoverWidth(_ width: CGFloat) -> CGFloat {
        let text: NSString = "Your Sequencing.com account doesn't appear to have any genetic data.\n\nPlease go to the Upload Center at Sequencing.com to upload your genetic data. You'll then be able to connect this app with your genetic data.\n\nUntil then, please use one of the following sample files."
        
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
        return rect.height + 40
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }


}
