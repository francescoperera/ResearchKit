//
//  CTFGoNoGoStepViewController.swift
//  ORKCatalog
//
//  Created by James Kizer on 9/28/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

import UIKit
import ResearchKit

class CTFGoNoGoActiveStepViewController: ORKActiveStepViewController {
    
    let goNoGoView: CTFGoNoGoView = CTFGoNoGoView(frame: CGRectZero)
    
    override func prepareStep() {
        super.prepareStep()
        if self.customView == nil {
            self.customView = self.goNoGoView
        }
    }
    
}
