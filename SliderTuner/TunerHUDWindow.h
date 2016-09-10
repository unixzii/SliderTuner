//
//  TunerHUDWindow.h
//  SliderTuner
//
//  Created by 杨弘宇 on 10/09/2016.
//  Copyright © 2016 杨弘宇. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FocusWindow.h"

@interface TunerHUDWindow : NSPanel

@property (weak) IBOutlet NSTextField *minTextField;
@property (weak) IBOutlet NSTextField *maxTextField;
@property (weak) IBOutlet NSTextField *valueTextField;

@property (readonly) FocusWindow *focusWindow;

@property (copy) void (^changeAction)(id sender);

@end
