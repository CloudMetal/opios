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

#import "HOPAccount_Internal.h"
#import "HOPIdentity_Internal.h"

#import "OpenPeerStorageManager.h"

#import <hookflash/core/IAccount.h>
#import <hookflash/core/IContact.h>
#import <hookflash/core/IIdentity.h>
#import <hookflash/core/IHelper.h>

using namespace hookflash;
using namespace hookflash::core;

@implementation HOPAccountState

@end

@implementation HOPAccount

+ (id)sharedAccount
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.dictionaryOfIdentities = [[NSMutableDictionary alloc] init];
    }
    return self;
}



//- (BOOL) loginWithAccountDelegate:(id<HOPAccountDelegate>) inAccountDelegate conversationThreadDelegate:(id<HOPConversationThreadDelegate>) inConversationThreadDelegate callDelegate:(id<HOPCallDelegate>) inCallDelegate peerContactServiceDomain:(NSString*) inPeerContactServiceDomain identity:(HOPIdentity*) inIdentity
- (BOOL) loginWithAccountDelegate:(id<HOPAccountDelegate>) inAccountDelegate conversationThreadDelegate:(id<HOPConversationThreadDelegate>) inConversationThreadDelegate callDelegate:(id<HOPCallDelegate>) inCallDelegate namespaceGrantOuterFrameURLUponReload:(NSString*) namespaceGrantOuterFrameURLUponReload  grantID:(NSString*) grantID lockboxServiceDomain:(NSString*) lockboxServiceDomain forceCreateNewLockboxAccount:(BOOL) forceCreateNewLockboxAccount
{
    BOOL passedWithoutErrors = NO;
    
    if (!inAccountDelegate || !inConversationThreadDelegate || !inCallDelegate || [namespaceGrantOuterFrameURLUponReload length] == 0 || [grantID length] == 0  || [lockboxServiceDomain length] == 0 )
        return passedWithoutErrors;
    
    if (accountPtr)
        accountPtr->shutdown();
    
    [self setLocalDelegates:inAccountDelegate conversationThread:inConversationThreadDelegate callDelegate:inCallDelegate];
    
    accountPtr = IAccount::login(openpeerAccountDelegatePtr, openpeerConversationDelegatePtr, openpeerCallDelegatePtr, [namespaceGrantOuterFrameURLUponReload UTF8String], [grantID UTF8String], [lockboxServiceDomain UTF8String], forceCreateNewLockboxAccount);
    
    if (accountPtr)
        passedWithoutErrors = YES;
    
    return passedWithoutErrors;
}


- (BOOL)reloginWithAccountDelegate:(id<HOPAccountDelegate>)inAccountDelegate conversationThreadDelegate:(id<HOPConversationThreadDelegate>)inConversationThreadDelegate callDelegate:(id<HOPCallDelegate>)inCallDelegate lockboxOuterFrameURLUponReload:(NSString *)lockboxOuterFrameURLUponReload lockboxReloginInfo:(NSString *)lockboxReloginInfo
{
    BOOL passedWithoutErrors = NO;
    
    if (!inAccountDelegate || !inConversationThreadDelegate || !inCallDelegate || [lockboxOuterFrameURLUponReload length] == 0 || [lockboxReloginInfo length] == 0)
        return passedWithoutErrors;
    
    [self setLocalDelegates:inAccountDelegate conversationThread:inConversationThreadDelegate callDelegate:inCallDelegate];
    
    
    
    //TODO: For relogin create an xml with domain,    accountID, reloginInformation,keyIdentityHalf,keyLockboxHalf 
    accountPtr = IAccount::relogin(openpeerAccountDelegatePtr, openpeerConversationDelegatePtr, openpeerCallDelegatePtr, [lockboxOuterFrameURLUponReload UTF8String],IHelper::createFromString([lockboxReloginInfo UTF8String]));
    
    if (accountPtr)
        passedWithoutErrors = YES;
    
    return passedWithoutErrors;
}

- (HOPAccountState*) getState
{
    HOPAccountState* ret = nil;
    
    if(accountPtr)
    {
        ret = [[HOPAccountState alloc] init];
        WORD errorCode;
        String errorReason;
        ret.state  = (HOPAccountStates) accountPtr->getState(&errorCode, &errorReason);
        ret.errorCode = errorCode;
        ret.errorReason = [NSString stringWithUTF8String:errorReason];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid account object!"];
    }
    
    return ret;
}

