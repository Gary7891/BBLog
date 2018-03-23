//
//  AppDelegate.m
//  BBLog
//
//  Created by Gary on 15/03/2018.
//  Copyright © 2018 czy. All rights reserved.
//

#import "AppDelegate.h"
#import "BBLogAgent.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    
    ViewController *viewController = [[ViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:viewController];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [BBLogAgent ConfigWith:@{@"x-version":@"1.0",
                                 @"Authorization":@"1234567890",
                                 @"x-platform"    : @"iOS",
                                 @"x-client"      : @"store",
                                 @"x-equCode"     : @"dsdsdsdsdsddsdsdsd",
                                 @"endPoint"      : @"cn-shanghai.log.aliyuncs.com",
                                 @"projectName"   : @"tticar",
                                 @"logStoreName"  : @"store-test",
                                 @"sts_ak"        : @"STS.HLJXEu6x7iapCkrCWpaaoHpH7",
                                 @"sts_sk"        : @"4HPUbGDm5idFZRLmTRutSvL2CrykXcKbSnnzfwMNkJTR",
                                 @"sts_token"     : @"CAISgQJ1q6Ft5B2yfSjIqY//E//B26cW3qObQU3Dp1clbe5Dp7Xj1Tz2IH1NdHBuBO4bvvswnWtU6PkelqVoRoReREvCKM1565kPZOMZ7EaF6aKP9rUhpMCPOwr6UmzWvqL7Z+H+U6muGJOEYEzFkSle2KbzcS7YMXWuLZyOj+wMDL1VJH7aCwBLH9BLPABvhdYHPH/KT5aXPwXtn3DbATgD2GM+qxsmsP3gnpPGskOB0AOilr5OnemrfMj4NfsLFYxkTtK40NZxcqf8yyNK43BIjvwr1fwdp2qZ44HCXAAKv0vZb/Cq+9l+MQl9Yac6BqRNqvTmkvx0oOvXmpQSMZmR4wPDOhqAATdE9/Aq8EUNa+PjLsatPa6FW6wKNZpT3tARAN00R+uaqMGUXwPG1RwIBEWyotg5GlQrAB40/A3340Nj/eMdI6oL2vbB9VGNeKaWleuVB9ZCbE65KiFJ3rH/ihenXO3bo/RdkkERSW9f5R+O3CDzpwmwMFTJM93OsRGQ/W67UCO/"
                                 }];
        

//        configModel.projectName = [configDic objectForKey:@"projectName"];
//        configModel.logStoreName = [configDic objectForKey:@"logStoreName"];
//        configModel.sts_ak = [configDic objectForKey:@"sts_ak"];
//        configModel.sts_sk = [configDic objectForKey:@"sts_sk"];
//        configModel.sts_token = [configDic objectForKey:@"sts_token"];
        [BBLogAgent startWithAppKey:@"test" reportPolicy:ReportPolicyBatch serverURL:@""];
        
    });
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
