//
// --------------------------------------------------------------------------
// ButtonInputParser.h
// Created for Mac Mouse Fix (https://github.com/noah-nuebling/mac-mouse-fix)
// Created by Noah Nuebling in 2019
// Licensed under MIT
// --------------------------------------------------------------------------
//

#import <Foundation/Foundation.h>
#import "ButtonInputReceiver_CG.h"

@interface ButtonInputParser : NSObject

+ (MFEventPassThroughEvaluation)sendActionTriggersForInputWithButton:(int64_t)button type:(MFButtonInputType)type inputDevice:device;
+ (void)reset;

@end
