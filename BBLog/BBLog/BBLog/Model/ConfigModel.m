//
//  ConfigModel.m
//  BBLog
//
//  Created by Gary on 20/03/2018.
//  Copyright © 2018 czy. All rights reserved.
//

#import "ConfigModel.h"

@implementation ConfigModel

- (NSDictionary*)headerDictionary {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.version?:@"" forKey:@"x-version"];
    [dic setObject:self.token?:@"" forKey:@"Authorization"];
    [dic setObject:self.clientName?:@"" forKey:@"x-client"];
    [dic setObject:self.deviceId?:@"" forKey:@"x-equCode"];
    [dic setObject:self.platform?:@"" forKey:@"x-platform"];
    
    return dic;
}

@end
