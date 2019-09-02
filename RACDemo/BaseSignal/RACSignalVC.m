//
//  RACSignalVC.m
//  RACDemo
//
//  Created by 峰 on 2019/8/30.
//  Copyright © 2019 峰. All rights reserved.
//

#import "RACSignalVC.h"

@interface RACSignalVC ()

///信号
@property (nonatomic,strong) RACSignal *signal;

///信号
@property (nonatomic,strong) RACSubject *subject;

///信号
@property (nonatomic,strong) RACReplaySubject *replaysubject;

///
@property (nonatomic,copy) NSString *name;

@end

@implementation RACSignalVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /**
     信号signal是RAC的绝对核心，所有的操作都是围绕着信号来处理的。
     比如：创建信号，订阅信号，发送信号是消息发送的核心步骤。
     常见的三个信号类为：
     
     -RACSignal
     -RACSubject
     -RACReplaySubject
     */
    
    [self zipSignal];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [_signal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
        
    }];
}

#pragma mark - RACSignal  创建信号+订阅，订阅一次，发送一次（因此不会执有block）
///一、RACSignal ——> RACSignal的订阅不会持有block,不会导致self的循环引用！！
/**
 RACSignal总结：
 三步骤（先创建信号，然后订阅信号，最后执行didSubscribe内部的方法）顺序是不能变的。
 RACSignal底层实现：
 
 1.创建信号，首先把didSubscribe保存到信号中，还不会触发。
 2.当信号被订阅，也就是调用signal的subscribeNext:nextBlock
 2.1 subscribeNext内部会创建订阅者subscriber，并且把nextBlock保存到subscriber中。
 2.2 subscribeNext内部会调用siganl的didSubscribe
 3.siganl的didSubscribe中调用[subscriber sendNext:@1];
 3.1 sendNext底层其实就是执行subscriber的nextBlock
 
 */
- (void)racsignalDemo {
    
    // 1.创建信号
    RACSignal *siganl = [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 注：block在此仅仅是个参数，未被调用，
        //当有订阅者订阅信号时会调用block。
        // 2.发送信号
        //[subscriber sendNext:@1];
        [subscriber sendNext:RACTuplePack(@1,@4)];//发送元祖
        
        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        //[subscriber sendCompleted];//调用这个方法，就会取消订阅，订阅里的bloc才会释放！否则订阅里的block会持有self无法释放
        return nil;
        /**
         return [RACDisposable disposableWithBlock:^{
         NSLog(@"执行清理");
         //RACDisposable:用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它
         //使用场景:不想监听某个信号时，可以通过它主动取消订阅信号
         }];
         */
    }] doNext:^(id  _Nullable x) {
        NSLog(@"执行sendNext前，会先执行这个Block");
    }] doCompleted:^{
        NSLog(@"执行sendConplete前，会先执行这个Block");
    }];
    _signal = siganl;

    
    /** RACSignal的订阅不会持有block,不会导致self的循环引用！！
    // 3.订阅信号,才会激活信号.
    [siganl subscribeNext:^(id x) {
        // block调用时刻：每当有信号发出数据，就会调用block.
        NSLog(@"接收到数据:%@",x);
    }];
    
    [siganl subscribeError:^(NSError *error) {
        NSLog(@"当前出现错误%@",error);
    }];
    
    [siganl subscribeCompleted:^{
        
    }];
     */
    
    //解析信号中值为元祖的值，拦截进行解析 并返回
    [[siganl reduceEach:^id(NSNumber *first,NSNumber *secnod){
        return @([first integerValue]+[secnod integerValue]);
    }] subscribeNext:^(NSNumber *x) {
        NSLog(@"reduceEach当前的值：%zd",[x integerValue]);
    }];

}


#pragma mark - RACSubject  创建信号+订阅  ——> 发送信号，订阅接受信号 （因此会先执有订阅block，会产生循环引用）
///二、RACSubject  可以创建多个订阅者，并发送信号； RACSubject订阅里有self的话必须用weakSelf，订阅里的block会产生循环引用
/**
 1.创建信号
 2.订阅信号
 而RACSubject订阅信号的实质就是将内部创建的订阅者保存在订阅者数组self.subscribers中，
 3.发送信号
 底层实现是：
 先遍历订阅者数组中的订阅者;
 后执行订阅者中的nextBlock;
 最后让订阅者发送信号。
 */
