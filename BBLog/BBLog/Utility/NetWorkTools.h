//
//  NetWorkTools.h
//   BBLog
//
//  Created by  Gary on 6/26/14.
//  Copyright (c) 2014 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BBGlobalModel.h"
#import "BBReturnModel.h"

#import "BBClientModel.h"
#import "BBErrorModel.h"
#import "BBTagModel.h"
#import "BBActivityModel.h"
#import "BBEventModel.h"
#import "BBConfigModel.h"

#define kHeadDeviceId @"kHeadDeviceId"

#ifdef DEBUG
#define debug_NSLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define debug_NSLog(format, ...)
#endif

@interface NetWorkTools : NSObject

+ (instancetype)sharedNetWork;


- (BBReturnModel *) postClient:(NSString *) appkey deviceInfo:(BBClientModel *) clientModel;

- (BBReturnModel *) postUsingTime:(NSString *) appkey
                   sessionMills:(NSString *)sessionMills
                      startMils:(NSString*)startMils
                        endMils:(NSString*)endMils
                       duration:(NSString*)duration
                       activity:(NSString *) activity
                        version:(NSString *) version;

- (BBReturnModel *) postArchiveLogs:(NSMutableDictionary *) archiveLogs;

- (BBReturnModel *) postErrorLog:(NSString *) appkey errorLog:(BBErrorModel *) errorModel;

- (BBReturnModel *) postEvent:(NSString *) appkey event:(BBEventModel *) eventModel;

- (BBReturnModel *) postTag:(NSString *) appkey tag:(BBTagModel *) tagModel;

- (BBReturnModel*)postAllLogs:(NSMutableDictionary*)allLogs;


@property (nonatomic, strong) NSString *kServerUrl;

@property (nonatomic, strong) BBConfigModel *configModel;


@end
