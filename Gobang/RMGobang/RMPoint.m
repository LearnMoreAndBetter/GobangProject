//
//  RMPoint.m
//  Gobang
//
//  Created by wanglin on 2017/4/17.
//  Copyright © 2017年 wanglin. All rights reserved.
//

#import "RMPoint.h"

@implementation RMPoint

- (instancetype)initPointWith:(NSInteger)x Y:(NSInteger)y {
	self = [self init];
	if (self) {
		self.x = x;
		self.y = y;
	}
	return self;
}

+ (instancetype)pointWithPoint:(RMPoint *)point{
	RMPoint *currentPoint = [[RMPoint alloc]init];
	currentPoint.x = point.x;
	currentPoint.y = point.y;
	return currentPoint;
}

+ (instancetype)initWith:(NSInteger)x Y:(NSInteger)y{
	RMPoint *currentPoint = [[RMPoint alloc]init];
	currentPoint.x = x;
	currentPoint.y = y;
	return currentPoint;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		self.x = -1;
		self.y = -1;
	}
	return self;
}

- (NSString *)description{
	NSString *des = [NSString stringWithFormat:@"KWPoint : (%ld, %ld)", self.x, self.y];
	return des;
}

@end
