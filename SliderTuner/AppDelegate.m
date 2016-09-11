//
//  AppDelegate.m
//  SliderTuner
//
//  Created by 杨弘宇 on 10/09/2016.
//  Copyright © 2016 杨弘宇. All rights reserved.
//

#import <Carbon/Carbon.h>

#import "AppDelegate.h"
#import "TunerHUDWindowController.h"

@interface AppDelegate () {
    BOOL _tunerEnabled;
}

@property (strong) NSStatusItem *statusItem;
@property (strong) TunerHUDWindowController *HUDWindowController;

@end

CGEventRef GlobalMouseEventCallBack(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *userInfo) {
    do {
        AppDelegate *__self = (AppDelegate *) ((__bridge id) userInfo);
        if (!__self.tunerEnabled) {
            break;
        }
        [__self tryDisplayTunerHUD];
        NSLog(@"Hit!!");
    } while (0);
    
    return event;
}

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupStatusBarItem];
    if ([self registerHotkey] != noErr) {
        [self quit:nil];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
    self.statusItem = nil;
}

- (void)setupStatusBarItem {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    self.statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.button.title = @"T";
    self.statusItem.menu = [[NSMenu alloc] init];
    [self.statusItem.menu addItemWithTitle:@"Enabled" action:@selector(toggleEnabled:) keyEquivalent:@""];
    [self.statusItem.menu addItem:[NSMenuItem separatorItem]];
    [self.statusItem.menu addItemWithTitle:@"Quit" action:@selector(quit:) keyEquivalent:@""];
    
    self.statusItem.menu.itemArray[0].state = 1;
    _tunerEnabled = YES;
}

- (OSStatus)registerHotkey {
    CFMachPortRef port = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionListenOnly, CGEventMaskBit(kCGEventRightMouseUp), GlobalMouseEventCallBack, (__bridge void *) self);
    CFRunLoopSourceRef source = CFMachPortCreateRunLoopSource(NULL, port, 0);
    CFRunLoopAddSource(CFRunLoopGetMain(), source, kCFRunLoopCommonModes);
    
    CFRelease(port);
    CFRelease(source);
    
    return noErr;
}

- (void)tryDisplayTunerHUD {
    NSPoint mouseLocation = [NSEvent mouseLocation];
    CGPoint convertedMouseLocation = [AppDelegate carbonScreenPointFromCocoaScreenPoint:mouseLocation];
    
    AXUIElementRef systemElem = AXUIElementCreateSystemWide();
    AXUIElementRef pointedElem = NULL;
    AXUIElementCopyElementAtPosition(systemElem, convertedMouseLocation.x, convertedMouseLocation.y, &pointedElem);
    
    if (pointedElem) {
        CFStringRef role = NULL;
        AXUIElementCopyAttributeValue(pointedElem, CFSTR("AXRole"), (CFTypeRef *) &role);
        if ([((__bridge NSString *) role) isEqualToString:@"AXSlider"]) {
#if DEBUG
            NSLog(@"Found it!!!");
#endif
            
            CFNumberRef minValue = NULL;
            CFNumberRef maxValue = NULL;
            CFNumberRef currentValue = NULL;
            AXValueRef elemFrame = NULL;
            
            AXUIElementCopyAttributeValue(pointedElem, CFSTR("AXMinValue"), (CFTypeRef *) &minValue);
            AXUIElementCopyAttributeValue(pointedElem, CFSTR("AXMaxValue"), (CFTypeRef *) &maxValue);
            AXUIElementCopyAttributeValue(pointedElem, CFSTR("AXValue"), (CFTypeRef *) &currentValue);
            AXUIElementCopyAttributeValue(pointedElem, CFSTR("AXFrame"), (CFTypeRef *) &elemFrame);
            
            if (!self.HUDWindowController) {
                self.HUDWindowController = [[TunerHUDWindowController alloc] initWithWindowNibName:@"TunerHUDWindow"];
            }
            
            [self.HUDWindowController showWindow:nil]; // show first to force window to be loaded.
            
            self.HUDWindowController.minTextField.floatValue = ((__bridge NSNumber *) minValue).floatValue;
            self.HUDWindowController.maxTextField.floatValue = ((__bridge NSNumber *) maxValue).floatValue;
            self.HUDWindowController.valueTextField.floatValue = ((__bridge NSNumber *) currentValue).floatValue;
            self.HUDWindowController.changeAction = ^(id sender) {
                float value = [sender floatValue];
                AXUIElementSetAttributeValue(pointedElem, CFSTR("AXValue"), (CFTypeRef) @(value));
            };
            
            mouseLocation.y += 20;
            [self.HUDWindowController.window setFrameOrigin: mouseLocation];
            
            [self.HUDWindowController.focusWindow setFrame:[AppDelegate cocoaRectFromCarbonAXValue:elemFrame] display:YES];
        }
    }
}

- (BOOL)tunerEnabled {
    return _tunerEnabled;
}

#pragma mark - Menu actions

- (void)toggleEnabled:(id)sender {
    NSMenuItem *item = sender;
    item.state ^= 1;
    
    _tunerEnabled = item.state;
}

- (void)quit:(id)sender {
    [NSApp terminate:sender];
}

#pragma mark - Utilities

+ (CGPoint)carbonScreenPointFromCocoaScreenPoint:(NSPoint)cocoaPoint {
    NSScreen *foundScreen = nil;
    CGPoint thePoint;
    
    for (NSScreen *screen in [NSScreen screens]) {
        if (NSPointInRect(cocoaPoint, screen.frame)) {
            foundScreen = screen;
            break;
        }
    }
    
    if (foundScreen) {
        CGFloat screenHeight = [foundScreen frame].size.height;
        
        thePoint = CGPointMake(cocoaPoint.x, screenHeight - cocoaPoint.y - 1);
    } else {
        thePoint = CGPointMake(0.0, 0.0);
    }
    
    return thePoint;
}

+ (NSRect)cocoaRectFromCarbonAXValue:(AXValueRef)value {
    CGRect rect;
    AXValueGetValue(value, kAXValueTypeCGRect, &rect);
    
    rect.origin = [AppDelegate carbonScreenPointFromCocoaScreenPoint:NSPointFromCGPoint(rect.origin)];
    rect.origin.y -= 25;
    
    return NSRectFromCGRect(rect);
}

@end
