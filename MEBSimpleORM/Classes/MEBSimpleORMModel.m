//
//  MEBSimpleORMModel.m
//  MEBSimpleORM
//
//  Created by Matthew Brochstein on 1/29/13.
//  Copyright (c) 2013 Matthew Brochstein. All rights reserved.
//

#import "MEBSimpleORMModel.h"
#import "ObjectiveCPropertyDescription.h"
#import <objc/runtime.h>
#import "NSString+ActiveSupportInflector.h"

static NSMutableDictionary *classPropertyCache;

@interface MEBSimpleORMModel ()

@property (nonatomic, strong) id internalData;
@property (nonatomic, readonly) NSArray *classProperties;
@property (nonatomic, readonly) NSDictionary *classPropertyDescriptions;

+ (ObjectiveCPropertyDescription *)propertyDescriptionForSelector:(SEL)aSelector;
+ (BOOL)isSelectorAPropertySetter:(SEL)aSelector;
+ (NSString *)propertyNameFromSetterSelector:(SEL)aSelector;
+ (BOOL)isStringAClassPropertyName:(NSString *)propertyName;
+ (BOOL)isSelectorAPropertyAccessor:(SEL)aSelector;
+ (IMP)getterImplementationForProperty:(ObjectiveCPropertyDescription *)property;
+ (NSArray *)classProperties;
+ (NSDictionary *)classPropertyDescriptions;

- (NSString *)convertPropertySelectorToKeyedSubscript:(SEL)aSelector;
- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;

@end

@implementation MEBSimpleORMModel

#pragma mark - Object Lifecycle

+ (void)initialize
{
    if (self == [MEBSimpleORMModel class]) {
        
        classPropertyCache = [NSMutableDictionary dictionary];
        
    }
}

+ (id)objectFromJSONString:(NSString *)string
{
    if ([[self class] isSubclassOfClass:[MEBSimpleORMModel class]]) {
        
        return [[[self class] alloc] initWithJSONString:string];
        
    }
    return nil;
}

+ (id)objectFromJSONObject:(NSDictionary *)object
{
    if ([[self class] isSubclassOfClass:[MEBSimpleORMModel class]]) {
        
        return [[[self class] alloc] initWithJSONObject:object];
        
    }
    return nil;
}

- (id)init
{
    if ([self class] == [MEBSimpleORMModel class]) {
        [NSException raise:@"com.meb.simpleorm.cannotInstantiateBaseClassException" format:@"You cannot instantiate the MEBSipleORMModel Base Class. Please subclass."];
    }
    return [super init];
}

- (id)initWithJSONString:(NSString *)string
{
    
    // Parse the string into a JSONObject
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    
    if (object && [object isKindOfClass:[NSDictionary class]]) {
        return [self initWithJSONObject:object];
    }
    
    return nil;
    
}

- (id)initWithJSONObject:(NSDictionary *)jsonObject
{
    
    self = [self init];
    if (self) {
        
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            if (![jsonObject isKindOfClass:[NSMutableDictionary class]]) {
                jsonObject = [NSMutableDictionary dictionaryWithDictionary:jsonObject];
            }
        }
        else {
            jsonObject = nil;
        }
        
        if (jsonObject) {
            self.internalData = jsonObject;
        }

    }
    return self;
}

#pragma mark - NSObject Methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ - %@", NSStringFromClass([self class]), self.internalData];
}

#pragma mark - Private Methods

+ (BOOL)isStringAClassPropertyName:(NSString *)propertyName
{
    
    NSArray *classProperties = [self classProperties];
    
    return ([classProperties indexOfObjectPassingTest:^BOOL(NSString *property, NSUInteger idx, BOOL *stop) {
        BOOL propertyFound = [property isEqualToString:propertyName];
        if (propertyFound) {
            *stop = YES;
            return YES;
        }
        return NO;
    }] != NSNotFound);
    
}

