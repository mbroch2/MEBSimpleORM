//
//  ObjectiveCPropertyDescription.m
//  MEBSimpleORM
//
//  Created by Matthew Brochstein on 1/31/13.
//  Copyright (c) 2013 Matthew Brochstein. All rights reserved.
//

#import "ObjectiveCPropertyDescription.h"

@interface NSString (ObjectiveCPropertyDescription)

@property (nonatomic, readonly) NSString *firstCharacter;

@end

@interface ObjectiveCPropertyDescription ()

@property (nonatomic, assign) ObjectiveCPropertyAtomicity atomicity;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *attributesDescriptionString;
@property (nonatomic, assign) ObjectiveCPropertyType type;
@property (nonatomic, strong) NSString *objectClass;
@property (nonatomic, strong) NSString *typeCharacter;
@property (nonatomic, assign) SEL getter;
@property (nonatomic, assign) SEL setter;
@property (nonatomic, assign) BOOL isReadonly;
@property (nonatomic, assign) BOOL isCopy;
@property (nonatomic, assign) BOOL isRetain;

- (void)checkForGetterAndSetterDefinitions;
- (NSString *)objectTypeFromAttributeString;
- (void)parseAttributeDescriptionString;
- (void)setPropertyTypeWithTypeString:(NSString *)typeString;

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

    self = [super init];
    if (self) {
        
        self.name = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        self.attributesDescriptionString = [NSString stringWithCString:attributes encoding:NSUTF8StringEncoding];
        
        // [self inferTypeFromAttributeDescription];
        
        [self parseAttributeDescriptionString];

    }
    return self;
    
}

- (void)dealloc
{
    self.typeCharacter = nil;
    self.objectClass = nil;
    self.name = nil;
}


#pragma mark - Private Methods

- (void)setPropertyTypeWithTypeString:(NSString *)typeString
{
    
    if (typeString && typeString.length > 0) {

        NSString *firstCharacter = [typeString substringWithRange:NSMakeRange(0, 1)];

        // Handle the primative types
        if ([firstCharacter isEqualToString:@"i"]) {
            self.type = ObjectiveCPropertyTypeInt;
        }
        else if ([firstCharacter isEqualToString:@"I"]) {
            self.type = ObjectiveCPropertyTypeUnsignedInt;
        }
        else if ([firstCharacter isEqualToString:@"c"]) {
            self.type = ObjectiveCPropertyTypeChar;
        }
        else if ([firstCharacter isEqualToString:@"C"]) {
            self.type = ObjectiveCPropertyTypeUnsignedChar;
        }
        else if ([firstCharacter isEqualToString:@"l"]) {
            self.type = ObjectiveCPropertyTypeLong;
        }
        else if ([firstCharacter isEqualToString:@"L"]) {
            self.type = ObjectiveCPropertyTypeUnsignedLong;
        }
        else if ([firstCharacter isEqualToString:@"q"]) {
            self.type = ObjectiveCPropertyTypeLongLong;
        }
        else if ([firstCharacter isEqualToString:@"Q"]) {
            self.type = ObjectiveCPropertyTypeUnsignedLongLong;
        }
        else if ([firstCharacter isEqualToString:@"s"]) {
            self.type = ObjectiveCPropertyTypeShort;
        }
        else if ([firstCharacter isEqualToString:@"S"]) {
            self.type = ObjectiveCPropertyTypeUnsignedShort;
        }
        else if ([firstCharacter isEqualToString:@"d"]) {
            self.type = ObjectiveCPropertyTypeDouble;
        }
        else if ([firstCharacter isEqualToString:@"f"]) {
            self.type = ObjectiveCPropertyTypeFloat;
        }
        else if ([firstCharacter isEqualToString:@"{"]) {
            
            self.type = ObjectiveCPropertyTypeStruct;
            
        }
        else if ([firstCharacter isEqualToString:@"@"]) {
            
            self.type = ObjectiveCPropertyTypeObject;
            
            self.objectClass = [self objectTypeFromAttributeString];
            
        }
        
    }
    
}

- (void)parseAttributeDescriptionString
{
    
    NSScanner *scanner = [NSScanner scannerWithString:self.attributesDescriptionString];
    
    NSLog(@"Attribute Description: %@", self.attributesDescriptionString);
    
    // All properties must start with a T - if this isn't the case, then we're done
    NSString *buffer = nil;
    
    [scanner scanString:@"T" intoString:&buffer];
    
    if ([buffer isEqualToString:@"T"]) {
        
        // First, let's scan up to the first comma - that defines the type
        NSString *type = nil;
        [scanner scanUpToString:@"," intoString:&type];
        [scanner scanString:@"," intoString:NULL];
        
        [self setPropertyTypeWithTypeString:type];
        
        // Now, let's grab the next tokens, in order.
        
        NSString *currentToken = nil;
        
        BOOL scannedCharacters = YES;
        
        do {
            
            scannedCharacters = [scanner scanUpToString:@"," intoString:&currentToken];
            
            if (scannedCharacters) {
                
                NSString *code = currentToken.firstCharacter;
                
                NSLog(@"Code: %@", code);
            
                [scanner scanString:@"," intoString:NULL];
                
                if ([code isEqual:@"R"]) {
                    
                    self.isReadonly = YES;
                    
                }
                else if ([code isEqual:@"C"]) {
                    
                    self.isCopy = YES;
                    
                }
                else if ([code isEqual:@"&"]) {
                    
                    self.isRetain = YES;
                    
                }
                else if ([code isEqual:@"N"]) {
                    
                    self.atomicity = ObjectiveCPropertyAtomicityNonatomic;
                    
                }
                else if ([code isEqual:@"G"]) {

                    self.getter = NSSelectorFromString([currentToken substringFromIndex:1]);
                    
                }
                else if ([code isEqual:@"S"]) {
                    
                    self.setter = NSSelectorFromString([currentToken substringFromIndex:1]);
                    
                }
        
            }
            
        } while (scannedCharacters);
 
    }

}

- (void)checkForGetterAndSetterDefinitions
{
    
}

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

@implementation NSString (ObjectiveCPropertyDescription)

- (NSString *)firstCharacter
{
    return [self substringWithRange:NSMakeRange(0, 1)];
}

@end
