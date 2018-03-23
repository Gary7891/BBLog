//
//  EventModel.h
//   BBLog
//
//  Created by  Gary on 6/26/14.
//  Copyright (c) 2014 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface EventModel : RLMObject


/**
 主键
 */
@property NSString  *ID;
/**
 *  事件ID
 */
@property  NSString *eventId;
/**
 *  事件发生时间
 */
@property  double time;

/**
 包名 bundlId
 */
@property  NSString *activityName;
/**
 *  事件描述
 */
@property  NSString *descriptionString;

/**
 事件相关数据
 */
@property NSString  *relatedData;

/**
 事件索引
 */
@property NSInteger index;
/**
 *  事件计数
 */
@property  NSInteger acc;
/**
 *  系统版本
 */
@property  NSString *version;



- (NSDictionary*)toDictionary;



@end
