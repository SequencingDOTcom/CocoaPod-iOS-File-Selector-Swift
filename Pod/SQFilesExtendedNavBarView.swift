//
//  SQFilesExtendedNavBarView.swift
//  oauthdemoapp-swift
//
//  Created by Bogdan Laukhin on 9/9/16.
//  Copyright © 2016 ua.org. All rights reserved.
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
