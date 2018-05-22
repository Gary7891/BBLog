//
//  ActivityModel.m
//  BBLog
//
//  Created by  Gary on 6/26/14.
//  Copyright (c) 2014 TimeFace. All rights reserved.
//

#import "BBActivityModel.h"
#import "BBLogAgent.h"

@implementation BBActivityModel

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
    long timemmils = self.startMils * 1000;
    [dic setObject:[NSString stringWithFormat:@"%@",@(timemmils)] forKey:@"ctime"];
    NSDictionary *configDic = [BBLogAgent configDictionary];
    NSString *storeId = [configDic objectForKey:@"storeId"]?:@"";
    [dic setObject:storeId forKey:@"storeId"];
    [dic setObject:[configDic objectForKey:@"storeName"]?:@"" forKey:@"storeName"];
    
    return dic;
    
}

@end
