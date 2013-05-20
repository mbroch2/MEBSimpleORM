//
//  MEBSimpleORMManager.m
//  MEBSimpleORM
//
//  Created by Matthew Brochstein on 1/31/13.
//  Copyright (c) 2013 Matthew Brochstein. All rights reserved.
//

#import "MEBSimpleORMManager.h"

@implementation MEBSimpleORMManager

#pragma mark - Singleton Lifecycle (per Apple docs)

+ (MEBSimpleORMManager *)sharedInstance
{
    static dispatch_once_t pred;
    static MEBSimpleORMManager *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[MEBSimpleORMManager alloc] init];
    });
    return shared;
}

- (id)init
{
    if (self = [super init])
    {
        // Do additional initialization here
    }
    return self;
}

- (MEBSimpleORMModel *)modelWithJSONObject:(NSDictionary *)dictionary andRootClass:(Class)rootClass
{
    return [rootClass objectFromJSONObject:dictionary];
}

- (MEBSimpleORMModel *)modelWithJSONString:(NSString *)string andRootClass:(Class)rootClass
{
    return [rootClass objectFromJSONString:string];
}

- (MEBSimpleORMModel *)modelFromURL:(NSURL *)url completion:(MEBSimpleORMManagerCompletionBlock)completionBlock error:(MEBSimpleORMManagerErrorBlock)errorBlock
{
    return nil;
}

- (MEBSimpleORMModel *)modelWithRequest:(NSURLRequest *)request completion:(MEBSimpleORMManagerCompletionBlock)completionBlock error:(MEBSimpleORMManagerErrorBlock)errorBlock
{
    return nil;
}

@end
