//
//  BBLogKeychain.m
//  BBLogKeychain
//
//  Created by Sam Soffes on 5/19/10.
//  Copyright (c) 2010-2013 Sam Soffes. All rights reserved.
//

#import "BBLogKeychain.h"

NSString *const kBBLogKeychainErrorDomain = @"com.samsoffes.BBLogKeychain";
NSString *const kBBLogKeychainAccountKey = @"acct";
NSString *const kBBLogKeychainCreatedAtKey = @"cdat";
NSString *const kBBLogKeychainClassKey = @"labl";
NSString *const kBBLogKeychainDescriptionKey = @"desc";
NSString *const kBBLogKeychainLabelKey = @"labl";
NSString *const kBBLogKeychainLastModifiedKey = @"mdat";
NSString *const kBBLogKeychainWhereKey = @"svce";

#if __IPHONE_4_0 && TARGET_OS_IPHONE
    static CFTypeRef BBLogKeychainAccessibilityType = NULL;
#endif

@implementation BBLogKeychain

+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account {
	return [self passwordForService:serviceName account:account error:nil];
}


+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
    BBLogKeychainQuery *query = [[BBLogKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    [query fetch:error];
    return query.password;
}


+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account {
	return [self deletePasswordForService:serviceName account:account error:nil];
}


+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
    BBLogKeychainQuery *query = [[BBLogKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    return [query deleteItem:error];
}


+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account {
	return [self setPassword:password forService:serviceName account:account error:nil];
}


+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
    BBLogKeychainQuery *query = [[BBLogKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    query.password = password;
    return [query save:error];
}


+ (NSArray *)allAccounts {
    return [self accountsForService:nil];
}


+ (NSArray *)accountsForService:(NSString *)serviceName {
    BBLogKeychainQuery *query = [[BBLogKeychainQuery alloc] init];
    query.service = serviceName;
    return [query fetchAll:nil];
}


#if __IPHONE_4_0 && TARGET_OS_IPHONE
+ (CFTypeRef)accessibilityType {
	return BBLogKeychainAccessibilityType;
}


+ (void)setAccessibilityType:(CFTypeRef)accessibilityType {
	CFRetain(accessibilityType);
	if (BBLogKeychainAccessibilityType) {
		CFRelease(BBLogKeychainAccessibilityType);
	}
	BBLogKeychainAccessibilityType = accessibilityType;
}
#endif

@end
