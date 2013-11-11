//
//  AppDelegate.m
//  BackgroundDownload
//
//  Created by zgw on 13-11-11.
//  Copyright (c) 2013年 zhao. All rights reserved.
//

#import "AppDelegate.h"
#import "APService.h"

typedef void(^CompletionType)();
@implementation AppDelegate

#pragma mark - 私有方法
- (NSURLSession*)backgroundSession
{
    static NSURLSession *session = nil;
    static dispatch_once_t flag;
    dispatch_once(&flag,^{
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:@"identifer"];
        session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    });
    return session;
}
- (void)addCompletionHandle :(void(^)())completionHandle :(NSString*)identifier
{
    if([self.completionHandlerDictionary objectForKey:identifier]){
        NSLog(@"error");
        return;
    }
    [self.completionHandlerDictionary setObject:completionHandle forKey:identifier];
}
- (void)callCompletionHandle :(NSString*)identifier
{
    if([self.completionHandlerDictionary objectForKey:identifier])
    {
        CompletionType handle = [self.completionHandlerDictionary objectForKey:identifier];
        [self.completionHandlerDictionary removeObjectForKey:identifier];
        handle();
    }else
    {
        NSLog(@"error");
    }
}
#pragma mark - NSURLSessionDownLoadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSData *imageData = [NSData dataWithContentsOfURL:location];
    UIImage *image = [UIImage imageWithData:imageData];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    [self.rootViewController.view addSubview:imageView];
    NSLog(@"将image展现到了屏幕上");
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}
#pragma mark - NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"生成了快照");
    [self callCompletionHandle:session.configuration.identifier];
}



#pragma mark - 系统的委托方法
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.rootViewController = [[ViewController alloc]init];
    self.rootViewController.view.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = self.rootViewController;
    self.completionHandlerDictionary = [[NSMutableDictionary alloc]init];
    [self.window makeKeyAndVisible];
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert];
    [APService setupWithOption:launchOptions];
    return YES;
}
//收到远程通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
        NSURL *url = [[NSURL alloc] initWithString:@"http://simg.cocoachina.com/201111220746561330.jpg"];
    NSURLRequest *downRequest = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *task = [[self backgroundSession] downloadTaskWithRequest:downRequest];
    [task resume];
    NSLog(@"收到了远程通知");
    completionHandler(UIBackgroundFetchResultNewData);
}
//获取到设备的token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [APService registerDeviceToken:deviceToken];
}
//在NSURLSessionDelegate出发前触发
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    NSLog(@"保存了快照回调的块");
    [self addCompletionHandle:completionHandler :identifier];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
   
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
     [application enabledRemoteNotificationTypes];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
