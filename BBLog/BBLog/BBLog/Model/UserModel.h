//
//  UserModel.h
//  BBLog
//
//  Created by Gary on 19/03/2018.
//  Copyright © 2018 czy. All rights reserved.
//

#import <Realm/Realm.h>

@interface UserModel : RLMObject

@property NSString                   *usrName;

@property NSString                   *account;

@property NSString                   *token;

@property NSString                   *userId;

@property NSString                   *ID;

@end

RLM_ARRAY_TYPE(UserModel);
