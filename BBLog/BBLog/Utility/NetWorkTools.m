//
//  NetWorkTools.m
//   BBLog
//
//  Created by  Gary on 6/26/14.
//  Copyright (c) 2014 TimeFace. All rights reserved.
//

#import "NetWorkTools.h"
#import "CJSONSerializer.h"
#import "LGZIP.h"

#import "AliyunLogObjc.h"



@implementation NetWorkTools

+ (instancetype)sharedNetWork
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = self.new;
    });
    return instance;
}


- (ReturnModel *) postClient:(NSString *) appkey deviceInfo:(ClientModel *) clientModel
{
    @autoreleasepool {
        NSString* url = [NSString stringWithFormat:@"%@%@",_kServerUrl,@"cdLog"];
        ReturnModel *ret = [[ReturnModel alloc] init];
        NSDictionary *requestDictionary = [clientModel toDictionary];
        
        NSArray *array = @[requestDictionary];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:@{@"clientDataArray":array}];
        NSData *data = [self sendData:url data:dic];
        NSError *error = nil;
        
        NSDictionary *retDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&error];
        if(!error)
        {
            ret.status = [[retDictionary objectForKey:@"status" ] intValue];
            ret.info = [retDictionary objectForKey:@"info"];
        }
        return ret;
    }
}

- (ReturnModel *) postUsingTime:(NSString *) appkey
                  sessionMills:(NSString *)sessionMills
                     startMils:(NSString*)startMils
                       endMils:(NSString*)endMils
                      duration:(NSString*)duration
                      activity:(NSString *) activity
                       version:(NSString *) version
{
    debug_NSLog(@"version %@",version);
    @autoreleasepool {
        NSString* url = [NSString stringWithFormat:@"%@%@",_kServerUrl,@"pvLog"];
        ReturnModel *ret = [[ReturnModel alloc] init];
        NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
        [requestDictionary setObject:sessionMills forKey:@"session_id"];
        [requestDictionary setObject:startMils forKey:@"start_millis"];
        [requestDictionary setObject:endMils forKey:@"end_millis"];
        [requestDictionary setObject:duration forKey:@"duration"];
        [requestDictionary setObject:activity forKey:@"activities"];
        [requestDictionary setObject:appkey forKey:@"appkey"];
        [requestDictionary setObject:version forKey:@"version"];
        NSArray *array = @[requestDictionary];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:@{@"activityLog" : array}];
        NSData *data = [self sendData:url data:dic];
        NSError *error = nil;
        
        NSDictionary *retDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&error];
        
        if(!error)
        {
            ret.status = [[retDictionary objectForKey:@"status" ] intValue];
            ret.info = [retDictionary objectForKey:@"info"];
        }
        return ret;
    }
}

- (ReturnModel *) postArchiveLogs:(NSMutableDictionary *) archiveLogs
{
    @autoreleasepool {
        NSString* url = [NSString stringWithFormat:@"%@%@",_kServerUrl,@"allLog"];
        debug_NSLog(@"url = %@",url);
        ReturnModel *ret = [[ReturnModel alloc] init];
        NSData *data = [self sendData:url data:archiveLogs];
        NSError *error = nil;
        if (!data) {
           return  nil;
        }
        NSDictionary *retDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&error];
        if(!error)
        {
            ret.status = [[retDictionary objectForKey:@"status" ] intValue];
            ret.info = [retDictionary objectForKey:@"info"];
        }
        return ret;
    }
}



- (ReturnModel *) postErrorLog:(NSString *) appkey errorLog:(ErrorModel *) errorModel
{
    @autoreleasepool {
        NSString* url = [NSString stringWithFormat:@"%@%@",_kServerUrl,@"erLog"];
        ReturnModel *ret = [[ReturnModel alloc] init];
        NSDictionary *requestDictionary = [errorModel toDictionary];
        NSArray *array = @[requestDictionary];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:@{@"errorLog":array}];
        NSData *data = [self sendData:url data:dic];
        NSError *error = nil;
        NSDictionary *retDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&error];
        if(!error)
        {
            ret.status = [[retDictionary objectForKey:@"status" ] intValue];
            ret.info = [retDictionary objectForKey:@"info"];
        }
        return ret;
    }
}

