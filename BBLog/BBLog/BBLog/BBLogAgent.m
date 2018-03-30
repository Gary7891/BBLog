//
//  BBLogAgent.m
//  BBLog
//
//  Created by  Gary on 6/25/14.
//  Copyright (c) 2014 TimeFace. All rights reserved.
//

#import "BBLogAgent.h"
#import "BBLogKeychain.h"

//Model
#import "BBClientModel.h"
#import "BBActivityModel.h"
#import "BBErrorModel.h"
#import "BBEventModel.h"
#import "BBTagModel.h"
#import "BBReturnModel.h"
#import "BBAppPageModel.h"
#import "BBConfigModel.h"
#import "NetWorkTools.h"

#import "asl.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <arpa/inet.h> // For AF_INET, etc.
#import <ifaddrs.h> // For getifaddrs()
#import <net/if.h> // For IFF_LOOPBACK
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access
#import <sys/utsname.h>

#include <libkern/OSAtomic.h>
#include <execinfo.h>

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";
NSString * const RealmDataBaseName =  @"BBLogRealmDataBase";

NSString * applicationDocumentsDirectory()
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}






@interface BBLogAgent() {
    
}

@property (nonatomic ,assign) ReportPolicyType             reportPolicy;

@property (nonatomic ,copy) NSString                       *serverUrl;

@property (nonatomic ,assign) BOOL                         isLogEnabled;

@property (nonatomic ,assign) BOOL                         isCrashReportEnabled;

@property (nonatomic ,copy) NSString                       *appKey;

@property (nonatomic ,copy) NSString                       *updateOnlyWifi;

@property (nonatomic ,copy) NSString                       *sessionmillis;

@property (nonatomic ,assign) BOOL                         isOnLineConfig;

@property (nonatomic ,strong) NSDate                       *startDate;

@property (nonatomic ,copy) NSString                       *sessionId;

@property (nonatomic ,copy) NSString                       *pageName;

@property (nonatomic ,strong) NSDate                       *sessionStopDate;

@property (nonatomic, copy) NSString                     *relatedData;

@property (nonatomic, copy) NSString                     *currentPageId;

@property (nonatomic, strong)BBConfigModel                 *configModel;

@end

@implementation BBLogAgent

+ (instancetype)sharedLogAgent
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = self.new;
        
        NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [docPath objectAtIndex:0];
        NSString *filePath = [path stringByAppendingPathComponent:RealmDataBaseName];
        NSLog(@"数据库目录 = %@",filePath);
        
        RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
        config.fileURL = [NSURL URLWithString:filePath];
        config.readOnly = NO;
        int currentVersion = 1.0;
        config.schemaVersion = currentVersion;
        
        config.migrationBlock = ^(RLMMigration *migration , uint64_t oldSchemaVersion) {
            // 这里是设置数据迁移的block
            if (oldSchemaVersion < currentVersion) {
            }
        };
        
        [RLMRealmConfiguration setDefaultConfiguration:config];
        
       
    });
    return instance;
}

void UncaughtExceptionHandler(NSException * exception)
{
    debug_NSLog(@"UncaughtExceptionHandler");
    //    NSArray * arr = [exception callStackSymbols];
    //    NSString * reason = [exception reason];
    //    NSString * name = [exception name];
    //    NSString * url = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[arr componentsJoinedByString:@"\n"]];
    //    NSString * path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
    //    [url writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    //
    //    NSString *urlStr = [NSString stringWithFormat:@"mailto:wy@91goal.com?subject=客户端bug报告&body=很抱歉应用出现故障,感谢您的配合!发送这封邮件可协助我们改善此应用<br>"
    //                        "错误详情:<br>%@<br>--------------------------<br>%@<br>---------------------<br>%@",
    //                        name,reason,[arr componentsJoinedByString:@"<br>"]];
    //
    //    NSURL *url2 = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //    [[UIApplication sharedApplication] openURL:url2];
    debug_NSLog(@"CRASH: %@", exception);
    debug_NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    NSString *stackTrace = [[NSString alloc] initWithFormat:@"%@\n%@",exception,[exception callStackSymbols]];
    stackTrace = [stackTrace stringByReplacingOccurrencesOfString:@"\n" withString:@";"];
    stackTrace = [stackTrace stringByReplacingOccurrencesOfString:@"\t[0-9]+" withString:@";" options:NSRegularExpressionSearch range:NSMakeRange(0, stackTrace.length)];
    [[BBLogAgent sharedLogAgent] saveErrorLog:stackTrace];
    
}

