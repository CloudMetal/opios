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

#import "MainViewController.h"
#import "OpenPeer.h"
#import "OpenPeerUser.h"
#import "Constants.h"
//SDK
#import <OpenpeerSDK/HOPConversationThread.h>
//Managers
#import "SessionManager.h"
#import "LoginManager.h"
#import "ContactsManager.h"
#import "MessageManager.h"
//Model
#import "Session.h"
//View controllers
#import "LoginViewController.h"
#import "WebLoginViewController.h"
#import "ContactsTableViewController.h"
#import "ActiveSessionViewController.h"
#import "MainViewController.h"
#import "ChatViewController.h"

//Private methods
@interface MainViewController ()

- (void) removeAllSubViews;
- (SessionTransitionStates) determineViewControllerTransitionStateForSession:(NSString*) sessionId forIncomingCall:(BOOL) incomingCall forIncomingMessage:(BOOL) incomingMessage;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.sessionViewControllersDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) removeAllSubViews
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [[[self view] subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
}

/**
 Show Demo menu
 */
- (void)actionDemo
{
    NSString* remoteSessionTitle = ![[OpenPeer sharedOpenPeer] isRemoteSessionActivationModeOn] ? @"Remote Session - Turn On" : @"Remote Session - Turn Off";
    NSString* faceDectionTitle = ![[OpenPeer sharedOpenPeer] isFaceDetectionModeOn] ? @"Face Detection - Turn On" : @"Face Detection - Turn Off";
    
    NSString* redialTitle = ![[OpenPeer sharedOpenPeer] isRedialModeOn] ? @"Redial - Turn On" : @"Redial - Turn Off";
    
    NSString* loggedUserInfo = [[[OpenPeerUser sharedOpenPeerUser] fullName] length] > 0 ? [[[OpenPeerUser sharedOpenPeerUser] fullName] stringByAppendingString:@" info"] : nil;
    
    UIActionSheet *sheet = nil;
    
    if (loggedUserInfo)
        sheet = [[UIActionSheet alloc] initWithTitle:@"Demo options"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:remoteSessionTitle, faceDectionTitle, redialTitle, loggedUserInfo, nil];
    else
        sheet = [[UIActionSheet alloc] initWithTitle:@"Demo options"
                                            delegate:self
                                   cancelButtonTitle:@"Cancel"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:remoteSessionTitle, faceDectionTitle, redialTitle, nil];
    
    [sheet setActionSheetStyle:UIActionSheetStyleAutomatic];
    
    [sheet setAlpha:0.9];
    
    [sheet showFromBarButtonItem:self.contactsTableViewController.navigationItem.leftBarButtonItem animated:YES];
}

#pragma mark - Login views
/**
 Show view with login button
*/
- (void) showLoginView
{
    if (!self.loginViewController)
    {
        self.loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    }
    
    [self removeAllSubViews];
    [self.loginViewController prepareForLogin];
    [self.view addSubview:self.loginViewController.view];
}

/**
 Show web view with opened login page.
 @param url NSString Login page url.
*/
- (void) showWebLoginView:(WebLoginViewController*) webLoginViewController
{
    if (webLoginViewController)
    {
        //[self removeAllSubViews];
        [self.view addSubview:webLoginViewController.view];
    }
}

#pragma mark - Contacts views
/**
 Show table with list of contacts.
 */
- (void)showContactsTable
{
    [self removeAllSubViews];
    
    if (!self.contactsTableViewController)
        self.contactsTableViewController = [[ContactsTableViewController alloc] initWithNibName:@"ContactsTableViewController" bundle:nil];
    
    if (!self.contactsNavigationController)
    {
        self.contactsNavigationController = [[UINavigationController alloc] initWithRootViewController:self.contactsTableViewController];
        [self.contactsNavigationController.navigationBar.topItem setTitle:@"Contacts"];
        // Add logout button in navigation bar
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"LogOut"
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:[LoginManager sharedLoginManager]
                                                                     action:@selector(logout)];
        self.contactsTableViewController.navigationItem.rightBarButtonItem = barButton;
        
        //Create Demo options button
        UIBarButtonItem *barButtonLeft = [[UIBarButtonItem alloc] initWithTitle:@"Demo"
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(actionDemo)];
        self.contactsTableViewController.navigationItem.leftBarButtonItem = barButtonLeft;
    }
    
    [self presentViewController:self.contactsNavigationController animated:NO completion:nil];
}

#pragma mark - Session view
/**
 Show session view.
 @param session Session which needs to be displyed
 @param incomingCall BOOL - Yes if it is session with incoming call, otherwise NO
 @param incomingMessage BOOL - Yes if it is session with incoming message, otherwise NO
 */
