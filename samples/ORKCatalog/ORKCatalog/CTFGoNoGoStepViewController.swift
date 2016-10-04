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



enum CTFGoNoGoResponseCode{
    /**
     * correctBlue = user does not tap when rectangle is blue (NoGo target)
     * incorrectBlue = user taps when rectangle is blue ( NoGo target)
     * correctGreen = user taps when rectangle is green (Go target)
     * incorrectGreen = user does not tap when rectangle is green (Go target)
    */
    case Default
    case correctBlue
    case incorrectBlue
    case correctGreen
    case incorrectGreen
}

struct CTFGoNoGoTrial {
    
    var waitTime: NSTimeInterval!
    var crossTime : NSTimeInterval!
    var blankTime:NSTimeInterval!
    var cueTime: NSTimeInterval!
    var fillTime : NSTimeInterval!
    
    var cue: CTFGoNoGoCueType!
    var target: CTFGoNoGoTargetType!
    
    var trialIndex: Int!
    
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

class CTFGoNoGoStepViewController: ORKStepViewController, CTFGoNoGoViewDelegate {

    
    @IBOutlet weak var goNoGoView: CTFGoNoGoView!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    var correctFeedbackColor: UIColor? = UIColor(red: 52.0/255.0, green: 152.0/255.0, blue: 219.0/255.0, alpha: 1.0)
    var incorrectFeedbackColor: UIColor? = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
    
    var trials: [CTFGoNoGoTrial]?
    var trialResults: [CTFGoNoGoTrialResult]?
    
//    var trialTimer: NSTimer?
//    var trialCompletion: ((NSDate?) -> ())?
    
    var tapTime: NSDate? = nil
    
    var canceled = false
    
    let RFC3339DateFormatter = NSDateFormatter()
    
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
    
    func coinFlip<T>(obj1: T, obj2: T, bias: Float = 0.5) -> T {
        
        let realBias: Float = min(bias, 1.0)
        let flip = Float(arc4random()) /  Float(UInt32.max)
        
        if flip < realBias {
            return obj1
        }
        else {
            return obj2
        }
    }
    
