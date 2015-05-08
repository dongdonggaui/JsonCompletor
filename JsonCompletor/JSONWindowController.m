//
//  JSONWindowController.m
//  JsonCompletor
//
//  Created by huangluyang on 14-11-13.
//  Copyright (c) 2014年 huangluyang. All rights reserved.
//

#import "JSONWindowController.h"

@interface JSONWindowController ()

@end

@implementation JSONWindowController
@synthesize jsonContent;
@synthesize jsonName;
@synthesize preName;
@synthesize jsonURL;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    array = [[NSArrayController alloc] init];
}


-(void)generateClass:(NSString *)name forDic:(NSDictionary *)json
{
    //准备模板
    NSMutableString *templateH =[[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"json" ofType:@"tq1"]
                                                                       encoding:NSUTF8StringEncoding
                                                                          error:nil];
    NSMutableString *templateM =[[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"json" ofType:@"tq2"]
                                                                       encoding:NSUTF8StringEncoding
                                                                          error:nil];
    
    
    //.h
    //name
    //property
    NSMutableString *proterty = [NSMutableString string];
    NSMutableString *import = [NSMutableString string];
    
    for(NSString *key in [json allKeys])
    {
        NSString *propertyName = [self humpfulFromKey:key withClassName:name];
        JsonValueType type = [self type:[json objectForKey:key]];
        switch (type) {
            case kString:
            case kNumber:
                [proterty appendFormat:@"@property (nonatomic, strong) %@ *%@%@;\n", [self typeName:type],preName.stringValue, propertyName];
                break;
            case kArray:
            {
                if([self isDataArray:[json objectForKey:key]])
                {
                    [proterty appendFormat:@"@property (nonatomic, strong) NSMutableArray *%@%@;\n", preName.stringValue, propertyName];
                    [import appendFormat:@"#import \"%@Entity.h\"\n",[self uppercaseFirstChar:propertyName]];
                    [self generateClass:[NSString stringWithFormat:@"%@Entity",[self uppercaseFirstChar:propertyName]] forDic:[[json objectForKey:key]objectAtIndex:0]];
                }
            }
                break;
            case kDictionary:
                [proterty appendFormat:@"@property (nonatomic, strong) %@Entity *%@%@;\n", [self uppercaseFirstChar:propertyName], preName.stringValue, propertyName];
                [import appendFormat:@"#import \"%@Entity.h\"\n",[self uppercaseFirstChar:propertyName]];
                [self generateClass:[NSString stringWithFormat:@"%@Entity", [self uppercaseFirstChar:propertyName]] forDic:[json objectForKey:key]];
                
                break;
            case kBool:
                [proterty appendFormat:@"@property (nonatomic, assign) %@ %@%@;\n", [self typeName:type], preName.stringValue, propertyName];
                break;
            default:
                break;
        }
    }
    
    [templateH replaceOccurrencesOfString:@"#name#"
                               withString:name
                                  options:NSCaseInsensitiveSearch
                                    range:NSMakeRange(0, templateH.length)];
    [templateH replaceOccurrencesOfString:@"#import#"
                               withString:import
                                  options:NSCaseInsensitiveSearch
                                    range:NSMakeRange(0, templateH.length)];
    [templateH replaceOccurrencesOfString:@"#property#"
                               withString:proterty
                                  options:NSCaseInsensitiveSearch
                                    range:NSMakeRange(0, templateH.length)];
    
    //.m
    //NSCoding
    //name
    [templateM replaceOccurrencesOfString:@"#name#"
                               withString:name
                                  options:NSCaseInsensitiveSearch
                                    range:NSMakeRange(0, templateM.length)];
    
    
    NSMutableString *config = [NSMutableString string];
    NSMutableString *encode = [NSMutableString string];
    NSMutableString *decode = [NSMutableString string];
    NSMutableString *description = [NSMutableString string];
    
    NSDictionary *list =  @{
                            @"config":config,
                            @"encode":encode,
                            @"decode":decode,
                            @"description":description
                            };
    
    
    for(NSString *key in [json allKeys])
    {
        NSString *propertyName = [self humpfulFromKey:key withClassName:name];
        JsonValueType type = [self type:[json objectForKey:key]];
        switch (type) {
            case kString:
//                [config appendFormat:@"self.%@%@ = [json tq_validStringForKey:@\"%@\"];\n\t\t\t", preName.stringValue, propertyName, key];
//                [encode appendFormat:@"[aCoder encodeObject:self.%@%@ forKey:@\"tq_%@\"];\n\t", preName.stringValue, propertyName, key];
//                [decode appendFormat:@"self.%@%@ = [aDecoder decodeObjectForKey:@\"tq_%@\"];\n\t\t", preName.stringValue, propertyName, key];
//                [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@];\n\t", preName.stringValue, propertyName, preName.stringValue, propertyName];
//                break;
            case kNumber:
                [config appendFormat:@"self.%@%@ = [json tq_safeObjectForKey:@\"%@\"];\n\t\t\t", preName.stringValue, propertyName, key];
                [encode appendFormat:@"[aCoder encodeObject:self.%@%@ forKey:@\"tq_%@\"];\n\t", preName.stringValue, propertyName, key];
                [decode appendFormat:@"self.%@%@ = [aDecoder decodeObjectForKey:@\"tq_%@\"];\n\t\t", preName.stringValue, propertyName, key];
                [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@];\n\t", preName.stringValue, propertyName, preName.stringValue, propertyName];
                break;
            case kArray:
            {
                if([self isDataArray:[json objectForKey:key]])
                {
                    [config appendFormat:@"self.%@%@ = [NSMutableArray array];\n", preName.stringValue, propertyName];
                    [config appendFormat:@"\t\t\tfor(NSDictionary *item in [json tq_validArrayForKey:@\"%@\"])\n", key];
                    [config appendString:@"\t\t\t{\n"];
                    [config appendFormat:@"\t\t\t\t[self.%@%@ tq_addSafeObject:[[%@Entity alloc] initWithJson:item]];\n", preName.stringValue, propertyName, [self uppercaseFirstChar:propertyName]];
                    [config appendString:@"\t\t\t}\n\t\t\t"];
                    [encode appendFormat:@"[aCoder encodeObject:self.%@%@ forKey:@\"tq_%@\"];\n\t", preName.stringValue, propertyName, key];
                    [decode appendFormat:@"self.%@%@ = [aDecoder decodeObjectForKey:@\"tq_%@\"];\n\t\t",  preName.stringValue, propertyName,key];
                    [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@];\n\t", preName.stringValue, propertyName, preName.stringValue, propertyName];
                }
            }
                break;
            case kDictionary:
                [config appendFormat:@"self.%@%@ = [[%@Entity alloc] initWithJson:[json tq_validDictionaryForKey:@\"%@\"]];\n\t\t\t", preName.stringValue, propertyName, [self uppercaseFirstChar:propertyName], key];
                [encode appendFormat:@"[aCoder encodeObject:self.%@%@ forKey:@\"tq_%@\"];\n\t", preName.stringValue, propertyName, key];
                [decode appendFormat:@"self.%@%@ = [aDecoder decodeObjectForKey:@\"tq_%@\"];\n\t\t", preName.stringValue, propertyName, key];
                [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@];\n\t", preName.stringValue, propertyName, preName.stringValue, propertyName];
                
                break;
            case kBool:
                [config appendFormat:@"self.%@%@ = [[json tq_safeObjectForKey:@\"%@\"] boolValue];\n\t\t\t", preName.stringValue, propertyName, key];
                [encode appendFormat:@"[aCoder encodeBool:self.%@%@ forKey:@\"tq_%@\"];\n\t", preName.stringValue, propertyName, key];
                [decode appendFormat:@"self.%@%@ = [aDecoder decodeBoolForKey:@\"tq_%@\"];\n\t\t", preName.stringValue, propertyName, key];
                [description appendFormat:@"result = [result stringByAppendingFormat:@\"%@%@ : %%@\\n\",self.%@%@?@\"yes\":@\"no\"];\n\t", preName.stringValue, propertyName, preName.stringValue, propertyName];
                break;
            default:
                break;
        }
    }
    
    //修改模板
    for(NSString *key in [list allKeys])
    {
        [templateM replaceOccurrencesOfString:[NSString stringWithFormat:@"#%@#",key]
                                   withString:[list objectForKey:key]
                                      options:NSCaseInsensitiveSearch
                                        range:NSMakeRange(0, templateM.length)];
    }
    
    
    //写文件
    NSLog(@"%@",[NSString stringWithFormat:@"%@/%@.h",path,name]);
    [templateH writeToFile:[NSString stringWithFormat:@"%@/%@.h",path,name]
                atomically:NO
                  encoding:NSUTF8StringEncoding
                     error:nil];
    [templateM writeToFile:[NSString stringWithFormat:@"%@/%@.m",path,name]
                atomically:NO
                  encoding:NSUTF8StringEncoding
                     error:nil];
    
    
}



