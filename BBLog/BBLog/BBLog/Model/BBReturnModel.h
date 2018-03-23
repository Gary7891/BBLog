//
//  ReturnModel.h
//  BBLog
//
//  Created by  Gary on 6/26/14.
//  Copyright (c) 2014 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBReturnModel : NSObject

@property (nonatomic ,assign) int      status;
@property (nonatomic ,copy  ) NSString *info;

@property (nonatomic, assign) BOOL      evnetSuccess;

@property (nonatomic, assign) BOOL      activitySuccess;

@property (nonatomic, assign) BOOL      errorSuccess;

@property (nonatomic, assign) BOOL      clientSuccess;

@property (nonatomic, assign) BOOL      tagSuccess;

@end
