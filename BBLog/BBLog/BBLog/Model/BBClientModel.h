//
//  ClientModel.h
//  BBLog
//
//  Created by Gary on 6/26/14.
//  Copyright (c) 2014 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface BBClientModel : RLMObject

/**
 主键
 */
@property NSString                 *ID;

/**
 *  平台
 */
@property NSString         *platform;
/**
 *  系统版本
 */
@property NSString         *os_version;
/**
 *  系统语言
 */
@property NSString         *language;
/**
 *  屏幕分辨率 640X1136
 */
@property NSString         *resolution;
/**
 *  设备唯一ID
 */
@property NSString         *deviceId;
/**
 *  运营商信息
 */
@property NSString         *mccmnc;
/**
 *  版本信息
 */
@property NSString         *version;
/**
 *  网络信息
 */
@property NSString         *network;
/**
 *  设备名称
 */
@property NSString         *deviceName;
/**
 *  设备型号
 */
@property NSString         *moduleName;
/**
 *  时间
 */
@property double           time;
/**
 *  是否越狱
 */
@property NSString         *isjailbroken;
/**
 *  用户ID
 */
@property NSString         *userId;

/**
 app名称
 */
@property NSString         *clientName;

- (NSDictionary*)toDictionary;

@end

RLM_ARRAY_TYPE(BBClientModel)

