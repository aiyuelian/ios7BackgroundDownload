//
//  AppDelegate.h
//  BackgroundDownload
//
//  Created by zgw on 13-11-11.
//  Copyright (c) 2013年 zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,NSURLSessionDelegate,NSURLSessionDownloadDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) NSMutableDictionary *completionHandlerDictionary;
@property (strong,nonatomic) ViewController *rootViewController;

@end
