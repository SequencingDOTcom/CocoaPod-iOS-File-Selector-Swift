//
//  SQDemoDataCell.swift
//  Copyright © 2017 Sequencing.com. All rights reserved
//


import UIKit


class SQFilesTableCell: UITableViewCell {
    
    
    @IBOutlet weak var cellLabel: UILabel!
    
    
    class func heightForRow(_ text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 13)
        
        let shadow: NSShadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 0, height: -1)
        shadow.shadowBlurRadius = 0.5
        
        let paragraph: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraph.alignment = NSTextAlignment.left
        
        let options = unsafeBitCast(NSStringDrawingOptions.usesLineFragmentOrigin.rawValue |
            NSStringDrawingOptions.usesFontLeading.rawValue,
            to: NSStringDrawingOptions.self)
        
        let rect: CGRect = text.boundingRect(
            with: CGSize(width: 280, height: CGFloat.greatestFiniteMagnitude),
            options: options, // NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraph, NSShadowAttributeName: shadow],
            context: nil)
        
        if rect.height < 42.960938 {
            return 43.0
        } else {
            return rect.height + 20
        }
    }
    
    
    class func prepareText(_ text: NSDictionary, FromFileType fileType: String) -> String {
        var preparedText = String()
        if fileType.contains("Sample") {
            // working with sample file type
            let friendlyDesc1 = text.object(forKey: "FriendlyDesc1") as? String
            let friendlyDesc2 = text.object(forKey: "FriendlyDesc2") as? String
            preparedText += friendlyDesc1! + "\n" + friendlyDesc2!
        } else {
            // working with own file type
            let fileName = text.object(forKey: "Name") as! String?
            preparedText += fileName!
        }
        return preparedText
    }
    
    
    class func prepareText(_ demoText: NSDictionary) -> String {
        var preparedText = String()
        let keys = NSArray(array: demoText.allKeys)
        
        let descriptor: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortedKeys = keys.sortedArray(using: [descriptor]) as NSArray
        // let sortedKeys = keys.sort { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        // let sortedKeys: NSArray = keys.sortedArray(using: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        
        for key in sortedKeys {
            let keyString = key as! String
            
            if demoText.object(forKey: key) is NSNull {
                preparedText = preparedText + keyString + ": \"" + "<null>\"" + "\n"
                
            } else if let value = demoText.object(forKey: key) as! String? {
                preparedText = preparedText + keyString + ": \"" + value + "\"\n"
                
            } else {
                preparedText = preparedText + keyString + ": \"" + "nil\"" + "\n"
            }
        }        
        return preparedText
    }
    
    
    
    
    
}
