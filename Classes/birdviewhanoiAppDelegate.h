//
//  birdviewhanoiAppDelegate.h
//  birdviewhanoi
//
//  Created by Jie Yan on 10-10-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class birdviewhanoiViewController;

@interface birdviewhanoiAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    birdviewhanoiViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet birdviewhanoiViewController *viewController;

@end

