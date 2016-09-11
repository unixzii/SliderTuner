//
//  TunerHUDWindowController.m
//  SliderTuner
//
//  Created by 杨弘宇 on 10/09/2016.
//  Copyright © 2016 杨弘宇. All rights reserved.
//

#import "TunerHUDWindowController.h"

@interface TunerHUDWindowController () <NSWindowDelegate>

@property (strong, readwrite) FocusWindow *focusWindow;

@end

@implementation TunerHUDWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.delegate = self;
    
    self.focusWindow = [[FocusWindow alloc] init];
    
    self.valueTextField.target = self;
    self.valueTextField.action = @selector(textFieldDidChange:);
}

- (void)showWindow:(id)sender {
    [super showWindow:sender];
    
    [self.focusWindow orderFront:sender];
}

- (void)textFieldDidChange:(id)sender {
    if (self.changeAction) {
        self.changeAction(sender);
    }
}

#pragma mark - Delegate

- (void)windowWillClose:(NSNotification *)notification {
    [self.focusWindow orderOut:nil];
}

@end
