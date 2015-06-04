//
//  SwiftPropertyAccessorController.h
//  JsonCompletor
//
//  Created by huangluyang on 15/6/4.
//  Copyright (c) 2015年 me.zhangxi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SwiftPropertyAccessorController : NSWindowController

@end

@interface SwiftPropertyAccessorInfo : NSObject

@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *propertyName;

@end