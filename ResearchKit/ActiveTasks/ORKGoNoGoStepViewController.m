//
//  ORKGoNoGoStepViewController.m
//  ResearchKit
//
//  Created by Francesco Perera on 9/24/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKGoNoGoStepViewController.h"
static const float BUTTON_HEIGHT = 60.f;

@implementation ORKGoNoGoStepViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissView)];
    [item setTintColor:[UIColor colorWithRed:52.0/255 green:73.0/255 blue:94.0/255 alpha:1.0]];
    [self.navigationItem setRightBarButtonItem:item];
}

- (void)dismissView
{
    self.done = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.done = NO;
    
    // Game Explanation
    NSString *instructionsString = @"Welcome to the Square Task.\n\n\nOnce you start, you will be presented with a rectangle. When the rectangle turns green, tap anywhere on the screen as quickly as possible. When it turns blue, do not respond at all. \n\nThe test will take approximately 3 min.";
    NSMutableAttributedString *instructionsText = [[NSMutableAttributedString alloc] initWithString:instructionsString];
    [instructionsText addAttribute:NSFontAttributeName
                             value:[UIFont boldSystemFontOfSize:24.0]
                             range:[instructionsString rangeOfString:@"green, tap anywhere on the screen as quickly as possible"]];
    [instructionsText addAttribute:NSFontAttributeName
                             value:[UIFont boldSystemFontOfSize:24.0]
                             range:[instructionsString rangeOfString:@"blue, do not respond at all"]];
    [instructionsText addAttribute:NSFontAttributeName
                             value:[UIFont boldSystemFontOfSize:24.0]
                             range:[instructionsString rangeOfString:@"3 min"]];
    [self.explanationLabel setAttributedText:instructionsText];
    
    // Start Button
    self.startButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame) - BUTTON_HEIGHT, CGRectGetWidth(self.view.frame), BUTTON_HEIGHT)];
    [self.startButton setTitle:@"Start Square Task" forState:UIControlStateNormal];
    [self.startButton setBackgroundColor:[UIColor colorWithRed:52.0/255 green:73.0/255 blue:94.0/255 alpha:1.0]]; //rgba(52, 73, 94,1.0)
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(startTest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startButton];
    
    // Feedback label
    self.feedbackLabel = [[UILabel alloc] initWithFrame:self.startButton.frame];
    [self.feedbackLabel setNumberOfLines:1];
    [self.feedbackLabel setTextAlignment:NSTextAlignmentCenter];
    [self.feedbackLabel setHidden:YES];
    [self.view addSubview:self.feedbackLabel];
    
    // Tap gesture
    self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedScreen)];
    [self.view addGestureRecognizer:self.gestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    //Francesco - add results here
}

@end
