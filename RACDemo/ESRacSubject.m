//
//  ESRacSubject.m
//  esReadStudent
//
//  Created by edz on 2019/7/5.
//  Copyright © 2019 AK.ios. All rights reserved.
//

#import "ESRacSubject.h"



@interface ESRacSubject ()

/**
 subject
 */
@property (nonatomic, strong) RACSubject *subject;

/**
 next
 */
@property (nonatomic, copy) void (^next)(id _Nonnull);


/**
 error
 */
@property (nonatomic, copy) void (^error)(NSError * _Nullable error);

/**
 completed
 */
@property (nonatomic, copy) void (^complet)(void);


@end

@implementation ESRacSubject

- (ESRacSubject *)subscribeNext:(void (^)(id _Nullable x))nextBlock error:(void (^)(NSError * _Nullable error))errorBlock {
    self.next = nextBlock;
    self.error = errorBlock;
    return self;
}

- (void)sendNext:(id)value {
    if (!self.next) {
        return;
    }
//    self.subject = [RACSubject subject];
//    [self.subject subscribeNext:self.next];
//    [self.subject sendNext:value];
}

- (void)sendError:(NSError *)error {
    if (!self.error) {
        return;
    }
//    self.subject = [RACSubject subject];
//    [self.subject subscribeError:self.error];
//    [self.subject sendError:error];
}

@end