- (IBAction)useTestURL:(id)sender {
    jsonURL.stringValue = @"";
}

- (IBAction)getJSONWithURL:(id)sender {
    
    NSString *str = [jsonURL.stringValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:nil
                                                     error:nil];
    
    NSDictionary *json = [data objectFromJSONData];
    if(json != nil)
        jsonContent.string = [json JSONStringWithOptions:JKSerializeOptionPretty error:nil];
}

-(void)generateProperty:(NSDictionary *)json withName:(NSString *)className;
{
    for(NSString *key in [json allKeys])
    {
        NSString *propertyName = [self humpfulFromKey:key withClassName:className];
        JsonValueType type = [self type:[json objectForKey:key]];
        NSLog(@"tyoe --> %d", type);
        switch (type) {
            case kString:
            {
                NSDictionary *dic =
                @{
                  @"jsonKey":key,
                  @"jsonType":@"string",
                  @"classKey":[NSString stringWithFormat:@"%@%@", preName.stringValue, propertyName],
                  @"classType":@"NSString",
                  @"className":className
                  };
                [array addObject:[dic mutableCopy]];
            }
                break;
            case kNumber:
            {
                NSDictionary *dic =
                @{
                  @"jsonKey":key,
                  @"jsonType":@"number",
                  @"classKey":[NSString stringWithFormat:@"%@%@", preName.stringValue, propertyName],
                  @"classType":@"NSNumber",
                  @"className":className
                  
                  };
                [array addObject:[dic mutableCopy]];
            }
                break;
            case kArray:
            {
                NSDictionary *dic =
                @{
                  @"jsonKey":key,
                  @"jsonType":@"array",
                  @"classKey":[NSString stringWithFormat:@"%@%@", preName.stringValue, propertyName],
                  @"classType":[NSString stringWithFormat:@"NSArray(%@)",[self uppercaseFirstChar:propertyName]],
                  @"className":className
                  };
                [array addObject:[dic mutableCopy]];
                NSLog(@"array type is data array --> %@", [self isDataArray:[json objectForKey:key]] ? @"YES" : @"NO");
                if([self isDataArray:[json objectForKey:key]])
                {
                    [self generateProperty:[[json objectForKey:key] objectAtIndex:0]
                                  withName:[self uppercaseFirstChar:propertyName]];
                }
                
                break;
            }
                break;
            case kDictionary:
            {
                NSDictionary *dic =
                @{
                  @"jsonKey":[self lowercaseFirstChar:key],
                  @"jsonType":@"object",
                  @"classKey":[NSString stringWithFormat:@"%@%@", preName.stringValue, propertyName],
                  @"classType":[self uppercaseFirstChar:propertyName],
                  @"className":className
                  };
                [array addObject:[dic mutableCopy]];
                [self generateProperty:[json objectForKey:key]
                              withName:[self uppercaseFirstChar:propertyName]];
            }
                break;
            case kBool:
            {
                NSDictionary *dic =
                @{
                  @"jsonKey":[self lowercaseFirstChar:key],
                  @"jsonType":@"bool",
                  @"classKey":[NSString stringWithFormat:@"%@%@", preName.stringValue, propertyName],
                  @"classType":@"BOOL",
                  @"className":className
                  };
                [array addObject:[dic mutableCopy]];
            }
                break;
            default:
                break;
        }
    }
}

