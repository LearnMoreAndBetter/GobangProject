//
//  RMGobangView.m
//  Gobang
//
//  Created by wanglin on 2017/4/17.
//  Copyright © 2017年 wanglin. All rights reserved.
//

#import "RMGobangView.h"
#import "RMGobangDefine.h"
#import "RMAI.h"
#import "RMPoint.h"

@interface RMGobangView ()
{
	CGFloat _interval;
}
@property (nonatomic, assign) BOOL isPlayerPlaying; // 标志为，标志是否是玩家正在下棋

@property (nonatomic, strong) NSMutableArray *places; // 记录所有的位置状态
@property (nonatomic, strong) NSMutableArray *chesses; // 记录所有在棋盘上的棋子
@property (nonatomic, strong) NSMutableArray *holders; // 记录五子连珠后对应的五个棋子

@property (nonatomic, strong) UIView *redDot; // 指示AI最新一步所在的位置

@end

@implementation RMGobangView

- (void)drawRect:(CGRect)rect{
	[super drawRect:rect];
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	for (NSInteger i = 0; i < kBoardSize + 2; i ++) {
		[path moveToPoint:CGPointMake(0, self.frame.size.height/(kBoardSize + 1) * i)];
		[path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height/(kBoardSize + 1) * i)];
		
		[path moveToPoint:CGPointMake(self.frame.size.height/(kBoardSize + 1) * i, 0)];
		[path addLineToPoint:CGPointMake(self.frame.size.height/(kBoardSize + 1) * i, self.frame.size.width)];
	}
	[kLineColor setStroke];
	[path stroke];
	/*CAShapeLayer *layer = [CAShapeLayer layer];
	layer.strokeColor = kLineColor.CGColor;
	layer.lineWidth = 1;
	layer.path = path.CGPath;
	[self.layer addSublayer:layer];*/
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = kChessBackgroundColor;
		
		_interval = self.frame.size.width / (kBoardSize + 1);
		[self chessesEmpty];
	}
	return self;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	self.userInteractionEnabled = NO;
	self.isPlayerPlaying = YES;
	
	UITouch *touch = [touches anyObject];//视图中的所有对象
	CGPoint viewTouchPoint = [touch locationInView:self]; //返回触摸点在视图中的当前坐标
	
	RMPoint *chessboardPoint = [self chessBoardPointWithViewTouchPoint:viewTouchPoint];
	OccupyType currentPlaceType = [self getType:chessboardPoint];
	
	if (currentPlaceType != OccupyTypeEmpty) {
		self.userInteractionEnabled = YES;
		return;
	}
	
	if ([self move:chessboardPoint] == FALSE) {
		[self win:OccupyTypeAI];
		return;
	}
	
	if ([self checkVictory:OccupyTypeUser]== OccupyTypeUser) {
		[self win:OccupyTypeUser];
		return;
	}
	
	chessboardPoint = [RMAI geablog:self.places type:OccupyTypeAI];
	
	if ([self move:chessboardPoint] == FALSE) {
		[self win:OccupyTypeUser];
		return;
	}
	if ([self checkVictory:OccupyTypeAI] == OccupyTypeAI) {
		[self win:OccupyTypeAI];
		return;
	}
	
	self.userInteractionEnabled = YES;
}

//根据落子位置确定在棋盘上的坐标，棋盘的周边不能落子
- (RMPoint *)chessBoardPointWithViewTouchPoint:(CGPoint)touchPoint{
	NSUInteger x = 0 , y = 0;
	
	for (NSUInteger i = 0; i <= kBoardSize; i ++) {
		if (i * _interval <= touchPoint.x && touchPoint.x < (i + 1) * _interval) {
			
			if (i == 0) {
				x = 0;
				break;
			}
			
			if (i == kBoardSize) {
				x = kBoardSize - 1;
				break;
			}
			
			if (fabs(touchPoint.x - i * _interval) >= fabs((i + 1) * _interval - touchPoint.x)) {
				x = i;
			} else {
				x = i - 1;
			}
			break;
		}
	}
	
	for (NSUInteger i = 0; i <= kBoardSize; i ++) {
		if (i * _interval <= touchPoint.y && touchPoint.y < (i + 1) * _interval) {
			if (i == 0) {
				y = 0;
				break;
			}
			
			if (i == kBoardSize) {
				y = kBoardSize - 1;
				break;
			}
			
			if (fabs(i * _interval - touchPoint.y) >= fabs((i + 1) * _interval - touchPoint.y)) {
				y = i;
			} else {
				y = i - 1;
			}
			break;
		}
	}
	RMPoint *point = [[RMPoint alloc] initPointWith:x Y:y];
	return  point;
}

