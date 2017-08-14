//
//  MVKQueueEntity.h
//  MVKQueue
//
//  Created by Volodimir Moskaliuk on 8/14/17.
//
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(UInt32, MVKQueueNotification) {
	RAKQueueNotificationNone             = 0,
	RAKQueueNotificationRename           = 1 << 0,
	RAKQueueNotificationWrite            = 1 << 1,
	RAKQueueNotificationDelete           = 1 << 2,
	RAKQueueNotificationAttributeChange  = 1 << 3,
	RAKQueueNotificationSizeIncrease     = 1 << 4,
	RAKQueueNotificationLinkCountChange  = 1 << 5,
	RAKQueueNotificationAccessRevocation = 1 << 6,
	RAKQueueNotificationDefault          = 0x7F
};

@class MVKQueue;

@interface MVKQueueEntity : NSObject

@property(nonatomic, strong, readonly)NSString *path;
@property(nonatomic, assign, readonly)int fileDescriptor;
@property(nonatomic, assign, readonly)MVKQueueNotification notification;

- (instancetype)initWithPath:(NSString *)path notification:(MVKQueueNotification)notification;

@end
