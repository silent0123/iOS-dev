//
//  API.h
//  QuickPoll
//
//  Created by dennis young on 10/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPHelperDelegate.h"
#import "APICall.h"
#import "HTTPHelper.h"
#import "JSONUtil.h"

@interface API : NSObject

@property (nonatomic, strong) NSString *urlPrefix;
@property (nonatomic, strong) NSString *selfId;
@property (nonatomic, strong) NSString *authKey;

-(void)call:(NSString*)url target:(id)target selector:(SEL)sel;
-(void)call:(NSString *)url param:(NSDictionary*)obj target:(id)target selector:(SEL)sel;
-(void)putcall:(NSString *)url param:(NSDictionary*)obj target:(id)target selector:(SEL)sel;
-(void)delcall:(NSString*)url target:(id)target selector:(SEL)sel;
-(API*)initWithURLPrefix:(NSString*)prefix;

-(void)register:(NSString*)getParam target:(id)target selector:(SEL)sel;
-(void)getAccountInfo:(NSString*)getParam target:(id)target selector:(SEL)sel;
-(void)checkUsernameExist:(NSString*)getParam target:(id)target selector:(SEL)sel;
-(void)listGroup:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)listTrustedContact:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)listGroupMember:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)addGroup:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)addTrustContact:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)deleteTrustContact:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)removeGroup:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)removeGroupMember:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)addGroupMember:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)createKey:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)getKey:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)deleteKey:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)setFriendListPermision:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)listFriendListPermision:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)listOperationLogByTime:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)listKeyLogByTime:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)editEmailAddress:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)editPassword:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)editFriendNote:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)editFriendAlias:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)editFriendEmail:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)editGroupName:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)addFriend:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)listTrustedContactStatus:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)listGroupMemberStatus:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)checkClientUpdate:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)listKeyLogById:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)setcontactlistpermission:(NSString *)urlPart P: (NSData*)getParam target:(id)target selector:(SEL)sel;
-(void)createKeyAndHeader:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)getKeyByHeader:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)getcontactlistpermission:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)getDecryptKey:(NSString *)getParam target:(id)target selector:(SEL)sel;
-(void)isKeyOwner:(NSString *)getParam target:(id)target selector:(SEL)sel;
@end
