//
//  MVKQueueDelegatImpl.m
//  MVKQueue
//
//  Created by Volodimir Moskaliuk on 8/14/17.
//
//

#import "MVKQueueDelegatImpl.h"

@implementation MVKQueueDelegatImpl

- (void)receiveNotification:(MVKQueueNotification)notification path:(NSString *)path queue:(MVKQueue *) queue
{
	NSLog(@"path :%@  notification:%u", path , (unsigned int)notification);
}

@end
