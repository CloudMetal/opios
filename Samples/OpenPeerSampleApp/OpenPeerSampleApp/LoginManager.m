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

#import "LoginManager.h"


#import "OpenPeer.h"
#import "OpenPeerUser.h"
//Utility
#import "XMLWriter.h"
#import "Utility.h"
#import "Constants.h"
//Managers
#import "ContactsManager.h"
//SDK
#import <OpenPeerSDK/HOPAccount.h>
#import <OpenPeerSDK/HOPIdentity.h>
#import <OpenPeerSDK/HOPTypes.h>
#import <OpenpeerSDK/HOPHomeUser.h>
#import <OpenpeerSDK/HOPModelManager.h>
//Delegates
#import "StackDelegate.h"
//View Controllers
#import "MainViewController.h"
#import "LoginViewController.h"
#import "ActivityIndicatorViewController.h"
#import "WebLoginViewController.h"

@interface LoginManager ()

@property (nonatomic) BOOL isLogin;
@property (nonatomic) BOOL isAssociation;

@property (nonatomic, weak) HOPIdentity* loginIdentity;
@end


@implementation LoginManager

/**
 Retrieves singleton object of the Login Manager.
 @return Singleton object of the Login Manager.
 */
+ (id) sharedLoginManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

/**
 Initialize singleton object of the Login Manager.
 @return Singleton object of the Login Manager.
 */
- (id) init
{
    self = [super init];
    if (self)
    {
        self.isLogin  = NO;
        self.isAssociation = NO;
    }
    return self;
}

/**
 Custom getter for webLoginViewController
 */
- (WebLoginViewController *)webLoginViewController
{
    if (!_webLoginViewController)
    {
        _webLoginViewController = [[WebLoginViewController alloc] init];
        if (_webLoginViewController)
            _webLoginViewController.view.hidden = YES;
    }
    
    return _webLoginViewController;
}

/**
 This method will show login window in case user data does not exists on device, or start relogin automatically if information are available.
 @return Singleton object of the Contacts Manager.
 */
- (void) login
{
    //If peer file doesn't exists, show login view, otherwise start relogin
    if ([[[OpenPeerUser sharedOpenPeerUser] privatePeerFile] length] == 0)
    {
        [[[OpenPeer sharedOpenPeer] mainViewController] showLoginView];
        self.isLogin = YES;
    }
    else
    {
        [self startRelogin];
    }
}

/**
 Logout from the current account.
 */
- (void) logout
{    
    //Delete all cookies.
    [Utility removeCookiesAndClearCredentials];
    
    //Delete user data stored on device.
    [[OpenPeerUser sharedOpenPeerUser] deleteUserData];
    
    //Remove all contacts
    //[[[ContactsManager sharedContactsManager] contactArray] removeAllObjects];
    [[[ContactsManager sharedContactsManager] contactsDictionaryByProvider] removeAllObjects];
    
    //Call to the SDK in order to shutdown Open Peer engine.
    [[HOPAccount sharedAccount] shutdown];
    
    //Return to the login page.
    [[[OpenPeer sharedOpenPeer] mainViewController] showLoginView];
    
}

- (void) startAccount
{
    [[HOPAccount sharedAccount] loginWithAccountDelegate:(id<HOPAccountDelegate>)[[OpenPeer sharedOpenPeer] accountDelegate] conversationThreadDelegate:(id<HOPConversationThreadDelegate>) [[OpenPeer sharedOpenPeer] conversationThreadDelegate]  callDelegate:(id<HOPCallDelegate>) [[OpenPeer sharedOpenPeer] callDelegate]  namespaceGrantOuterFrameURLUponReload:grantOuterFrameURLUponReload grantID:@"Id" lockboxServiceDomain:identityProviderDomain forceCreateNewLockboxAccount:NO];
}
/**
 Starts user login for specific identity URI. Activity indicator is displayed and identity login started.
 @param identityURI NSString identity uri (e.g. identity://facebook.com/)
 */
