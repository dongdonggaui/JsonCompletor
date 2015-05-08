//
//  PropertyAccesorController.m
//  JsonCompletor
//
//  Created by huangluyang on 15/5/8.
//  Copyright (c) 2015年 me.zhangxi. All rights reserved.
//

#import "PropertyAccesorController.h"

@interface PropertyAccesorController ()

@property (nonatomic, strong) NSMutableArray *properties;

@end

@implementation PropertyAccessorInfo

@end

@implementation PropertyAccesorController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (IBAction)compete:(id)sender {
    NSString *mContent = self.inputTextView.string;
    if (mContent.length == 0) {
        self.outputTextView.string = @".m file is invalid";
        return;
    }
    
    NSMutableString *codeText = [NSMutableString stringWithString:mContent];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@end" options:0 error:nil];
    NSArray *matches = [regex matchesInString:codeText options:0 range:NSMakeRange(0, codeText.length)];
    if (matches.count < 1) {
        self.outputTextView.string = @".m file is invalid";
        return;
    }
    NSTextCheckingResult *matchResult = [matches lastObject];
    [codeText deleteCharactersInRange:matchResult.range];
    self.outputTextView.string = codeText;
    
    NSArray *components = [codeText componentsSeparatedByString:@"@implementation"];
    if (components.count <= 0) {
        self.outputTextView.string = @".m file is invalid";
        return;
    }
    
    NSString *propertyListString = [components firstObject];
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:@"@interface([\\s\\S]*)@end" options:0 error:nil];
    NSRange range = [regex1 rangeOfFirstMatchInString:propertyListString options:NSMatchingWithTransparentBounds range:NSMakeRange(0, propertyListString.length)];
    if (range.location == NSNotFound) {
        self.outputTextView.string = @"no properties";
        return;
    }
    propertyListString = [propertyListString substringWithRange:range];
    
    NSArray *propertyListComponents = [propertyListString componentsSeparatedByString:@"\n"];
    for (NSString *propertyListEntity in propertyListComponents) {
        NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:@"@property([\\s\\S]*);" options:0 error:nil];
        NSArray *propertyCheckResults = [regex2 matchesInString:propertyListEntity options:0 range:NSMakeRange(0, propertyListEntity.length)];
        for (NSTextCheckingResult *result in propertyCheckResults) {
            NSString *propertyString = [propertyListEntity substringWithRange:result.range];
            PropertyAccessorInfo *propertyInfo = [[PropertyAccessorInfo alloc] init];
            NSArray *propertyComponents = [propertyString componentsSeparatedByString:@" "];
            if (propertyComponents.count != 5) {
                self.outputTextView.string = @"property wrong format";
                return;
            }
            propertyInfo.className = [propertyComponents objectAtIndex:3];
            NSString *propertyName = [propertyComponents objectAtIndex:4];
            propertyInfo.hasAsterisk = [propertyName hasPrefix:@"*"];
            if (propertyInfo.hasAsterisk) {
                propertyName = [propertyName substringFromIndex:1];
            }
            propertyInfo.propertyName = [propertyName substringToIndex:propertyName.length - 1];
            [self.properties addObject:propertyInfo];
        }
    }
    
    for (PropertyAccessorInfo *info in self.properties) {
        [codeText appendFormat:@"\n-(%@%@)%@\n", info.className, info.hasAsterisk ? @" *" : @"", info.propertyName];
        [codeText appendFormat:@"{\n\tif (!_%@) {\n", info.propertyName];
        [codeText appendFormat:@"\t\t\t_%@ = [[%@ alloc] init];\n", info.propertyName, info.className];
        [codeText appendString:@"\t\t\t<#initialize#>;\n"];
        [codeText appendString:@"\t\t}\n"];
        [codeText appendFormat:@"\treturn _%@;\n", info.propertyName];
        [codeText appendString:@"}\n"];
    }
    [codeText appendString:@"\n@end"];
    
    self.outputTextView.string = codeText;
}

- (NSMutableArray *)properties
{
    if (!_properties) {
        _properties = [NSMutableArray array];
    }
    
    return _properties;
}

@end
