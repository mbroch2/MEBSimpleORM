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

- (void)modelFromURL:(NSURL *)url rootClass:(__unsafe_unretained Class)rootClass completion:(MEBSimpleORMManagerCompletionBlock)completionBlock error:(MEBSimpleORMManagerErrorBlock)errorBlock
{

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [self modelWithRequest:request rootClass:rootClass completion:completionBlock error:errorBlock];
    
}

- (void)modelWithRequest:(NSURLRequest *)request rootClass:(__unsafe_unretained Class)rootClass completion:(MEBSimpleORMManagerCompletionBlock)completionBlock error:(MEBSimpleORMManagerErrorBlock)errorBlock
{

    [NSURLConnection sendAsynchronousRequest:request queue:self.requestQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error == nil) {
  
            if (errorBlock) errorBlock(error);
            
        }
        else {
            
            // Take the data and convert it into a string
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            if (responseString) {
                
                id object = [self modelWithJSONString:responseString andRootClass:rootClass];
                
                if (object) {
                    
                    if (completionBlock) completionBlock(object);
                    
                }
                else {
                    
                    // We need to create an error
                    
                    if (errorBlock) errorBlock(error);
                    
                }
                
            }
            else {
            
                // Encoding or parsing error
                
                if (errorBlock) errorBlock(error);
                
            }
            
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