    func generateTrials(goNoGoParams:CTFGoNoGoStepParams) -> [CTFGoNoGoTrial]? {
        if let numTrials = goNoGoParams.numTrials {
            return (0..<numTrials).map { index in
                let cueTime: NSTimeInterval = (goNoGoParams.cueTimeOptions?.random())!
                let cueType: CTFGoNoGoCueType = self.coinFlip(CTFGoNoGoCueType.Go, obj2: CTFGoNoGoCueType.NoGo)
                let targetType: CTFGoNoGoTargetType = self.coinFlip(CTFGoNoGoTargetType.Go, obj2: CTFGoNoGoTargetType.NoGo, bias: (cueType == CTFGoNoGoCueType.Go) ? 0.7: 0.3)
                
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
        
        
        self.RFC3339DateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        self.RFC3339DateFormatter.dateFormat = "HH:mm:ss.SSS"
        
        self.goNoGoView.delegate = self

        // Do any additional setup after loading the view.
        
        //clear results
        if let trials = self.trials {
            self.performTrials(trials, results: [], completion: { (results) in
                print(results)
                // results is a list that contains all the trial results - Francesco
                self.calculateAggregateResults(results)
                
            
                if !self.canceled {
                    //set results
                    self.trialResults = results
                    self.goForward()
                }
            })
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.canceled = true
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
        if self.canceled {
            completion([])
            return
        }
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
    
    func delay(delay:NSTimeInterval, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    //impliment trial
    func doTrial(trial: CTFGoNoGoTrial, completion: (CTFGoNoGoTrialResult) -> ()) {
        
        let delay = self.delay
        let goNoGoView = self.goNoGoView
        
        goNoGoView.state = CTFGoNoGoState.Blank
        
        print("Trial number \(trial.trialIndex)")
        
        delay(trial.waitTime) {
            
            goNoGoView.state = CTFGoNoGoState.Cross
            
            delay(trial.crossTime) {
                
                goNoGoView.state = CTFGoNoGoState.Blank
                
                delay(trial.blankTime) {
                    
                    if trial.cue == CTFGoNoGoCueType.Go {
                        goNoGoView.state = CTFGoNoGoState.GoCue
                    }
                    else {
                        goNoGoView.state = CTFGoNoGoState.NoGoCue
                    }
                    
                    delay(trial.cueTime!) {
                        
                        if trial.cue == CTFGoNoGoCueType.Go {
                            if trial.target == CTFGoNoGoTargetType.Go {
                                goNoGoView.state = CTFGoNoGoState.GoCueGoTarget
                            }
                            else {
                                goNoGoView.state = CTFGoNoGoState.GoCueNoGoTarget
                            }
                            
                        }
                        else {
                            if trial.target == CTFGoNoGoTargetType.Go {
                                goNoGoView.state = CTFGoNoGoState.NoGoCueGoTarget
                            }
                            else {
                                goNoGoView.state = CTFGoNoGoState.NoGoCueNoGoTarget
                            }
                        }
                        
                        //race for tap and timer expiration
                        let startTime: NSDate = NSDate()
                        print("Start time: \(self.RFC3339DateFormatter.stringFromDate(startTime))")
                        self.tapTime = nil
                        
                        delay(trial.fillTime) {
                            let tapped = self.tapTime != nil
                            let responseTime: NSTimeInterval = (tapped ? self.tapTime!.timeIntervalSinceDate(startTime) : trial.fillTime) * 1000
                            
                            if let tapTime = self.tapTime {
                                print("Tapped Handler: \(self.RFC3339DateFormatter.stringFromDate(tapTime))")
                            }
                            
                            goNoGoView.state = CTFGoNoGoState.Blank
                            
                            if tapped {
                                if trial.target == CTFGoNoGoTargetType.Go {
                                    self.feedbackLabel.text = "Correct! \(String(format: "%0.0f", responseTime)) ms"
                                    self.feedbackLabel.textColor = self.correctFeedbackColor
                                }
                                else {
                                    self.feedbackLabel.text = "Incorrect"
                                    self.feedbackLabel.textColor = self.incorrectFeedbackColor
                                }
                                self.feedbackLabel.hidden = false
                            }
                            delay(trial.waitTime) {
                                
                                let result = CTFGoNoGoTrialResult(trial: trial, responseTime: responseTime, tapped: tapped)
                                completion(result)
                            }
                            
                            delay(0.6) {
                                self.feedbackLabel.hidden = true
                            }
                        }
                    }
                }
                
            }
            
        }
    }
    
    func goNoGoViewDidTap(goNoGoView: CTFGoNoGoView) {
        if self.tapTime == nil {
            self.tapTime = NSDate()
        }
    }
    
    func calculateAggregateResults(results:[CTFGoNoGoTrialResult]){
        /**
         * uses data in results to calculate the aggregate results.
        */
        
        let firstThird = (results.count * 1/3) - 1
        let secondThird = (results.count * 2/3) - 1
        print(firstThird)
        print(secondThird)
        print(results.count - 1)
        
        let trialResponseCodeAndTime = results.map{(checkResponse($0.trial, tapped: $0.tapped),$0.responseTime!)}
        print(trialResponseCodeAndTime)
        
        //Mean Response Time
        let taskMeanResponseTime = trialResponseCodeAndTime.map{$0.1}.reduce(0, combine:{$0 + $1})/Double(results.count)
        let firstThirdMeanResponseTime = trialResponseCodeAndTime[0...firstThird].map{$0.1}.reduce(0, combine:{$0 + $1})/Double(results.count * 1/3)
        let secondThirdMeanResponseTime = trialResponseCodeAndTime[firstThird+1...secondThird].map{$0.1}.reduce(0, combine:{$0 + $1})/Double(results.count * 1/3)
        let lastThirdMeanResponseTime = trialResponseCodeAndTime[secondThird+1...results.count-1].map{$0.1}.reduce(0, combine:{$0 + $1})/Double(results.count * 1/3)
        print(taskMeanResponseTime,firstThirdMeanResponseTime,secondThirdMeanResponseTime,lastThirdMeanResponseTime)
        
        //Number of  Total Correct Responses
        let taskNumCorrectResponses = trialResponseCodeAndTime.filter{$0.0 == CTFGoNoGoResponseCode.correctGreen || $0.0 == CTFGoNoGoResponseCode.correctBlue}.count
        let firstThirdNumCorrectResponses = trialResponseCodeAndTime[0...firstThird].filter{$0.0 == CTFGoNoGoResponseCode.correctGreen ||
                                                                                            $0.0 == CTFGoNoGoResponseCode.correctBlue}.count
        let secondThirdNumCorrectResponses = trialResponseCodeAndTime[firstThird+1...secondThird].filter{$0.0 == CTFGoNoGoResponseCode.correctGreen ||
                                                                                                         $0.0 == CTFGoNoGoResponseCode.correctBlue}.count
        let lastThirdNumCorrectResponses = trialResponseCodeAndTime[secondThird+1...results.count-1].filter{$0.0 == CTFGoNoGoResponseCode.correctGreen ||
                                                                                                            $0.0 == CTFGoNoGoResponseCode.correctBlue}.count
        print(taskNumCorrectResponses,firstThirdNumCorrectResponses,secondThirdNumCorrectResponses,lastThirdNumCorrectResponses)
        
        // Number of  Total Incorrect Responses
        let taskNumIncorrectResponses = trialResponseCodeAndTime.filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen || $0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
        let firstThirdNumIncorrectResponses = trialResponseCodeAndTime[0...firstThird].filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen ||
                                                                                              $0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
        let secondThirdNumIncorrectResponses = trialResponseCodeAndTime[firstThird+1...secondThird].filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen ||
                                                                                                           $0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
        let lastThirdNumIncorrectResponses = trialResponseCodeAndTime[secondThird+1...results.count-1].filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen ||
                                                                                                              $0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
        print(taskNumIncorrectResponses,firstThirdNumIncorrectResponses,secondThirdNumIncorrectResponses,lastThirdNumIncorrectResponses)
        
        // Number of Correct Blue Responses
        let taskNumCorrectBlueResponses = trialResponseCodeAndTime.filter{$0.0 == CTFGoNoGoResponseCode.correctBlue}.count
        let firstThirdNumCorrectBlueResponses = trialResponseCodeAndTime[0...firstThird].filter{$0.0 == CTFGoNoGoResponseCode.correctBlue}.count
        let secondThirdNumCorrectBlueResponses = trialResponseCodeAndTime[firstThird+1...secondThird].filter{$0.0 == CTFGoNoGoResponseCode.correctBlue}.count
        let lastThirdNumCorrectBlueResponses = trialResponseCodeAndTime[secondThird+1...results.count-1].filter{$0.0 == CTFGoNoGoResponseCode.correctBlue}.count
        print(taskNumCorrectBlueResponses,firstThirdNumCorrectBlueResponses,secondThirdNumCorrectBlueResponses,lastThirdNumCorrectBlueResponses)
        
        //Number of Correct Green Responses
        let taskNumCorrectGreenResponses = trialResponseCodeAndTime.filter{$0.0 == CTFGoNoGoResponseCode.correctGreen}.count
        let firstThirdNumCorrectGreenResponses = trialResponseCodeAndTime[0...firstThird].filter{$0.0 == CTFGoNoGoResponseCode.correctGreen}.count
        let secondThirdNumCorrectGreenResponses = trialResponseCodeAndTime[firstThird+1...secondThird].filter{$0.0 == CTFGoNoGoResponseCode.correctGreen}.count
        let lastThirdNumCorrectGreenResponses = trialResponseCodeAndTime[secondThird+1...results.count-1].filter{$0.0 == CTFGoNoGoResponseCode.correctGreen}.count
        print(taskNumCorrectGreenResponses,firstThirdNumCorrectGreenResponses,secondThirdNumCorrectGreenResponses,lastThirdNumCorrectGreenResponses)
        
        // Number of Incorrect Blue Responses
        let taskNumIncorrectBlueResponses = trialResponseCodeAndTime.filter{$0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
        let firstThirdNumIncorrectBlueResponses = trialResponseCodeAndTime[0...firstThird].filter{$0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
        let secondThirdNumIncorrectBlueResponses = trialResponseCodeAndTime[firstThird+1...secondThird].filter{$0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
        let lastThirdNumIncorrectBlueResponses = trialResponseCodeAndTime[secondThird+1...results.count-1].filter{$0.0 == CTFGoNoGoResponseCode.incorrectBlue}.count
        print(taskNumIncorrectBlueResponses,firstThirdNumIncorrectBlueResponses,secondThirdNumIncorrectBlueResponses,lastThirdNumIncorrectBlueResponses)
        
        //Number of Incorrect Green Responses
        let taskNumIncorrectGreenResponses = trialResponseCodeAndTime.filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen}.count
        let firstThirdNumIncorrectGreenResponses = trialResponseCodeAndTime[0...firstThird].filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen}.count
        let secondThirdNumIncorrectGreenResponses = trialResponseCodeAndTime[firstThird+1...secondThird].filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen}.count
        let lastThirdNumIncorrectGreenResponses = trialResponseCodeAndTime[secondThird+1...results.count-1].filter{$0.0 == CTFGoNoGoResponseCode.incorrectGreen}.count
        print(taskNumIncorrectGreenResponses,firstThirdNumIncorrectGreenResponses,secondThirdNumIncorrectGreenResponses,lastThirdNumIncorrectGreenResponses)

        
        
        
        
        
        
        
        
        
        
        
    }
    
    func checkResponse(trial:CTFGoNoGoTrial?,tapped:Bool?) -> CTFGoNoGoResponseCode{
        /**
         * checkResponses uses the trial.target and compares to the bool tapped and returns an Int.
         * response codes:
            1 :Go target and user taps
            2: Go target and user does not tap
            3: No Go target and user taps
            4: No Go target and user does not tap
        */
        let targetType = trial!.target
        let userResponse = tapped!
        var responseCode = CTFGoNoGoResponseCode.Default
        switch (targetType!) {
            case CTFGoNoGoTargetType.Go:
            
                switch(userResponse){
                case true:
                    responseCode = CTFGoNoGoResponseCode.correctGreen
                case false:
                    responseCode = CTFGoNoGoResponseCode.incorrectGreen
            }
            
            case CTFGoNoGoTargetType.NoGo:
            
                switch(userResponse){
                case true:
                    responseCode = CTFGoNoGoResponseCode.incorrectBlue
                case false:
                    responseCode = CTFGoNoGoResponseCode.correctBlue
            }
            
        }
        return responseCode
    }
    
    
    


}
