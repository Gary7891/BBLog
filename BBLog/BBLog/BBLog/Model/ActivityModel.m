//
//  ActivityModel.m
//  BBLog
//
//  Created by  Gary on 6/26/14.
//  Copyright (c) 2014 TimeFace. All rights reserved.
//

#import "ActivityModel.h"

@implementation ActivityModel

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
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.activityName?:@"" forKey:@"type"];
    [dic setObject:self.relatedData?:@"" forKey:@"refid"];
    [dic setObject:[NSString stringWithFormat:@"%f",self.startMils] forKey:@"ctime"];
    
    return dic;
    
}

@end
