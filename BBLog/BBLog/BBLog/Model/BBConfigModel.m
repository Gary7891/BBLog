//
//  ConfigModel.m
//  BBLog
//
//  Created by Gary on 20/03/2018.
//  Copyright © 2018 czy. All rights reserved.
//

#import "BBConfigModel.h"

@implementation BBConfigModel

- (NSDictionary*)headerDictionary {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.version?:@"" forKey:@"x-version"];
    [dic setObject:self.accountId?:@"" forKey:@"accountId"];
    [dic setObject:self.subAccountId?:@"" forKey:@"subAccountId"];
    [dic setObject:self.accountName?:@"" forKey:@"accountName"];
    [dic setObject:self.clientName?:@"" forKey:@"x-client"];
    [dic setObject:self.deviceId?:@"" forKey:@"x-equCode"];
    [dic setObject:self.platform?:@"" forKey:@"x-platform"];
    
    return dic;
}

@end