+(void)ConfigWith:(NSDictionary *)configDic {
    BBConfigModel *configModel = [[BBConfigModel alloc]init];
    
    
    configModel.version = [configDic objectForKey:@"x-version"]?:@"";
    configModel.token = [configDic objectForKey:@"Authorization"]?:@"";
    configModel.clientName = [configDic objectForKey:@"x-client"]?:@"";
    configModel.deviceId = [configDic objectForKey:@"x-equCode"]?:@"";
    configModel.platform = [configDic objectForKey:@"x-platform"]?:@"";
    configModel.endPoint = [configDic objectForKey:@"endPoint"]?:@"";
    configModel.projectName = [configDic objectForKey:@"projectName"]?:@"";
    configModel.logStoreName = [configDic objectForKey:@"logStoreName"]?:@"";
    configModel.sts_ak = [configDic objectForKey:@"sts_ak"]?:@"";
    configModel.sts_sk = [configDic objectForKey:@"sts_sk"]?:@"";
    configModel.sts_token = [configDic objectForKey:@"sts_token"]?:@"";
    
    [BBLogAgent sharedLogAgent].configModel = configModel;
  
}

+(void)startWithAppKey:(NSString*)appKey serverURL:(NSString *)serverURL
{
    [[BBLogAgent sharedLogAgent] initWithAppKey:appKey reportPolicy:ReportPolicyBatch serverURL:serverURL];

}

+(void)startWithAppKey:(NSString*)appKey reportPolicy:(ReportPolicyType)reportPolicy serverURL:(NSString*)serverURL
{
    [[BBLogAgent sharedLogAgent] initWithAppKey:appKey reportPolicy:reportPolicy serverURL:serverURL];
}

+ (void)setIsLogEnabled:(BOOL)isLogEnabled
{
    [BBLogAgent sharedLogAgent].isLogEnabled = isLogEnabled;
}


-(void)initWithAppKey:(NSString*)appKey reportPolicy:(ReportPolicyType)reportPolicy serverURL:(NSString*)serverURL
{
    [self setAppKey:appKey];
    [self setReportPolicy:reportPolicy];
    [self setServerUrl:serverURL];
    [[NetWorkTools sharedNetWork] setKServerUrl:serverURL];
    [[NetWorkTools sharedNetWork] setConfigModel:self.configModel];
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self
                    selector:@selector(didEnterBackground:)
                        name:UIApplicationDidEnterBackgroundNotification
                      object:nil];
    [notifCenter addObserver:self
                    selector:@selector(becomeActive:)
                        name:UIApplicationWillEnterForegroundNotification
                      object:nil];

    
    
    self.startDate = [[NSDate date] copy];
    self.currentPageId = @"";
    NSString *currentTime = [[NSString alloc] initWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    NSString *sessionIdentifier = [[NSString alloc] initWithFormat:@"%@%@", currentTime, [BBLogAgent getDeviceId]
                                   ];
    debug_NSLog(@"sessionIdentifier = %@",sessionIdentifier);
    self.sessionId = [self md5:sessionIdentifier];
    debug_NSLog(@"self.sessionId = %@",self.sessionId);
    if (!self.sessionId.length) {
        self.sessionId = @"B534833A9FC6B34644377282EC53CCE1";
    }
    BBAppPageModel *pageModel = [[BBAppPageModel alloc]init];
    pageModel.startMils = [[NSDate date] timeIntervalSince1970];
    pageModel.activityName = [[NSBundle mainBundle] bundleIdentifier];
    pageModel.sessionId = self.sessionId;
    pageModel.version = self.configModel.version;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm addObject: pageModel];
        }];
    });
    if(_isLogEnabled)
    {
        debug_NSLog(@"Get Session ID = %@",_sessionId);
    }
//    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [self performSelectorInBackground:@selector(archiveClientData) withObject:nil];
}

- (BBClientModel*)getCurrentClentModel {
    BBClientModel *model = [[BBClientModel allObjects] sortedResultsUsingKeyPath:@"time" ascending:NO].firstObject;
    if (model) {
        return model;
    }
    return nil;
}



+(void)startTracPage:(NSString*)pageName
{
    [[BBLogAgent sharedLogAgent] performSelectorInBackground:@selector(recordStartTime:) withObject:[pageName copy]];
}

+ (void)startTracPage:(NSString *)pageName relatedData:(NSString *)data {

    NSDictionary *params = @{
                             @"pageName"     :   [pageName copy] ,
                             @"relatedData"  :   data?:@""
                             };
    [[BBLogAgent sharedLogAgent] performSelectorInBackground:@selector(recordStartTimeWithParams:) withObject:params];

}

- (void)recordStartTimeWithParams:(NSDictionary*)params {
    @autoreleasepool {
        NSString *pageName = [params objectForKey:@"pageName"];
        NSString *data = [params objectForKey:@"relatedData"];
        self.pageName = [[NSString alloc] initWithString:pageName];
        self.relatedData = data?:@"";
        NSDate *pageStartDate = [[NSDate date] copy];
        RLMResults<BBActivityModel*> *activityResult = [BBActivityModel objectsWhere:@"ID = %@",self.currentPageId];
        BBActivityModel *activityModel = nil;
        if (activityResult.count && activityResult.firstObject) {
            if ([activityResult.firstObject isKindOfClass:[BBActivityModel class]] && !activityResult.firstObject.relatedData) {
                activityModel = activityResult.firstObject;
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm transactionWithBlock:^{
                    activityModel.relatedData = self.relatedData;
                }];
            }
            
        }
        
        if (!activityModel) {
            activityModel = [[BBActivityModel alloc] init];
            self.currentPageId = activityModel.ID;
            activityModel.sessionId = self.sessionId;
            activityModel.relatedData = data;
            activityModel.startMils = [pageStartDate timeIntervalSince1970];
            activityModel.activityName = pageName;
            activityModel.version = [self getVersion];
            activityModel.userToken = self.configModel.token;
            if(activityModel)
            {
                debug_NSLog(@"acLog sessionId = %@",activityModel.sessionId);
            }
            
            
                
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm transactionWithBlock:^{
                [realm addObject: activityModel];
            }];
            
        }
    }
}