+ (ObjectiveCPropertyDescription *)propertyDescriptionForSelector:(SEL)aSelector
{
    
    NSString *selector = NSStringFromSelector(aSelector);
    
    __block ObjectiveCPropertyDescription *propertyDescription = nil;
    
    // Check getters
    [[self classPropertyDescriptions] enumerateKeysAndObjectsUsingBlock:^(NSString *property, ObjectiveCPropertyDescription *description, BOOL *stop) {
        
        if ([property isEqual:selector] || aSelector == description.getter || aSelector == description.setter) {

            propertyDescription = description;
            
            *stop = YES;
            
        }
        
    }];
    
    if (propertyDescription) return propertyDescription;
    
    return nil;
    
}

+ (BOOL)isSelectorAPropertySetter:(SEL)aSelector
{

    NSString *propertyName = [self propertyNameFromSetterSelector:aSelector];
    
    __block BOOL found = NO;
    
    [[self classPropertyDescriptions] enumerateKeysAndObjectsUsingBlock:^(NSString *property, ObjectiveCPropertyDescription *description, BOOL *stop) {
        
        if ([property isEqual:propertyName]) {
            
            found = YES;
            *stop = YES;
            
        }
        else if (aSelector == description.setter) {
            
            found = YES;
            *stop = YES;
            
        }
        
    }];
    
    return found;
    
}

+ (BOOL)isSelectorAPropertyAccessor:(SEL)aSelector
{
    
    NSString *selector = NSStringFromSelector(aSelector);
    
    __block BOOL found = NO;

    [[self classPropertyDescriptions] enumerateKeysAndObjectsUsingBlock:^(NSString *property, ObjectiveCPropertyDescription *description, BOOL *stop) {
        
        if ([property isEqual:selector]) {
            
            found = YES;
            *stop = YES;
            
        }
        else if (aSelector == description.getter) {
            
            found = YES;
            *stop = YES;
            
        }
        
    }];
    
    return found;
    
}

- (NSString *)convertPropertySelectorToKeyedSubscript:(SEL)aSelector
{
    return NSStringFromSelector(aSelector);
}

- (NSString *)setterSelectorStringForPropertyName:(NSString *)propertyName
{
    NSString *camelCasedProperty = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[propertyName substringWithRange:NSMakeRange(0, 1)] uppercaseString]];
    return [NSString stringWithFormat:@"set%@:", camelCasedProperty];
}

+ (NSString *)propertyNameFromSetterSelector:(SEL)aSelector
{
    
    NSString *selector = NSStringFromSelector(aSelector);
    
    // Make sure this is a setter
    if (selector.length <= 3) return nil;
    if (![[selector substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"set"]) return nil;
    if (![[selector substringWithRange:NSMakeRange(selector.length-1, 1)] isEqualToString:@":"]) return nil;
    
    NSString *potentialPropertyName = [selector substringWithRange:NSMakeRange(3, selector.length - 4)];
    
    // Make sure the first character is lowercase
    NSString *propertyName = [potentialPropertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[potentialPropertyName substringWithRange:NSMakeRange(0, 1)] lowercaseString]];
    
    return propertyName;
    
}

- (NSArray *)classProperties
{
    return [[self class] classProperties];
}

- (NSDictionary *)classPropertyDescriptions
{
    return [[self class] classPropertyDescriptions];
}

+ (NSDictionary *)classPropertyDescriptions
{

    NSString *key = NSStringFromClass([self class]);
    
    if (classPropertyCache[key] == nil) {
    
        NSMutableDictionary *propertyDescriptions = [NSMutableDictionary dictionary];
        
        unsigned int propertyCount, i;
        
        objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
        
        for (i = 0; i < propertyCount; i++) {
            
            objc_property_t property = propertyList[i];
            
            ObjectiveCPropertyDescription *propertyDescription = [[ObjectiveCPropertyDescription alloc] initWithProperty:property];
            
            [propertyDescriptions setValue:propertyDescription forKey:propertyDescription.name];
            
        }
        
        free(propertyList);
        
        classPropertyCache[key] = propertyDescriptions;
        
    }
    
    return classPropertyCache[key];
}

+ (NSArray *)classProperties
{
    
    return [[self classPropertyDescriptions] allKeys];
    
}

#pragma mark - Generic Method Handling

