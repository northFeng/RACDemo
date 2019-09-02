//
//  RACDefineVC.m
//  RACDemo
//
//  Created by 峰 on 2019/8/30.
//  Copyright © 2019 峰. All rights reserved.
//

#import "RACDefineVC.h"

@interface RACDefineVC ()

///
@property (nonatomic,strong) UITextField *textField;

///name
@property (nonatomic,copy) NSString *name;

@end

@implementation RACDefineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

///常见宏
- (void)racDefine {
    
    /** 1、
     RAC(TARGET, [KEYPATH, [NIL_VALUE]])
     作用: 用于给某个对象的某个属性绑定
     实例: 只要文本框的文字改变，就会修改label的文字
     */
    RAC(self,name) = _textField.rac_textSignal;
    
    /**2、
    RACObserve(self, name)
    作用: 监听某个对象的某个属性，返回的是信号
    实例: 监听self.view的center变化
     
    注意：当RACObserve放在block里面使用时一定要加上weakify，不管里面有没有使用到self；否则会内存泄漏，因为RACObserve宏里面就有一个self。
     */
    [RACObserve(self.view, center) subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    /** 3、
    @weakify(Obj)和@strongify(Obj)
   一般两个都是配套使用,在主头文件(ReactiveCocoa.h)中并没有导入，需要自己手动导入，RACEXTScope.h才可以使用。但是每次导入都非常麻烦，只需要在主头文件自己导入就好了
     */
    
    /** 4、
    RACTuplePack
    
    作用: 把数据包装成RACTuple（元组类）
    实例: 把参数中的数据包装成元组
    RACTuple *tuple = RACTuplePack(@10,@20);
    
    RACTupleUnpack
    
    作用: 把RACTuple（元组类）解包成对应的数据
    实例: 把参数中的数据包装成元组
    RACTuple *tuple = RACTuplePack(@"xmg",@20);
    注意事项: 解包元组，会把元组的值，按顺序给参数里面的变量赋值
     */
    
}

@end
