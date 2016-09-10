//
//  FocusWindow.m
//  SliderTuner
//
//  Created by 杨弘宇 on 10/09/2016.
//  Copyright © 2016 杨弘宇. All rights reserved.
//

#import "FocusWindow.h"

@implementation FocusWindow

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.opaque = NO;
    self.hasShadow = NO;
    self.alphaValue = 0.3;
    self.level = NSStatusWindowLevel;
    self.backgroundColor = [NSColor redColor];
    self.titleVisibility = NSWindowTitleHidden;
    self.ignoresMouseEvents = YES;
    self.styleMask = NSWindowStyleMaskBorderless;
}

@end
