//
//  CTFGoNoGoStepViewController.swift
//  ORKCatalog
//
//  Created by James Kizer on 9/29/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

import UIKit
import ResearchKit

enum CTFGoNoGoCueType {
    case Go
    case NoGo
}

enum CTFGoNoGoTargetType {
    case Go
    case NoGo
}

struct CTFGoNoGoTrial {
    
    var waitTime: NSTimeInterval?
    var crossTime : NSTimeInterval?
    var blankTime:NSTimeInterval?
    var cueTime: NSTimeInterval?
    var fillTime : NSTimeInterval?
    
    var cue: CTFGoNoGoCueType?
    var target: CTFGoNoGoTargetType?
    
    var trialIndex: Int?
    
}

struct CTFGoNoGoTrialResult {
    
    var trial: CTFGoNoGoTrial?
    
    var responseTime: NSTimeInterval?
    var tapped: Bool?
    
}

extension Array {
    func random() -> Element? {
        if self.count == 0 {
            return nil
        }
        else{
            let index = Int(arc4random_uniform(UInt32(self.count)))
            return self[index]
        }
    }
}

class CTFGoNoGoStepViewController: ORKStepViewController {

    
    @IBOutlet weak var goNoGoView: CTFGoNoGoView!
    
    var trials: [CTFGoNoGoTrial]?
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override convenience init(step: ORKStep?) {
        let framework = NSBundle(forClass: CTFGoNoGoStepViewController.self)
        self.init(nibName: "CTFGoNoGoStepViewController", bundle: framework)
        self.step = step
        self.restorationIdentifier = step!.identifier
        self.restorationClass = CTFGoNoGoStepViewController.self
        guard let goNoGoStep = self.step as? CTFGoNoGoStep,
        let params = goNoGoStep.goNoGoParams else {
            return
        }
        self.trials = self.generateTrials(params)
    }
    
    func generateTrials(goNoGoParams:CTFGoNoGoStepParams) -> [CTFGoNoGoTrial]? {
        if let numTrials = goNoGoParams.numTrials {
            return (0..<numTrials).map { index in
                let cueTime: NSTimeInterval = (goNoGoParams.cueTimeOptions?.random())!
                let cueType: CTFGoNoGoCueType = [CTFGoNoGoCueType.Go, CTFGoNoGoCueType.NoGo].random()!
                let targetType: CTFGoNoGoTargetType = [CTFGoNoGoTargetType.Go, CTFGoNoGoTargetType.NoGo].random()!
                
                return CTFGoNoGoTrial(
                    waitTime: goNoGoParams.waitTime,
                    crossTime: goNoGoParams.crossTime,
                    blankTime: goNoGoParams.blankTime,
                    cueTime: cueTime,
                    fillTime: goNoGoParams.fillTime,
                    cue: cueType,
                    target: targetType,
                    trialIndex: index)
                
            }
        }
        else {
            return nil
        }
    }
    
    override convenience init(step: ORKStep?, result: ORKResult?) {
        self.init(step: step)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let trials = self.trials {
            self.performTrials(trials, results: [], completion: { (results) in
                print(results)
            })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var result: ORKStepResult? {
        guard let parentResult = super.result else {
            return nil
        }
        return parentResult
    }
    
    func performTrials(trials: [CTFGoNoGoTrial], results: [CTFGoNoGoTrialResult], completion: ([CTFGoNoGoTrialResult]) -> ()) {
        if let head = trials.first {
            let tail = Array(trials.dropFirst())
            doTrial(head, completion: { (result) in
                var newResults = Array(results)
                newResults.append(result)
                self.performTrials(tail, results: newResults, completion: completion)
            })
        }
        else {
            completion(results)
        }
    }
    
    //impliment trial
    func doTrial(trial: CTFGoNoGoTrial, completion: (CTFGoNoGoTrialResult) -> ()) {
        let result = CTFGoNoGoTrialResult(trial: trial, responseTime: 0.0, tapped: true)
        completion(result)
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
