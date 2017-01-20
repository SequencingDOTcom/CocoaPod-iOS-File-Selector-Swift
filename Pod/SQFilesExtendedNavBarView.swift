//
//  SQFilesExtendedNavBarView.swift
//  Copyright © 2017 Sequencing.com. All rights reserved
//


import UIKit


class SQFilesExtendedNavBarView: UIView {

    override func willMove(toWindow newWindow: UIWindow?) {
        self.layer.shadowOffset = CGSize(width: 0, height: 1/UIScreen.main.scale)
        self.layer.shadowRadius = 0
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.25
    }

}
