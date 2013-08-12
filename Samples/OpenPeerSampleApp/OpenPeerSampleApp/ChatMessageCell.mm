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

#import "ChatMessageCell.h"
#import "Message.h"
#import "OpenPeerUser.h"
#import <OpenpeerSDK/HOPRolodexContact.h>

#define AVATAR_SIZE 31

@interface ChatMessageCell()

@property (nonatomic, strong) UIFont *chatNameFont;
@property (nonatomic, strong) UIFont *chatTimestampFont;
@property (nonatomic, strong) NSString *unicodeMessageText;
@property (nonatomic, weak) Message *message;


@end

@implementation ChatMessageCell

@synthesize messageLabel = _messageLabel;
@synthesize hasSendingIndicator = _hasSendingIndicator;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor clearColor];
        _chatNameFont =  [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
        _chatTimestampFont = [UIFont fontWithName:@"Helvetica" size:12.0];
        _messageLabel = [[UILabel alloc] init];
        _hasSendingIndicator = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


-(void)setUnicodeChars:(NSString *)str
{
    // replace emotions
    if(str != _unicodeMessageText)
    {
        
        _unicodeMessageText = nil;

        NSMutableString *ms1 = [[NSMutableString alloc] initWithString:str];        
        
        [ms1 replaceOccurrencesOfString:@":)" withString:@"\ue415" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@":)" withString:@"\ue415" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-)" withString:@"\ue415" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":]" withString:@"\ue415" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"=)" withString:@"\ue415" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=)" withString:@"\ue415" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@";)" withString:@"\ue405" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@";=)" withString:@"\ue405" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@";-)" withString:@"\ue405" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@":D" withString:@"\ue057" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-D" withString:@"\ue057" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=D" withString:@"\ue057" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":d" withString:@"\ue057" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-d" withString:@"\ue057" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=d" withString:@"\ue057" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@":(" withString:@"\ue403" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-(" withString:@"\ue403" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":[" withString:@"\ue403" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=(" withString:@"\ue403" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@";(" withString:@"\ue413" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@";-(" withString:@"\ue413" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@";=(" withString:@"\ue413" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@":o" withString:@"\ue40d" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-o" withString:@"\ue40d" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=o" withString:@"\ue40d" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":O" withString:@"\ue40d" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];       
        [ms1 replaceOccurrencesOfString:@":-O" withString:@"\ue40d" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];               
        [ms1 replaceOccurrencesOfString:@":=O" withString:@"\ue40d" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];       
        
        [ms1 replaceOccurrencesOfString:@":*" withString:@"\ue418" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=*" withString:@"\ue418" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-*" withString:@"\ue418" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];       
        
        [ms1 replaceOccurrencesOfString:@":p" withString:@"\ue105" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-p" withString:@"\ue105" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":=p" withString:@"\ue105" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":P" withString:@"\ue105" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];       
        [ms1 replaceOccurrencesOfString:@":-P" withString:@"\ue105" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];               
        [ms1 replaceOccurrencesOfString:@":=P" withString:@"\ue105" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@":$" withString:@"\ue414" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-$" withString:@"\ue414" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];       
        [ms1 replaceOccurrencesOfString:@":=$" withString:@"\ue414" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];               
        
        [ms1 replaceOccurrencesOfString:@"|-)" withString:@"\ue13c" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"I-)" withString:@"\ue13c" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];       
        [ms1 replaceOccurrencesOfString:@"I=)" withString:@"\ue13c" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];               
        [ms1 replaceOccurrencesOfString:@"(snooze)" withString:@"\ue13c" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];                       
        
        [ms1 replaceOccurrencesOfString:@"|(" withString:@"\ue40e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"|-(" withString:@"\ue40e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];       
        [ms1 replaceOccurrencesOfString:@"|=(" withString:@"\ue40e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])]; 
        
        [ms1 replaceOccurrencesOfString:@"(inlove)" withString:@"\ue106" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];         
        
        [ms1 replaceOccurrencesOfString:@":&" withString:@"\ue408" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-&" withString:@"\ue408" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];       
        [ms1 replaceOccurrencesOfString:@":=&" withString:@"\ue408" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];               
        [ms1 replaceOccurrencesOfString:@"(puke)" withString:@"\ue408" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];         
        
        [ms1 replaceOccurrencesOfString:@":@" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@":-@" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];       
        [ms1 replaceOccurrencesOfString:@":=@" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];               
        [ms1 replaceOccurrencesOfString:@"x(" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];         
        [ms1 replaceOccurrencesOfString:@"x-(" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"x=(" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];       
        [ms1 replaceOccurrencesOfString:@"X(" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];               
        [ms1 replaceOccurrencesOfString:@"X-(" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])]; 
        [ms1 replaceOccurrencesOfString:@"X=(" withString:@"\ue059" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];         
        
        [ms1 replaceOccurrencesOfString:@"(party)" withString:@"\ue312" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];                 
        [ms1 replaceOccurrencesOfString:@"(call)" withString:@"\ue009" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(devil)" withString:@"\ue11a" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];        
        [ms1 replaceOccurrencesOfString:@"(wait)" withString:@"\ue012" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];         
        [ms1 replaceOccurrencesOfString:@"(clap)" withString:@"\ue41f" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(rofl)" withString:@"\ue412" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(happy)" withString:@"\ue056" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(punch)" withString:@"\ue00d" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(y)" withString:@"\ue00e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])]; 
        [ms1 replaceOccurrencesOfString:@"(Y)" withString:@"\ue00e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])]; 
        [ms1 replaceOccurrencesOfString:@"(ok)" withString:@"\ue00e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])]; 
        
        [ms1 replaceOccurrencesOfString:@"(n)" withString:@"\ue421" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])]; 
        [ms1 replaceOccurrencesOfString:@"(N)" withString:@"\ue421" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])]; 
        
        [ms1 replaceOccurrencesOfString:@"(handshake)" withString:@"\ue420" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        
        [ms1 replaceOccurrencesOfString:@"(h)" withString:@"\ue022" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(H)" withString:@"\ue022" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];       
        [ms1 replaceOccurrencesOfString:@"(l)" withString:@"\ue022" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];               
        [ms1 replaceOccurrencesOfString:@"(L)" withString:@"\ue022" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];         
        
        [ms1 replaceOccurrencesOfString:@"(u)" withString:@"\ue023" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];               
        [ms1 replaceOccurrencesOfString:@"(U)" withString:@"\ue023" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];         
        
        [ms1 replaceOccurrencesOfString:@"(e)" withString:@"\ue103" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];               
        [ms1 replaceOccurrencesOfString:@"(m)" withString:@"\ue103" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];         
        
        [ms1 replaceOccurrencesOfString:@"(f)" withString:@"\ue305" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];               
        [ms1 replaceOccurrencesOfString:@"(F)" withString:@"\ue305" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];         
        
        [ms1 replaceOccurrencesOfString:@"(rain)" withString:@"\ue331" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])]; 
        [ms1 replaceOccurrencesOfString:@"(london)" withString:@"\ue331" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])]; 
        
        [ms1 replaceOccurrencesOfString:@"(sun)" withString:@"\ue04a" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])]; 
        
        [ms1 replaceOccurrencesOfString:@"(music)" withString:@"\ue03e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(coffee)" withString:@"\ue045" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])]; 
        [ms1 replaceOccurrencesOfString:@"(beer)" withString:@"\ue047" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];         
        
        [ms1 replaceOccurrencesOfString:@"(cash)" withString:@"\ue12f" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])]; 
        [ms1 replaceOccurrencesOfString:@"(mo)" withString:@"\ue12f" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])]; 
        [ms1 replaceOccurrencesOfString:@"($)" withString:@"\ue12f" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];         
        
        [ms1 replaceOccurrencesOfString:@"(muscle)" withString:@"\ue14c" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(flex)" withString:@"\ue14c" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];         
        
        [ms1 replaceOccurrencesOfString:@"(^)" withString:@"\ue34b" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(cake)" withString:@"\ue34b" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];         
        
        [ms1 replaceOccurrencesOfString:@"(d)" withString:@"\ue044" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(D)" withString:@"\ue044" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];         
        
        [ms1 replaceOccurrencesOfString:@"(*)" withString:@"\ue32f" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];         
        
        [ms1 replaceOccurrencesOfString:@"(smoking)" withString:@"\ue30e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];
        [ms1 replaceOccurrencesOfString:@"(smoke)" withString:@"\ue30e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];                 
        [ms1 replaceOccurrencesOfString:@"(ci)" withString:@"\ue30e" options:NSLiteralSearch range:NSMakeRange(0, [ms1 length])];         
        
        _unicodeMessageText = [NSString stringWithString:ms1];
        //NSLog(@"******************setUnicodeChars: _unicodeMessageText:%@",_unicodeMessageText);

    } 
}   

- (void)setMessage:(Message *)message
{
    _message = message;
    
}

-(void)layoutSubviews
{
    // prepare cell
    CGRect cf = self.contentView.frame;
    cf.size.width = self.frame.size.width;
    self.contentView.frame = self.bounds;//cf;
    
    for(UIView *v in [self.contentView subviews])
    {
        [v removeFromSuperview];
    }
    
    if(self.message)
    {
        if([self.message.message length] > 0)
        {
            NSLog(@"%@",self.message.message);
            [self setUnicodeChars:self.message.message];
            
            CGSize messageSize = [ChatMessageCell calcMessageHeight:_unicodeMessageText forScreenWidth:(self.frame.size.width - 15.0)];

            NSString *messageSenderName;
            
            //if message is received
            if(self.message.contact)
            {
                messageSenderName = [self.message.contact name];
                [self.contentView setBackgroundColor:[UIColor colorWithRed:193.0/255.0 green:208.0/255.0 blue:1.0 alpha:1.0]];
            }
            else
            {
                messageSenderName = [[OpenPeerUser sharedOpenPeerUser] fullName];
                [self.contentView setBackgroundColor:[UIColor colorWithRed:198.0/255.0 green:1.0 blue:216.0/255.0 alpha:1.0]];
            }
            
            CGSize sizeOftheName = [messageSenderName sizeWithFont:_chatNameFont];
            
            float headerLabelXpos = 10.0;
            float messageLabelXpos = 5.0;
            
        
            UILabel *lblWhoIsChatting = [[UILabel alloc] initWithFrame:CGRectMake(headerLabelXpos, 2, sizeOftheName.width + 2, sizeOftheName.height + 2)];
            lblWhoIsChatting.backgroundColor = [UIColor clearColor];
            lblWhoIsChatting.textColor = [UIColor grayColor];
            lblWhoIsChatting.font = _chatNameFont;
            lblWhoIsChatting.text = messageSenderName;
            
            headerLabelXpos += lblWhoIsChatting.frame.size.width;
            
            // set separator
            UILabel *lblSep = [[UILabel alloc] initWithFrame:CGRectMake(headerLabelXpos, 2, 10, 15)];
            lblSep.backgroundColor =[UIColor clearColor];
            lblSep.textColor = [UIColor whiteColor];
            lblSep.textAlignment = UITextAlignmentCenter;
            lblSep.font = _chatTimestampFont;
            lblSep.text = @" | ";
            
            headerLabelXpos += 10;
            
            // set message date        
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            
            NSDateComponents *massageDayOfDate = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self.message.date];
            NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
            if([today day] == [massageDayOfDate day] &&
               [today month] == [massageDayOfDate month] &&
               [today year] == [massageDayOfDate year] &&
               [today era] == [massageDayOfDate era])
            {
                [df setDateFormat:@"hh:mm aa"];
            }
            else
            {
                [df setDateFormat:@"MM/dd/yyyy hh:mm aa"];
            }
            
            NSString *sDate = [df stringFromDate:self.message.date];
            
            CGSize sizeOftheDate = [sDate sizeWithFont:_chatTimestampFont];
            UILabel *lblChatMessageTimestamp = [[UILabel alloc] initWithFrame:CGRectMake(headerLabelXpos, 2, sizeOftheDate.width + 10, sizeOftheDate.height + 2)];
            lblChatMessageTimestamp.textColor = [UIColor grayColor];
            lblChatMessageTimestamp.backgroundColor = [UIColor clearColor];
            lblChatMessageTimestamp.font = _chatTimestampFont;
            lblChatMessageTimestamp.text = sDate;


            [_messageLabel setFrame:CGRectMake(messageLabelXpos, 25, messageSize.width, messageSize.height)];
            //_messageLabel.dataDetectorTypes = UIDataDetectorTypeLink;
            _messageLabel.backgroundColor = [UIColor clearColor];
            _messageLabel.font = [UIFont systemFontOfSize:14.0];
            _messageLabel.lineBreakMode = UILineBreakModeWordWrap;
            _messageLabel.text = _unicodeMessageText;
            _messageLabel.numberOfLines = 0;
            //NSLog(@"******************layoutSubviews STANDARD_MESSAGE [_messageText length] : lblMsg:%@",lblMsg.text);
            [_messageLabel sizeToFit];

            if(!self.message.contact)
            {
                // set header labels position
                headerLabelXpos = self.frame.size.width  - lblChatMessageTimestamp.frame.size.width;
                CGRect f = lblChatMessageTimestamp.frame;
                f.origin.x = headerLabelXpos;
                lblChatMessageTimestamp.frame = f;
                headerLabelXpos -= lblSep.frame.size.width;
                f = lblSep.frame;
                f.origin.x = headerLabelXpos;
                lblSep.frame = f;
                headerLabelXpos -= lblWhoIsChatting.frame.size.width;
                f = lblWhoIsChatting.frame;
                f.origin.x = headerLabelXpos;
                lblWhoIsChatting.frame = f;
                messageLabelXpos = self.frame.size.width - (messageSize.width + 38.0);
                f = _messageLabel.frame;
                f.origin.x = messageLabelXpos;
                _messageLabel.frame = f;
            }
            
            [self.contentView addSubview:_messageLabel];
            
            [self.contentView addSubview:lblWhoIsChatting];
            [self.contentView addSubview:lblSep];
            [self.contentView addSubview:lblChatMessageTimestamp];

        }
    }
}

+(CGSize)calcMessageHeight:(NSString *)message forScreenWidth:(float)width
{
    CGSize maxSize = {width, 200000.0};
    CGSize calcSize = [message sizeWithFont:[UIFont systemFontOfSize:14.0] 
                                                constrainedToSize:maxSize];
    
    return calcSize;
    
}



@end
