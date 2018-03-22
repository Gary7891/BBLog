//
//  NetWorkTools.h
//   BBLog
//
//  Created by  Gary on 6/26/14.
//  Copyright (c) 2014 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GlobalModel.h"
#import "ReturnModel.h"

#import "ClientModel.h"
#import "ErrorModel.h"
#import "TagModel.h"
#import "ActivityModel.h"
#import "EventModel.h"
#import "ConfigModel.h"

#define kHeadDeviceId @"kHeadDeviceId"

#ifdef DEBUG
#define debug_NSLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define debug_NSLog(format, ...)
#endif

@interface NetWorkTools : NSObject

+ (instancetype)sharedNetWork;


- (ReturnModel *) postClient:(NSString *) appkey deviceInfo:(ClientModel *) clientModel;

- (ReturnModel *) postUsingTime:(NSString *) appkey
                   sessionMills:(NSString *)sessionMills
                      startMils:(NSString*)startMils
                        endMils:(NSString*)endMils
                       duration:(NSString*)duration
                       activity:(NSString *) activity
                        version:(NSString *) version;

- (ReturnModel *) postArchiveLogs:(NSMutableDictionary *) archiveLogs;

- (ReturnModel *) postErrorLog:(NSString *) appkey errorLog:(ErrorModel *) errorModel;

- (ReturnModel *) postEvent:(NSString *) appkey event:(EventModel *) eventModel;

- (ReturnModel *) postTag:(NSString *) appkey tag:(TagModel *) tagModel;

- (ReturnModel*)postAllLogs:(NSMutableDictionary*)allLogs;


@property (nonatomic, strong) NSString *kServerUrl;

@property (nonatomic, strong) ConfigModel *configModel;


@end