//- (NSString*) getUserID
//{
//    NSString* ret = nil;
//    
//    if(accountPtr)
//    {
//        ret = [NSString stringWithUTF8String: accountPtr->getUserID()];
//    }
//    else
//    {
//        [NSException raise:NSInvalidArgumentException format:@"Invalid account object!"];
//    }
//    return ret;
//}


- (NSString*) getLocationID
{
    NSString* ret = nil;
    
    if(accountPtr)
    {
        ret = [NSString stringWithUTF8String: accountPtr->getLocationID()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid account object!"];
    }
    return ret;
}


- (void) shutdown
{
    if(accountPtr)
    {
        accountPtr->shutdown();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid account object!"];
    }
}


- (NSString*) getPeerFilePrivate
{
    NSString* xml = nil;
    if(accountPtr)
    {
        zsLib::XML::ElementPtr element = accountPtr->savePeerFilePrivate();
        if (element)
        {
            xml = [NSString stringWithUTF8String: IHelper::convertToString(element)];
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid account object!"];
    }
    return xml;
}


- (NSData*) getPeerFilePrivateSecret
{
    NSData* ret = nil;
    if(accountPtr)
    {
        SecureByteBlockPtr secure = accountPtr->getPeerFilePrivateSecret();
        if (secure)
        {
            byte* secureInBytes = secure->BytePtr();
            int sizeInBytes = secure->SizeInBytes();
            ret = [NSData dataWithBytes:secureInBytes length:sizeInBytes];
            //SecureByteBlock secureByteBlock = secure.;
            //ret = [NSString stringWithUTF8String: IHelper::convertToString(secureByteBlock)];
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid account object!"];
    }
    return ret;
}


- (NSArray*) getAssociatedIdentities
{
    NSMutableArray* array = nil;
    
    if(accountPtr)
    {
        IdentityListPtr associatedIdentities = accountPtr->getAssociatedIdentities();
        
        if (associatedIdentities->size() > 0)
        {
            array = [[NSMutableArray alloc] init];
            for (IdentityList::iterator it = associatedIdentities->begin(); it != associatedIdentities->end(); ++it)
            {
                NSString* identityURI = [NSString stringWithUTF8String: it->get()->getIdentityURI()];
                
                HOPIdentity* identity = [[OpenPeerStorageManager sharedStorageManager] getIdentityForId:identityURI];
                
                //HOP_CHECK: At this moment this identity should be present in the dictionary. Check if this is not the case.
                if (identity)
                    [array addObject:identity];
            }
        }
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid account object!"];
    }
    return array;
}

/*
- (void) associateIdentities:(NSArray*) inIdentitiesToAssociate identitiesToRemove:(NSArray*) inIdentitiesToRemove
{
    IdentityList identitiesToAssociate;
    IdentityList identitiesToRemove;
    
    if ([inIdentitiesToAssociate count] > 0)
    {
        for (HOPIdentity* identity in inIdentitiesToAssociate)
        {
            if ([identity getIdentityPtr])
            {
                identitiesToAssociate.push_back([identity getIdentityPtr]);
            }
        }
    }
    
    if ([inIdentitiesToRemove count] > 0)
    {
        for (HOPIdentity* identity in inIdentitiesToRemove)
        {
            if ([identity getIdentityPtr])
            {
                identitiesToRemove.push_back([identity getIdentityPtr]);
            }
        }
    }
    
    [self getAccountPtr]->associateIdentities(identitiesToAssociate, identitiesToRemove);
}*/

+ (NSString*) stateToString:(HOPAccountStates) state
{
    return [NSString stringWithUTF8String: IAccount::toString((IAccount::AccountStates) state)];
}

- (NSString *)description
{
    NSString* ret = nil;
    
    if (accountPtr)
        ret = [NSString stringWithUTF8String: IAccount::toDebugString(accountPtr,NO)];
    else
        ret = NSLocalizedString(@"Core account object is not created.", @"Core account object is not created.");
    
    return ret;
}

#pragma mark - Internal methods
- (void)setLocalDelegates:(id<HOPAccountDelegate>)inAccountDelegate conversationThread:(id<HOPConversationThreadDelegate>)inConversationThread callDelegate:(id<HOPCallDelegate>)inCallDelegate
{
    openpeerAccountDelegatePtr = OpenPeerAccountDelegate::create(inAccountDelegate);
    openpeerConversationDelegatePtr = OpenPeerConversationThreadDelegate::create(inConversationThread);
    openpeerCallDelegatePtr = OpenPeerCallDelegate::create(inCallDelegate);
}
- (IAccountPtr) getAccountPtr
{
    return accountPtr;
}
@end