- (void) startLoginUsingIdentityURI:(NSString*) identityURI
{
    NSLog(@"Identity login started");
    [[ActivityIndicatorViewController sharedActivityIndicator] showActivityIndicator:YES withText:@"Getting identity login url ..." inView:[[[[OpenPeer sharedOpenPeer] mainViewController] loginViewController] view]];
    
    NSString* redirectAfterLoginCompleteURL = [NSString stringWithFormat:@"%@?reload=true",outerFrameURL];

    [self startAccount];
    //For identity login it is required to pass identity delegate, URL that will be requested upon successful login, identity URI and identity provider domain. This is 
    HOPIdentity* hopIdentity = [HOPIdentity loginWithDelegate:(id<HOPIdentityDelegate>)[[OpenPeer sharedOpenPeer] identityDelegate] identityProviderDomain:identityProviderDomain  identityURIOridentityBaseURI:identityURI outerFrameURLUponReload:redirectAfterLoginCompleteURL];
    
    if (!hopIdentity)
        NSLog(@"Identity login failed");
}

/**
 Initiates relogin procedure.
 */
- (void) startRelogin
{
    BOOL reloginStarted = NO;
    NSLog(@"Relogin started");
    [[ActivityIndicatorViewController sharedActivityIndicator] showActivityIndicator:YES withText:@"Relogin ..." inView:[[[OpenPeer sharedOpenPeer] mainViewController] view]];
    
    HOPHomeUser* homeUser = [[HOPModelManager sharedModelManager] getLastLoggedInHomeUser];
    
    if (homeUser && [homeUser.reloginInfo length] > 0)
    {
        //To start relogin procedure it is required to pass account, conversation thread and call delegates. Also, private peer file and secret, received on previous login procedure, are required.
        reloginStarted = [[HOPAccount sharedAccount] reloginWithAccountDelegate:(id<HOPAccountDelegate>) [[OpenPeer sharedOpenPeer] accountDelegate] conversationThreadDelegate:(id<HOPConversationThreadDelegate>)[[OpenPeer sharedOpenPeer] conversationThreadDelegate]  callDelegate:(id<HOPCallDelegate>)[[OpenPeer sharedOpenPeer] callDelegate] lockboxOuterFrameURLUponReload:outerFrameURL reloginInformation:homeUser.reloginInfo];
    }
    
    if (!reloginStarted)
        NSLog(@"Relogin failed");
}

/**
 Handles core event that login URL is available.
 @param url NSString Login URL.
 */
//- (void) onLoginUrlReceived:(NSString*) url forIdentity:(HOPIdentity*) identity
//{
//    self.loginIdentity = identity;
//    
//    //Login url is received. Remove activity indicator
//    [[ActivityIndicatorViewController sharedActivityIndicator] showActivityIndicator:NO withText:nil inView:nil];
//    
//    if ([url length] > 0)
//    {
//        [[ActivityIndicatorViewController sharedActivityIndicator] showActivityIndicator:YES withText:@"Opening login page ..." inView:[[[OpenPeer sharedOpenPeer] mainViewController] view]];
//        //Open identity login web page
//        [self.webLoginViewController openLoginUrl:url];
//    }
//}

/**
 Outer frame of login page is loaded, so it is time now to initiate a inner frame.
 */
//- (void) onOuterFrameLoaded
//{
//    NSString* jsMethod = [NSString stringWithFormat:@"initInnerFrame(\'%@\')",[self.loginIdentity getInnerBrowserWindowFrameURL]];
//    [self.webLoginViewController passMessageToJS:jsMethod];
//}

/**
 Passes JSON message received from core to JS in inner frame in login page.
 @param message NSString JSON message to pass
 */
//- (void) onMessageForJS: (NSString*) message
//{
//  NSString* jsMethod = [NSString stringWithFormat:@"sendNotifyBundleToInnerFrame(\'%@\')", message];
//  [self.webLoginViewController passMessageToJS:jsMethod];
//}

/**
 Handles case when redirection url upon successful login is received.
 */
- (void) onLoginRedirectURLReceived
{
    //Notifies core that redirection URL for completed login is received.
    [self.loginIdentity notifyBrowserWindowClosed];
}

/**
 Makes login web view visible or hidden, depending of input parameter.
 @param isVisible BOOL YES to make web view visible, NO to hide it 
 */
