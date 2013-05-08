//
//  ObjectiveCPropertyDescription.m
//  MEBSimpleORM
//
//  Created by Matthew Brochstein on 1/31/13.
//  Copyright (c) 2013 Matthew Brochstein. All rights reserved.
//

#import "ObjectiveCPropertyDescription.h"

@interface ObjectiveCPropertyDescription ()

@property (nonatomic, assign) ObjectiveCPropertyAtomicity internalAtomicity;
@property (nonatomic, strong) NSString *internalName;
@property (nonatomic, strong) NSString *attributesDescriptionString;
@property (nonatomic, assign) ObjectiveCPropertyType internalType;
@property (nonatomic, strong) NSString *internalObjectClass;
@property (nonatomic, strong) NSString *typeCharacter;

- (void)inferTypeFromAttributeDescription;
- (NSString *)objectTypeFromAttributeString;

@end

@implementation ObjectiveCPropertyDescription

+ (id)propertyDescriptionForProperty:(NSString *)propertyName inClass:(Class)c
{
    objc_property_t property = class_getProperty(c, [propertyName cStringUsingEncoding:NSUTF8StringEncoding]);
    return [[[self class] alloc] initWithProperty:property];
}

- (id)initWithProperty:(objc_property_t)property
{
    const char *attributes = property_getAttributes(property);
    const char *propertyName = property_getName(property);
    
    // printf("Property Name:%s, attributes=%s\n", propertyName, attributes);

    self = [super init];
    if (self) {
        
        self.internalName = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        self.attributesDescriptionString = [NSString stringWithCString:attributes encoding:NSUTF8StringEncoding];
        
        [self inferTypeFromAttributeDescription];

    }
    return self;
    
}

- (void)dealloc
{
    self.typeCharacter = nil;
    self.internalObjectClass = nil;
    self.internalName = nil;
}

- (void)inferTypeFromAttributeDescription
{
    self.internalType = ObjectiveCPropertyTypeUnknown;
    
    if ([self.attributesDescriptionString rangeOfString:@"@"].location != NSNotFound) {
        
        self.internalType = ObjectiveCPropertyTypeObject;
        
        // Parse out the class and assign it
        self.internalObjectClass = [self objectTypeFromAttributeString];
        
    }
    else {
        
        // Get the second character
        NSString *typeCharacter = [self.attributesDescriptionString substringWithRange:NSMakeRange(1, 1)];
        self.typeCharacter = typeCharacter;
        
        // Handle the primative types
        if ([typeCharacter isEqualToString:@"i"]) {
            self.internalType = ObjectiveCPropertyTypeInt;
        }
        else if ([typeCharacter isEqualToString:@"I"]) {
            self.internalType = ObjectiveCPropertyTypeUnsignedInt;
        }
        else if ([typeCharacter isEqualToString:@"c"]) {
            self.internalType = ObjectiveCPropertyTypeChar;
        }
        else if ([typeCharacter isEqualToString:@"C"]) {
            self.internalType = ObjectiveCPropertyTypeUnsignedChar;
        }
        else if ([typeCharacter isEqualToString:@"l"]) {
            self.internalType = ObjectiveCPropertyTypeLong;
        }
        else if ([typeCharacter isEqualToString:@"L"]) {
            self.internalType = ObjectiveCPropertyTypeUnsignedLong;
        }
        else if ([typeCharacter isEqualToString:@"q"]) {
            self.internalType = ObjectiveCPropertyTypeLongLong;
        }
        else if ([typeCharacter isEqualToString:@"Q"]) {
            self.internalType = ObjectiveCPropertyTypeUnsignedLongLong;
        }
        else if ([typeCharacter isEqualToString:@"s"]) {
            self.internalType = ObjectiveCPropertyTypeShort;
        }
        else if ([typeCharacter isEqualToString:@"S"]) {
            self.internalType = ObjectiveCPropertyTypeUnsignedShort;
        }
        else if ([typeCharacter isEqualToString:@"d"]) {
            self.internalType = ObjectiveCPropertyTypeDouble;
        }
        else if ([typeCharacter isEqualToString:@"f"]) {
            self.internalType = ObjectiveCPropertyTypeFloat;
        }
        else if ([typeCharacter isEqualToString:@"{"]) {
            self.internalType = ObjectiveCPropertyTypeStruct;
        }
    
    }
    
}

#pragma mark - Private Methods

- (NSString *)objectTypeFromAttributeString
{
    
    // Create a scanner for the string
    NSScanner *scanner = [NSScanner scannerWithString:self.attributesDescriptionString];
    [scanner scanUpToString:@"@" intoString:NULL];
    if (scanner.isAtEnd) {
        return nil;
    }
    
    // Eat the @
    [scanner scanString:@"@" intoString:NULL];
    if (scanner.isAtEnd) {
        return @"id";
    }
    
    // Eat the "
    [scanner scanString:@"\"" intoString:NULL];
    
    // Grab the type
    NSString *type = nil;
    [scanner scanUpToString:@"\"" intoString:&type];
    
    // Return
    return type;
    
}

#pragma mark - Internal Properties

- (NSString *)name
{
    return self.internalName;
}

- (ObjectiveCPropertyType)type
{
    return self.internalType;
}

- (BOOL)isPointer
{
    return ([self.attributesDescriptionString rangeOfString:@"^"].location != NSNotFound);
}

- (BOOL)isPrimative
{
    return (self.type != ObjectiveCPropertyTypeObject);
}

- (BOOL)isObject
{
    return (self.type == ObjectiveCPropertyTypeObject);
}

- (BOOL)isReadonly
{
    return ([self.attributesDescriptionString rangeOfString:@",R"].location != NSNotFound);
}

- (NSString *)objectClass
{
    return self.internalObjectClass;
}

- (NSString *)description
{
    
    NSMutableString *description = [NSMutableString stringWithString:self.name];
    [description appendString:@": "];
    
    if (!self.isPrimative) {
        [description appendFormat:@"Object of type %@", self.objectClass];
    }
    else {
        [description appendString:@"Primative of type unknown"];
    }
    
    return description;
    
}

- (const char *)getterImplementationTypeList
{
    return [[NSString stringWithFormat:@"%@@:", self.typeCharacter] cStringUsingEncoding:NSUTF8StringEncoding];
}

- (const char *)setterImplementationTypeList
{
    return [[NSString stringWithFormat:@"v@:%@", self.typeCharacter] cStringUsingEncoding:NSUTF8StringEncoding];
}

@end
