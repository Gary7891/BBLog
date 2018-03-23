//
//  ClientModel.m
//  BBLog
//
//  Created by Gary on 6/26/14.
//  Copyright (c) 2014 TimeFace. All rights reserved.
//

#import "BBClientModel.h"

@implementation BBClientModel

+(NSString*)primaryKey {
    return @"ID";
}

+(NSDictionary*)defaultPropertyValues {
    NSDictionary *defaultValuesDic = @{
                                       @"ID" :  [[NSUUID UUID] UUIDString]
                                       };
    return defaultValuesDic;
}

+ (NSArray<NSString*>*)indexedProperties {
    return @[@"ID"];
}


- (NSDictionary*)toDictionary {
    
    return nil;
}

@end