- (void) showSessionViewControllerForSession:(Session*) session forIncomingCall:(BOOL) incomingCall forIncomingMessage:(BOOL) incomingMessage
{
    ActiveSessionViewController* sessionViewContorller = nil;
    NSString* sessionId = [[session conversationThread] getThreadId];
    
    SessionTransitionStates transition = [self determineViewControllerTransitionStateForSession:sessionId forIncomingCall:incomingCall forIncomingMessage:incomingMessage];
    
    NSString* title = [[[session participantsArray] objectAtIndex:0] fullName];
    
    switch (transition)
    {
        case NEW_SESSION_SWITCH:
        {
            [self.contactsNavigationController popToRootViewControllerAnimated:NO];
        }
        case NEW_SESSION:
        case NEW_SESSION_WITH_CALL:
            sessionViewContorller = [[ActiveSessionViewController alloc] initWithSession:session];
            [self.sessionViewControllersDictionary setObject:sessionViewContorller forKey:sessionId];
            
            [self.contactsNavigationController pushViewController:sessionViewContorller animated:YES];
            [self.contactsNavigationController.navigationBar.topItem setTitle:title];
            break;
            
        case NEW_SESSION_WITH_CHAT:
            sessionViewContorller = [[ActiveSessionViewController alloc] initWithSession:session];
            [self.sessionViewControllersDictionary setObject:sessionViewContorller forKey:sessionId];
            
            [self.contactsNavigationController pushViewController:sessionViewContorller animated:NO];
            [self.contactsNavigationController.navigationBar.topItem setTitle:title];
            
            [self.contactsNavigationController pushViewController:sessionViewContorller.chatViewController animated:YES];
            
            //[sessionViewContorller.chatViewController refreshViewWithData];
            break;
            
        case NEW_SESSION_REFRESH_CHAT:
        {
            sessionViewContorller = [[ActiveSessionViewController alloc] initWithSession:session];
            [self.sessionViewControllersDictionary setObject:sessionViewContorller forKey:sessionId];
            [sessionViewContorller.chatViewController refreshViewWithData];
            
            [self showNotification:[NSString stringWithFormat:@"New message from %@",title]];
        }
            break;
            
        case EXISITNG_SESSION_SWITCH:
            sessionViewContorller = [self.sessionViewControllersDictionary objectForKey:sessionId];
            [self.contactsNavigationController popToRootViewControllerAnimated:NO];
            [self.contactsNavigationController pushViewController:sessionViewContorller animated:YES];
            [self.contactsNavigationController.navigationBar.topItem setTitle:title];
            break;
            
        case EXISTING_SESSION_REFRESH_NOT_VISIBLE_CHAT:
            [self showNotification:[NSString stringWithFormat:@"New message from %@",title]];
        case EXISTING_SESSION_REFRESH_CHAT:
            sessionViewContorller = [self.sessionViewControllersDictionary objectForKey:sessionId];
            [sessionViewContorller.chatViewController refreshViewWithData];
            break;
            
        case EXISTIG_SESSION_SHOW_CHAT:
            sessionViewContorller = [self.sessionViewControllersDictionary objectForKey:sessionId];
            if (self.contactsNavigationController.visibleViewController != sessionViewContorller)
            {
                [self.contactsNavigationController popToRootViewControllerAnimated:NO];
                [self.contactsNavigationController pushViewController:sessionViewContorller animated:NO];
            }
            [self.contactsNavigationController pushViewController:sessionViewContorller.chatViewController animated:YES];
            break;
            
        case INCOMING_CALL_WHILE_OTHER_INPROGRESS:
            [self showNotification:[NSString stringWithFormat:@"%@ is trying to reach you.",title]];
            break;
            
        case EXISTING_SESSION:
        default:
            break;
    }
}

- (SessionTransitionStates) determineViewControllerTransitionStateForSession:(NSString*) sessionId forIncomingCall:(BOOL) incomingCall forIncomingMessage:(BOOL) incomingMessage
{
    //If session view controller is laredy created for this session get it from dictionary
    ActiveSessionViewController* sessionViewContorller = [self.sessionViewControllersDictionary objectForKey:sessionId];
    
    if (!sessionViewContorller)
    {
        if (incomingCall)
        {
            if ([[SessionManager sharedSessionManager] isCallInProgress])
                return INCOMING_CALL_WHILE_OTHER_INPROGRESS; //Cannot have two active calls at once
            else
            {
                if (self.contactsNavigationController.visibleViewController && self.contactsNavigationController.visibleViewController != self.contactsTableViewController)
                    return NEW_SESSION_SWITCH; //Incoming call has priority over chat session, so switch from currently active session to new with incoming call
                else
                    return NEW_SESSION_WITH_CALL; //Create and show a new session with incomming call
            }
            
        }
        else if (incomingMessage)
        {
            if (self.contactsNavigationController.visibleViewController && self.contactsNavigationController.visibleViewController != self.contactsTableViewController)
                return NEW_SESSION_REFRESH_CHAT; //Create a new session and update chat, but don't switch from existing session
            else
                return NEW_SESSION_WITH_CHAT; //Create and show a new session with incomming message
        }
        else
            return NEW_SESSION; //Create and show a new session
        
    }
    else
    {
        if (incomingCall)
        {
            if ([[SessionManager sharedSessionManager] isCallInProgress])
                return ERROR_CALL_ALREADY_IN_PROGRESS; //Cannot have two active calls at once
            else
            {
                if (self.contactsNavigationController.visibleViewController == sessionViewContorller)
                    return EXISTING_SESSION; //Incoming call for currenlty displayed session so don't change anything
                else
                    return EXISITNG_SESSION_SWITCH; //Incoming call for session that is not displayed at the moment so swith to that session
            }
        }
        else if (incomingMessage)
        {
            if (self.contactsNavigationController.visibleViewController == sessionViewContorller)
            {
                if ([[SessionManager sharedSessionManager] isCallInProgress])
                    return EXISTING_SESSION_REFRESH_CHAT; //Incoming message for session with active call. Just refresh list of messages but don't display chat view
                else
                    return EXISTIG_SESSION_SHOW_CHAT; //Show chat for currently displayed session
            }
            else if (self.contactsNavigationController.visibleViewController == sessionViewContorller.chatViewController)
            {
                return EXISTING_SESSION_REFRESH_CHAT; //Already displayed chat view, so just refresh messages
            }
            else if (self.contactsNavigationController.visibleViewController == self.contactsTableViewController)
            {
                return EXISTIG_SESSION_SHOW_CHAT; //Move from the contacts list to the chat view for session
            }
            else
            {
                return EXISTING_SESSION_REFRESH_NOT_VISIBLE_CHAT; //Move from the contacts list to the chat view for session
            }
        }
        else
        {
            return EXISITNG_SESSION_SWITCH; //Switch to exisitng session
        }
    }
}


