//
//  MEBSimpleORMManager.m
//  MEBSimpleORM
//
//  Created by Matthew Brochstein on 1/31/13.
//  Copyright (c) 2013 Matthew Brochstein. All rights reserved.
//

#import "MEBSimpleORMManager.h"
#import "AFNetworking.h"

@interface MEBSimpleORMManager ()

@property (nonatomic, strong) NSOperationQueue *requestQueue;

@end

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
    if (self = [super init]) {
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

- (void)modelFromURL:(NSURL *)url completion:(MEBSimpleORMManagerCompletionBlock)completionBlock error:(MEBSimpleORMManagerErrorBlock)errorBlock
{

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self modelWithRequest:request completion:completionBlock error:errorBlock];
    
}

- (void)modelWithRequest:(NSURLRequest *)request completion:(MEBSimpleORMManagerCompletionBlock)completionBlock error:(MEBSimpleORMManagerErrorBlock)errorBlock
{

    [NSURLConnection sendAsynchronousRequest:request queue:self.requestQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error == nil) {
  
        }
        else {
            
            // Take the data and convert it into a string
            
            
        }
        
    }];
    
}

#pragma mark - Setters and Getters

- (NSOperationQueue *)requestQueue
{
    if (!_requestQueue) {
       
        self.requestQueue = [NSOperationQueue new];
        
    }
    return _requestQueue;
}

@end
