//
//  Person.h
//  MEBSimpleORMDemo
//
//  Created by HUGE | Matt Brochstein on 5/20/13.
//  Copyright (c) 2013 Matthew Brochstein. All rights reserved.
//

#import "MEBSimpleORMModel.h"

@interface Person : MEBSimpleORMModel

@property (nonatomic, strong, getter = givenName, setter = setGivenName:) NSString *firstName;

@property (nonatomic, strong, getter = familyName, setter = setFamilyName:) NSString *lastName;

@end