- (void) makeLoginWebViewVisible:(BOOL) isVisible
{
    self.webLoginViewController.view.hidden = !isVisible;
    if (!self.webLoginViewController.view.superview)
    {
        [[[OpenPeer sharedOpenPeer] mainViewController] showWebLoginView:self.webLoginViewController];
        [self.webLoginViewController.view setFrame:[[OpenPeer sharedOpenPeer] mainViewController].view.bounds];
    }
}

/**
 Handles successful identity login event. Adds identity in the list of associated identities and starts account login procedure
 @param identity HOPIdentity identity used for login
 */
- (void) onIdentityLoginFinished:(HOPIdentity*) identity
{
    [[[OpenPeerUser sharedOpenPeerUser] dictionaryIdentities] setObject:[identity getIdentityURI] forKey:[identity identityBaseURI]];
}

/**
 Handles successful identity association. It updates list of associated identities on server side.
 @param identity HOPIdentity identity used for login
 */
- (void) onIdentityAssociationFinished:(HOPIdentity*) identity
{
    
}


/**
 Handles SDK event after login is successful.
 */
- (void) onUserLoggedIn
{
    NSString* uris = @"";
    for (NSString* uri in [[[OpenPeerUser sharedOpenPeerUser] dictionaryIdentities]allValues])
    {
        if ([uris length] == 0)
        {
            uris = uri;
        }
        else
        {
            uris = [uris stringByAppendingFormat:@"%@,",uri];
        }
    }
    NSLog(@"\n ---------- \n%@ is logged in. \nIdentity URIs: %@ \nPeer URI: %@ \n ----------", [[OpenPeerUser sharedOpenPeerUser] fullName],uris,[[OpenPeerUser sharedOpenPeerUser] peerURI]);
    
    //Login finished. Remove activity indicator
    [[ActivityIndicatorViewController sharedActivityIndicator] showActivityIndicator:NO withText:nil inView:nil];
    
    HOPHomeUser* previousLoggedInHomeUser = [[HOPModelManager sharedModelManager] getLastLoggedInHomeUser];
    HOPHomeUser* homeUser = [[HOPModelManager sharedModelManager] getHomeUserByStableID:[[HOPAccount sharedAccount] getStableID]];
    
    if (homeUser)
    {
        if (![homeUser.loggedIn boolValue])
        {
            previousLoggedInHomeUser.loggedIn = NO;
            homeUser.loggedIn = [NSNumber numberWithBool: YES];
            [[HOPModelManager sharedModelManager] saveContext];
        }
    }
    else
    {
        homeUser = (HOPHomeUser*)[[HOPModelManager sharedModelManager] createObjectForEntity:@"HOPModelManager"];
        homeUser.stableId = [[HOPAccount sharedAccount] getStableID];
        homeUser.reloginInfo = [[HOPAccount sharedAccount] getReloginInformation];
        homeUser.loggedIn = [NSNumber numberWithBool: YES];
        if (previousLoggedInHomeUser)
            previousLoggedInHomeUser.loggedIn = NO;
        
        [[HOPModelManager sharedModelManager] saveContext];
    }
    
    
    
    //Save user data on successful login.
    [[OpenPeerUser sharedOpenPeerUser] saveUserData];

    if (self.isLogin)
    {
        self.isLogin = NO;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Identity association" message:@"Do you want to associate another social account" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        
        [alert show];
    }
    else
    {
        //Start loading contacts.
        [[ContactsManager sharedContactsManager] loadContacts];
    }
}

/**
 It passes JSON message from web view to core. This method is invoked from JS.
 @param message NSString JSON message
 */
//- (void) notifyClient:(NSString*) message
//{
//    [self.loginIdentity handleMessageFromInnerBrowserWindowFrame:message];
//}

/**
 Retrieves info if an identity with specified URI is associated or not.
 @param inBaseIdentityURI NSString base identity URI
 @return YES if associated, otherwise NO
 */
- (BOOL) isAssociatedIdentity:(NSString*) inBaseIdentityURI
{
    BOOL ret = [[((OpenPeerUser*)[OpenPeerUser sharedOpenPeerUser]).dictionaryIdentities allKeys] containsObject:inBaseIdentityURI];
    return ret;
}

#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        self.isAssociation = YES;
        [[[OpenPeer sharedOpenPeer] mainViewController] showLoginView];
    }
    else
    {
        [[ContactsManager sharedContactsManager] loadContacts];
    }
}
@end
