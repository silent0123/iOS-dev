//
//  API.m
//  QuickPoll
//
//  Created by dennis young on 10/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "API.h"

@implementation API

@synthesize urlPrefix;
@synthesize selfId;
@synthesize authKey;

-(API*)initWithURLPrefix:(NSString*)prefix {
	if (self = [super init]) {
		urlPrefix = prefix;
	}
	return self;
}


-(void)post:(NSString*)url param:(NSData*)content target:(id)target selector:(SEL)sel {
    APICall *apiCall = [[APICall alloc] initWithTarget:target selector:sel];
	[apiCall.httpHelper post:url data:content contentType:@"application/json"];
}

-(void)call:(NSString*)url target:(id)target selector:(SEL)sel {
	NSLog(@"API: call(%@)", url);
	APICall *apiCall = [[APICall alloc] initWithTarget:target selector:sel];
	[apiCall.httpHelper get:url];
}

-(void)call:(NSString *)url param:(NSDictionary*)obj target:(id)target selector:(SEL)sel {
	//NSLog(@"API: call(%@, %@)", url, obj);
	APICall *apiCall = [[APICall alloc] initWithTarget:target selector:sel];
	NSData *data = [[JSONUtil objectToString:obj] dataUsingEncoding:NSUTF8StringEncoding];
	[apiCall.httpHelper post:url data:data contentType:@"application/json"];
}

-(void)putcall:(NSString *)url param:(NSDictionary*)obj target:(id)target selector:(SEL)sel {
    
	//NSLog(@"API: putcall(%@, %@)", url, obj);
	APICall *apiCall = [[APICall alloc] initWithTarget:target selector:sel];
	NSData *data = [[JSONUtil objectToString:obj] dataUsingEncoding:NSUTF8StringEncoding];
	[apiCall.httpHelper put:url data:data contentType:@"application/json"];
}

-(void)delcall:(NSString*)url target:(id)target selector:(SEL)sel {
	//NSLog(@"API: delcall(%@)", url);
	APICall *apiCall = [[APICall alloc] initWithTarget:target selector:sel];
	[apiCall.httpHelper del:url];
}

-(void)call:(NSString *)url param:(NSDictionary*)obj target:(id)target selector:(SEL)sel context:(id)context {
	//NSLog(@"API: call(%@, %@)", url, obj);
	APICall *apiCall = [[APICall alloc] initWithTarget:target selector:sel];
	apiCall.context = context;
	NSData *data = [[JSONUtil objectToString:obj] dataUsingEncoding:NSUTF8StringEncoding];
	[apiCall.httpHelper post:url data:data contentType:@"application/json"];
}

-(void)checkUsernameExist:(NSString*)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/checkuserexist?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)register:(NSString*)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/simpleRegister?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)getAccountInfo:(NSString*)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/getaccountinfo?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)setSecurityQuestionAnswer:(NSString*)getParam target:(id)target selector:(SEL)sel {
    NSString *url = [NSString stringWithFormat:@"%@/account/setSecurityQuestionAnswer?req=%@", urlPrefix, getParam];
    [self call:url target:target selector:sel];
}

-(void)listGroup:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/listgroup?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)listTrustedContact:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/listtrustedcontact?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)listTrustedContactStatus:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/listtrustedcontactstatus?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)listGroupMemberStatus:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/listgroupmemberstatus?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)listGroupMember:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/listgroupmember?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)addGroup:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/addgroup?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)addTrustContact:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/addtrustcontact?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}


-(void)checkClientUpdate:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/system/checkClientUpdate?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}


-(void)addFriend:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/addFriend?req=%@", urlPrefix, getParam];
    [self call:url target:target selector:sel];
}

-(void)setcontactlistpermission:(NSString *)urlPart P: (NSData*)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/key/setContactlistPermission?req=%@", urlPrefix, urlPart];
    [self post:url param:getParam target:target selector:sel];

}

-(void)deleteTrustContact:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/deletetrustcontact?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)editFriendAlias:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/editFriendAlias?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)editGroupName:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/editGroupName?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)editFriendEmail:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/editFriendEmail?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)editFriendNote:(NSString *)getParam target:(id)target selector:(SEL)sel {
    NSString *url = [NSString stringWithFormat:@"%@/account/editFriendNote?req=%@", urlPrefix, getParam];
    [self call:url target:target selector:sel];
}

-(void)removeGroup:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/removegroup?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)removeGroupMember:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/removegroupmember?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)addGroupMember:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/addgroupmember?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)setFriendListPermision:(NSString *)getParam target:(id)target selector:(SEL)sel {
    NSString *url = [NSString stringWithFormat:@"%@/key/setFriendListPermission?req=%@", urlPrefix, getParam];
    [self call:url target:target selector:sel];
}

-(void)editEmailAddress:(NSString *)getParam target:(id)target selector:(SEL)sel {
    NSString *url = [NSString stringWithFormat:@"%@/account/editEmail?req=%@", urlPrefix, getParam];
    [self call:url target:target selector:sel];
}

-(void)editPassword:(NSString *)getParam target:(id)target selector:(SEL)sel {
    NSString *url = [NSString stringWithFormat:@"%@/account/editPassword?req=%@", urlPrefix, getParam];
    [self call:url target:target selector:sel];
}

-(void)listOperationLogByTime:(NSString *)getParam target:(id)target selector:(SEL)sel {
    NSString *url = [NSString stringWithFormat:@"%@/account/listOperationLogByTime?req=%@", urlPrefix, getParam];
    [self call:url target:target selector:sel];
}

-(void)listKeyLogByTime:(NSString *)getParam target:(id)target selector:(SEL)sel {
    NSString *url = [NSString stringWithFormat:@"%@/account/listKeyLogByTime?req=%@", urlPrefix, getParam];
    [self call:url target:target selector:sel];
}

-(void)listFriendListPermision:(NSString *)getParam target:(id)target selector:(SEL)sel {
    NSString *url = [NSString stringWithFormat:@"%@/key/listFriendListPermission?req=%@", urlPrefix, getParam];
    [self call:url target:target selector:sel];
}

-(void)getcontactlistpermission:(NSString *)getParam target:(id)target selector:(SEL)sel {
    NSString *url = [NSString stringWithFormat:@"%@/key/getContactListPermission?req=%@", urlPrefix, getParam];
    [self call:url target:target selector:sel];
}

-(void)createKey:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/key/createkey?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)isKeyOwner:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/key/iskeyowner?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)getDecryptKey:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/key/getDecryptKey?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)createKeyAndHeader:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/key/createKeyAndHeader?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}
-(void)getKey:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/key/getkey?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}
-(void)getKeyByHeader:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/key/getKeyByHeader?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}


-(void)listKeyLogById:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/account/listKeyLogById?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

-(void)deleteKey:(NSString *)getParam target:(id)target selector:(SEL)sel {
	NSString *url = [NSString stringWithFormat:@"%@/key/deletekey?req=%@", urlPrefix, getParam];
	[self call:url target:target selector:sel];
}

@end
