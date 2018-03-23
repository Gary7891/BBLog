//
//  ErrorModel.h
//  BBLog
//
//  Created by Gary on 6/26/14.
//  Copyright (c) 2014 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface BBErrorModel : RLMObject

/**
 主键
 */
@property NSString                 *ID;

/**
 *  堆栈信息
 */
@property NSString     *stackTrace;
/**
 *  发生时间
 */
@property double       time;

@property NSString     *activity;

@property NSString     *appkey;
/**
 *  系统版本
 */
@property NSString     *osVersion;
/**
 *  设备编号
 */
@property NSString     *deviceID;
/**
 *  应用版本
 */
@property NSString     *version;

/**
 用户token或者ID
 */
@property NSString                 *userToken;


- (NSDictionary*)toDictionary;

@end
RLM_ARRAY_TYPE(BBErrorModel)