-(void)recordStartTime:(NSString*) pageName
{
    @autoreleasepool {
        self.pageName = [[NSString alloc] initWithString:pageName];
        self.relatedData = @"";
        NSDate *pageStartDate = [[NSDate date] copy];
        BBActivityModel *activityModel = [[BBActivityModel alloc] init];
        self.currentPageId = activityModel.ID;
        activityModel.sessionId = self.sessionId;
        activityModel.relatedData = self.relatedData;
        activityModel.startMils = [pageStartDate timeIntervalSince1970];
        activityModel.activityName = self.pageName;
        activityModel.version = [self getVersion];
        activityModel.userToken = self.configModel.token;
        if(activityModel)
        {
            debug_NSLog(@"acLog sessionId = %@",activityModel.sessionId);
        }
        
        
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm transactionWithBlock:^{
                [realm addObject: activityModel];
            }];
        
        
    }
}

+(void)endTracPage:(NSString*)pageName
{
    if([BBLogAgent sharedLogAgent].reportPolicy == ReportPolicyRealTime)
    {
        [[BBLogAgent sharedLogAgent] performSelectorInBackground:@selector(commitUsingTime:) withObject:[pageName copy]];
    }
    else if([BBLogAgent sharedLogAgent].reportPolicy == ReportPolicyBatch)
    {
        [[BBLogAgent sharedLogAgent] performSelectorInBackground:@selector(saveActivityUsingTime:) withObject:[pageName copy]];
    }
    
}

- (void)didEnterBackground:(NSNotification *)notification
{
//    if(self.pageName!=nil)
//    {
//        [BBLogAgent endTracPage:self.pageName];
//    }
    
    _sessionStopDate = [NSDate date];
    RLMResults<BBAppPageModel*> *result = [BBAppPageModel objectsWhere:@"sessionId = %@",self.sessionId];
    BBAppPageModel *pageModel = result.firstObject;
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        if (pageModel) {
            pageModel.endMils = [_sessionStopDate timeIntervalSince1970];
            pageModel.duration = pageModel.endMils - pageModel.startMils;
            pageModel.version = self.configModel.version;
        }
    }];
    
    
    if(_isLogEnabled)
    {
        debug_NSLog(@"Resign Active: click home button or lose focus. End Trace Page and save session stop date.");
    }
}

- (void)becomeActive:(NSNotification *)notification
{
    if(_isLogEnabled)
    {
        debug_NSLog(@"Application become active");
    }

    NSString *sessionId = [[NSString alloc] initWithFormat:@"%f%@",[[NSDate date] timeIntervalSince1970],[BBLogAgent getDeviceId]];
    if(_sessionStopDate!=nil)
    {
        NSTimeInterval sessionStopInterval = -[_sessionStopDate timeIntervalSinceNow];
        if(sessionStopInterval + 0.0000001 > 30)
        {
            self.sessionId = [self md5:sessionId];
            BBAppPageModel *pageModel = [[BBAppPageModel alloc]init];
            pageModel.startMils = [[NSDate date] timeIntervalSince1970];
            pageModel.activityName = [[NSBundle mainBundle] bundleIdentifier];
            pageModel.sessionId = self.sessionId;
            pageModel.version = self.configModel.version;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm transactionWithBlock:^{
                    [realm addObject: pageModel];
                }];
            });

            if(_isLogEnabled)
            {
                debug_NSLog(@"Stop session more than 30 seconds, so consider as new session id.");
            }
        }
        else
        {
            if(_isLogEnabled)
            {
                debug_NSLog(@"Stop session less than 30 seconds, so consider as old session.");
            }
        }
    }
    else
    {
        self.sessionId = [self md5:sessionId];
    }
    if(_isLogEnabled)
    {
        debug_NSLog(@"Current session ID = %@",_sessionId);
    }
    
    [self performSelectorInBackground:@selector(archiveClientData) withObject:nil];
    
    if(_isLogEnabled)
    {
        debug_NSLog(@"Application Resign Active");
    }
    
}

