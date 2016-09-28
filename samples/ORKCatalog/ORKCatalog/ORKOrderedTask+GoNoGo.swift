//
//  ORKOrderedTask+GoNoGo.swift
//  ORKCatalog
//
//  Created by Francesco Perera on 9/28/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

import Foundation
import ResearchKit

extension ORKOrderedTask{

    
    class func goNoGo(identifier:String,params:CTFGoNoGoStepParams?) -> ORKOrderedTask {
        
        return CTFGoNoGoTask(identifier: identifier, params: params)
        
    }
}
