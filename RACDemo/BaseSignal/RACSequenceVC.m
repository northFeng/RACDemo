//
//  RACSequenceVC.m
//  RACDemo
//
//  Created by 峰 on 2019/8/30.
//  Copyright © 2019 峰. All rights reserved.
//

#import "RACSequenceVC.h"

@interface RACSequenceVC ()

@end

@implementation RACSequenceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /**
     简单的总结一下使用的流程:
     
     把数组转换成集合RACSequence   numbers.rac_sequence
     
     把集合RACSequence转换RACSignal信号类  numbers.rac_sequence.signal
     
     订阅信号，激活信号，会自动把集合中的所有值，遍历出来
     */
}

///使用demo
- (void)racSequenceDemo {
    
    NSArray *arr = @[@1,@2,@3,@4,@5,@6];
    [arr.rac_sequence.signal subscribeNext:^(id x) {
        
        NSLog(@"当前的值x:%@",x);
    }];
    //输出
    //    当前的值x:1
    //    当前的值x:2
    //    当前的值x:3
    //    当前的值x:4
    //    当前的值x:5
    //    当前的值x:6
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"jtd",@"name",@"man",@"sex",@"jx",@"jg", nil];
    [dict.rac_sequence.signal subscribeNext:^(id x) {
        RACTupleUnpack(NSString *key,NSString *value) = x;
        
        NSLog(@"key:%@,value:%@",key,value);
    }];
}

///数组、字典 转化成信号后，可以进行信号的一切操作 map,filter,reduce,skip,take,contact..
- (void)handleArrayAndDictionry {
    
    NSArray *array=@[@(2),@(5),@(7),@(15)];
    RACSequence *sequence = [array rac_sequence];
    
    id mapData = [sequence map:^id(id value) {
        return @([value integerValue] * 2);
    }];
    NSLog(@"序列Map之后的数据:%@",[mapData array]);
    
    id filterData = [sequence filter:^BOOL(id value) {
        return [value integerValue]%2 == 0;
    }];
    NSLog(@"序列Filter之后的数据:%@",[filterData array]);
    
    id reduceData = [sequence foldLeftWithStart:@"" reduce:^id(id accumulator, id value) {
        return [accumulator stringByAppendingString:[value stringValue]];
    }];
    NSLog(@"序列Left-Reduce之后的数据:%@",reduceData);
    
    id rightReduceData = [sequence foldRightWithStart:@"" reduce:^id(id first, RACSequence *rest) {
        return [NSString stringWithFormat:@"%@%@", rest.head, first];
    }];
    NSLog(@"序列Right-Reduce之后的数据:%@",rightReduceData);
    
    id skipData = [sequence skip:1];
    NSLog(@"序列Skip之后的数据:%@",[skipData array]);
    
    
    id takeData = [sequence take:2];
    NSLog(@"序列Take之后的数据:%@",[takeData array]);
    
    id takeUntilData = [sequence takeUntilBlock:^BOOL(id x) {
        return [x integerValue] == 7;
    }];
    NSLog(@"序列TakeUntil之后的数据:%@",[takeUntilData array]);
    
    NSArray *nextArr = @[@"A",@"B",@"C"];
    RACSequence *nextSequence = [nextArr rac_sequence];
    id contactData = [sequence concat:nextSequence];
    NSLog(@"FlyElephant序列Contact之后的数据:%@",[contactData array]);
    
}

///元祖使用
- (void)racTupleDemo {
    
    //普通创建
    RACTuple *tuple1 = [RACTuple tupleWithObjects:@1, @2, @3, nil];
    RACTuple *tuple2 = [RACTuple tupleWithObjectsFromArray:@[@1, @2, @3]];
    RACTuple *tuple3 = [[RACTuple alloc] init];
    
    //宏创建
    RACTuple *tuple4 = RACTuplePack(@1, @2, @3, @4);
    
    //解包(等号前面是参数定义，后面是已存在的Tuple，参数个数需要跟Tuple元素相同）
    RACTupleUnpack(NSNumber * value1, NSNumber * value2, NSNumber * value3, NSNumber * value4) = tuple4;
    NSLog(@"%@ %@ %@ %@", value1, value2, value3, value4);
    
    //元素访问方式
    NSLog(@"%@", [tuple4 objectAtIndex:1]);
    NSLog(@"%@", tuple4[1]);
    
    //输出
    //1 2 3 4
    //2
    //2
    
}


@end
