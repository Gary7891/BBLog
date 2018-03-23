//
//  ConfigModel.h
//  BBLog
//
//  Created by Gary on 20/03/2018.
//  Copyright © 2018 czy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBConfigModel : NSObject


@property (nonatomic, copy) NSString               *version;

@property (nonatomic, copy) NSString               *token;

@property (nonatomic, copy) NSString               *clientName;

@property (nonatomic, copy) NSString               *platform;

@property (nonatomic, copy) NSString               *deviceId;

////////////////////////////阿里云日志服务的一些参数////////////////////////////////////


@property (nonatomic, copy) NSString               *endPoint;
@property (nonatomic, copy) NSString               *projectName;
@property (nonatomic, copy) NSString               *logStoreName;

//通过STS使用日志服务
@property (nonatomic, copy) NSString               *sts_ak;
@property (nonatomic, copy) NSString               *sts_sk;
@property (nonatomic, copy) NSString               *sts_token;

- (NSDictionary*)headerDictionary;


@end
