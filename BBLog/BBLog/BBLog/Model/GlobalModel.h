//
//  GlobalModel.h
//   BBLog
//
//  Created by  Gary on 6/26/14.
//  Copyright (c) 2014 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalModel : NSObject

/**
 *  Log服务器
 */
@property (nonatomic ,copy) NSString    *serverUrl;
/**
 *  app key
 */
@property (nonatomic ,copy) NSString    *appKey;

@end
