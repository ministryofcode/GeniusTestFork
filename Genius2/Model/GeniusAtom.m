// 
//  GeniusAtom.m
//  Genius2
//
//  Created by John R Chang on 2005-09-24.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "GeniusAtom.h"


NSString * GeniusAtomStringKey = @"string";
NSString * GeniusAtomRTFDDataKey = @"rtfdData";

NSString * GeniusAtomStringRTDDataKey = @"stringRTFDData";
NSString * GeniusAtomDirtyKey = @"dirty";


@implementation GeniusAtom 

#pragma mark <NSCopying>

+ (NSArray *)copyKeys {
    static NSArray *copyKeys = nil;
    if (copyKeys == nil) {
        copyKeys = [[NSArray alloc] initWithObjects:
            GeniusAtomStringKey, GeniusAtomRTFDDataKey, nil];
    }
    return copyKeys;
}

- (NSDictionary *)dictionaryRepresentation
{
    return [self dictionaryWithValuesForKeys:[[self class] copyKeys]];
}

- (id)copyWithZone:(NSZone *)zone
{
	NSManagedObjectContext * context = [self managedObjectContext];
	GeniusAtom * newObject = [[[self class] allocWithZone:zone] initWithEntity:[self entity] insertIntoManagedObjectContext:context];
	[newObject setValuesForKeysWithDictionary:[self dictionaryRepresentation]];
    return newObject;
}


#pragma mark -

+ (NSSet *)userModifiableKeySet {
    static NSSet *userModifiableKeySet = nil;
    if (userModifiableKeySet == nil) {
        userModifiableKeySet = [[NSSet alloc] initWithObjects:
            GeniusAtomStringKey, @"stringRTFDData", nil];
    }
    return userModifiableKeySet;
}

- (void)didChangeValueForKey:(NSString *)key
{
	if ([[GeniusAtom userModifiableKeySet] containsObject:key])
	{
		[self willChangeValueForKey:GeniusAtomDirtyKey];
		[self didChangeValueForKey:GeniusAtomDirtyKey];
	}
	
	[super didChangeValueForKey:key];
}


#pragma mark -

+ (NSDictionary *) defaultTextAttributes
{
	static NSDictionary * sDefaultAttribs = nil;
	if (sDefaultAttribs == nil)
	{
		NSMutableParagraphStyle * parStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		[parStyle setAlignment:NSCenterTextAlignment];

		sDefaultAttribs = [[NSDictionary alloc] initWithObjectsAndKeys:
			[NSFont boldSystemFontOfSize:24.0], NSFontAttributeName,
/*			[NSColor blackColor], NSForegroundColorAttributeName,*/
			parStyle, NSParagraphStyleAttributeName,
			NULL];

		[parStyle release];
	}
	return sDefaultAttribs;
}

+ (BOOL) _isDefaultTextAttributes:(NSDictionary *)attributes
{
	if (attributes == nil)
		return YES;
	if ([attributes count] == 0)
		return YES;
	if ([attributes count] > [[self defaultTextAttributes] count])
		return NO;

	NSEnumerator * keyEnumerator = [attributes keyEnumerator];
	NSString * key;
	while ((key = [keyEnumerator nextObject]))
	{
		id defaultValue = [[self defaultTextAttributes] objectForKey:key];
		if (defaultValue == nil)
			return NO;

		id value = [attributes objectForKey:key];
		if ([defaultValue isEqual:value] == NO)
			return NO;
	}
	return YES;
}

+ (BOOL) _attributedStringUsesDefaultTextAttributes:(NSAttributedString *)attrString
{
	if ([attrString length] > 0)
	{
		NSRange fullRange = NSMakeRange(0, [attrString length]);
		NSRange effectiveRange;
		NSDictionary * attribs = [attrString attributesAtIndex:0 longestEffectiveRange:&effectiveRange inRange:fullRange];
		if ([GeniusAtom _isDefaultTextAttributes:attribs] == NO)
			return NO;

		if (NSEqualRanges(fullRange, effectiveRange) == NO)
			return NO;
	}
	
	return YES;
}

- (BOOL) usesDefaultTextAttributes
{
	NSData * rtfdData = [self primitiveValueForKey:GeniusAtomRTFDDataKey];
	return (rtfdData == nil);
}

- (void)clearTextAttributes
{
	[self willChangeValueForKey:GeniusAtomRTFDDataKey];
	[self setPrimitiveValue:nil forKey:GeniusAtomRTFDDataKey];
	[self didChangeValueForKey:GeniusAtomRTFDDataKey];
}


#pragma mark -

- (void) setStringRTFDData:(NSData *)rtfdData
{
	[self willChangeValueForKey:@"stringRTFDData"];
//	_isImageOnly = NO;

	// rtfdData -> attrString
	NSString * string = nil;
	NSAttributedString * attrString = [[NSAttributedString alloc] initWithRTFD:rtfdData documentAttributes:nil];
	if (attrString)
	{
		// attrString -> string
		string = [attrString string];
		
		// It's plain text
		if ([GeniusAtom _attributedStringUsesDefaultTextAttributes:attrString])
			rtfdData = nil;
	}
	
	//NSLog(@"string=%X, rtfdData=%X", string, rtfdData);

	[self willChangeValueForKey:GeniusAtomRTFDDataKey];
	[self setPrimitiveValue:rtfdData forKey:GeniusAtomRTFDDataKey];
	[self didChangeValueForKey:GeniusAtomRTFDDataKey];
	
	[self willChangeValueForKey:GeniusAtomStringKey];
	[self setPrimitiveValue:string forKey:GeniusAtomStringKey];
	[self didChangeValueForKey:GeniusAtomStringKey];

	[self didChangeValueForKey:@"stringRTFDData"];
}


- (NSData *) stringRTFDData	// falls back to string
{
	[self willAccessValueForKey:GeniusAtomRTFDDataKey];
	NSData * rtfdData = [self primitiveValueForKey:GeniusAtomRTFDDataKey];	
	if (rtfdData == nil)
	{
		NSString * string = [self primitiveValueForKey:GeniusAtomStringKey];
		if (string)
		{
			// string -> rtfdData
			NSAttributedString * attrString = [[[NSAttributedString alloc] initWithString:string attributes:[GeniusAtom defaultTextAttributes]] autorelease];
			if (attrString)
			{
				NSRange range = NSMakeRange(0, [attrString length]);
				rtfdData = [attrString RTFDFromRange:range documentAttributes:nil];
			}
		}
	}
	[self didAccessValueForKey:GeniusAtomRTFDDataKey];
	return rtfdData;
}

@end