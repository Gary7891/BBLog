//
//  UserModel.m
//  BBLog
//
//  Created by Gary on 19/03/2018.
//  Copyright © 2018 czy. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

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

@end
