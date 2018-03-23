//
//  BBLogAgent.h
//  BBLog
//
//  Created by  Gary on 6/25/14.
//  Copyright (c) 2014 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    /**
     *  实时发送
     */
    ReportPolicyRealTime,
    /**
     *  下次启动发送
     */
    ReportPolicyBatch,
} ReportPolicyType;

@interface BBLogAgent : NSObject

+(void)ConfigWith:(NSDictionary*)configDic;

+(void)startWithAppKey:(NSString*)appKey serverURL:(NSString *)serverURL;

+(void)startWithAppKey:(NSString*)appKey reportPolicy:(ReportPolicyType)reportPolicy serverURL:(NSString*)serverURL
;
+(void)postEvent:(NSString *)eventId;

+(void)postEvent:(NSString *)eventId relatedData:(NSString *)data;

+(void)postEvent:(NSString *)eventId acc:(NSInteger)acc;

+(void)postEvent:(NSString *)eventId relatedData:(NSString *)data acc:(NSInteger)acc;

/**
 点击事件记录

 @param eventId 事件类型（ID）
 @param data 相关的数据，比如广告ID
 @param index 事件索引
 */
+(void)postEvent:(NSString *)eventId relatedData:(NSString*)data index:(NSInteger)index;

+(void)postTag:(NSString *)tag;

+(void)bindUserIdentifier:(NSString *)userid;

+(void)startTracPage:(NSString*)pageName;

+(void)endTracPage:(NSString*)pageName;

/**
 页面访问记录，开始进入页面

 @param pageName 页面名称
 @param data 相关的数据，如商品ID
 */
+(void)startTracPage:(NSString *)pageName relatedData:(NSString*)data;

// Check if the device jail broken
+ (BOOL)isJailbroken;
+ (NSString*)getDeviceId;
- (void)saveErrorLog:(NSString*)stackTrace;
+ (void)setDefaultHandler;
+ (NSUncaughtExceptionHandler *)getHandler;
+ (void)TakeException:(NSException *) exception;

@end
void InstallUncaughtExceptionHandler();
