//
//  AppDelegate.m
//  JsonCompletor
//
//  Created by huangluyang on 14-11-13.
//  Copyright (c) 2014年 huangluyang. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if(flag == NO)
    {
        [self.window makeKeyAndOrderFront:nil];
    }
    return YES;
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    [self json:nil];
    
}
- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"%@ : %@\n",@"",@""];
    return result;
}

- (IBAction)json:(id)sender {

    json = [[JSONWindowController alloc] initWithWindowNibName:@"JSONWindowController"];
    [[json window] makeKeyAndOrderFront:nil];
}

- (IBAction)donate:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://zxapi.sinaapp.com/paypal.html"]];
}

- (IBAction)propertyAccessor:(id)sender {
    
    [[self.property window] makeKeyAndOrderFront:nil];
}

- (IBAction)swiftPropertyAccessor:(id)sender {
    
    [[self.swiftProperty window] makeKeyAndOrderFront:nil];
}

- (PropertyAccesorController *)property
{
    if (!_property) {
        _property = [[PropertyAccesorController alloc] initWithWindowNibName:@"PropertyAccesorController"];
    }
    
    return _property;
}

- (SwiftPropertyAccessorController *)swiftProperty
{
    if (!_swiftProperty) {
        _swiftProperty = [[SwiftPropertyAccessorController alloc] initWithWindowNibName:@"SwiftPropertyAccessorController"];
    }
    
    return _swiftProperty;
}

@end