//根据棋盘中坐标判断当前坐标属性
- (OccupyType)getType:(RMPoint *)point {
	if ((point.x >= 0 && point.x < kBoardSize) && (point.y >= 0 && point.y < kBoardSize)) {
		return [self.places[point.x][point.y] integerValue];
	}
	return OccupyTypeUnknown;
}


// 检查是否type方胜利了的方法
- (OccupyType)checkVictory:(OccupyType)type {
	for (int i = 0; i < kBoardSize; i ++) {
		for (int j = 0; j < kBoardSize; j ++) {
			RMPoint *p = [[RMPoint alloc] initPointWith:i Y:j];
			OccupyType ty = [self getType:p];
			if (ty == OccupyTypeEmpty) {
				continue;//结束本次循环
			}
			
			OccupyType winType = [self checkNode:p]; // 检查是否形成5子连珠
			if (winType == OccupyTypeUser) {
				return OccupyTypeUser;
			} else if (winType == OccupyTypeAI) {
				return OccupyTypeAI;
			}
			
		}
	}
	return OccupyTypeEmpty;
}

//对给定的点向四周遍历 看是否能形成5子连珠
- (OccupyType)checkNode:(RMPoint *)point {
	//横
	BOOL horizonalVic = [self checkHorizonalWithPoint:point];
	//竖
	BOOL verticalVic = [self checkVerticalWithPoint:point];
	//撇丿
	BOOL leftFallingVic = [self checkLeftFallingWithPoint:point];
	//捺
	BOOL rightFallingVic = [self checkRightFallingWithPoint:point];
	
	BOOL vic = horizonalVic || verticalVic || leftFallingVic || rightFallingVic;
	if (vic) {
		OccupyType curType = [self getType:point];
		return curType;
	}
	return OccupyTypeEmpty;
}

//横
- (BOOL)checkHorizonalWithPoint:(RMPoint *)point{
	OccupyType curType = [self getType:point];
	BOOL vic = YES;
	for (int i = 1; i < 5; i ++) {
		RMPoint *nextP = [[RMPoint alloc] initPointWith:point.x + i Y:point.y];
		if (nextP.x  >= kBoardSize || [self getType:nextP] != curType) {
			vic = NO;
			break;
		}
	}
	return vic;
}

//竖
- (BOOL)checkVerticalWithPoint:(RMPoint *)point{
	OccupyType curType = [self getType:point];
	BOOL vic = YES;
	for (int i = 1; i < 5; i++) {
		RMPoint *nextP = [[RMPoint alloc] initPointWith:point.x Y:point.y + i];
		if (nextP.y  >= kBoardSize || [self getType:nextP] != curType) {
			vic = NO;
			break;
		}
	}
	return vic;
}

//撇丿
- (BOOL)checkLeftFallingWithPoint:(RMPoint *)point{
	OccupyType curType = [self getType:point];
	BOOL vic = YES;
	for (int i = 1; i < 5; i ++) {
		RMPoint *nextP = [[RMPoint alloc] initPointWith:point.x - i Y:point.y + i];
		if (nextP.x < 0 || nextP.y >= kBoardSize || [self getType:nextP] != curType) {
			vic = NO;
			break;
		}
	}
	return vic;
}

//捺
- (BOOL)checkRightFallingWithPoint:(RMPoint *)point{
	OccupyType curType = [self getType:point];
	BOOL vic = YES;
	for (int i = 1; i < 5; i++) {
		RMPoint *nextP = [[RMPoint alloc] initPointWith:point.x + i Y:point.y + i];
		if (nextP.x >= kBoardSize || nextP.y >= kBoardSize || [self getType:nextP] != curType) {
			vic = NO;
			break;
		}
	}
	return vic;
}