+ (BOOL)resolveInstanceMethod:(SEL)sel
{

    if ([self isSelectorAPropertyAccessor:sel]) {
        
        ObjectiveCPropertyDescription *property = [self propertyDescriptionForSelector:sel];
        
        IMP imp = [self getterImplementationForProperty:property];
        
        if (imp) {
        
            class_addMethod([self class], sel, imp, property.getterImplementationTypeList);
            return YES;
            
        }
        
        return NO;

    }
    else if ([self isSelectorAPropertySetter:sel]) {
        
        ObjectiveCPropertyDescription *property = [self propertyDescriptionForSelector:sel];
        
        if (!property.isReadonly) {
            
            IMP imp = [self setterImplementationForProperty:property];
            
            if (imp) {
                
                class_addMethod([self class], sel, imp, property.setterImplementationTypeList);
                return YES;
                
            }
            
            return NO;
            
            
        }
        else {
            
            return [super resolveInstanceMethod:sel];
            
        }
 
    }
    return [super resolveInstanceMethod:sel];

}

+ (IMP)setterImplementationForProperty:(ObjectiveCPropertyDescription *)property
{
    IMP imp = NULL;
    
    switch (property.type) {
        case ObjectiveCPropertyTypeBool:
        case ObjectiveCPropertyTypeInt:
        case ObjectiveCPropertyTypeUnsignedInt:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me, int value) { me.internalData[property.name] = @(value); });
            break;
        }
            
        case ObjectiveCPropertyTypeFloat:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me, float value) { me.internalData[property.name] = @(value); });
            break;
        }
            
        case ObjectiveCPropertyTypeDouble:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me, double value) { me.internalData[property.name] = @(value); });
            break;
        }
            
        case ObjectiveCPropertyTypeLong:
        case ObjectiveCPropertyTypeUnsignedLong:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me, long value) { me.internalData[property.name] = @(value); });
            break;
        }
            
        case ObjectiveCPropertyTypeLongLong:
        case ObjectiveCPropertyTypeUnsignedLongLong:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me, long long value) { me.internalData[property.name] = @(value); });
            break;
        }
            
        case ObjectiveCPropertyTypeShort:
        case ObjectiveCPropertyTypeUnsignedShort:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me, short value) { me.internalData[property.name] = @(value); });
            break;
        }
            
        case ObjectiveCPropertyTypeChar:
        case ObjectiveCPropertyTypeUnsignedChar:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me, char value) { me.internalData[property.name] = @(value); });
            break;
        }
            
        case ObjectiveCPropertyTypeSelector:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me, SEL value) { me.internalData[property.name] = NSStringFromSelector(value); });
            break;
        }
            
        case ObjectiveCPropertyTypeCharacterString:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me, const char * value) { me.internalData[property.name] = [NSString stringWithCString:value encoding:NSUTF8StringEncoding]; });
            break;
        }
            
        case ObjectiveCPropertyTypeObject:
        case ObjectiveCPropertyTypeArray:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me, id value) { me.internalData[property.name] = value; });
            break;
        }
            
        case ObjectiveCPropertyTypeStruct:
        case ObjectiveCPropertyTypeUnknown:
        case ObjectiveCPropertyTypeVoid:
        default:
            break;
    }
    
    return imp;
}

