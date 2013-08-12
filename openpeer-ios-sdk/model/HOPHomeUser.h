//
//  HOPHomeUser.h
//  openpeer-ios-sdk
//
//  Created by Sergej on 8/7/13.
//  Copyright (c) 2013 Hookflash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HOPIdentityProvider;

@interface HOPHomeUser : NSManagedObject

@property (nonatomic, retain) NSString * reloginInfo;
@property (nonatomic, retain) NSString * stableId;
@property (nonatomic, retain) NSNumber * loggedIn;
@property (nonatomic, retain) NSSet *identityProviders;
@end

@interface HOPHomeUser (CoreDataGeneratedAccessors)

- (void)addIdentityProvidersObject:(HOPIdentityProvider *)value;
- (void)removeIdentityProvidersObject:(HOPIdentityProvider *)value;
- (void)addIdentityProviders:(NSSet *)values;
- (void)removeIdentityProviders:(NSSet *)values;

@end