-(void)commitUsingTime:(NSString*)currentPageName
{
    @autoreleasepool
    {
        NSString *session_mills = self.sessionId;
        NSString *end_mils = [self getCurrentTime];
        NSDate *pageStartDate = [[NSUserDefaults standardUserDefaults] objectForKey:currentPageName];
        if(pageStartDate!=nil)
        {
            NSString *start_mils = [self getDateStr:pageStartDate];
            NSTimeInterval duration = (-[pageStartDate timeIntervalSinceNow]);
            NSString *durationStr = [[NSString alloc] initWithFormat:@"%f",duration];
            NSString *activities = currentPageName;
            NSString *appVersion = [self getVersion];
            //发送client model
            [[NetWorkTools sharedNetWork] postUsingTime:_appKey
                                           sessionMills:session_mills
                                              startMils:start_mils
                                                endMils:end_mils
                                               duration:durationStr
                                               activity:activities
                                                version:appVersion];
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:currentPageName];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            if(_isLogEnabled)
            {
                debug_NSLog(@"Page Start time not found. in commitUsingTime pagename = %@",currentPageName);
            }
        }
    }
}

- (void)saveErrorLog:(NSString*)stackTrace
{
    @autoreleasepool {
        if(_isLogEnabled)
        {
            debug_NSLog(@"save error log");
        }
        BBErrorModel *errorModel = [[BBErrorModel alloc] init];
        errorModel.stackTrace = stackTrace;
        errorModel.appkey = self.appKey;
        errorModel.version = [self getVersion];
        errorModel.time = [self getCurrentTime].doubleValue;
        errorModel.activity = [[NSBundle mainBundle] bundleIdentifier];
        errorModel.osVersion = [[UIDevice currentDevice] systemVersion];
        errorModel.deviceID = [BBLogAgent getDeviceId];
        debug_NSLog(@"Error Log");
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm addObject:errorModel];
        }];
    }
}

- (void)saveActivityUsingTime:(NSString*)currentPageName
{
    @autoreleasepool
    {
        BBActivityModel *activityModel = nil;
        if (self.currentPageId.length) {
            RLMResults<BBActivityModel*> *activityResult = [BBActivityModel objectsWhere:@"ID = %@",[self.currentPageId copy]];
            if (activityResult.count) {
                activityModel = activityResult.firstObject;
            }
        }
        if (!activityModel) {
            RLMResults<BBActivityModel*> *activityResult = [[BBActivityModel objectsWhere:@"activityName = %@ and sessionId = %@",currentPageName,[self.sessionId copy]] sortedResultsUsingKeyPath:@"startMils" ascending:NO];
            if (activityResult.count) {
                NSLog(@"排序得来");
                activityModel = activityResult.firstObject;
            }
            
        }
        if (!activityModel || activityModel.endMils > 0) {
            return;
        }
        NSDate *pageStartDate = [NSDate dateWithTimeIntervalSince1970:activityModel.startMils];
        double currentTimeinterval = [self getCurrentTime].doubleValue;
        NSTimeInterval duration = (-[pageStartDate timeIntervalSinceNow]);
        
        if(activityModel)
        {
            debug_NSLog(@"acLog sessionId = %@",activityModel.sessionId);
        }
        NSString *sessionId = [self.sessionId copy];
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            activityModel.endMils = currentTimeinterval;
            activityModel.duration = duration;
            activityModel.sessionId = sessionId;
        }];
        if(_isLogEnabled)
        {
            debug_NSLog(@"Activity Log array size %lu",(unsigned long)[BBActivityModel allObjects].count);
        }
    }
}

