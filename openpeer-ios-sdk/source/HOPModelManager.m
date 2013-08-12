/*
 
 Copyright (c) 2013, SMB Phone Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are those
 of the authors and should not be interpreted as representing official policies,
 either expressed or implied, of the FreeBSD Project.
 
 */

#import "HOPModelManager.h"
#import "HOPRolodexContact.h"
#import "HOPIdentityContact.h"
#import "HOPIdentityProvider.h"
#import "HOPPublicPeerFile.h"
#import "HOPHomeUser.h"
#import "OpenPeerConstants.h"
#import <CoreData/CoreData.h>

@interface HOPModelManager()

- (id) initSingleton;
- (NSArray*) getResultsForEntity:(NSString*) entityName withPredicateString:(NSString*) predicateString;
@end

@implementation HOPModelManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (id)sharedModelManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initSingleton]; // or some other init method
    });
    return _sharedObject;
}

- (id) initSingleton
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:modelName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *pathDirectory = [libraryPath stringByAppendingPathComponent:databaseDirectory];
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:pathDirectory withIntermediateDirectories:YES attributes:nil error:&error])
    {
        [NSException raise:@"Failed creating directory" format:@"[%@], %@", pathDirectory, error];
    }
    
    NSString *path = [pathDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",databaseName]];
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory


- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Core Data storing

- (void)saveContext
{
    NSError *error = nil;
    if (self.managedObjectContext != nil)
    {
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void) deleteObject:(NSManagedObject*) managedObjectToDelete
{
    [self.managedObjectContext deleteObject:managedObjectToDelete];
}

- (NSManagedObject*) createObjectForEntity:(NSString*) entityName
{
    NSManagedObject* ret = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
    return ret;
}

#pragma mark - Core Data retrieving
- (NSArray*) getResultsForEntity:(NSString*) entityName withPredicateString:(NSString*) predicateString
{
    NSArray* ret = nil;
    
    if ([entityName length] > 0)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        if ([predicateString length] > 0)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
            [fetchRequest setPredicate:predicate];
        }
        
        NSError *error;
        NSArray *fetchedObjects  = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if (!error)
        {
            if([fetchedObjects count] > 0)
            {
                ret = fetchedObjects;
            }
        }
    }
    return ret;
}

- (HOPRolodexContact *) getRolodexContactByIdentityURI:(NSString*) identityURI
{
    HOPRolodexContact* ret = nil;
    
    NSArray* results = [self getResultsForEntity:@"HOPRolodexContact" withPredicateString:[NSString stringWithFormat:@"(identityURI MATCHES '%@')", identityURI]];
    
    if([results count] > 0)
    {
        ret = [results objectAtIndex:0];
    }
    
    return ret;
}

- (NSArray *) getRolodexContactsByPeerURI:(NSString*) peerURI
{
    NSArray* ret = [self getResultsForEntity:@"HOPRolodexContact" withPredicateString:[NSString stringWithFormat:@"(ANY identityContact.peerFile.peerURI MATCHES '%@')", peerURI]];
    
    return ret;
}

- (NSArray*) getAllRolodexContactForHomeUserIdentityURI:(NSString*) homeUserIdentityURI
{
    NSArray* ret = nil;
    NSArray* results = [self getResultsForEntity:@"HOPIdentityProvider" withPredicateString:[NSString stringWithFormat:@"(homeUserIdentityURI MATCHES '%@')",homeUserIdentityURI]];
    
    if([results count] > 0)
    {
        HOPIdentityProvider* identityProvider = [results objectAtIndex:0];
        ret = [identityProvider.rolodexContacts allObjects];
    }
    return ret;
}

- (NSArray*) getRolodexContactsForHomeUserIdentityURI:(NSString*) homeUserIdentityURI openPeerContacts:(BOOL) openPeerContacts
{
    NSArray* ret = nil;
    NSString* stringFormat = nil;
    
    if (openPeerContacts)
    {
        stringFormat = [NSString stringWithFormat:@"(identityContact != nil || identityContact.@count > 0 && identityProvider.homeUserIdentityURI MATCHES '%@')",homeUserIdentityURI];
    }
    else
    {
        stringFormat = [NSString stringWithFormat:@"(identityContact == nil || identityContact.@count == 0 && identityProvider.homeUserIdentityURI MATCHES '%@')",homeUserIdentityURI];
    }
    
    ret = [self getResultsForEntity:@"HOPRolodexContact" withPredicateString:stringFormat];
    
    return ret;
}

