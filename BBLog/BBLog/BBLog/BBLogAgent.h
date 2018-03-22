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

+(void)postEvent:(NSString *)eventId relatedData:(NSString*)data index:(NSInteger)index;

+(void)postTag:(NSString *)tag;

+(void)bindUserIdentifier:(NSString *)userid;

+(void)startTracPage:(NSString*)pageName;

+(void)endTracPage:(NSString*)pageName;

// Check if the device jail broken
+ (BOOL)isJailbroken;
+ (NSString*)getDeviceId;
- (void)saveErrorLog:(NSString*)stackTrace;
+ (void)setDefaultHandler;
+ (NSUncaughtExceptionHandler *)getHandler;
+ (void)TakeException:(NSException *) exception;

@end
void InstallUncaughtExceptionHandler();