- (void)racSubjectDemo {
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    _subject = subject;
    
    // 2.订阅信号（这里可以创建多个订阅者）
    
    //解决循环引用 使用weakSelf
    /**
    @weakify(self);
    [_subject subscribeNext:^(id x) {
        @strongify(self);
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第一个订阅者%@",x);
        
        self.name = @"花儿乐队";
        self.title = self.name;
    }];
     */
    
    //在VC死亡之前 使用 [_subject sendCompleted]; ——>使订阅block释放！！
    [_subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第二个订阅者%@",x);
        self.name = @"花田喜事";
        self.title = self.name;
    }];
    
    /**
    [_subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第三个订阅者%@",x);
        self.name = @"花龄盛会";
        self.title = self.name;
    }];
     */
    
    // 3.发送信号
    //[subject sendNext:@"1"];
}

/**
 总结
 RACSubscriber:表示订阅者的意思，用于发送信号，这是一个协议，不是一个类，只要遵守这个协议，并且实现方法才能成为订阅者。通过create创建的信号，都有一个订阅者，帮助他发送数据。
 RACDisposable:用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它。
 RACSubject:底层实现和RACSignal不一样。
 1.调用subscribeNext订阅信号，只是把订阅者保存起来，并且订阅者的nextBlock已经赋值了。
 2.调用sendNext发送信号，遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
 3.由于本质是将订阅者保存到数组中，所以可以有多个订阅者订阅信息。
 使用场景:不想监听某个信号时，可以通过它主动取消订阅信号。
 RACSubject:信号提供者，自己可以充当信号，又能发送信号。
 使用场景:通常用来代替代理，有了它，就不必要定义代理了。
 缺点：
 还是必须先订阅，后发送信息。订阅信号就是创建订阅者的过程，如果不先订阅，数组中就没有订阅者对象，那就通过订阅者发送消息。
 
 */


#pragma mark - RACReplaySubject
///三、RACReplaySubject
/**
 RACReplaySubject总结
 RACReplaySubject是RACSubject的子类
 RACReplaySubject使用步骤:
 // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
 // 2.可以先订阅信号，也可以先发送信号。
 // 2.1 订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
 // 2.2 发送信号 sendNext:(id)value
 */
- (void)racReplaySubjectDemo {
    
    // 1.创建信号
    RACReplaySubject *subject = [RACReplaySubject subject];
    _replaysubject = subject;
    
    /** 可以先发信号 后订阅
    // 2.订阅信号
    [subject subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
     */
    
    // 遍历所有的值,拿到当前订阅者去发送数据
    // 3.发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    // RACReplaySubject发送数据:
    // 1.保存值
    // 2.遍历所有的订阅者,发送数据
    // RACReplaySubject:可以先发送信号,在订阅信号
    
    //内部原理
    //1、订阅信号时，内部保存了订阅者，和订阅者响应block
    //2、当发送信号时，遍历订阅者，调用订阅者的nextBlock
    //3、发送的信号会保存起来！！！，当订阅者订阅信号时，会将之前保存的信号，一个一个遍历！！！
    
    //可以利用 过滤 && take && skip 来取自己想要的信号
}

#pragma mark - 信号  过滤 && 拦截 && take(取信号过滤) && skip(跳过过滤)
///过滤 && 忽略
- (void)filterAndIgnoreSignal {
    
    RACSignal *signal=[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"3"];
        [subscriber sendNext:@"15"];
        [subscriber sendNext:@"wujy"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"执行清理");
        }];
    }];
    
    //添加过滤条件
    [[signal filter:^BOOL(id value) {
        
        //过滤 添加 过滤条件
        if ([value isEqualToString:@"wujy"]) {
            return YES;
        }
        return NO;
    }] subscribeNext:^(id x) {
        NSLog(@"当前的值为：%@",x);
    }];
    
    //ignore 忽略某个值
    [[signal ignore:@"3"] subscribeNext:^(id x) {
        NSLog(@"当前的值为：%@",x);
    }];
    //输出：当前的值为：1  当前的值为：15  当前的值为：wujy   执行清理
    
    //ignoreValues 这个比较极端，忽略所有值，只关心Signal结束，也就是只取Comletion和Error两个消息，中间所有值都丢弃。
    [[signal ignoreValues] subscribeNext:^(id x) {
        //它是没机会执行  因为ignoreValues已经忽略所有的next值
        NSLog(@"ignoreValues当前值：%@",x);
    } error:^(NSError *error) {
        NSLog(@"ignoreValues error");
    } completed:^{
        NSLog(@"ignoreValues completed");
    }];
}

