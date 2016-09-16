//
//  SQFilesPopoverMyFilesViewController.swift
//  oauthdemoapp-swift
//
//  Created by Bogdan Laukhin on 9/12/16.
//  Copyright © 2016 ua.org. All rights reserved.
//

import UIKit


class SQFilesPopoverMyFilesViewController: UIViewController {
    
    
    class func heightForPopoverWidth(width: CGFloat) -> CGFloat {
        let text: NSString = "Your Sequencing.com account doesn't appear to have any genetic data.\n\nPlease go to the Upload Center at Sequencing.com to upload your genetic data. You'll then be able to connect this app with your genetic data.\n\nUntil then, please use one of the following sample files."
        
        let font = UIFont.systemFontOfSize(14)
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: -1)
        shadow.shadowBlurRadius = 0.5
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraph.alignment = NSTextAlignment.Left
        
        let size = CGSize(width: width - 30, height:CGFloat.max)
        let options: NSStringDrawingOptions = [.UsesLineFragmentOrigin, .UsesFontLeading]
        
        let rect: CGRect = text.boundingRectWithSize(size,
                                                     options: options,
                                                     attributes: [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraph, NSShadowAttributeName: shadow],
                                                     context: nil)
        
        return CGRectGetHeight(rect) + 40
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
