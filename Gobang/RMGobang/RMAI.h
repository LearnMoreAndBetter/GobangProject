//
//  RMAI.h
//  Gobang
//
//  Created by wanglin on 2017/4/17.
//  Copyright © 2017年 wanglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMGobangDefine.h"
#import "RMPoint.h"

@interface RMAI : NSObject

+ (RMPoint *)geablog:(NSMutableArray *)board type:(OccupyType)type;
+ (RMPoint *)SeraphTheGreat:(NSMutableArray *)board type:(OccupyType)type;

@end

@interface RMOmni : NSObject

@property (nonatomic, strong) NSMutableArray *curBoard;//存有棋盘上每个位置的属性
@property (nonatomic, assign) OccupyType oppoType;//对手类型
@property (nonatomic, assign) OccupyType myType;//我的类型

- (instancetype)initWithArr:(NSMutableArray *)arr opp:(OccupyType)opp my:(OccupyType)my;
- (BOOL)isStepEmergent:(RMPoint *)pp Num:(NSInteger)num type:(OccupyType)xType;
- (RMPoint *)nextStep:(OccupyType)xType needLinkNum:(NSInteger)num;
- (BOOL)checkPoint:(RMPoint *)point;

@end

