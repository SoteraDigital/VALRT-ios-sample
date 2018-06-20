//
//  AppDelegate.h
//  VSNConnect
//
//  Created by Ed Gilmore on 8/12/14.
//  Copyright (c) 2014 Ed Gilmore - Onn, Inc. All rights reserved.
//  www.onncreative.com
//

#import <UIKit/UIKit.h>
#import "BLEConnectionClass.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate,BLEConnectionDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(strong,nonatomic)BLEConnectionClass *ObjBLEConnection;

@end
