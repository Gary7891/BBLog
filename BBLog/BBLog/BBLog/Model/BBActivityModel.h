//
//  ActivityModel.h
//  BBLog
//
//  Created by  Gary on 6/26/14.
//  Copyright (c) 2014 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface BBActivityModel : RLMObject



/**
 主键
 */
@property NSString                 *ID;
/**
 *  时间sessionId
 */
@property NSString                 *sessionId;
/**
 *  进入页面时间
 */
@property double                   startMils;
/**
 *  离开页面时间
 */
@property double                   endMils;
/**
 *  在页面停留的时间
 */
@property double                  duration;
/**
 *  页面名称
 */
@property NSString                 *activityName;
/**
 *  软件版本
 */
@property NSString                 *version;

/**
 相关的数据
 */
@property NSString                 *relatedData;

/**
 用户token或者ID
 */
@property NSString                 *userToken;

- (NSDictionary*)toDictionary;

@end

RLM_ARRAY_TYPE(BBActivityModel);
