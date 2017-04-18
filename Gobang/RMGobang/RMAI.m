//
//  RMAI.m
//  Gobang
//
//  Created by wanglin on 2017/4/17.
//  Copyright © 2017年 wanglin. All rights reserved.
//

#import "RMAI.h"

@implementation RMAI

+ (RMPoint *)geablog:(NSMutableArray *)board type:(OccupyType)type {
	
	RMPoint *calibur = [[self class] SeraphTheGreat:board type:type];
	return calibur;
}

//遍历棋盘上所有空点，寻找最适合的点
+ (RMPoint *)SeraphTheGreat:(NSMutableArray *)board type:(OccupyType)myType {
	
	RMOmni *omniknight;
	if(myType == OccupyTypeUser){
		omniknight = [[RMOmni alloc] initWithArr:board opp:OccupyTypeAI my:OccupyTypeUser];
	} else {
		omniknight = [[RMOmni alloc] initWithArr:board opp:OccupyTypeUser my:OccupyTypeAI];
	}
	
	for (NSInteger num = 5; num >= 2; num --) {
		// 以AI自己的角度观察场上形势,寻找可以形成num子连珠的点
		RMPoint *calibur = [omniknight nextStep:omniknight.myType needLinkNum:num];
		if([omniknight checkPoint:calibur]) { // 如果有 在此摆子形成进攻或直接胜利
			return calibur;
		}

		// AI以用户的角度观察场上形势，寻找用户棋子排放可以形成num子连珠的点
		calibur = [omniknight nextStep:omniknight.oppoType needLinkNum:num];
		if ([omniknight checkPoint:calibur]) { // 如果有 则在此落子进行防守
			return calibur;
		}
	}
	//  如果什么都没有则返回不可用的点
	RMPoint *sad = [[RMPoint alloc] initPointWith:(kBoardSize+1)/2 Y:(kBoardSize+1)/2];
	return sad;
}

@end

@implementation RMOmni

- (id)init {
	
	self = [super init];
	if (self) {
		self.oppoType = OccupyTypeEmpty;
		self.myType = OccupyTypeEmpty;
	}
	
	return self;
}

- (instancetype)initWithArr:(NSMutableArray *)arr opp:(OccupyType)opp my:(OccupyType)my {
	
	self = [self init];
	if (self) {
		self.curBoard = arr;
		self.oppoType = opp;
		self.myType = my;
	}
	
	return self;
}

// 如果一个点的X Y 坐标都大于等于0且小于棋盘大小时才认为可用
- (BOOL)checkPoint:(RMPoint *)point {
	if ((point.x >= 0 && point.x < kBoardSize) && (point.y >= 0 && point.y < kBoardSize)) {
		return YES;
	}
	return NO;
}

//根据棋盘中坐标判断当前坐标属性
- (OccupyType)getType:(RMPoint *)point {
	if ([self checkPoint:point]) {
		return [self.curBoard[point.x][point.y] integerValue];
	}
	return OccupyTypeUnknown;
}