- (ReturnModel *) postEvent:(NSString *) appkey event:(EventModel *) eventModel {
    @autoreleasepool {
        NSString* url = [NSString stringWithFormat:@"%@%@",_kServerUrl,@"evLog"];
        debug_NSLog(@"post event url = %@",url);
        ReturnModel *ret = [[ReturnModel alloc] init];
        NSDictionary *requestDictionary = [eventModel toDictionary];
        NSArray *array = @[requestDictionary];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:@{@"eventArray" : array}];
        NSData *data = [self sendData:url data:dic];
        NSError *error = nil;
        NSDictionary *retDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&error];
        if(!error)
        {
            ret.status = [[retDictionary objectForKey:@"status" ] intValue];
            ret.info = [retDictionary objectForKey:@"info"];
        }
        return ret;
    }
}

- (ReturnModel *) postTag:(NSString *) appkey tag:(TagModel *) tagModel {
    @autoreleasepool {
        
        NSString* url = [NSString stringWithFormat:@"%@%@",_kServerUrl,@"/ums/postTag"];
        
        ReturnModel *ret = [[ReturnModel alloc] init];
        NSDictionary *requestDictionary = [tagModel toDictionary];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:requestDictionary];
        NSData *data = [self sendData:url data:dic];
        NSError *error = nil;
        NSDictionary *retDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&error];
        if(!error)
        {
            ret.status = [[retDictionary objectForKey:@"status" ] intValue];
            ret.info = [retDictionary objectForKey:@"info"];
        }
        return ret;
    }
}




