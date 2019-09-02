//
//  ViewController.m
//  RACDemo
//
//  Created by 峰 on 2019/8/30.
//  Copyright © 2019 峰. All rights reserved.
//

#import "ViewController.h"
#import "RACSignalVC.h"
#import "RACDefineVC.h"
#import "RACSequenceVC.h"
#import "RACCommandVC.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSArray *_arrayData;
    
    NSArray *_arrayTitle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    
    //创建其他视图
    [self createView];
}

- (void)initData{
    _arrayData = @[
                   @[@"三种基本信号",@"RACSignal",@"RACSignalVC"],
                   @[@"RAC常用宏",@"常用宏",@"RACDefineVC"],
                   @[@"RACSequence集合",@"RACSequence集合使用",@"RACSequenceVC"],
                   @[@"RACCommand",@"RACCommand处理事件的类",@"RACCommandVC"],
                   @[@"",@"",@""],
                   @[@"",@"",@""],
                   @[@"",@"",@""],
                   @[@"",@"",@""],
                   @[@"",@"",@""],
                   @[@"",@"",@""],
                   @[@"",@"",@""],
                   @[@"",@"",@""],
                   @[@"",@"",@""],
                   @[@"",@"",@""],
                   @[@"",@"",@""],
                   @[@"",@"",@""],
                   @[@"",@"",@""],
                   @[@"",@"",@""],
                   @[@"",@"",@""],
                   @[@"",@"",@""],
                   ];
    
    
}

#pragma mark - UITableView&&代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = _arrayData[indexPath.row][0];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *classStr = _arrayData[indexPath.row][2];
    RACBaseViewController *classVC = [[NSClassFromString(classStr) alloc] init];
    classVC.title = _arrayData[indexPath.row][1];
    [self.navigationController pushViewController:classVC animated:YES];
}

#pragma mark - Init View  初始化一些视图之类的
- (void)createView{
    
    //创建tableView  UITableViewStyleGrouped:cell的组头视图不会吸顶（会被压）  UITableViewStylePlain:组头视图会吸顶（不会被压）
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopNaviBarHeight, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
    //背景颜色
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.tableView];
    
    //防止UITableView被状态栏压下20
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        //self.tableView.adjustedContentInset =
    }
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];//非Xib
    
}


@end