//pp为落子点，属性为empty，判断落子点形成的连珠两侧是否都是可以落子的空点
- (BOOL)isStepEmergent:(RMPoint *)pp Num:(NSInteger)num type:(OccupyType)xType {
	RMPoint* check = [RMPoint pointWithPoint:pp];
	if (![self checkPoint:check]) {
		return FALSE;
	}
	
	RMPoint *testR = [RMPoint initWith:check.x + 1 Y:check.y]; // 开始遍历点的正右侧
	RMPoint *testL = [RMPoint initWith:check.x - 1 Y:check.y]; // 开始遍历的点的正左侧
	//在相应点向右侧进行遍历，寻找最长的连续距离
	for(NSInteger i = 0; [self getType:testR] == xType; i++) {
		testR.x ++;
	}
 
	//在相应点向左侧进行遍历，寻找最长的连续距离
	for(NSInteger i = 0; [self getType:testL] == xType; i++){
		testL.x --;
	}

	// 如果两个点之间的距离大于或等于我们需要的距离，这个条件必然成立，因为pp已是落子点
	if (testR.x - testL.x - 1 >= num) {
		// 并且这段连续距离的两侧都是可以落子的空点
		if ([self getType:testR] == OccupyTypeEmpty && [self getType:testL] == OccupyTypeEmpty) {
			return TRUE;
		}
		//增加ai三子扩四子时的情况
		if (([self getType:testR] == OccupyTypeEmpty || [self getType:testL] == OccupyTypeEmpty) && num == 4 && xType == OccupyTypeAI) {
			return true;
		}
	}
	
	RMPoint *testDown = [RMPoint initWith:check.x Y:check.y + 1]; // 开始遍历点的正下方
	RMPoint *testUp = [RMPoint initWith:check.x Y:check.y - 1];	// 开始遍历的点的正上方
	// 不断向正下方寻找最长连续
	for(NSInteger i = 0; [self getType:testDown] == xType; i++){
		testDown.y ++;
	}
	// 不断向正上方寻找最长连续
	for(NSInteger i = 0; [self getType:testUp] == xType; i++){
		testUp.y --;
	}

	if(testDown.y - testUp.y - 1 >= num){
		if([self getType:testUp] == OccupyTypeEmpty && [self getType:testDown] == OccupyTypeEmpty){
			return true;
		}
		//增加ai三子扩四子时的情况
		if (([self getType:testUp] == OccupyTypeEmpty || [self getType:testDown] == OccupyTypeEmpty) && num == 4 && xType == OccupyTypeAI) {
			return true;
		}
	}
	
	RMPoint *testRightDown = [RMPoint initWith:check.x + 1 Y:check.y + 1]; // 开始遍历点的右下方
	RMPoint *testLeftUp = [RMPoint initWith:check.x - 1 Y:check.y - 1];	// 开始遍历点的左上方
	// 后面的判断逻辑和上面是相同的 不再赘述
	for(NSInteger i = 0; [self getType:testRightDown] == xType; i ++) {
		testRightDown.x ++;
		testRightDown.y ++;
	}
	
	for(NSInteger i = 0; [self getType:testLeftUp] == xType; i ++) {
		testLeftUp.x --;
		testLeftUp.y --;
	}
	
	if(testRightDown.x - testLeftUp.x - 1 >= num){
		if([self getType:testLeftUp] == OccupyTypeEmpty && [self getType:testRightDown] == OccupyTypeEmpty){
			return true;
		}
		//增加ai三子扩四子时的情况
		if (([self getType:testLeftUp] == OccupyTypeEmpty || [self getType:testRightDown] == OccupyTypeEmpty) && num == 4 && xType == OccupyTypeAI) {
			return true;
		}
	}
	
	RMPoint *testRightUp = [RMPoint initWith:check.x + 1 Y:check.y - 1]; // 开始遍历点的右上方
	RMPoint *testLeftDown = [RMPoint initWith:check.x - 1 Y:check.y + 1];	// 开始遍历点的左下方
	// 后面的判断逻辑和上面是相同的 不再赘述
	for(NSInteger i = 0; [self getType:testRightUp] == xType; i ++) {
		testRightUp.x ++;
		testRightUp.y --;
	}
	
	for(NSInteger i = 0; [self getType:testLeftDown] == xType; i ++) {
		testLeftDown.x --;
		testLeftDown.y ++;
	}
	
	if(testRightUp.x - testLeftDown.x - 1 >= num){
		if([self getType:testLeftDown] == OccupyTypeEmpty && [self getType:testRightUp] == OccupyTypeEmpty){
			return true;
		}
		//增加ai三子扩四子时的情况
		if (([self getType:testLeftDown] == OccupyTypeEmpty || [self getType:testRightUp] == OccupyTypeEmpty) && num == 4 && xType == OccupyTypeAI) {
			return true;
		}
	}
	return FALSE;
}

- (RMPoint *)nextStep:(OccupyType)xType needLinkNum:(NSInteger)num{
	//从（0， 0）点开始遍历
	RMPoint *startPoint = [[RMPoint alloc] initPointWith:0 Y:0];
	// 横向上寻找形成的num连珠的起始点
	RMPoint *hPoint = [self horizontal:startPoint type:xType needLinkNum:num];
	// 竖向上寻找形成的num连珠的起始点
	RMPoint *vPoint = [self vertical:startPoint type:xType needLinkNum:num];
	// 右下方向上寻找形成的num连珠的起始点
	RMPoint *rPoint = [self rightDown:startPoint type:xType needLinkNum:num];
	// 左下方向上寻找形成的num连珠的起始点
	RMPoint *lPoint = [self leftDown:startPoint type:xType needLinkNum:num];
	
	if(num == 5){
		if([self checkPoint:hPoint])// 表示找到胜利的五子连珠了
			return hPoint;
		if([self checkPoint:vPoint])
			return vPoint;
		if([self checkPoint:rPoint])
			return rPoint;
		if([self checkPoint:lPoint])
			return lPoint;
	} else {
		//如果该落子点两侧都为empty属性，返回改点
		if([self isStepEmergent:hPoint Num:num type:xType])
			return hPoint;
		
		if([self isStepEmergent:vPoint Num:num type:xType])
			return vPoint;
		
		if([self isStepEmergent:rPoint Num:num type:xType])
			return rPoint;
		
		if([self isStepEmergent:lPoint Num:num type:xType])
			return lPoint;
	}
	
	RMPoint * invalid = [[RMPoint alloc] init];
	return invalid;
}

