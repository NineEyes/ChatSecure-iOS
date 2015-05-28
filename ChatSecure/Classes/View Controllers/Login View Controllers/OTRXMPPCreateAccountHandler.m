//
//  OTRXMPPCreateAccountHandler.m
//  ChatSecure
//
//  Created by David Chiles on 5/13/15.
//  Copyright (c) 2015 Chris Ballinger. All rights reserved.
//

#import "OTRXMPPCreateAccountHandler.h"
#import "OTRXMPPManager.h"
#import "XLForm.h"
#import "OTRXLFormCreator.h"
#import "OTRProtocolManager.h"
#import "OTRDatabaseManager.h"
#import "OTRXMPPServerTableViewCell.h"
#import "XMPPJID.h"
#import "OTRXMPPManager.h"

@implementation OTRXMPPCreateAccountHandler

- (OTRXMPPAccount *)moveValues:(XLFormDescriptor *)form intoAccount:(OTRXMPPAccount *)account
{
    account = (OTRXMPPAccount *)[super moveValues:form intoAccount:account];
    OTRXMPPServerTableViewCellInfo *serverInfo = [[form formRowWithTag:kOTRXLFormXMPPServerTag] value];
    
    //Get correct user domain
    NSString *userDomain = serverInfo.serverDomain;
    if ([serverInfo.userDomain length]) {
        userDomain = serverInfo.userDomain;
    }
    
    //Create valid 'username' which is a bare jid (user@domain.com)
    XMPPJID *jid = [XMPPJID jidWithString:account.username];
    
    if (!([jid.user length] && [jid.domain length])) {
        jid = [XMPPJID jidWithUser:account.username domain:userDomain resource:nil];
    } else if (![userDomain isEqual:jid.domain]) {
        jid = [XMPPJID jidWithUser:jid.user domain:userDomain resource:nil];
    }
    
    if (jid) {
        account.username = [jid bare];
    }
    
    return account;
}

- (void)performActionWithValidForm:(XLFormDescriptor *)form account:(OTRAccount *)account completion:(void (^)(NSError *, OTRAccount *))completion
{
    self.completion = completion;
    [self prepareForXMPPConnectionFrom:form account:(OTRXMPPAccount *)account];
    
    NSString *password = [[form formRowWithTag:kOTRXLFormPasswordTextFieldTag] value];
    

    [self.xmppManager registerNewAccountWithPassword:password];
    
}

@end