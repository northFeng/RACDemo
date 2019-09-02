//
//  ESRacSubject.h
//  esReadStudent
//
//  Created by edz on 2019/7/5.
//  Copyright © 2019 AK.ios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/RACReturnSignal.h>

NS_ASSUME_NONNULL_BEGIN

@interface ESRacSubject : NSObject

- (ESRacSubject *)subscribeNext:(void (^)(id _Nullable x))nextBlock error:(void (^)(NSError * _Nullable error))errorBlock;

- (void)sendNext:(id)value;

- (void)sendError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