//递归 寻找可落子的空点
- (RMPoint *)horizontal:(RMPoint *)startPoint type:(OccupyType)xType needLinkNum:(NSInteger)num {
	//遍历所有数据没有找到需要的点，跳出递归循环
	if (![self checkPoint:startPoint]) {
		return startPoint;
	}
	
	NSInteger count = 0;
	RMPoint *solution = [[RMPoint alloc] init];
	for(NSInteger i = 0; i < num; i++){
		@autoreleasepool {
			RMPoint *nextPoint = [RMPoint initWith:startPoint.x + i Y:startPoint.y];
			if (![self checkPoint:nextPoint]) {
				break;
			}
			OccupyType nextPointType = [self getType:nextPoint];
			if (nextPointType == xType) {// 如果满足了一定连续条件
				count ++;
			}
			if (nextPointType == OccupyTypeEmpty) {// 在横向上找到了一个空点
				solution = nextPoint;
			}
		}
	}
	
	// 如果找到了我们希望的连珠个数，并且这些连珠之后还有可以落子的点
	NSInteger currentLinkNum = num - 1;
	if(count >= currentLinkNum && [self checkPoint:solution]){
		return solution;
	}
	// 否则以递归的方式向后一个点进行遍历
	return [self horizontal:[self getNextPoint:startPoint] type:xType needLinkNum:num];
}

- (RMPoint *)vertical:(RMPoint *)startPoint type:(OccupyType)xType needLinkNum:(NSInteger)num {
	//遍历所有数据没有找到需要的点，跳出递归循环
	if (![self checkPoint:startPoint]) {
		return startPoint;
	}

	NSInteger count = 0;
	RMPoint *solution = [[RMPoint alloc] init];
	for(NSInteger i = 0; i < num; i++){
		RMPoint *nextPoint = [RMPoint initWith:startPoint.x Y:startPoint.y + i];
		if (![self checkPoint:nextPoint]) {
			break;
		}
		OccupyType nextPointType = [self getType:nextPoint];
		if (nextPointType == xType) {// 如果满足了一定连续条件
			count ++;
		}
		if (nextPointType == OccupyTypeEmpty) {// 在横向上找到了一个空点
			solution = nextPoint;
		}
	}
	NSInteger currentLinkNum = num - 1;
	if(count >= currentLinkNum && [self checkPoint:solution])
		return solution;
	
	return [self vertical:[self getNextPoint:startPoint] type:xType needLinkNum:num];
}

- (RMPoint *)rightDown:(RMPoint *)startPoint type:(OccupyType)xType needLinkNum:(NSInteger)num {

	if (![self checkPoint:startPoint]) {
		return startPoint;
	}
	
	NSInteger count = 0;
	RMPoint *solution = [[RMPoint alloc] init];
	for(NSInteger i = 0; i < num; i++){
		// 在右下向上逐渐寻找下一个点
		RMPoint *nextPoint = [RMPoint initWith:startPoint.x + i Y:startPoint.y + i];
		if (![self checkPoint:nextPoint]) {
			break;
		}
		OccupyType nextPointType = [self getType:nextPoint];
		if (nextPointType == xType) {// 如果满足了一定连续条件
			count ++;
		}
		if (nextPointType == OccupyTypeEmpty) {// 在横向上找到了一个空点
			solution = nextPoint;
		}
	}
	NSInteger currentLinkNum = num - 1;
	if(count >= currentLinkNum && [self checkPoint:solution])
		return solution;

	return [self rightDown:[self getNextPoint:startPoint] type:xType needLinkNum:num];
}

- (RMPoint *)leftDown:(RMPoint *)startPoint type:(OccupyType)xType needLinkNum:(NSInteger)num {
	
	if (![self checkPoint:startPoint]) {
		return startPoint;
	}
	
	NSInteger count = 0;
	RMPoint *solution = [[RMPoint alloc] init];
	for(NSInteger i = 0; i < num; i++){
		// 在左下向上逐渐寻找下一个点
		RMPoint *nextPoint = [RMPoint initWith:startPoint.x - i Y:startPoint.y + i];
		if (![self checkPoint:nextPoint]) {
			break;
		}
		OccupyType nextPointType = [self getType:nextPoint];
		if (nextPointType == xType) {// 如果满足了一定连续条件
			count ++;
		}
		if (nextPointType == OccupyTypeEmpty) {// 在横向上找到了一个空点
			solution = nextPoint;
		}
	}

	NSInteger currentLinkNum = num - 1;
	if(count >= currentLinkNum && [self checkPoint:solution])
		return solution;
	
	return [self leftDown:[self getNextPoint:startPoint] type:xType needLinkNum:num];
}

//寻找下一个点
- (RMPoint *)getNextPoint:(RMPoint *)pp {

	RMPoint *result = [RMPoint pointWithPoint:pp];
	if(result.x + 1 < kBoardSize){
		result.x ++; //如果下一个点在同一排 则返回下一个
		return result;
	}
	result.x = 0; // 否则返回下一排第一个
	result.y ++;
	return result;
}

@end