-(NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[32];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


+(void)postEvent:(NSString *)eventId
{
    BBEventModel *eventModel =[[BBEventModel alloc] init];
    eventModel.eventId = eventId;
    eventModel.activityName = [[NSBundle mainBundle] bundleIdentifier];
    eventModel.descriptionString = @"";
    eventModel.relatedData = @"";
    eventModel.time = [[BBLogAgent sharedLogAgent] getCurrentTime].doubleValue;
    eventModel.version = [[BBLogAgent sharedLogAgent] getVersion];
    eventModel.acc = 1;
    eventModel.userToken = [BBLogAgent sharedLogAgent].configModel.token;
    [[BBLogAgent sharedLogAgent] archiveEvent:eventModel];
}

+(void)postEvent:(NSString *)eventId relatedData:(NSString *)label
{
    BBEventModel *eventModel = [[BBEventModel alloc] init];
    eventModel.eventId = eventId;
    eventModel.time = [[BBLogAgent sharedLogAgent] getCurrentTime].doubleValue;
    eventModel.acc = 1;
    eventModel.version = [[BBLogAgent sharedLogAgent] getVersion];
    eventModel.activityName = [[NSBundle mainBundle] bundleIdentifier];
    eventModel.descriptionString = @"";
    eventModel.relatedData = label;
    eventModel.userToken = [BBLogAgent sharedLogAgent].configModel.token;
    [[BBLogAgent sharedLogAgent] archiveEvent:eventModel];
    
}

+(void)postEvent:(NSString *)eventId acc:(NSInteger)acc
{
    BBEventModel *eventModel = [[BBEventModel alloc] init];
    eventModel.eventId = eventId;
    eventModel.time = [[BBLogAgent sharedLogAgent] getCurrentTime].doubleValue;
    eventModel.acc = acc;
    eventModel.version = [[BBLogAgent sharedLogAgent] getVersion];
    eventModel.activityName =[[NSBundle mainBundle] bundleIdentifier];
    eventModel.descriptionString = @"";
    eventModel.relatedData = @"";
    eventModel.userToken = [BBLogAgent sharedLogAgent].configModel.token;
    [[BBLogAgent sharedLogAgent] archiveEvent:eventModel];
    
}

+(void)postEvent:(NSString *)eventId relatedData:(NSString *)label acc:(NSInteger)acc
{
    BBEventModel *eventModel = [[BBEventModel alloc] init];
    eventModel.eventId = eventId;
    eventModel.time = [[BBLogAgent sharedLogAgent] getCurrentTime].doubleValue;
    eventModel.acc = acc;
    eventModel.activityName = [[NSBundle mainBundle] bundleIdentifier];
    eventModel.version = [[BBLogAgent sharedLogAgent] getVersion];
    eventModel.descriptionString = @"";
    eventModel.relatedData = label;
    eventModel.userToken = [BBLogAgent sharedLogAgent].configModel.token;
    [[BBLogAgent sharedLogAgent] archiveEvent:eventModel];
}

+(void)postEvent:(NSString *)eventId relatedData:(NSString *)data index:(NSInteger)index {
    BBEventModel *eventModel = [[BBEventModel alloc] init];
    eventModel.eventId = eventId;
    eventModel.time = [[BBLogAgent sharedLogAgent] getCurrentTime].doubleValue;
    eventModel.acc = 1;
    eventModel.activityName = [[NSBundle mainBundle] bundleIdentifier];
    eventModel.version = [[BBLogAgent sharedLogAgent] getVersion];
    eventModel.descriptionString = @"";
    eventModel.relatedData = data;
    eventModel.index = index;
    eventModel.userToken = [BBLogAgent sharedLogAgent].configModel.token;
    [[BBLogAgent sharedLogAgent] archiveEvent:eventModel];
}

+(void)postTag:(NSString *)tag
{
    BBTagModel *tagModel = [[BBTagModel alloc] init];
    tagModel.tags = tag;
    tagModel.productkey = [[BBLogAgent sharedLogAgent] appKey];
    tagModel.deviceid = [BBLogAgent getDeviceId];
    
    [[BBLogAgent sharedLogAgent] archiveTag:tagModel];
}

+(void)bindUserIdentifier:(NSString *)userToken
{
    if (!userToken) {
        userToken = @"";
    }
    BBClientModel *clientModel = [[BBLogAgent sharedLogAgent] getCurrentClentModel];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        clientModel.userId = userToken;
    }];
    
    [BBLogAgent sharedLogAgent].configModel.token = userToken;
    
}


-(void) processEvent:(BBEventModel *)event
{
    [self performSelectorInBackground:@selector(postEventInBackGround:) withObject:event];
}

-(void) processTag:(BBTagModel *)tag
{
    [self performSelectorInBackground:@selector(postTagInBackGround:) withObject:tag];
}

-(void) processArchivedLogs
{
    @autoreleasepool {

        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    
        RLMResults<BBEventModel*> *eventResults = [BBEventModel objectsWhere:@"time < %f",currentTime];
        NSMutableArray *eventArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < eventResults.count; i++) {
            BBEventModel *model = [eventResults objectAtIndex:i];
            NSDictionary *dic = model.toDictionary?:[[NSDictionary alloc]init];
            [eventArray addObject:dic];
        }
        
        RLMResults<BBActivityModel*> *activitResult = [BBActivityModel objectsWhere:@"startMils < %f",currentTime];
        NSMutableArray *activityLogArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < activitResult.count; i++) {
            BBActivityModel *model = [activitResult objectAtIndex:i];
            NSDictionary *dic = model.toDictionary?:[[NSDictionary alloc]init];
            [activityLogArray addObject:dic];
        }
        
        RLMResults<BBErrorModel*> *errorResult = [BBErrorModel objectsWhere:@"time < %f",currentTime];
        NSMutableArray *errorLogArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < errorResult.count; i++) {
            BBErrorModel *model = [errorResult objectAtIndex:i];
            NSDictionary *dic = model.toDictionary?:[[NSDictionary alloc]init];
            [errorLogArray addObject:dic];
        }
        
        RLMResults<BBClientModel*> *clientResult = [BBClientModel objectsWhere:@"time < %f",currentTime];
        NSMutableArray *clientDataArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < clientResult.count; i++) {
            BBClientModel *model = [clientResult objectAtIndex:i];
            NSDictionary *dic = model.toDictionary?:[[NSDictionary alloc]init];
            [clientDataArray addObject:dic];
        }
        
        RLMResults<BBTagModel*> *tagResult = [BBTagModel allObjects];
        NSMutableArray *tagArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < tagResult.count; i++) {
            BBTagModel *model = [tagResult objectAtIndex:i];
            NSDictionary *dic = model.toDictionary?:[[NSDictionary alloc]init];
            [tagArray addObject:dic];
        }
        
        if([eventArray count]>0 || [activityLogArray count]>0 || [errorLogArray count]>0 || [clientDataArray count]>0 || [tagArray count]>0)
        {
//            NSMutableDictionary *dic_ = [[NSMutableDictionary alloc]init];
            NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
            
            [requestDic setObject:_appKey forKey:@"appkey"];
            
            [requestDic setObject:eventArray forKey:@"eventArray"];
            
            if([tagArray count]>0)
            {
                [requestDic setObject:tagArray forKey:@"tagArray"];
            }
            [requestDic setObject:activityLogArray forKey:@"activityLog"];
            
            if([errorLogArray count]>0)
            {
                [requestDic setObject:errorLogArray forKey:@"errorLog"];
            }
            [requestDic setObject:clientDataArray forKey:@"clientDataArray"];

            
            if(_isLogEnabled)
            {
                debug_NSLog(@"Post Archive Logs");
            }
            
            BBReturnModel *returnModel = [[NetWorkTools sharedNetWork] postAllLogs:requestDic];
            
            if (returnModel.evnetSuccess) {
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm transactionWithBlock:^{
                    [realm deleteObjects:eventResults];
                }];
            }
            if (returnModel.activitySuccess) {
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm transactionWithBlock:^{
                    
                    [realm deleteObjects:activitResult];
                  
                }];
            }
            if (returnModel.clientSuccess) {
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm transactionWithBlock:^{
                    
                    [realm deleteObjects:clientResult];
    
                }];
            }
            if (returnModel.errorSuccess) {
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm transactionWithBlock:^{
                   
                    [realm deleteObjects:errorResult];
                }];
            }
            
            if (returnModel.tagSuccess) {
                RLMRealm *realm = [RLMRealm defaultRealm];
                [realm transactionWithBlock:^{
                    
                    [realm deleteObjects:tagResult];
                }];
            }
            
        }
    }
}



