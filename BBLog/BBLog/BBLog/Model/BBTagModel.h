//
//  TagModel.h
//   BBLog
//
//  Created by  Gary on 6/26/14.
//  Copyright (c) 2014 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface BBTagModel : RLMObject

/**
 主键
 */
@property NSString                 *ID;

@property  NSString          *tags;
@property  NSString          *deviceid;
@property  NSString          *productkey;

- (NSDictionary*)toDictionary;

@end

RLM_ARRAY_TYPE(BBTagModel);
