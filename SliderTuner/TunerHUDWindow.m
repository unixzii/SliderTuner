//
//  TunerHUDWindow.m
//  SliderTuner
//
//  Created by 杨弘宇 on 10/09/2016.
//  Copyright © 2016 杨弘宇. All rights reserved.
//

#import "TunerHUDWindow.h"

@interface TunerHUDWindow () <NSWindowDelegate>

@property (strong, readwrite) FocusWindow *focusWindow;

@end

@implementation TunerHUDWindow

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.delegate = self;
    
    self.focusWindow = [[FocusWindow alloc] init];
    
    self.valueTextField.target = self;
    self.valueTextField.action = @selector(textFieldDidChange:);
}

- (void)orderFront:(id)sender {
    [super orderFront:sender];
    
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
