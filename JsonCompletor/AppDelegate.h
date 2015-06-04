//
//  AppDelegate.h
//  JsonCompletor
//
//  Created by huangluyang on 14-11-13.
//  Copyright (c) 2014年 huangluyang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JSONWindowController.h"
#import "PropertyAccesorController.h"
#import "SwiftPropertyAccessorController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    JSONWindowController *json;

}


@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) PropertyAccesorController *property;
@property (nonatomic, strong) SwiftPropertyAccessorController *swiftProperty;


- (IBAction)json:(id)sender;
- (IBAction)donate:(id)sender;


@end
