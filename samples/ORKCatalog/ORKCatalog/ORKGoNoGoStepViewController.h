//
//  ORKGoNoGoStepViewController.h
//  ResearchKit
//
//  Created by Francesco Perera on 9/24/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@interface ORKGoNoGoStepViewController : ORKActiveStepViewController

// UI elements
@property (strong, nonatomic) IBOutlet UILabel *explanationLabel; //Francesco - remember to connect to storyboard (9/24)
@property (strong, nonatomic) UIButton *startButton;
@property (strong, nonatomic) UILabel *feedbackLabel;
@property (strong, nonatomic) UITextView *resultsTextView;


//Flags
@property (assign, nonatomic) BOOL done;


// Track user reactions during tests
@property (strong, nonatomic) UITapGestureRecognizer *gestureRecognizer;




@end
