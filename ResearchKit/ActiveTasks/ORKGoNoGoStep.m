//
//  ORKGoNoGoStep.m
//  ResearchKit
//
//  Created by Francesco Perera on 9/24/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import "ORKGoNoGoStep.h"
#import "ORKGoNoGoStepViewController.h"

@implementation ORKGoNoGoStep

+ (Class)stepViewControllerClass {
    return [ORKGoNoGoStepViewController class];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        self.shouldShowDefaultTimer = NO;
        self.optional = NO; // default to *not* optional
    }
    return self;
}

- (void)validateParameters {
    [super validateParameters];
    
    //Francesco - update this to GoNoGo parameters
    NSTimeInterval const ORKTwoFingerTappingMinimumDuration = 5.0;
    
    if ( self.stepDuration < ORKTwoFingerTappingMinimumDuration) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"duration cannot be shorter than %@ seconds.", @(ORKTwoFingerTappingMinimumDuration)]  userInfo:nil];
    }
}


@end