-(NSMutableArray *)getArchiveEvent:(NSTimeInterval)currentTime
{
    
    RLMResults<BBEventModel*> *eventResults = [BBEventModel objectsWhere:@"time < %f",currentTime];
    NSMutableArray *eventArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < eventResults.count; i++) {
        BBEventModel *model = [eventResults objectAtIndex:i];
        [eventArray addObject:model];
    }
    return eventArray;
}

-(NSMutableArray *)getArchiveTag
{
    RLMResults<BBTagModel*> *tagResult = [BBTagModel allObjects];
    NSMutableArray *tagArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < tagResult.count; i++) {
        BBTagModel *model = [tagResult objectAtIndex:i];
        [tagArray addObject:model];
    }
    return tagArray;
}


-(NSMutableArray *)getArchiveActivityLog:(NSTimeInterval)currentTime
{
    RLMResults<BBActivityModel*> *activitResult = [BBActivityModel objectsWhere:@"startMils < %f",currentTime];
    NSMutableArray *activityLogArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < activitResult.count; i++) {
        BBActivityModel *model = [activitResult objectAtIndex:i];
        [activityLogArray addObject:model];
    }
    return activityLogArray;
}

-(NSMutableArray *)getArchiveErrorLog:(NSTimeInterval)currentTime
{
    RLMResults<BBErrorModel*> *errorResult = [BBErrorModel objectsWhere:@"time < %f",currentTime];
    NSMutableArray *errorLogArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < errorResult.count; i++) {
        BBErrorModel *model = [errorResult objectAtIndex:i];
        [errorLogArray addObject:model];
    }
    return errorLogArray;
}


-(void)postEventInBackGround:(BBEventModel *)event
{
    @autoreleasepool {
        BBReturnModel *ret = [[NetWorkTools sharedNetWork] postEvent:_appKey event:event];
        if (ret.status < 0)
        {
            //上传失败，存入数据库
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm transactionWithBlock:^{
                [realm addObject:event];
            }];
        }
    }
}

-(void)postTagInBackGround:(BBTagModel *)tag
{
    @autoreleasepool {
        BBReturnModel *ret = [[NetWorkTools sharedNetWork] postTag:_appKey tag:tag];
        if (ret.status<0)
        {
            //上传失败，存入数据库
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm transactionWithBlock:^{
                [realm addObject:tag];
            }];
        }
    }
}





-(void)archiveClientData
{
    
    BBClientModel *clientModel = [[BBLogAgent sharedLogAgent] getDeviceInfo];
    clientModel.time = [[NSDate date] timeIntervalSince1970];
    clientModel.version = self.configModel.version;
    clientModel.userId = self.configModel.token;
    clientModel.clientName = self.configModel.clientName;
    clientModel.deviceId = self.configModel.deviceId;
    clientModel.platform = self.configModel.platform;
    
    if (self.reportPolicy == ReportPolicyBatch) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm transactionWithBlock:^{
                [realm addObject: clientModel];
            }];
        });
        if(_isLogEnabled)
        {
            debug_NSLog(@"archive client data because of BATCH mode");
        }
    }
    else if(self.reportPolicy == ReportPolicyRealTime)
    {

        [self processClientData:clientModel];
    }

    //Process archived logs after post ClientData
    [self performSelector:@selector(processArchivedLogs)];
//    [self performSelector:@selector(groupSync2)];
    
}

-(void)processClientData:(BBClientModel *)clientModel
{
    [self performSelector:@selector(postClientDataInBackground:) withObject:clientModel];
}