- (NSData *)sendData:(NSString*)urlString data:(NSMutableDictionary*)content
{
    @autoreleasepool {
        NSURL *url = [NSURL URLWithString:urlString];
        NSError *error = NULL;
        
        
        
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
        [request setHTTPMethod: @"POST"];
        NSString *deviceId = [[NSUserDefaults standardUserDefaults] objectForKey:kHeadDeviceId];
        debug_NSLog(@"log deviceId = %@",deviceId);
        if (deviceId) {
            [request setValue:deviceId forHTTPHeaderField:@"DEVICEID"];
        }
        NSMutableString *requestStr = [[NSMutableString alloc]init];
        NSString *str2Request = nil;
        NSArray *allKeys = [content allKeys];
        if ([urlString rangeOfString:@"allLog"].location != NSNotFound) {
            NSData *data = [[CJSONSerializer serializer] serializeDictionary:content error:&error];
            [requestStr appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            str2Request = [requestStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            debug_NSLog(@"requestStr = %@",requestStr);
        }else {
            int index = -1;
            for (int i = 0;i < allKeys.count; i++) {
                NSString *key = [allKeys objectAtIndex:i];
                NSArray *dic = [content objectForKey:key];
                debug_NSLog(@"dic.class = %@,dic.description = %@",dic.class,dic.description);
                if ([key isEqualToString:@"appkey"]) {
                    continue;
                }
                index ++;
                NSData *valueData = [[CJSONSerializer serializer] serializeArray:dic error:&error];
                if(error)
                {
                    debug_NSLog(@"Serialization Error: %@", error);
                    return nil;
                }
                NSString *valueStr = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
                debug_NSLog(@"key: %@ = value : %@",key,valueStr);
                if (index == 0 || allKeys.count == 2) {
                    [requestStr appendFormat:@"%@=%@",key,valueStr];
                }else {
                    [requestStr appendFormat:@"&%@=%@",key,valueStr];
                }
                
            }
            str2Request = [requestStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        
        NSData *requestData = [str2Request dataUsingEncoding:NSUTF8StringEncoding];

        NSData *bodyData = [requestData log_gzippedData];
        [request setHTTPBody:bodyData];
        
        [request addValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
        [request addValue:@"text/plain" forHTTPHeaderField:@"Accept"];
        [request addValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
//        NSString *body = [[NSString alloc]initWithData:[[request HTTPBody] log_gunzippedData] encoding:NSUTF8StringEncoding];
//        debug_NSLog(@"httpbody: %@",bodyData);
        
        NSError        *responseError = nil;
        NSURLResponse  *response = nil;
        
        NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &responseError ];
        debug_NSLog(@"returndata = %@,response = %@",returnData,response);
        if (response == nil) {
            if (responseError != nil) {
                debug_NSLog(@"Connection to server failed.");
            }
            return nil;
//            return @"{\"flag\":-9,\"info\":\"network connection error\"}";
        }
        else {
            
//            NSString *jsonString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
//            debug_NSLog(@"RET JSON STR = %@",jsonString);
//            jsonString = [jsonString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            return returnData;
        }
    }
	
}

- (ReturnModel*)postAllLogs:(NSMutableDictionary*)allLogs {
    
    __block BOOL eventSuccess = YES;
    __block BOOL activitySuccess = YES;
    dispatch_semaphore_t semaphore_top = dispatch_semaphore_create(0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSArray *activityArray = [allLogs objectForKey:@"activityLog"];
        NSMutableDictionary *activtyLogDic = [[NSMutableDictionary alloc]init];
        [activtyLogDic setObject:[self.configModel headerDictionary] forKey:@"header"];
        [activtyLogDic setObject:@"BrowsingPath" forKey:@"mdtype"];
        [activtyLogDic setObject:activityArray forKey:@"entity"];
        activitySuccess = [self postActivityLogs:activtyLogDic semaphore:semaphore];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *eventDic = [[NSMutableDictionary alloc]init];
        [eventDic setObject:[self.configModel headerDictionary] forKey:@"header"];
        [eventDic setObject:@"Clicks" forKey:@"mdtype"];
        NSArray *eventArray = [allLogs objectForKey:@"eventArray"];
        [eventDic setObject:eventArray forKey:@"entity"];
        eventSuccess = [self postEventLogs:eventDic semaphore:semaphore];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
    
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"任务完成");
        dispatch_semaphore_signal(semaphore_top);
    });
    dispatch_semaphore_wait(semaphore_top, DISPATCH_TIME_FOREVER);
    ReturnModel *model = [[ReturnModel alloc]init];
    model.evnetSuccess = eventSuccess;
    model.activitySuccess = activitySuccess;
    return model;
 
}

- (BOOL)postActivityLogs:(NSDictionary*)dictionary semaphore:(dispatch_semaphore_t)semaphore{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                        error:&error];
    
    NSString *dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return [self sendDataToAliyun:dataString topic:@"BrowsingPath" semaphore:semaphore];
    
}

- (BOOL)postEventLogs:(NSDictionary*)dictionary semaphore:(dispatch_semaphore_t)semaphore{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return  [self sendDataToAliyun:dataString topic:@"Clicks" semaphore:semaphore];
}

- (BOOL)sendDataToAliyun:(NSString*)data topic:(NSString*)topic semaphore:(dispatch_semaphore_t)semaphore{
    
    dispatch_semaphore_t semaphoreSend = dispatch_semaphore_create(0);
    __block BOOL success = YES;
    
    LogClient *client = [[LogClient alloc]initWithApp:self.configModel.endPont
                                          accessKeyID:self.configModel.sts_ak
                                      accessKeySecret:self.configModel.sts_sk
                                          projectName:self.configModel.projectName];
    [client SetToken:self.configModel.sts_token];
    
    Log *logInfo = [[Log alloc]init];
    [logInfo PutContent:data withKey:topic];
    LogGroup *group = [[LogGroup alloc]initWithTopic:topic andSource:@"iOS"];
    [group PutLog:logInfo];
    [client PostLog:group logStoreName:self.configModel.logStoreName call:^(NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"response %@", [response debugDescription]);
        NSLog(@"error %@",[error debugDescription]);
        if (error) {
            success = NO;
        }
        dispatch_semaphore_signal(semaphore);
        dispatch_semaphore_signal(semaphoreSend);
    }];
    
    dispatch_semaphore_wait(semaphoreSend, DISPATCH_TIME_FOREVER);
    return success;
    

    
}


@end
