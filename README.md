MEBSimpleORM
============

A very simple object mapper for ingesting JSON Feeds and converting them into strongly typed objects.

Current limitations:

1. Really, overly simple at times.
2. Haven't integrated networking/downloading of JSON yet.

How To Use
----------

- Import the MEBSimpleORMManager Header

```objective-c
#import "MEBSimpleORMManager.h"
```

- Create a simple Model class (or multiple Models/classes) that subclases MEBSimpleORMModel with appropriate properties.

```objective-c
@interface Person : MEBSimpleORMModel

@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSUInteger age;

@end

@implementation Person

@dynamic firstName;
@dynamic lastName;
@dynamic age;

@end
```
- Create the corresponding JSON feed or source text file.

```javascript
{
  "firstName": "Test",
  "lastName": "User",
  "age": 50
}
```
- Pass the string into the ORM (or use your favorite JSON parser to convert to an NSDictionary and pass that in) 
and the ORM will return you a strongly type object!

```objective-c

Person *p = [MEBSimpleORMManager modelWithJSONString:string class:[Person class]];
Person *p2 = [MEBSimpleORMManager modelWithJSONObject:dictionary class:[Person class]];
```

That's it!

But that's not all!
-------------------

You can also strongly type properties as other objects, and the ORM will convert them too!

```objective-c

@interface Company : MEBSimpleORMModel

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *address;

@end

@interface Person : MEBSimpleORMModel

@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSUInteger age;
@property (nonatomic, readonly) Company *company;

@end
```
```javascript
{
  "firstName": "Test",
  "lastName": "User",
  "age": 50,
  "company": {
    "name": "My Company",
    "address": "123 Main St"
  }
}
```

And `p.company` will be a strongly typed `Company` object!

But, I have collections, too!
----------------------------

Sure, we can handle those, too! Just name your JSON object the plural of the singular class, and (most of the time)
we'll figure it out.

```objective-c

@interface Role : MEBSimpleORMModel

@property (nonatomic, strong) NSString *roleName;
@property (nonatomic, strong) CGFloat randomFloat;

@end

@interface Person : MEBSimpleORMModel

@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSUInteger age;
@property (nonatomic, readonly) Company *company;
@property (nonatomic, readonly) NSArray *roles;

@end
```
```javascript
{
  "firstName": "Test",
  "lastName": "User",
  "age": 50,
  "company": {
    "name": "My Company",
    "address": "123 Main St"
  },
  "roles": [
    { "name": "Administrator", "randomFloat": 1.2 },
    { "name": "Grand Poobah", "randomFloat": 5.0 }
  ]
}
```

Once you run that through the parser, `p.roles` will be an array of `Role` objects!

Other fun things you can do, and things you should know.
--------------------------------------------------------

- Feel free to set your properties as readonly OR assign/strong! Haven't quite figured out how to do weak, but we'll get
there eventually....

- Numeric primatives are dynamically typed. Because the JSON parser recognizes ALL numbers and bools as NSNumbers, the conversion
to the property type is done dynamically through the getter at runtime. This means you can change the type of a property to
another type dynamically - for example, if you have `@property (readonly) NSUInteger age`, you can simple change your
header delaration to `@property (readonly) CGFloat age;` or `@property (readonly) unsigned long long age;` without changing any of your
feeds.

- Feel free to add methods and other properties to your Model objects - the ORM will only pay attention to properties that
are marked @dynamic.

- If there are objects in the JSON that you don't want to add properties for, you can access them using Objective-C's
keyed subscripting syntax - mymodel[propertyName]. Also really helpful for accessing properties that don't map nicely
to Objective-C's variable naming (such as keys with spaces).

- Because this is really just a wrapper around the parsed JSON objects, you can always access the origin, unparsed data
through the originalJSONData property on MEBSimpleORMModel.

Planned Improvements
--------------------

- Adding an actual demo application!
- Adding networking support for download/parsing in one line.
- Adding support for dynamic setters for non-object types.
- Adding documentation.
- Adding framework exporting
- ~~Support for special property commands (setter, getter).~~
- Support for mapping fields and objects to properties and collections with different names (i.e. children -> array of Person objects).
