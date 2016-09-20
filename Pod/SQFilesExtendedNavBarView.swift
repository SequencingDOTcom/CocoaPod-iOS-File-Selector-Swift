//
//  SQFilesExtendedNavBarView.swift
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

import UIKit


class SQFilesExtendedNavBarView: UIView {

    override func willMoveToWindow(newWindow: UIWindow?) {
        self.layer.shadowOffset = CGSize(width: 0, height: 1/UIScreen.mainScreen().scale)
        self.layer.shadowRadius = 0
        
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.25
    }

}
