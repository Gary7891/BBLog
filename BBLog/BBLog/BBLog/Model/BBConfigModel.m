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
    NSString *storeId = @"";
    if (self.accountId.length && !storeId.length) {
        storeId = self.accountId;
    }
    if (self.subAccountId.length && !storeId.length) {
        storeId = self.subAccountId;
    }
    [dic setObject:storeId forKey:@"storeId"];
    [dic setObject:self.accountName?:@"" forKey:@"storeName"];
    [dic setObject:self.clientName?:@"" forKey:@"x-client"];
    [dic setObject:self.deviceId?:@"" forKey:@"x-equCode"];
    [dic setObject:self.platform?:@"" forKey:@"x-platform"];
    
    return dic;
}

@end