-(NSString *)uppercaseFirstChar:(NSString *)str
{
    return [NSString stringWithFormat:@"%@%@",[[str substringToIndex:1] uppercaseString],[str substringWithRange:NSMakeRange(1, str.length-1)]];
}
-(NSString *)lowercaseFirstChar:(NSString *)str
{
    return [NSString stringWithFormat:@"%@%@",[[str substringToIndex:1] lowercaseString],[str substringWithRange:NSMakeRange(1, str.length-1)]];
}

-(void)showPropertys:(NSDictionary *)json
{
    array = nil;
    array = [[NSArrayController alloc] init];
    
    [self generateProperty:json withName:jsonName.stringValue];
    
    
    propertyWindowController = [[JSONPropertyWindowController alloc] initWithWindowNibName:@"JSONPropertyWindowController"];
    propertyWindowController.arrayController = array;
    [propertyWindowController.window makeKeyAndOrderFront:nil];
    
}



- (IBAction)generateClass:(id)sender {
    
    //    NSData *jsonData = [jsonContent.string dataUsingEncoding:NSUTF8StringEncoding];
    //    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    //
    //    if (!json) {
    //        NSAlert *alert = [[NSAlert alloc] init];
    //        alert.messageText = @"JSON转换失败";
    //        [alert showsHelp];
    //    }
    
    NSDictionary *json   = [jsonContent.string objectFromJSONString];
    
    if(json == nil)
    {
        jsonContent.string = @"json is invalid.";
        return;
    }
    
    //    for (NSString *key in json.allKeys) {
    //        id obj = [json objectForKey:key];
    //        NSLog(@"obj class name --> %@\n", [obj className]);
    //    }
    //    return;
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseDirectories = YES;
    panel.canChooseFiles = NO;
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        
        if(result == 0) return ;
        
        path = [panel.URL path];
        [self generateClass:jsonName.stringValue forDic:json];
        jsonContent.string = @"generate .h.m(ARC)files，put those to the folder";
        
    }];
    
    
}