+ (IMP)getterImplementationForProperty:(ObjectiveCPropertyDescription *)property
{
    
    IMP imp = NULL;
    
    switch (property.type) {
            
        case ObjectiveCPropertyTypeInt:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me) { return [me.internalData[property.name] intValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeUnsignedInt:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me) { return [me.internalData[property.name] unsignedIntValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeFloat: {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me) { return [me.internalData[property.name] floatValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeDouble:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me) { return [me.internalData[property.name] doubleValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeChar:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me) { return [me.internalData[property.name] charValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeUnsignedChar:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me) { return [me.internalData[property.name] unsignedCharValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeBool:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me) { return [me.internalData[property.name] boolValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeLong:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me) { return [me.internalData[property.name] longValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeUnsignedLong:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me) { return [me.internalData[property.name] unsignedLongValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeShort:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me) { return [me.internalData[property.name] shortValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeUnsignedShort:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me) { return [me.internalData[property.name] unsignedShortValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeLongLong:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me) { return [me.internalData[property.name] longLongValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeUnsignedLongLong:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me) { return [me.internalData[property.name] unsignedLongLongValue]; });
            break;
        }
            
        case ObjectiveCPropertyTypeSelector:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me) { return NSSelectorFromString(me.internalData[property.name]); });
            break;
        }
            
        case ObjectiveCPropertyTypeObject:
        {
            
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me) {
                
                // Check to see if this is an object that we have a definition for
                Class c = NSClassFromString(property.objectClass);
                
                if (c && [c isSubclassOfClass:[MEBSimpleORMModel class]]) {
                    
                    id value = me.internalData[property.name];
                    
                    if ([value isKindOfClass:c]) {
                        return value;
                    }
                    else {
                    
                        id parsedObject = [c objectFromJSONObject:value];
                        
                        if (parsedObject) {
                            
                            [me.internalData setObject:parsedObject forKeyedSubscript:property.name];
                            return parsedObject;
                            
                        }
                        else {
                            
                            return value;
                            
                        }
                        
                    }
                    
                }
                else if ((c == [NSArray class] || [c isSubclassOfClass:[NSArray class]])) {
                    
                    
                    Class collectionModel = [me modelClassForCollectionProperty:property.name];
                    
                    if (!collectionModel) {
                        collectionModel = [self singularClassNameFromPluralPropertyName:property.name];
                    }
                    
                    if (collectionModel) {
                    
                        NSArray *arrayData = me.internalData[property.name];
                        __block NSMutableArray *arrayObjects = [NSMutableArray array];
                    
                        [arrayData enumerateObjectsUsingBlock:^(NSDictionary *objectData, NSUInteger idx, BOOL *stop) {
                            
                            id parsedObject = [c objectFromJSONObject:objectData];
                            
                            if (parsedObject) {
                                [arrayObjects addObject:parsedObject];
                            }
                            
                        }];
                        
                        if (arrayObjects && arrayObjects.count) {
                            
                            [me.internalData setObject:arrayObjects forKeyedSubscript:property.name];
                            return (id)[NSArray arrayWithArray:arrayObjects];
                            
                        }
                        else {

                            return me.internalData[property.name];
                            
                        }
                        
                    }
                    
                    return me.internalData[property.name];
                    
                }
                else {
                
                    return me.internalData[property.name];
                    
                }
            
            });
            break;
        }
            
        case ObjectiveCPropertyTypeCharacterString:
        {
            imp = imp_implementationWithBlock(^(MEBSimpleORMModel *me) { return [me.internalData[property.name] cStringUsingEncoding:NSUTF8StringEncoding]; });
            break;
        }
            
        case ObjectiveCPropertyTypeUnknown:
        case ObjectiveCPropertyTypeVoid:
        case ObjectiveCPropertyTypeStruct:
        default:
            break;
            
    }
    
    return imp;
}

+ (Class)singularClassNameFromPluralPropertyName:(NSString *)property
{
 
    NSString *singular = property.singularizeString;
    
    Class c = NSClassFromString(singular.capitalizedString);
    
    if (c) return c;
    
    return nil;
    
}

- (id)objectForKeyedSubscript:(id)key
{
    if ([self.internalData respondsToSelector:@selector(objectForKeyedSubscript:)]) {
        return self.internalData[key];
    }
    return nil;
}

- (id)objectAtIndexedSubscript:(NSInteger)index
{
    if ([self.internalData respondsToSelector:@selector(objectAtIndexedSubscript:)]) {
        return self.internalData[index];
    }
    return nil;
}

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key
{
    if ([self.internalData respondsToSelector:@selector(setObject:forKeyedSubscript:)]) {
        [self.internalData setObject:object forKeyedSubscript:key];
    }
}

- (Class)modelClassForCollectionProperty:(NSString *)propertyName
{
    return nil;
}

#pragma mark - Internal Data

- (id)originalJSONData
{
    return _internalData;
}

@end
