//
//  MVKQueueEntity.m
//  MVKQueue
//
//  Created by Volodimir Moskaliuk on 8/14/17.
//
//

#import "MVKQueueEntity.h"
#import <stdlib.h>

@interface MVKQueueEntity()

@property(nonatomic, strong, readwrite)NSString *path;
@property(nonatomic, assign, readwrite)int fileDescriptor;
@property(nonatomic, assign, readwrite)MVKQueueNotification notification;

@end

@implementation MVKQueueEntity

- (instancetype)initWithPath:(NSString *)path notification:(MVKQueueNotification)notification
{
	self = [self init];
	if(self != nil)
	{
		_fileDescriptor = open(path.fileSystemRepresentation, O_EVTONLY, 0);
		if(_fileDescriptor >= 0)
		{
			_path = path;
			_notification = notification;
		}
		else
		{
			self = nil;
		}
	}
	return self;
}

- (void)dealloc
{
	if(_fileDescriptor >= 0)
	{
		close(_fileDescriptor);
	}
}
@end