- (IBAction)checkProperty:(id)sender {
    
    NSDictionary *json   = [jsonContent.string objectFromJSONString];
    
    if(json == nil)
    {
        jsonContent.string = @"json is invalid.";
        return;
    }
    
    [self showPropertys:json];
}


//表示该数组内有且只有字典 并且 结构一致。
-(BOOL)isDataArray:(NSArray *)theArray
{
    if(theArray.count <=0 ) return NO;
    for(id item in theArray)
    {
        if([self type:item] != kDictionary)
        {
            return NO;
        }
    }
    
    NSMutableSet *keys = [NSMutableSet set];
    for(NSString *key in [[theArray objectAtIndex:0] allKeys])
    {
        [keys addObject:key];
    }
    
    
    for(id item in theArray)
    {
        NSMutableSet *newKeys = [NSMutableSet set];
        for(NSString *key in [item allKeys])
        {
            [newKeys addObject:key];
        }
        
        if([keys isEqualToSet:newKeys] == NO)
        {
            return NO;
        }
    }
    return YES;
}


-(JsonValueType)type:(id)obj
{
    NSLog(@"obj class name --> %@", [obj className]);
    if([[obj className] isEqualToString:@"__NSCFString"] || [[obj className] isEqualToString:@"__NSCFConstantString"] || [[obj className] isEqualToString:@"NSTaggedPointerString"]) return kString;
    else if([[obj className] isEqualToString:@"__NSCFNumber"]) return kNumber;
    else if([[obj className] isEqualToString:@"__NSCFBoolean"])return kBool;
    else if([[obj className] isEqualToString:@"JKDictionary"])return kDictionary;
    else if([[obj className] isEqualToString:@"JKArray"])return kArray;
    return -1;
}

-(NSString *)typeName:(JsonValueType)type
{
    switch (type) {
        case kString:
            return @"NSString";
            break;
        case kNumber:
            return @"NSNumber";
            break;
        case kBool:
            return @"BOOL";
            break;
        case kArray:
            return @"NSArray";
            break;
        case kDictionary:
            return @"NSDictionary";
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark - private
- (NSString *)humpfulFromKey:(NSString *)key withClassName:(NSString *)className
{
    NSArray *components = [key componentsSeparatedByString:@"_"];
    NSMutableString *humpfulKey = [NSMutableString stringWithString:[components firstObject]];
    for (int i = 1; i < components.count; i++) {
        NSString *component = [components objectAtIndex:i];
        NSString *upperFirstChar = [self uppercaseFirstChar:component];
        [humpfulKey appendString:upperFirstChar];
    }
    
    if ([humpfulKey isEqualToString:@"id"] || [humpfulKey isEqualToString:@"Id"]) {
        return [[self lowercaseFirstChar:className] stringByAppendingString:@"Id"];
    } else if ([humpfulKey isEqualToString:@"description"] || [humpfulKey isEqualToString:@"Description"]) {
        return [[self lowercaseFirstChar:className] stringByAppendingString:@"Description"];
    } else if ([humpfulKey isEqualToString:@"class"] || [humpfulKey isEqualToString:@"Class"]) {
        return [[self lowercaseFirstChar:className] stringByAppendingString:@"Class"];
    }
    
    return humpfulKey;
}

@end