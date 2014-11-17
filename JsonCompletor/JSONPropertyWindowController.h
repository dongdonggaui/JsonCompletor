//
//  JSONPropertyWindowController.h
//  JsonCompletor
//
//  Created by huangluyang on 14-11-13.
//  Copyright (c) 2014年 huangluyang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JSONPropertyWindowController : NSWindowController
{
    NSString *path;
}
@property (weak) IBOutlet NSTableView *table;
@property(nonatomic,strong)  NSArrayController *arrayController;

- (IBAction)closeWindow:(id)sender;



@end
