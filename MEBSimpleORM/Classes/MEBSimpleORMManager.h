//
//  MEBSimpleORMManager.h
//  MEBSimpleORM
//
//  Created by Matthew Brochstein on 1/31/13.
//  Copyright (c) 2013 Matthew Brochstein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEBSimpleORMModel.h"

typedef void (^MEBSimpleORMManagerCompletionBlock)(MEBSimpleORMModel *parsedObject);
typedef void (^MEBSimpleORMManagerErrorBlock)(NSError *error);

@interface MEBSimpleORMManager : NSObject

+ (id)sharedInstance;

- (void)modelWithRequest:(NSURLRequest *)request rootClass:(Class)rootClass completion:(MEBSimpleORMManagerCompletionBlock)completionBlock error:(MEBSimpleORMManagerErrorBlock)errorBlock;
- (void)modelFromURL:(NSURL *)url rootClass:(Class)rootClass completion:(MEBSimpleORMManagerCompletionBlock)completionBlock error:(MEBSimpleORMManagerErrorBlock)errorBlock;
- (MEBSimpleORMModel *)modelWithJSONObject:(NSDictionary *)dictionary andRootClass:(Class)rootClass;
- (MEBSimpleORMModel *)modelWithJSONString:(NSString *)string andRootClass:(Class)rootClass;

@end
