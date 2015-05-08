//
//  PropertyAccesorController.h
//  JsonCompletor
//
//  Created by huangluyang on 15/5/8.
//  Copyright (c) 2015年 me.zhangxi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PropertyAccesorController : NSWindowController
@property (unsafe_unretained) IBOutlet NSTextView *inputTextView;
@property (unsafe_unretained) IBOutlet NSTextView *outputTextView;

@end

@interface PropertyAccessorInfo : NSObject

@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *propertyName;
@property (nonatomic, assign) BOOL hasAsterisk;

@end