- (HOPIdentityContact*) getIdentityContactByStableID:(NSString*) stableID identityURI:(NSString*) identityURI
{
    HOPIdentityContact* ret = nil;
    
    NSArray* results = [self getResultsForEntity:@"HOPIdentityContact" withPredicateString:[NSString stringWithFormat:@"(stableID MATCHES '%@' AND rolodexContact.identityURI MATCHES '%@')", stableID, identityURI]];
    
    if([results count] > 0)
    {
        ret = [results objectAtIndex:0];
    }
    
    return ret;
}

- (HOPPublicPeerFile*) getPublicPeerFileForPeerURI:(NSString*) peerURI
{
    HOPPublicPeerFile* ret = nil;
    
    NSArray* results = [self getResultsForEntity:@"HOPPublicPeerFile" withPredicateString:[NSString stringWithFormat:@"(peerURI MATCHES '%@')", peerURI]];
    
    if([results count] > 0)
    {
        ret = [results objectAtIndex:0];
    }
    
    return ret;
}

- (HOPIdentityProvider *) getIdentityProviderByDomain:(NSString*) identityProviderDomain
{
    HOPIdentityProvider* ret = nil;
    
    NSArray* results = [self getResultsForEntity:@"HOPIdentityProvider" withPredicateString:[NSString stringWithFormat:@"(identityProviderDomain MATCHES '%@')", identityProviderDomain]];
    
    if([results count] > 0)
    {
        ret = [results objectAtIndex:0];
    }
    
    return ret;
}

- (HOPIdentityProvider *) getIdentityProviderByDomain:(NSString*) identityProviderDomain identityName:(NSString*) identityName homeUserIdentityURI:(NSString*) homeUserIdentityURI
{
    HOPIdentityProvider* ret = nil;
    
    NSArray* results = [self getResultsForEntity:@"HOPIdentityProvider" withPredicateString:[NSString stringWithFormat:@"(identityProviderDomain MATCHES '%@' AND name MATCHES '%@' AND homeUserIdentityURI MATCHES '%@')", identityProviderDomain, identityName, homeUserIdentityURI]];
    
    if([results count] > 0)
    {
        ret = [results objectAtIndex:0];
    }
    
    return ret;
}

- (HOPIdentityProvider *) getIdentityProviderByName:(NSString*) name
{
    HOPIdentityProvider* ret = nil;
    
    NSArray* results = [self getResultsForEntity:@"HOPIdentityProvider" withPredicateString:[NSString stringWithFormat:@"(name MATCHES '%@')", name]];
    
    if([results count] > 0)
    {
        ret = [results objectAtIndex:0];
    }
    
    return ret;
}

- (HOPAvatar*) getAvatarByURL:(NSString*) url
{
    HOPAvatar* ret = nil;
    
    NSArray* results = [self getResultsForEntity:@"HOPAvatar" withPredicateString:[NSString stringWithFormat:@"(url MATCHES '%@')", url]];
    
    if([results count] > 0)
    {
        ret = [results objectAtIndex:0];
    }
    
    return ret;
}

- (HOPHomeUser*) getLastLoggedInHomeUser
{
    HOPHomeUser* ret = nil;
    
    NSArray* results = [self getResultsForEntity:@"HOPHomeUser" withPredicateString:@"(loggedIn == YES)"];
    
    if([results count] > 0)
    {
        ret = [results objectAtIndex:0];
    }
    
    return ret;
}

- (HOPHomeUser*) getHomeUserByStableID:(NSString*) stableID
{
    HOPHomeUser* ret = nil;
    
    NSArray* results = [self getResultsForEntity:@"HOPHomeUser" withPredicateString:[NSString stringWithFormat:@"(stableId MATCHES '%@')", stableID]];
    
    if([results count] > 0)
    {
        ret = [results objectAtIndex:0];
    }
    
    return ret;
}

@end
