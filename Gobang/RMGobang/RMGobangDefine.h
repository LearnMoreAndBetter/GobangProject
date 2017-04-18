//
//  RMGobangDefine.h
//  Gobang
//
//  Created by wanglin on 2017/4/17.
//  Copyright © 2017年 wanglin. All rights reserved.
//

#ifndef RMGobangDefine_h
#define RMGobangDefine_h

#define kLineColor [UIColor blackColor]
#define kChessBackgroundColor [UIColor colorWithRed:230.0 / 255.0 green:192.0 / 255.0 blue:148.0 /255.0 alpha:1.0]

#define kBoardSize  19 


//落子位置类型
typedef NS_ENUM(NSUInteger, OccupyType) {
	OccupyTypeEmpty,
	OccupyTypeUser,
	OccupyTypeAI ,
	OccupyTypeUnknown
};

#endif /* RMGobangDefine_h */
