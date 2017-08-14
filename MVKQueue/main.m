//
//  main.m
//  MVKQueue
//
//  Created by Volodimir Moskaliuk on 8/14/17.
//
//

#import <Foundation/Foundation.h>
#import "MVKQueue.h"
#import "MVKQueueDelegatImpl.h"

int main(int argc, const char * argv[]) {
	@autoreleasepool {
	    // insert code here...
	    NSLog(@"Hello, World!");
		
		MVKQueueDelegatImpl *delegate = [MVKQueueDelegatImpl new];
		MVKQueue *queue = [[MVKQueue alloc] initWithDelegate:delegate];
		[queue addPathToQueue:[NSHomeDirectory() stringByAppendingPathComponent:@".Trash"] notificationAbout:RAKQueueNotificationDefault];
		while (YES) {
		}
	}
	return 0;
}
