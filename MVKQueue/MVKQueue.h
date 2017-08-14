//
//  MVKQueue.h
//  MVKQueue
//
//  Created by Volodimir Moskaliuk on 8/14/17.
//
//

#import <Foundation/Foundation.h>

#import "MVKQueueEntity.h"

@protocol MVKQueueDelegate;

@interface MVKQueue : NSObject

- (instancetype)initWithDelegate:(id<MVKQueueDelegate>)delegate;
- (MVKQueueEntity *)addPathToQueue:(NSString *)path notificationAbout:(MVKQueueNotification)notification;
- (void)removeAllPaths;
- (void)removePath:(NSString *)path;
- (NSInteger)watchPathCount;
- (BOOL)isPathWatched:(NSString *)path;
- (UInt32)fileDescriptorForpath:(NSString *)path;

@end

@protocol MVKQueueDelegate <NSObject>

- (void)receiveNotification:(MVKQueueNotification)notification path:(NSString *)path queue:(MVKQueue *) queue;

@end
