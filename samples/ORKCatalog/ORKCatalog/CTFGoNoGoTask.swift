//
//  CTFGoNoGoTask.swift
//  ORKCatalog
//
//  Created by Francesco Perera on 9/28/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

import Foundation
import ResearchKit

class CTFGoNoGoTask: ORKOrderedTask {
    
    static let CTFGoNoGoStepIdentifier: String = "goNoGoStep"
    
    init(identifier:String,
         params:CTFGoNoGoStepParams?) {
        
        let goNoGo = CTFGoNoGoStep(identifier: CTFGoNoGoTask.CTFGoNoGoStepIdentifier)
        
        goNoGo.goNoGoParams = params
        
        super.init(identifier: identifier, steps:[goNoGo])
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
        
    

}
