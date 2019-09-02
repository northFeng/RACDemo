//
//  ViewController.h
//  RACDemo
//
//  Created by 峰 on 2019/8/30.
//  Copyright © 2019 峰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

///tableView (记得热点导致的适配问题，一定要用约束！！)
@property (nonatomic,strong,nullable) UITableView *tableView;


@end

