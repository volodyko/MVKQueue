//
//  MVKQueue.m
//  MVKQueue
//
//  Created by Volodimir Moskaliuk on 8/14/17.
//
//

#import "MVKQueue.h"

//SYNOPSIS For Kevent
#include <sys/event.h>
#include <sys/types.h>
#include <sys/time.h>

#import "MVKQueueEntity.h"

@interface MVKQueue()

@property(nonatomic, assign) UInt32 kqueueId;
@property(nonatomic, strong) id<MVKQueueDelegate> delegate;
@property(nonatomic, strong) NSMutableDictionary<NSString *, MVKQueueEntity *> *watchedPaths;
@property(nonatomic, assign) BOOL keepWatcherThreadRunning;

@end

@implementation MVKQueue

- (instancetype)initWithDelegate:(id<MVKQueueDelegate>)delegate
{
	self = [self init];
	if(self != nil)
	{
		_kqueueId = kqueue();
		if(_kqueueId == -1)
		{
			self = nil;
		}
		else
		{
			_watchedPaths = [NSMutableDictionary new];
			_delegate = delegate;
			_keepWatcherThreadRunning = NO;
		}
	}
	return self;
}

- (void)dealloc
{
	_keepWatcherThreadRunning = NO;
	[self removeAllPaths];
}

- (MVKQueueEntity *)addPathToQueue:(NSString *)path notificationAbout:(MVKQueueNotification)notification
{
	MVKQueueEntity *pathEntity = [self.watchedPaths objectForKey:path];
	if(pathEntity != nil)
	{
		if(pathEntity.notification == notification)
		{
			return pathEntity;
		}
	}
	else
	{
		pathEntity =[[MVKQueueEntity alloc] initWithPath:path notification:notification];
		if(pathEntity == nil)
		{
			return nil;
		}
		
		[self.watchedPaths setObject:pathEntity forKey:path];
	}
	_STRUCT_TIMESPEC nullts;
	nullts.tv_nsec = 0;
	nullts.tv_sec = 0;
	
	struct kevent event = [self createkEventWithIdentity:pathEntity.fileDescriptor
												  filter:EVFILT_VNODE
												   flags:EV_ADD | EV_ENABLE | EV_CLEAR
												  fflags:notification
													data:0
												   udata:[self.watchedPaths objectForKey:path]
						   ];
	kevent(self.kqueueId, &event, 1, nil, 0, &nullts);
	
	if(!self.keepWatcherThreadRunning)
	{
		self.keepWatcherThreadRunning = YES;
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self watcher];
		});
	}
	return pathEntity;
}

- (struct kevent)createkEventWithIdentity:(UInt)ident filter:(UInt16)filter flags:(UInt16)flags fflags:(UInt32)fflags data:(int)data udata:(id)udata
{
	struct kevent event;
	
	event.ident = ident;
	event.filter = filter;
	event.flags = flags;
	event.fflags = fflags;
	event.data = data;
	event.udata = (__bridge void *)(udata);
	
	return event;
}

- (void)watcher
{
	struct kevent event;
	
	_STRUCT_TIMESPEC timeout;
	timeout.tv_sec = 1;
	timeout.tv_nsec = 0;
	
	UInt32 fd = self.kqueueId;
	
	while (self.keepWatcherThreadRunning) {
		int ev = kevent(fd, nil, 0, &event, 1, &timeout);
		if (ev > 0 && event.filter == EVFILT_VNODE && event.fflags != 0)
		{
			MVKQueueEntity *pathEntry = (__bridge MVKQueueEntity *)(event.udata);
			MVKQueueNotification notification = event.fflags;
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
				if([self.delegate respondsToSelector:@selector(receiveNotification:path:queue:)])
				{
					[self.delegate receiveNotification:notification path:pathEntry.path queue:self];
				}
			});
		}
	}
}

- (void)removeAllPaths
{
	[self.watchedPaths removeAllObjects];
}

- (void)removePath:(NSString *)path
{
	[self.watchedPaths removeObjectForKey:path];
}

- (BOOL)isPathWatched:(NSString *)path
{
	return [self.watchedPaths objectForKey:path] != nil;
}

- (NSInteger)watchPathCount
{
	return self.watchedPaths.count;
}

- (UInt32)fileDescriptorForpath:(NSString *)path
{
	UInt32 fileDescriptor = -1;
	MVKQueueEntity *pathEntity = [self.watchedPaths objectForKey:path];
	if(pathEntity != nil)
	{
		fileDescriptor = fcntl(pathEntity.fileDescriptor, F_DUPFD);
	}
	return fileDescriptor;
}

@end