/**
 Remove specific session view controller from the dictionary.
 @param sessionId NSString session id
 */
- (void) removeSessionViewControllerForSession:(NSString*) sessionId
{
    [self.sessionViewControllersDictionary removeObjectForKey:sessionId];
}

- (void) updateSessionViewControllerId:(NSString*) oldSessionId newSesionId:(NSString*) newSesionId
{
    ActiveSessionViewController* svc = [self.sessionViewControllersDictionary objectForKey:oldSessionId];
    [self removeSessionViewControllerForSession:oldSessionId];
    [self.sessionViewControllersDictionary setObject:svc forKey:newSesionId];
}
/**
 Prepare specific session vire controller for incoming call
 @param session Session with incomming call
 */
- (void) showIncominCallForSession:(Session*) session
{
    ActiveSessionViewController* sessionViewContorller = [self.sessionViewControllersDictionary objectForKey:[[session conversationThread] getThreadId]];
    [sessionViewContorller prepareForIncomingCall];
}


#pragma mark - UIActionSheet Delegate Methods
/**
 Handling choosed Demo option
 */
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case DEMO_REMOTE_SESSION_INIT:
        {
            ((OpenPeer*)[OpenPeer sharedOpenPeer]).isRemoteSessionActivationModeOn = ![[OpenPeer sharedOpenPeer] isRemoteSessionActivationModeOn];
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationRemoteSessionModeChanged object:nil];
            
            NSString* message = [[OpenPeer sharedOpenPeer] isRemoteSessionActivationModeOn] ? @"Remote session activation mode is turned ON. Please, select two openpeer contacts from your list and remote session will be created." : @"Remote session activation mode is turned OFF";
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Remote session activation"
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
            break;

            
        case DEMO_FACE_DETECTION_MODE:
        {
            ((OpenPeer*)[OpenPeer sharedOpenPeer]).isFaceDetectionModeOn = ![[OpenPeer sharedOpenPeer] isFaceDetectionModeOn];
            
            NSString* message = [[OpenPeer sharedOpenPeer] isFaceDetectionModeOn] ? @"Face detection mode is turned ON. Please, select contact from the list. Session will be created and face detection activated. As soon face is detected, video call will be started." : @"Face detection mode is turned OFF";
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Face detection"
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
            break;
            
        case DEMO_CALL_REDIAL:
            ((OpenPeer*)[OpenPeer sharedOpenPeer]).isRedialModeOn = ![[OpenPeer sharedOpenPeer] isRedialModeOn];
            break;
            
        case DEMO_LOGGED_USER_INFO:
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
            
            NSString* info = [NSString stringWithFormat:@"Identity URIs: %@ \n Stable Id: %@ \n Peer URI: %@",uris,[[OpenPeerUser sharedOpenPeerUser] stableUniqueId],[[OpenPeerUser sharedOpenPeerUser] peerURI]];
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:[[OpenPeerUser sharedOpenPeerUser] fullName]
                                                                message:info
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
            }
            break;
        default:
            
            break;
    }
    
}

- (void) showNotification:(NSString*) message
{
    UILabel* labelNotification = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 20.0, self.view.frame.size.width - 10.0, 40.0)];
    labelNotification.text = message;//[NSString stringWithFormat:@"New message from %@",contactName];
    labelNotification.textAlignment = NSTextAlignmentCenter;
    labelNotification.textColor = [UIColor whiteColor];
    labelNotification.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
    [self.contactsNavigationController.visibleViewController.view addSubview:labelNotification];
    
    [UIView animateWithDuration:0.5 delay:2.0 options:0 animations:^{
        // Animate the alpha value of your imageView from 1.0 to 0.0 here
        labelNotification.alpha = 0.0f;
    } completion:^(BOOL finished) {
        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        [labelNotification removeFromSuperview];
    }];
}
@end
