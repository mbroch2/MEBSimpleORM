//
//  ObjectiveCPropertyDescription.h
//  MEBSimpleORM
//
//  Created by Matthew Brochstein on 1/31/13.
//  Copyright (c) 2013 Matthew Brochstein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef enum {
    ObjectiveCPropertyTypeUnknown = 0,
    ObjectiveCPropertyTypeObject,
    ObjectiveCPropertyTypeChar,
    ObjectiveCPropertyTypeInt,
    ObjectiveCPropertyTypeShort,
    ObjectiveCPropertyTypeLong,
    ObjectiveCPropertyTypeLongLong,
    ObjectiveCPropertyTypeUnsignedChar,
    ObjectiveCPropertyTypeUnsignedInt,
    ObjectiveCPropertyTypeUnsignedShort,
    ObjectiveCPropertyTypeUnsignedLong,
    ObjectiveCPropertyTypeUnsignedLongLong,
    ObjectiveCPropertyTypeFloat,
    ObjectiveCPropertyTypeDouble,
    ObjectiveCPropertyTypeBool,
    ObjectiveCPropertyTypeVoid, // We should never see this
    ObjectiveCPropertyTypeCharacterString,
    ObjectiveCPropertyTypeSelector,
    ObjectiveCPropertyTypeArray,
    ObjectiveCPropertyTypeStruct
} ObjectiveCPropertyType;

typedef enum {
    ObjectiveCPropertyAtomicityAtomic = 0,
    ObjectiveCPropertyAtomicityNonatomic
} ObjectiveCPropertyAtomicity;

@interface ObjectiveCPropertyDescription : NSObject

@property (nonatomic, readonly) ObjectiveCPropertyType type;
@property (nonatomic, readonly) NSString *objectClass;
@property (nonatomic, readonly) BOOL isPointer;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) BOOL isPrimative;
@property (nonatomic, readonly) BOOL isObject;
@property (nonatomic, readonly) BOOL isReadonly;
@property (nonatomic, readonly) ObjectiveCPropertyAtomicity atomicity;
@property (nonatomic, readonly) const char * getterImplementationTypeList;
@property (nonatomic, readonly) const char * setterImplementationTypeList;

+ (id)propertyDescriptionForProperty:(NSString *)propertyName inClass:(Class)c;
- (id)initWithProperty:(objc_property_t)property;

@end
