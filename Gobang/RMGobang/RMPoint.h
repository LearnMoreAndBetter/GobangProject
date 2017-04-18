//
//  RMPoint.h
//  Gobang
//
//  Created by wanglin on 2017/4/17.
//  Copyright © 2017年 wanglin. All rights reserved.
//

#import <Foundation/Foundation.h>

//只能两个整数属性的点
@interface RMPoint : NSObject

@property (nonatomic, assign) NSInteger x;
@property (nonatomic, assign) NSInteger y;

- (instancetype)initPointWith:(NSInteger)x Y:(NSInteger)y;
+ (instancetype)pointWithPoint:(RMPoint *)point;
+ (instancetype)initWith:(NSInteger)x Y:(NSInteger)y;

@end
