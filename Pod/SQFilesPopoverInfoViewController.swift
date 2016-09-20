//
//  SQFilesPopoverInfoViewController.swift
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

import UIKit


class SQFilesPopoverInfoViewController: UIViewController {
    
    
    class func heightForPopoverWidth(width: CGFloat) -> CGFloat {
        let text: NSString = "This app uses Real-Time Personalization® (RTP) technology to analyze your genes and the weather, together. You'll receive daily guidance that is genetically tailored to you. This guidance is your forecast for a healthier day!\n\nRTP is as easy as 1, 2, 3...\n\n1) RTP is powered by genetic data. What genetic data do you want to use?\nSelect \"My Files\" to use your own data.\nSelect \"Sample Files\" to use fun sample data.\n\n2) On the next screen, a list of files will appear. Select one file from the list.\nThis app's Real-Time Personalization® will be powered by the genetic data in the file you select.\n\n3) Press Continue.\nWeather My Way will analyze your genes and the weather each day."
        
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
        
        return CGRectGetHeight(rect) + 180
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
