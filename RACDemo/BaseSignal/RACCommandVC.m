//
//  RACCommandVC.m
//  RACDemo
//
//  Created by 峰 on 2019/8/30.
//  Copyright © 2019 峰. All rights reserved.
//

#import "RACCommandVC.h"

@interface RACCommandVC ()

///
@property (nonatomic,strong) RACCommand *command;

@end

@implementation RACCommandVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /**
     RACCommand是RAC中用于处理事件的类，我们可以把事件如何处理,事件中的数据如何传递，包装到这个类中。使用这个类可以很方便的监控事件的执行过程。
     
     创建命令  initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
     在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
     
     执行命令 -(RACSignal * )execute:(id)input
     
     //执行过程
     RACCommand有个执行信号源executionSignals，这个是signal of signals(信号的信号),意思是信号发出的数据是信号，不是普通的类型。
     订阅executionSignals就能拿到RACCommand中返回的信号，然后订阅signalBlock返回的信号，就能获取发出的值。
     
     
     在RACCommand的使用过程中，我们及其要注意以下的几点事项:！！！！
     
     1、signalBlock必须要返回一个信号，不能传nil
     2、如果不想要传递信号，直接创建空的信号[RACSignal empty]
     3、RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中
     4、RACCommand需要被强引用，否则接收不到RACCommand中的信号，因此RACCommand中的信号是延迟发送的
     
     */
}

///使用demo
- (void)racCommandDemo {
    
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"执行命令");
        
        // 创建空信号,必须返回信号
        //        return [RACSignal empty];
        
        // 2.创建信号,用来传递数据
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            [subscriber sendNext:@"请求数据"];
            
            // 注意：数据传递完，最好调用sendCompleted，这时命令才执行完毕。
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    
    // 强引用命令，不要被销毁，否则接收不到数据
    _command = command;
    
    // 3.订阅RACCommand中的信号
    [command.executionSignals subscribeNext:^(id x) {
        
        //接受的是信号 ——> 在这里订阅 才会触发 block里的信号执行
        [x subscribeNext:^(id x) {
            
            NSLog(@"executionSignals:%@",x);
        }];
    }];
    
    // RAC高级用法
    // switchToLatest:用于signal of signals，获取signal of signals发出的最新信号,也就是可以直接拿到RACCommand中的信号
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        
        NSLog(@"executionSignals.switchToLatest:%@",x);
    }];
    
    // 4.监听命令是否执行完毕,默认会来一次，可以直接跳过，skip表示跳过第一次信号。
    [[command.executing skip:1] subscribeNext:^(id x) {
        
        if ([x boolValue] == YES) {
            // 正在执行
            NSLog(@"正在执行");
            
        }else{
            // 执行完成
            NSLog(@"执行完成");
        }
        
    }];
    // 5.执行命令
    [self.command execute:@1];
    
    
    //    输出
    //    执行命令
    //    正在执行
    //    executionSignals:请求数据
    //    executionSignals.switchToLatest:请求数据
    //    执行完成
    
}

/**
 2.RACMulticastConnection的使用
 讲到了RACCommand，那么必不可少的有按钮的多次点击导致多次网络请求的问题。RACMulticastConnection用于当一个信号，被多次订阅时，为了保证创建信号时，避免多次调用创建信号中的block，造成副作用，可以使用这个类处理。首先，我们看一下RACMulticastConnection的使用步骤:
 
 创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
 创建连接 RACMulticastConnection *connect = [signal publish];
 订阅信号,注意：订阅的不在是之前的信号，而是连接的信号。 [connect.signal subscribeNext:nextBlock]
 连接 [connect connect]

 */
- (void)demo2 {
    
    // 1.创建请求信号
    RACSignal *aSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        
        NSLog(@"aSignal发送请求");
        
        return nil;
    }];
    // 2.订阅信号
    [aSignal subscribeNext:^(id x) {
        
        NSLog(@"接收数据");
        
    }];
    // 2.订阅信号
    [aSignal subscribeNext:^(id x) {
        
        NSLog(@"接收数据");
        
    }];
    
    // 3.运行结果，会执行两遍发送请求，也就是每次订阅都会发送一次请求
    
    // RACMulticastConnection:解决重复请求问题
    // 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        
        NSLog(@"signal发送请求");
        [subscriber sendNext:@1];
        
        return nil;
    }];
    
    // 2.创建连接
    RACMulticastConnection *connect = [signal publish];
    
    // 3.订阅信号，
    // 注意：订阅信号，也不能激活信号，只是保存订阅者到数组，必须通过连接,当调用连接，就会一次性调用所有订阅者的sendNext:
    [connect.signal subscribeNext:^(id x) {
        
        NSLog(@"订阅者一信号");
        
    }];
    
    [connect.signal subscribeNext:^(id x) {
        
        NSLog(@"订阅者二信号");
        
    }];
    
    // 4.连接,激活信号
    [connect connect];
    
    
    
    //输出
    //aSignal发送请求
    //aSignal发送请求
    
    
    //signal发送请求
    //订阅者一信号
    //订阅者二信号
    
}

/**
 然后我们看一下RACMulticastConnection的底层实现原理:
 
 1、创建connect，connect.sourceSignal -> RACSignal(原始信号)  connect.signal -> RACSubject
 2、订阅connect.signal，会调用RACSubject的subscribeNext，创建订阅者，而且把订阅者保存起来，不会执行block
 3、[connect connect]内部会订阅RACSignal(原始信号)，并且订阅者是RACSubject
 订阅原始信号，就会调用原始信号中的didSubscribe
 didSubscribe，拿到订阅者调用sendNext，其实是调用RACSubject的sendNext
 
 4、RACSubject的sendNext,会遍历RACSubject所有订阅者发送信号
 因为刚刚第二步，都是在订阅RACSubject，因此会拿到第二步所有的订阅者，调用他们的nextBlock
 最后，我们通过简单的小需求来实际使用一下。假设在一个信号中发送请求，每次订阅一次都会发送请求，这样就会导致多次请求。我们需要使用RACMulticastConnection解决这个问题。
 
 */



@end