-(NSMutableArray *)getArchiveClientData:(NSTimeInterval)currentTime
{
    RLMResults<BBClientModel*> *clientResult = [BBClientModel objectsWhere:@"time < %f",currentTime];
    NSMutableArray *clientDataArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < clientResult.count; i++) {
        BBClientModel *model = [clientResult objectAtIndex:i];
        [clientDataArray addObject:model];
    }
    return clientDataArray;
}



-(void)archiveEvent:(BBEventModel *)eventModel
{
    if (self.reportPolicy == ReportPolicyBatch) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm addObject:eventModel];
        }];
    }
    else if(self.reportPolicy == ReportPolicyRealTime)
    {
        [self processEvent:eventModel];
    }
}

-(void)archiveTag:(BBTagModel *)tag
{
    NSMutableArray *mTagArray;
    if (self.reportPolicy == ReportPolicyBatch) {
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm transactionWithBlock:^{
            [realm addObject:tag];
        }];
        
        
        if(_isLogEnabled)
        {
            debug_NSLog(@"Archived tag count = %lu",(unsigned long)[mTagArray count]);
        }
    }
    else if(self.reportPolicy == ReportPolicyRealTime)
    {
        [self processTag:tag];
    }
}

-(NSString *) getVersion
{
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return appVersion;
}

-(BBClientModel *)getDeviceInfo
{
    BBClientModel  *clientModel = [[BBClientModel alloc] init];
    clientModel.platform = [[UIDevice currentDevice] systemName];
    clientModel.moduleName = [self machineName];
    clientModel.deviceName = [[UIDevice currentDevice] model];
    clientModel.os_version = [[UIDevice currentDevice] systemVersion];
    clientModel.time = [self getCurrentTime].doubleValue;
    if([BBLogAgent isJailbroken])
    {
        clientModel.isjailbroken = @"1";
    }
    else {
        clientModel.isjailbroken = @"0";
    }
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat scale = [[UIScreen mainScreen] scale];
    clientModel.resolution = [[NSString alloc] initWithFormat:@"%.fx%.f",rect.size.width*scale,rect.size.height*scale];
    //Using open UDID
    clientModel.deviceId = [BBLogAgent getDeviceId];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    clientModel.language = [languages objectAtIndex:0];
    
    
    CTTelephonyNetworkInfo*netInfo =[[CTTelephonyNetworkInfo alloc] init];
    CTCarrier*carrier =[netInfo subscriberCellularProvider];
    NSString*mcc =[carrier mobileCountryCode];
    NSString*mnc =[carrier mobileNetworkCode];
    clientModel.mccmnc = [mcc stringByAppendingString:mnc];
    
    clientModel.version = [self getVersion];
    BOOL isWifi = [self isWiFiAvailable];
    if(isWifi)
    {
        clientModel.network = @"WIFI";
    }
    else
    {
        clientModel.network = @"2G/3G";
    }
    return clientModel;
}

-(NSString *)getCurrentTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"ABC"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    // debug_NSLog(@"Current Time 2 = %@",timeStamp);
    
    timeStamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    
    return timeStamp;
    
}

-(NSString *)getDateStr:(NSDate *)inputDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"ABC"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [NSString stringWithFormat:@"%f",[inputDate timeIntervalSince1970]];
    return timeStamp;
    
}

-(void)postClientDataInBackground:(BBClientModel *)clientModel
{
    @autoreleasepool {
        //[self isWiFiAvailable];
        BBReturnModel *ret = [[NetWorkTools sharedNetWork] postClient:_appKey deviceInfo:clientModel];
        
        if(ret.status >0)
        {
            if(_isLogEnabled)
            {
                debug_NSLog(@"Post Client Data OK: Flag = %d, Msg = %@",ret.status,ret.info);
            }
        }
        else
        {
            if(_isLogEnabled)
            {
                debug_NSLog(@"Post Client Data Error: So save to archive. Flag = %d, Msg = %@",ret.status,ret.info);
            }
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm transactionWithBlock:^{
                [realm addObject:clientModel];
            }];
        }
    }
}



void uncaughtExceptionHandler(NSException *exception) {
    debug_NSLog(@"CRASH: %@", exception);
    debug_NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    NSString *stackTrace = [[NSString alloc] initWithFormat:@"%@\n%@",exception,[exception callStackSymbols]];
    [[BBLogAgent sharedLogAgent] saveErrorLog:stackTrace];
}

-(void)postErrorLog:(NSString*)stackTrace
{
    @autoreleasepool {
        if(_isLogEnabled)
        {
            debug_NSLog(@"Post error log realtime");
        }
        BBErrorModel *errorModel = [[BBErrorModel alloc] init];
        errorModel.stackTrace = stackTrace;
        errorModel.appkey = self.appKey;
        errorModel.version = [self getVersion];
        errorModel.time = [self getCurrentTime].doubleValue;
        errorModel.activity = [[NSBundle mainBundle] bundleIdentifier];
        errorModel.osVersion = [[UIDevice currentDevice] systemVersion];
        errorModel.deviceID = [BBLogAgent getDeviceId];
        errorModel.userToken = self.configModel.token;
        BBReturnModel *ret = [[NetWorkTools sharedNetWork] postErrorLog:_appKey errorLog:errorModel];
        if(ret.status<0)
        {
            [self saveErrorLog:stackTrace];
        }
    }
}


