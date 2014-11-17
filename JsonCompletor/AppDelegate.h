//
//  AppDelegate.h
//  JsonCompletor
//
//  Created by huangluyang on 14-11-13.
//  Copyright (c) 2014年 huangluyang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JSONWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    JSONWindowController *json;

}


@property (assign) IBOutlet NSWindow *window;


- (IBAction)json:(id)sender;
- (IBAction)donate:(id)sender;


@end
