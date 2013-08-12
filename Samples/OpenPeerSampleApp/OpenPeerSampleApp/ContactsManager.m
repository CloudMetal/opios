/*
 
 Copyright (c) 2012, SMB Phone Inc.
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

#import "ContactsManager.h"
#import "SessionManager.h"
#import "MessageManager.h"

#import "MainViewController.h"
#import "ContactsTableViewController.h"
#import "OpenPeer.h"
#import "OpenPeerUser.h"
#import "Constants.h"
#import "Utility.h"
#import "SBJsonParser.h"
#import <OpenpeerSDK/HOPIdentityLookup.h>
#import <OpenpeerSDK/HOPIdentityLookupInfo.h>
#import <OpenpeerSDK/HOPIdentity.h>
#import <OpenpeerSDK/HOPAccount.h>
#import <OpenpeerSDK/HOPModelManager.h>
#import <OpenpeerSDK/HOPRolodexContact.h>

@interface ContactsManager ()
{
    NSString* keyJSONContactFirstName;
    NSString* keyJSONContacLastName;
    NSString* keyJSONContactId;
    NSString* keyJSONContactProfession;
    NSString* keyJSONContactPictureURL;
    NSString* keyJSONContactFullName;
}
- (id) initSingleton;

@end
@implementation ContactsManager
@synthesize contactArray = _contactArray;

/**
 Retrieves singleton object of the Contacts Manager.
 @return Singleton object of the Contacts Manager.
 */
+ (id) sharedContactsManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initSingleton];
    });
    return _sharedObject;
}

/**
 Initialize singleton object of the Contacts Manager.
 @return Singleton object of the Contacts Manager.
 */
- (id) initSingleton
{
    self = [super init];
    if (self)
    {
        self.contactArray = [[NSMutableArray alloc] init];
        self.contactsDictionaryByProvider = [[NSMutableDictionary alloc] init];
        self.contactsDictionaryByIndentityURI = [[NSMutableDictionary alloc] init];
        self.contactsDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

/**
 Initiates contacts loading procedure.
 */
- (void) loadContacts
{
    [[[OpenPeer sharedOpenPeer] mainViewController] showContactsTable];
    
    [[[[OpenPeer sharedOpenPeer] mainViewController] contactsTableViewController] onContactsLoadingStarted];
    
    
    NSArray* associatedIdentities = [[HOPAccount sharedAccount] getAssociatedIdentities];
    for (HOPIdentity* identity in associatedIdentities)
    {
        [identity startRolodexDownload:nil];
    }
}

/**
 Check contact identites against openpeer database.
 @param contacts NSArray List of contacts.
 */
- (void) identityLookupForContacts:(NSArray *)contacts identityServiceDomain:(NSString*) identityServiceDomain
{
    HOPIdentityLookup* identityLookup = [[HOPIdentityLookup alloc] initWithDelegate:(id<HOPIdentityLookupDelegate>)[[OpenPeer sharedOpenPeer] identityLookupDelegate] identityLookupInfos:contacts identityServiceDomain:identityServiceDomain];
}

/**
 Handles response received from lookup server. 
 */
-(void)updateContactsWithDataFromLookup:(HOPIdentityLookup *)identityLookup
{
    BOOL refreshContacts = NO;
    NSError* error;
    if ([identityLookup isComplete:&error])
    {
        HOPIdentityLookupResult* result = [identityLookup getLookupResult];
        if ([result wasSuccessful])
        {
            NSArray* identityContacts = [identityLookup getUpdatedIdentities];
            
            refreshContacts = [identityContacts count] > 0 ? YES : NO;
        }
    }
    
    if (refreshContacts)
    {
        [self refreshListOfContacts];
        [[[[OpenPeer sharedOpenPeer] mainViewController] contactsTableViewController] onContactsLoaded];
    }
}



- (void) refreshListOfContacts
{
    NSArray* listOfContacts = [[NSArray alloc] init];
    NSSet* setOfContacts = [[NSSet alloc] init];
    
    for (NSDictionary* dictionaryOfContacts in [self.contactsDictionaryByProvider allValues])
    {
        setOfContacts = [setOfContacts setByAddingObjectsFromArray:[dictionaryOfContacts allValues]];
    }
    
    if ([setOfContacts count] > 0)
    {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                                           initWithKey:@"fullName"
                                                           ascending:YES];
        
        listOfContacts = [[setOfContacts allObjects]
               sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    }
    
    self.contactArray = listOfContacts;
}

- (void)setContactArray:(NSArray *)inContactArray
{
    @synchronized(self)
    {
        _contactArray = [NSArray arrayWithArray:inContactArray];
    }
}
- (NSArray *)contactArray
{
    @synchronized(self)
    {
        return _contactArray;
    }
}
@end
