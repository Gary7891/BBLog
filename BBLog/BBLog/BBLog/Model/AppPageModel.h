//
//  AppPageModel.h
//  BBLog
//
//  Created by Gary on 19/03/2018.
//  Copyright © 2018 czy. All rights reserved.
//

#import <Realm/Realm.h>

@interface AppPageModel : RLMObject

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
@property double                   duration;
/**
 *  页面名称
 */
@property NSString                 *activityName;
/**
 *  软件版本
 */
@property NSString                 *version;

@end

RLM_ARRAY_TYPE(AppPageModel);