//(0,0)~(kBoardSize-1, kBoardSize-1)
// 向p点进行落子并绘制的方法
- (BOOL)move:(RMPoint *)p {
	if (p.x < 0 || p.x >= kBoardSize ||
		p.y < 0 || p.y >= kBoardSize) {
		return false;
	}
	
	OccupyType currentType = [self getType:p];
	if (currentType != OccupyTypeEmpty) {
		return false;
	}
	
	NSInteger x = p.x;
	NSInteger y = p.y;
	
	UIImageView *black = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
	black.center = CGPointMake((x + 1) * _interval, (y + 1) * _interval);
	black.backgroundColor = [UIColor clearColor];
	black.layer.cornerRadius = 15/2.0;
	black.clipsToBounds = YES;
	[self addSubview:black];
	[self.chesses addObject:black];
	
	if (self.isPlayerPlaying) {
		self.places[x][y] = @(OccupyTypeUser);
		
		black.image = [UIImage imageNamed:@"black"];
	} else {
		self.places[x][y] = @(OccupyTypeAI);
		
		black.image = [UIImage imageNamed:@"white"];
		
		[self.redDot removeFromSuperview];
		[black addSubview:self.redDot];
		self.redDot.center = CGPointMake(15/2.0, 15/2.0);
	}
	self.isPlayerPlaying = !self.isPlayerPlaying;
	self.userInteractionEnabled = YES;
	return TRUE;
}

//棋盘上所有位置 置空类型 OccupyTypeEmpty
- (void)chessesEmpty{
	[self.places removeAllObjects];
	for (NSInteger i = 0; i < kBoardSize; i ++) {
		NSMutableArray *chil = [NSMutableArray array];
		for (NSInteger j = 0; j < kBoardSize; j ++) {
			[chil addObject:@(OccupyTypeEmpty)];
		}
		[self.places addObject:chil];
	}
}

// 重新开始的方法
- (void)reset {
	self.userInteractionEnabled = YES;
	[self.chesses makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[self.chesses removeAllObjects];
	[self chessesEmpty];
}

// type方获得胜利时出现动画的效果
- (void)win:(OccupyType)type {
	self.userInteractionEnabled = NO;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - 40) / 2, self.frame.size.width, 45)];
	label.layer.cornerRadius = 5;
	label.clipsToBounds = YES;
	label.layer.borderColor = [[UIColor blackColor] CGColor];
	label.layer.borderWidth = 5;
	label.font = [UIFont systemFontOfSize:38];
	[self addSubview:label];
	label.adjustsFontSizeToFitWidth = YES;
	label.alpha = 0;
	label.textAlignment = NSTextAlignmentCenter;
	
	if (OccupyTypeAI == type) {
		label.text = @"您输了～嘿嘿嘿";
		
	} else if (OccupyTypeUser == type) {
		label.text = @"您赢了 太棒！";
		
	}
	
	[UIView animateWithDuration:0.5 animations:^{
		label.alpha = 1;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.3 delay:2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			label.alpha = 0;
		} completion:^(BOOL finished) {
			[self reset];
			[label removeFromSuperview];
			self.userInteractionEnabled = YES;
		}];
	}];
}

#pragma mark- lazying
- (UIView *)redDot{
	if (!_redDot) {
		_redDot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
		_redDot.backgroundColor = [UIColor redColor];
		_redDot.layer.cornerRadius = 2.5;
	}
	return _redDot;
}

- (NSMutableArray *)places{
	if (!_places) {
		_places = [NSMutableArray array];
	}
	return _places;
}

- (NSMutableArray *)chesses{
	if (!_chesses) {
		_chesses = [NSMutableArray array];
	}
	return _chesses;
}

- (NSMutableArray *)holders{
	if (!_holders) {
		_holders = [NSMutableArray array];
	}
	return _holders;
}



@end
