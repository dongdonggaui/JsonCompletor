//
//  SwiftPropertyAccessorController.m
//  JsonCompletor
//
//  Created by huangluyang on 15/6/4.
//  Copyright (c) 2015年 me.zhangxi. All rights reserved.
//

#import "SwiftPropertyAccessorController.h"

@interface SwiftPropertyAccessorController ()

@property (unsafe_unretained) IBOutlet NSTextView *inputTextView;
@property (unsafe_unretained) IBOutlet NSTextView *outputTextView;
@property (nonatomic, strong) NSMutableArray *properties;

@end

@implementation SwiftPropertyAccessorController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (IBAction)compete:(id)sender {
    NSString *mContent = self.inputTextView.string;
    if (mContent.length == 0) {
        self.outputTextView.string = @".swift file is invalid";
        return;
    }
    
    NSMutableString *codeText = [NSMutableString stringWithString:mContent];
    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:@"\\}" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex1 matchesInString:codeText options:NSMatchingReportCompletion range:NSMakeRange(0, codeText.length)];
    if (matches.count == 0) {
        self.outputTextView.string = @".swift file is invalid";
        return;
    }
    NSRange lastRange = [(NSTextCheckingResult *)[matches lastObject] range];
    [codeText deleteCharactersInRange:lastRange];
//    self.outputTextView.string = codeText;
    
//    NSString *propertyListString = [components firstObject];
//    NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:@"@interface([\\s\\S]*)@end" options:0 error:nil];
//    NSRange range = [regex1 rangeOfFirstMatchInString:propertyListString options:NSMatchingWithTransparentBounds range:NSMakeRange(0, propertyListString.length)];
//    if (range.location == NSNotFound) {
//        self.outputTextView.string = @"no properties";
//        return;
//    }
//    propertyListString = [propertyListString substringWithRange:range];
    
    NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:@"private var _([a-zA-Z0-9: ]*)\\?" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *propertyCheckResults = [regex2 matchesInString:codeText options:NSMatchingReportCompletion range:NSMakeRange(0, codeText.length)];
    for (NSTextCheckingResult *result in propertyCheckResults) {
        NSString *propertyString = [codeText substringWithRange:result.range];
        SwiftPropertyAccessorInfo *propertyInfo = [[SwiftPropertyAccessorInfo alloc] init];
        NSArray *propertyComponents = [propertyString componentsSeparatedByString:@" "];
        if (propertyComponents.count != 4) {
            self.outputTextView.string = @"property wrong format";
            return;
        }
        propertyInfo.className = [[propertyComponents objectAtIndex:3] stringByReplacingOccurrencesOfString:@"?" withString:@""];
        NSString *propertyName = [[[propertyComponents objectAtIndex:2] stringByReplacingOccurrencesOfString:@"_" withString:@""] stringByReplacingOccurrencesOfString:@":" withString:@""];
        propertyInfo.propertyName = propertyName;
        [self.properties addObject:propertyInfo];
    }
    
    for (SwiftPropertyAccessorInfo *info in self.properties) {
        [codeText appendFormat:@"\n\tvar %@: %@ {\n", info.propertyName, info.className];
        [codeText appendFormat:@"\t\tif _%@ == nil {\n", info.propertyName];
        [codeText appendFormat:@"\t\t\t_%@ = %@()\n", info.propertyName, info.className];
        [codeText appendString:@"\t\t\t<#initialize#>\n"];
        [codeText appendString:@"\t\t}\n"];
        [codeText appendFormat:@"\treturn _%@\n", info.propertyName];
        [codeText appendString:@"\t}\n"];
    }
    [codeText appendString:@"\n}"];
    
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


@implementation SwiftPropertyAccessorInfo

@end