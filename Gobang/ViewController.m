//
//  ViewController.m
//  Gobang
//
//  Created by wanglin on 2017/4/17.
//  Copyright © 2017年 wanglin. All rights reserved.
//

#import "ViewController.h"
#import "RMGobangView.h"

#define APP_Screen_Width self.view.bounds.size.width
#define APP_Screen_Height self.view.bounds.size.height

@interface ViewController ()

@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *stopButton;

@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) RMGobangView *gobangView;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	self.gobangView = [[RMGobangView alloc] initWithFrame:CGRectMake(0, 20, APP_Screen_Width, APP_Screen_Width)];
	[self.view addSubview:self.gobangView];
	[self.view addSubview:self.maskView];
//	[self.view bringSubviewToFront:self.maskView];
}

- (void)stopButtonPressed:(UIButton *)button {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否退出游戏？" message:nil preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *quitAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		abort();
	}];
	UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
	[alertController addAction:quitAction];
	[alertController addAction:cancleAction];
	[self presentViewController:alertController animated:YES completion:nil];
}

- (void)startButtonPressed:(UIButton *)button {
	[self.maskView removeFromSuperview];
}

#pragma mark- lazying
- (UIButton *)startButton{
	if (!_startButton) {
		_startButton = [[UIButton alloc] initWithFrame:CGRectMake(APP_Screen_Width/2 - 120, APP_Screen_Height - 150, 90, 30)];
		[_startButton setBackgroundImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
		[_startButton addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _startButton;
}

- (UIButton *)stopButton{
	if (!_stopButton) {
		_stopButton = [[UIButton alloc] initWithFrame:CGRectMake(APP_Screen_Width/2 + 30, APP_Screen_Height - 150, 90, 30)];
		[_stopButton setBackgroundImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
		[_stopButton addTarget:self action:@selector(stopButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _stopButton;
}


- (UIImageView *)maskView{
	if (!_maskView) {
		_maskView = [[UIImageView alloc] initWithFrame:self.view.bounds];
		NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"launch.jpg"];
		_maskView.image = [UIImage imageWithContentsOfFile:path];
		_maskView.contentMode = UIViewContentModeScaleAspectFill;
		_maskView.userInteractionEnabled = YES;
		[_maskView addSubview:self.startButton];
		[_maskView addSubview:self.stopButton];
	}
	return _maskView;
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end
