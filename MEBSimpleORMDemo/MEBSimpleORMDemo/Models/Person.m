//
//  Person.m
//  MEBSimpleORMDemo
//
//  Created by HUGE | Matt Brochstein on 5/20/13.
//  Copyright (c) 2013 Matthew Brochstein. All rights reserved.
//

#import "Person.h"

@implementation Person

@dynamic firstName;

@dynamic lastName;

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", self.givenName, self.lastName];
}

@end
