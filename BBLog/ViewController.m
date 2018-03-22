//
//  ViewController.m
//  BBLog
//
//  Created by Gary on 15/03/2018.
//  Copyright © 2018 czy. All rights reserved.
//

#import "ViewController.h"
#import "BBLogAgent.h"
#import "SecondViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton                  *button;

@end

@implementation ViewController

- (void)loadView {
    [super loadView];
    self.view = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _button = [[UIButton alloc]init];
    _button.backgroundColor = [UIColor greenColor];
    [_button setTitle:@"下一页" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    _button.frame = CGRectMake(100, 300, 100, 30);
    _button.layer.cornerRadius = 3;
    _button.layer.masksToBounds = YES;
    [self.view addSubview:_button];
    
    [_button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [BBLogAgent startTracPage:NSStringFromClass(self.class)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [BBLogAgent endTracPage:NSStringFromClass(self.class)];
}


- (void)buttonAction:(id)sender {
    [BBLogAgent postEvent:@"Test" relatedData:@"00000001" acc:1];
    SecondViewController *secondViewController = [[SecondViewController alloc]init];
    [self.navigationController pushViewController:secondViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
