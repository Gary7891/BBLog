//
//  EventModel.m
//   BBLog
//
//  Created by  Gary on 6/26/14.
//  Copyright (c) 2014 TimeFace. All rights reserved.
//

#import "BBEventModel.h"
#import "BBConfigModel.h"
#import "BBLogAgent.h"
//#import <objc/runtime.h>
//#import <objc/message.h>

@implementation BBEventModel


+(NSString*)primaryKey {
    return @"ID";
}

+(NSDictionary*)defaultPropertyValues {
    NSDictionary *defaultValuesDic = @{
                                       @"ID" :  [[NSUUID UUID] UUIDString]
                                       };
    return defaultValuesDic;
}

+ (NSArray<NSString*>*)indexedProperties {
    return @[@"ID"];
}

- (NSDictionary*)toDictionary {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.index?:@"" forKey:@"index"];
    [dic setObject:self.eventId?:@"" forKey:@"adtype"];
    [dic setObject:self.relatedData?:@"" forKey:@"adid"];
    long timemills = self.time * 1000;
    [dic setObject:[NSString stringWithFormat:@"%@",@(timemills)] forKey:@"ctime"];
    NSDictionary *configDic = [BBLogAgent configDictionary];
    NSString *storeId = [configDic objectForKey:@"storeId"]?:@"";
    [dic setObject:storeId forKey:@"storeId"];
    [dic setObject:[configDic objectForKey:@"storeName"]?:@"" forKey:@"storeName"];

    return dic;
    
}

//- (NSDictionary*)dictionaryFromModel {
//    unsigned int count = 0;
//
//    objc_property_t *properties = class_copyPropertyList([self class], &count);
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:count];
//    static const char * kClassPropertiesKey;
//    NSDictionary* classProperties = objc_getAssociatedObject(self.class, &kClassPropertiesKey);
//    NSArray *propertiesArray = [classProperties allValues];
//
//    for (int i = 0; i < count; i++) {
//        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
//        id value = [self valueForKey:key];
//
//        //only add it to dictionary if it is not nil
//        if (key && value) {
//            if ([value isKindOfClass:[NSString class]]
//                || [value isKindOfClass:[NSNumber class]]) {
//                // 普通类型的直接变成字典的值
//                [dict setObject:value forKey:key];
//            }
//            else if ([value isKindOfClass:[NSArray class]]
//                     || [value isKindOfClass:[NSDictionary class]]) {
//                // 数组类型或字典类型
//                [dict setObject:[self idFromObject:value] forKey:key];
//            }
//            else {
//                // 如果model里有其他自定义模型，则递归将其转换为字典
//                [dict setObject:[value dictionaryFromModel] forKey:key];
//            }
//        } else if (key && value == nil) {
//            // 如果当前对象该值为空，设为nil。在字典中直接加nil会抛异常，需要加NSNull对象
//            [dict setObject:[NSNull null] forKey:key];
//        }
//    }
//
//    free(properties);
//    return dict;
//}
//
//- (id)idFromObject:(nonnull id)object
//{
//    if ([object isKindOfClass:[NSArray class]]) {
//        if (object != nil && [object count] > 0) {
//            NSMutableArray *array = [NSMutableArray array];
//            for (id obj in object) {
//                // 基本类型直接添加
//                if ([obj isKindOfClass:[NSString class]]
//                    || [obj isKindOfClass:[NSNumber class]]) {
//                    [array addObject:obj];
//                }
//                // 字典或数组需递归处理
//                else if ([obj isKindOfClass:[NSDictionary class]]
//                         || [obj isKindOfClass:[NSArray class]]) {
//                    [array addObject:[self idFromObject:obj]];
//                }
//                // model转化为字典
//                else {
//                    [array addObject:[obj dictionaryFromModel]];
//                }
//            }
//            return array;
//        }
//        else {
//            return object ? : [NSNull null];
//        }
//    }
//    else if ([object isKindOfClass:[NSDictionary class]]) {
//        if (object && [[object allKeys] count] > 0) {
//            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//            for (NSString *key in [object allKeys]) {
//                // 基本类型直接添加
//                if ([object[key] isKindOfClass:[NSNumber class]]
//                    || [object[key] isKindOfClass:[NSString class]]) {
//                    [dic setObject:object[key] forKey:key];
//                }
//                // 字典或数组需递归处理
//                else if ([object[key] isKindOfClass:[NSArray class]]
//                         || [object[key] isKindOfClass:[NSDictionary class]]) {
//                    [dic setObject:[self idFromObject:object[key]] forKey:key];
//                }
//                // model转化为字典
//                else {
//                    [dic setObject:[object[key] dictionaryFromModel] forKey:key];
//                }
//            }
//            return dic;
//        }
//        else {
//            return object ? : [NSNull null];
//        }
//    }
//
//    return [NSNull null];
//}




@end