///信号拦截
- (void)signalMap {
    
    RACSignal *signal=[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"3"];
        [subscriber sendNext:@"15"];
        [subscriber sendNext:@"wujy"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"执行清理");
        }];
    }];
    
    
    //map拦截信号数据
    [[signal map:^id(NSString *value) {
        return @(value.length);
    }] subscribeNext:^(NSNumber *x) {
        NSLog(@"当前的位数为：%zd",[x integerValue]);
    }];
    
    //拦截信号，并返回一个信号,并 把返回的信号中的值 传出去
    [[signal flattenMap:^RACSignal * _Nullable(id  _Nullable value) {
        return [RACSignal return:[NSString stringWithFormat:@"当前输出为：%@",value]];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"flattenMap中执行：%@",x);
    }];
    
    /**
     那么map跟flattenMap有什么区别呢？
     
     1. FlatternMap中的Block返回信号
     2. Map中的Block返回对象
     3. 如果信号发出的值不是信号，映射一般使用Map
     4. 如果信号发出的值是信号，映射一般使用FlatternMap
     */
    
}

///take 取几次拦截
- (void)takeSignal {
    
    RACSignal *signal=[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"3"];
        [subscriber sendNext:@"5"];
        [subscriber sendNext:@"7"];
        [subscriber sendNext:@"wujy"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"执行清理");
        }];
    }];
    _signal = signal;
    
    //只取第一次信号
    [[signal take:1] subscribeNext:^(id x) {
        NSLog(@"take 获取的值：%@",x);
    }];
    
    //takeUntilBlock的意思是:对于每个next值，运行block，当block返回YES时停止信号
    [[signal takeUntilBlock:^BOOL(NSString *x) {
        if ([x isEqualToString:@"15"]) {
            return YES;
        }
        return NO;
    }] subscribeNext:^(id x) {
        NSLog(@"takeUntilBlock 获取的值：%@",x);
    }];
    
    // 取最后N次的信号，但是它有一个前提条件，订阅者必须调用完成，因为只有完成，才知道总共有多少信号。
    [[signal takeLast:1] subscribeNext:^(id x) {
        NSLog(@"takeLast 获取的值：%@",x);
    }];
    
}

/**
  take 和 skip 的用法区别
  take： 取 一组信号  前半部分
  skip：取 一组信号  后半部分
 */

///跳过
- (void)skipSignal {
    
    RACSignal *signal=[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"3"];
        [subscriber sendNext:@"5"];
        [subscriber sendNext:@"wujy"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"执行清理");
        }];
    }];
    _signal = signal;
    
    //skip 跳过几次，只接受后面的信号
    [[signal skip:2] subscribeNext:^(id x) {
        NSLog(@"skip 获取的值：%@",x);
    }];
    //输出：skip 获取的值：15    skip 获取的值：wujy
    
    //一直跳过，直到！block返回 YES开始不跳过 接受信号
    [[signal skipUntilBlock:^BOOL(NSString *x) {
        if ([x isEqualToString:@"15"]) {
            return YES;
        }
        return NO;
    }] subscribeNext:^(id x) {
        NSLog(@"skipUntilBlock 获取的值：%@",x);
    }];
    
    //一直跳过，当 block返回NO，
    [[signal skipWhileBlock:^BOOL(id  _Nullable x) {
        return YES;
    }] subscribeNext:^(id  _Nullable x) {
        
    }];

}


#pragma mark - RAC定时器用法
///超时
- (void)timeOutSignal{
    
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        return nil;
    }] timeout:1 onScheduler:[RACScheduler currentScheduler]];
    
    [signal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    } error:^(NSError *error) {
        // 1秒后会自动调用
        NSLog(@"%@",error);
    }];
    
}

///定时器
- (void)timerSignal{
    
    _signal = [RACSignal interval:1 onScheduler:[RACScheduler currentScheduler]];
    [_signal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
}

///延时发送
- (void)delaySignal{
    
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        return nil;
    }] delay:2] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
}

#pragma mark - 重从订阅机制

- (void)retrySignal {
    
    //有很多场景需要我们重新执行某个操作，比如网络请求中的再次刷新等，类似的场景我们就可以使用retry语法来实现。
    //若发送的是error则可以使用retry来尝试重新刺激信号 retry重试 ：只要失败，就会重新执行创建信号中的block,直到成功.
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        static int i = 0;
        NSLog(@"i = %d",i);
        if (i == 5) {
            [subscriber sendNext:@"i == 2"];
        }else{
            i ++;
            [subscriber sendError:nil];
        }
        return nil;
        //当发送的是error时可以retry重新执行
    }] retry] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
}