+(BOOL)isJailbroken
{
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }
    return jailbroken;
}

-(BOOL)isWiFiAvailable
{
    struct ifaddrs *addresses;
    struct ifaddrs *cursor;
    BOOL wiFiAvailable = NO;
    if (getifaddrs(&addresses) != 0) return NO;
    
    cursor = addresses;
    while (cursor != NULL) {
        if (cursor -> ifa_addr -> sa_family == AF_INET
            && !(cursor -> ifa_flags & IFF_LOOPBACK)) // Ignore the loopback address
        {
            // Check for WiFi adapter
            if (strcmp(cursor -> ifa_name, "en0") == 0) {
                wiFiAvailable = YES;
                break;
            }
        }
        cursor = cursor -> ifa_next;
    }
    
    freeifaddrs(addresses);
    return wiFiAvailable;
}

-(void)dealloc
{
    NSSetUncaughtExceptionHandler(NULL);
}

-(NSString*) machineName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return  [NSString stringWithCString:systemInfo.machine
                               encoding:NSUTF8StringEncoding];
}

+(NSString *)getDeviceId
{
    BBConfigModel *model = [BBLogAgent sharedLogAgent].configModel;
    if (model.deviceId) {
        return model.deviceId;
    }else {
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
}

+ (NSArray *)backtrace

{
    
    void* callstack[128];
    
    int frames = backtrace(callstack, 128);
    
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    
    for (
         
         i = UncaughtExceptionHandlerSkipAddressCount;
         
         i < UncaughtExceptionHandlerSkipAddressCount +
         
         UncaughtExceptionHandlerReportAddressCount;
         
         i++)
        
    {
        
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
        
    }
    
    free(strs);
    
    return backtrace;
    
}
- (void)handleException:(NSException *)exception {
    debug_NSLog(@"UnHandled Exception has happend");
    
    debug_NSLog(@"CRASH: %@", exception);
    debug_NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    NSString *stackTrace = [[NSString alloc] initWithFormat:@"%@\n%@",exception,[exception callStackSymbols]];
    [[BBLogAgent sharedLogAgent] saveErrorLog:stackTrace];
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    for (NSString *mode in (__bridge NSArray *)allModes)
        
    {
        
        CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        
    }
    
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    
    signal(SIGABRT, SIG_DFL);
    
    signal(SIGILL, SIG_DFL);
    
    signal(SIGSEGV, SIG_DFL);
    
    signal(SIGFPE, SIG_DFL);
    
    signal(SIGBUS, SIG_DFL);
    
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName])
        
    {  
//        <span style="white-space:pre"> </span>kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);  
    }
    else  
    {  
        [exception raise];  
    }  
}

-(NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (void)setDefaultHandler
{
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}

+ (NSUncaughtExceptionHandler *)getHandler
{
    return NSGetUncaughtExceptionHandler();
}

+ (void)TakeException:(NSException *)exception
{
    NSArray * arr = [exception callStackSymbols];
    NSString * reason = [exception reason];
    NSString * name = [exception name];
    NSString * url = [NSString stringWithFormat:@"========异常错误报告========\nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",name,reason,[arr componentsJoinedByString:@"\n"]];
    NSString * path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
    [url writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    debug_NSLog(@"%s:%d %@", __FUNCTION__, __LINE__, url);
}

@end

NSString* getAppInfo() {
    NSString *appInfo = [NSString stringWithFormat:@"App : %@ %@(%@)\nDevice : %@\nOS Version : %@ %@\nUDID : %@\n", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"], [UIDevice currentDevice].model, [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion, [BBLogAgent getDeviceId]];
//    NSString *appInfo = @"bb_ios_1.10_dev";
    debug_NSLog(@"Crash!!!! %@", appInfo);
    return appInfo;
}
void MySignalHandler(int signal) {
    debug_NSLog(@"MySignalHandler");
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum){
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal]
                                                                       forKey:UncaughtExceptionHandlerSignalKey];
    NSArray *callStack = [BBLogAgent backtrace];
    [userInfo setObject:callStack
                 forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[BBLogAgent sharedLogAgent] performSelectorOnMainThread:@selector(handleException:)
                                                  withObject:
     [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                             reason:[NSString stringWithFormat:@"Signal %d was raised.\n%@",signal, getAppInfo()]
                           userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey]]
                                               waitUntilDone:YES];
    
}

void InstallUncaughtExceptionHandler()

{
    debug_NSLog(@"installUncaughtExceptionHandler");
    signal(SIGABRT, MySignalHandler);
    
    signal(SIGILL, MySignalHandler);  
    
    signal(SIGSEGV, MySignalHandler);  
    
    signal(SIGFPE, MySignalHandler);  
    
    signal(SIGBUS, MySignalHandler);  
    
    signal(SIGPIPE, MySignalHandler);  
    
}