#pragma mark - 组合信号
///拼接信号 concat:按一定顺序拼接信号，当多个信号发出的时候，有顺序的接收信号。
- (void)concatSignal{
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        
        [subscriber sendCompleted];//必须走这步，否则，B信号不会发送
        return nil;
    }];
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@2];
        
        return nil;
    }];
    
    // 把signalA拼接到signalB后，signalA发送完成，signalB才会被激活。
    RACSignal *concatSignal = [signalA concat:signalB];
    
    // 以后只需要面对拼接信号开发。
    // 订阅拼接的信号，不需要单独订阅signalA，signalB
    // 内部会自动订阅。
    // 注意：第一个信号必须发送完成，第二个信号才会被激活
    [concatSignal subscribeNext:^(id x) {

        NSLog(@"%@",x);

    }];
    _signal = concatSignal;
    
    // concat底层实现:
    // 1.当拼接信号被订阅，就会调用拼接信号的didSubscribe
    // 2.didSubscribe中，会先订阅第一个源信号（signalA）
    // 3.会执行第一个源信号（signalA）的didSubscribe
    // 4.第一个源信号（signalA）didSubscribe中发送值，就会调用第一个源信号（signalA）订阅者的nextBlock,通过拼接信号的订阅者把值发送出来.
    // 5.第一个源信号（signalA）didSubscribe中发送完成，就会调用第一个源信号（signalA）订阅者的completedBlock,订阅第二个源信号（signalB）这时候才激活（signalB）。
    // 6.订阅第二个源信号（signalB）,执行第二个源信号（signalB）的didSubscribe
    // 7.第二个源信号（signalA）didSubscribe中发送值,就会通过拼接信号的订阅者把值发送出来.
    
}

///合并信号 ——> 把多个信号合并为一个信号，任何一个信号有新值的时候就会调用
- (void)mergeSignal{
    
    //`merge`:把多个信号合并为一个信号，任何一个信号有新值的时候就会调用
    // merge:把多个信号合并成一个信号
    //创建多个信号
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@2];
        
        return nil;
    }];
    
    // 合并信号,任何一个信号发送数据，都能监听到.
    RACSignal *mergeSignal = [signalA merge:signalB];
    
    [mergeSignal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
        
    }];
    
    _signal = mergeSignal;
    
    // 底层实现：
    // 1.合并信号被订阅的时候，就会遍历所有信号，并且发出这些信号。
    // 2.每发出一个信号，这个信号就会被订阅
    // 3.也就是合并信号一被订阅，就会订阅里面所有的信号。
    // 4.只要有一个信号被发出就会被监听。
    
}

///连接信号
- (void)thenSignal{
    
    // then:用于连接两个信号，当第一个信号完成，才会连接then返回的信号
    // 注意使用then，之前信号的值会被忽略掉.
    // 底层实现：1、先过滤掉之前的信号发出的值。2.使用concat连接then返回的信号
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@2];
            return nil;
        }];
    }] subscribeNext:^(id x) {
        
        // 只能接收到第二个信号的值，也就是then返回信号的值
        NSLog(@"%@",x);
    }];
    
    //* `merge`:把多个信号合并为一个信号，任何一个信号有新值的时候就会调用
    
}

///压缩信号 ——> 只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元组，才会触发压缩流的next事件。
- (void)zipSignal{
    
    //zipWith:把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元组，才会触发压缩流的next事件。
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@2];
        
        return nil;
    }];
    
    
    
    // 压缩信号A，信号B
    RACSignal *zipSignal = [signalA zipWith:signalB];
    
    [zipSignal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    _signal = zipSignal;
    // 底层实现:
    // 1.定义压缩信号，内部就会自动订阅signalA，signalB
    // 2.每当signalA或者signalB发出信号，就会判断signalA，signalB有没有发出个信号，有就会把最近发出的信号都包装成元组发出。
    
}

///把两个信号组合成一个信号,跟zip一样，没什么区别
- (void)combineSignal{
    
    //将多个信号合并起来，并且拿到各个信号的最新的值,必须每个合并的signal至少都有过一次sendNext，才会触发合并的信号。
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@2];
        
        return nil;
    }];
    
    // 把两个信号组合成一个信号,跟zip一样，没什么区别
    //RACSignal *combineSignal = [signalA combineLatestWith:signalB];//和下面效果一样
    RACSignal *combineSignal  = [RACSignal combineLatest:@[signalA,signalB]];
    
    
    /**  解析 信号的值 (元祖)
    [[combineSignal reduceEach:^id(NSNumber *first,NSNumber *secnod){
        return @([first integerValue]+[secnod integerValue]);
    }] subscribeNext:^(NSNumber *x) {
        NSLog(@"reduceEach当前的值：%zd",[x integerValue]);
    }];
     */
    [combineSignal subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    // 底层实现：
    // 1.当组合信号被订阅，内部会自动订阅signalA，signalB,必须两个信号都发出内容，才会被触发。
    // 2.并且把两个信号组合成元组发出。
    
}


@end
