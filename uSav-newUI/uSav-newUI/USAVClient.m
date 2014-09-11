//
//  USAVClient.m
//  uSav
//
//  Created by dennis young on 27/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "USAVClient.h"
//#import "USAVAppDelegate.h"
#import "ProgressViewController.h"
#import "API.h"
#import "EventProcessor.h"
#import "EventListener.h"
#import "NSData+Base64.h"

@interface USAVClient()

@property (nonatomic) BOOL getShortIdFailed;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) ProgressViewController *progressViewController;
// @property (nonatomic, strong) NSString *identifier;
/*
 @property (nonatomic, strong) NSString *nickname;
 @property (nonatomic, strong) NSString *myShortIdStr;
 @property (nonatomic, strong) NSString *logoUrl;
 @property (nonatomic, strong) NSString *logoFile;
 @property (nonatomic, strong) NSString *groupId;
 @property (nonatomic, strong) NSString *playerId;
 */
@property (readwrite)	CFURLRef		soundFileURLRef;
@property (readonly)	SystemSoundID	soundFileObject;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

static USAVClient *usavClient = nil;

@implementation USAVClient

@synthesize homeViewController;
@synthesize api;
@synthesize alertView;

// @synthesize identifier;
@synthesize username;
@synthesize password;
@synthesize emailAddress;
/*
 @synthesize nickname;
 @synthesize myShortIdStr;
 @synthesize logoUrl;
 @synthesize logoFile;
 @synthesize groupId;
 @synthesize playerId;
 */

// @synthesize getShortIdFailed;
@synthesize userHasLogin;
@synthesize progressViewController;

// @synthesize processor;
// @synthesize delegate;
// @synthesize eventListener;

/*
 @synthesize usavRole;
 @synthesize usavState;
 */

@synthesize soundFileURLRef;
@synthesize soundFileObject;
@synthesize dateFormatter;

/*
 - (void)setDngRole:(int)role {
 dngRole = role;
 }
 
 - (int)getDngRole {
 return dngRole;
 }
 
 - (void)setDngState:(int)state {
 dngState = state;
 }
 
 - (int)getDngState {
 return dngState;
 }
 */

+(NSString *)convertNumberToKMString:(int)num {
    
    if (num > (1024 * 1024)) {
        float m = (float)num / (1024.0 * 1024.0);
        return ([NSString stringWithFormat:@"%.2fM", m]);
    }
    else if (num > 1024) {
        float k = (float)num / 1024.0;
        return ([NSString stringWithFormat:@"%.2fK", k]);
    }
    else
        return [NSString stringWithFormat:@"%d", num];
    
}


+(UIImage *)SelectImgForuSavFile:(NSString *) filename
{
    NSString *ext = [filename pathExtension];
    if ([ext caseInsensitiveCompare:@"doc"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_docL.png"];
    }
    else if ([ext caseInsensitiveCompare:@"docx"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_docL.png"];
    }
    else if ([ext caseInsensitiveCompare:@"jpg"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_imgL.png"];
    }
    else if ([ext caseInsensitiveCompare:@"mp4"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_imgL.png"];
    }
    else if ([ext caseInsensitiveCompare:@"pdf"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_pdfL.png"];
    }
    else if ([ext caseInsensitiveCompare:@"ppt"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_pptL.png"];
    }
    else if ([ext caseInsensitiveCompare:@"pptx"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_pptL.png"];
    }
    else if ([ext caseInsensitiveCompare:@"txt"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_txtL.png"];
    }
    else if ([ext caseInsensitiveCompare:@ "xls"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_xlsL.png"];
    }
    else if ([ext caseInsensitiveCompare:@ "xlsx"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_xlsL.png"];
    }
    else if ([ext caseInsensitiveCompare:@"zip"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_zipL.png"];
    }
    else {
        return [UIImage imageNamed:@"35x35_genL.png"];
    }
}

+(UIImage *)SelectImgForOriginalFile:(NSString *) filename
{
    NSString *ext = [filename pathExtension];
    if ([ext caseInsensitiveCompare:@"doc"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_doc.png"];
    } else if ([ext caseInsensitiveCompare:@"docx"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_doc.png"];
    }
    else if ([ext caseInsensitiveCompare:@"jpg"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_img.png"];
    }
    else if ([ext caseInsensitiveCompare:@"mp4"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_img.png"];
    }
    else if ([ext caseInsensitiveCompare:@"pdf"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_pdf.png"];
    }
    else if ([ext caseInsensitiveCompare:@"ppt"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_ppt.png"];
    }
    else if ([ext caseInsensitiveCompare:@"pptx"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_ppt.png"];
    }
    else if ([ext caseInsensitiveCompare:@"txt"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_txt.png"];
    }
    else if ([ext caseInsensitiveCompare:@ "xls"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_xls.png"];
    }
    else if ([ext caseInsensitiveCompare:@ "xlsx"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_xls.png"];
    }
    else if ([ext caseInsensitiveCompare:@"zip"] == NSOrderedSame) {
        return [UIImage imageNamed:@"35x35_zip.png"];
    }
    else {
        return [UIImage imageNamed:@"35x35_gen.png"];
    }
}


// Encode a string to embed in an URL.
-(NSString *)encodeToPercentEscapeString:(NSString *)string {
    return (__bridge NSString *)
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef) string,
                                            NULL,
                                            (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8);
}

// Decode a percent escape encoded string.
-(NSString *)decodeFromPercentEscapeString:(NSString *)string {
    return (__bridge NSString *)
    CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                            (CFStringRef) string,
                                                            CFSTR(""),
                                                            kCFStringEncodingUTF8);
}

-(NSString *)getDateTimeStr
{
    NSDate *now = [NSDate date];
    NSNumber *num = [NSNumber numberWithDouble:[now timeIntervalSince1970]];
    NSDate *msgdate = [NSDate dateWithTimeIntervalSince1970:[num doubleValue]];
    return [dateFormatter stringFromDate:msgdate];
}

-(NSString *)generateSignature:(NSString *)stringToSign withKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [stringToSign cStringUsingEncoding:NSUTF8StringEncoding];
   
    unsigned char cHMAC[SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    
    return [HMAC base64EncodedString];
}

- (NSString*)uuid {
	CFUUIDRef uid = CFUUIDCreate(NULL);
	return (__bridge NSString*)CFUUIDCreateString(NULL, uid);
}

- (UIImage*)imageWithImage:(UIImage*)image size:(CGSize)size {
	UIGraphicsBeginImageContext( size );
	[image drawInRect:CGRectMake(0,0,size.width,size.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

-(UIImage *)resizeImage:(UIImage *)image width:(float)resizeWidth height:(float)resizeHeight{
    
    UIGraphicsBeginImageContext(CGSizeMake(resizeWidth, resizeHeight));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, resizeHeight);
    
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, resizeWidth, resizeHeight), [image CGImage]);
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

-(NSString*) saveThumbnail:(UIImage*)image {
    
    NSString *myUuid = [self uuid];
	NSString *path = [NSString stringWithFormat:@"%@/Documents/%@.jpg", NSHomeDirectory(), myUuid];
    
	CGSize is = image.size;
	
	//float f = 200.0/is.width;
	//CGSize ts = CGSizeMake(200.0, is.height * f);
	float f = 180.0/is.width;
	CGSize ts = CGSizeMake(180.0, is.height * f);
	
	UIImage *thum = [self imageWithImage:image size:ts];
	[UIImageJPEGRepresentation(thum, 0.9) writeToFile:path atomically:YES];
	return path;
}

// keep this for compatibility purpose
- (NSString*)username {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"aliasName"];
}

- (void)setUsername:(NSString *)username  {
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"aliasName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)emailAddress {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"emailAddress"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
 
- (void)setEmailAddress:(NSString *)email  {
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"emailAddress"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

 - (NSString*)password {
     return [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
 }
 
 - (void)setPassword:(NSString *)password {
     [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
     [[NSUserDefaults standardUserDefaults] synchronize];
 }




/*
 - (void)setIdentifier:(NSString *)ident username:(NSString*)un nickname:(NSString*)nn logoFile:(NSString *)lf {
 [[NSUserDefaults standardUserDefaults] setObject:ident forKey:@"identifier"];
 [[NSUserDefaults standardUserDefaults] setObject:un forKey:@"username"];
 [[NSUserDefaults standardUserDefaults] setObject:nn forKey:@"nickname"];
 if (lf) [[NSUserDefaults standardUserDefaults] setObject:lf forKey:@"logoFile"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 
 // set up selfId to allow location api call to get the shortId
 self.api.selfId = ident;
 }
 */
/*
 - (void)setNickname:(NSString*)nickname logoFilename:(NSString *)lf {
 [[NSUserDefaults standardUserDefaults] setObject:nickname forKey:@"nickname"];
 [[NSUserDefaults standardUserDefaults] setObject:lf forKey:@"logoFile"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 */

/*
 - (void)setMyLogoUrl:(NSString*)lu logoData:(NSData *)logoData {
 [[NSUserDefaults standardUserDefaults] setObject:lu forKey:@"logoUrl"];
 [[NSUserDefaults standardUserDefaults] setObject:logoData forKey:@"logoData"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 - (NSData*)logoData {
 return [[NSUserDefaults standardUserDefaults] dataForKey:@"logoData"];
 }
 
 - (NSString*)identifier {
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"identifier"];
 }
 - (NSString*)username {
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
 }
 - (NSString*)password {
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
 }
 - (NSString*)nickname {
 // NSLog(@"dngclient: nickname:%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"]);
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
 }
 - (NSString*)logoFile {
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"logoFile"];
 }
 - (NSString*)groupId {
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"groupId"];
 }
 - (NSString*)playerId {
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"playerId"];
 }
 - (NSNumber*)saveInfoFlag {
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"saveInfoFlag"];
 }
 - (NSNumber*)autoLoginFlag {
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"autoLoginFlag"];
 }
 
 
 - (void)setSaveInfoFlag:(NSNumber *)saveInfoFlag {
 [[NSUserDefaults standardUserDefaults] setObject:saveInfoFlag forKey:@"saveInfoFlag"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 - (void)setAutoLoginFlag:(NSNumber *)autoLoginFlag {
 [[NSUserDefaults standardUserDefaults] setObject:autoLoginFlag forKey:@"autoLoginFlag"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 - (void)setPassword:(NSString *)password {
 [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 - (void)setLogoFile:(NSString *)myLogoFile {
 [[NSUserDefaults standardUserDefaults] setObject:myLogoFile forKey:@"logoFile"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 - (void)setIdentifier:(NSString *)ident {
 [[NSUserDefaults standardUserDefaults] setObject:ident forKey:@"identifier"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 - (void)setNickname:(NSString*)myNickname {
 // NSLog(@"dngclient: setNickname:%@", myNickname);
 [[NSUserDefaults standardUserDefaults] setObject:myNickname forKey:@"nickname"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 - (void)setUsername:(NSString*)myUsername {
 [[NSUserDefaults standardUserDefaults] setObject:myUsername forKey:@"username"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 
 - (NSArray *) getArrayOfFoldersUpToCurrentLayer {
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"arrayOfFoldersUpToCurrentLayer"];
 }
 - (void)setArrayOfFoldersUpToCurrentLayer:(NSArray *)pathArray {
 [[NSUserDefaults standardUserDefaults] setObject:pathArray forKey:@"arrayOfFoldersUpToCurrentLayer"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 
 - (NSArray *) getArrayOfFoldersInCurrentLayer {
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"arrayOfFoldersInCurrentLayer"];
 }
 - (void)setArrayOfFoldersInCurrentLayer:(NSArray *)folderArray {
 [[NSUserDefaults standardUserDefaults] setObject:folderArray forKey:@"arrayOfFoldersInCurrentLayer"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 
 - (NSArray *) getArrayOfPhrasesInCurrentLayer {
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"arrayOfPhrasesInCurrentLayer"];
 }
 - (void)setArrayOfPhrasesInCurrentLayer:(NSArray *)phraseArray {
 [[NSUserDefaults standardUserDefaults] setObject:phraseArray forKey:@"arrayOfPhrasesInCurrentLayer"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 
 - (NSArray *) getArrayOfSelectedPhrases {
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"arrayOfSelectedPhrases"];
 }
 - (void)setArrayOfSelectedPhrases:(NSArray *)selectedArray {
 [[NSUserDefaults standardUserDefaults] setObject:selectedArray forKey:@"arrayOfSelectedPhrases"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 
 - (NSString *) getRandomPhraseCount {
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"randomPhraseCount"];
 }
 - (void)setRandomPhraseCount:(NSString *)count {
 [[NSUserDefaults standardUserDefaults] setObject:count forKey:@"randomPhraseCount"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 
 - (NSString *) getDrawTime {
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"drawTime"];
 }
 - (void)setDrawTime:(NSString *)seconds {
 [[NSUserDefaults standardUserDefaults] setObject:seconds forKey:@"drawTime"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 
 - (NSNumber *) getPlayerLanguage {
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"playerLanguage"];
 }
 - (void)setPlayerLanguage:(NSNumber *)language {
 [[NSUserDefaults standardUserDefaults] setObject:language forKey:@"playerLanguage"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 
 - (NSString *) getPlayerAge {
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"playerAge"];
 }
 - (void)setPlayerAge:(NSString *)age {
 [[NSUserDefaults standardUserDefaults] setObject:age forKey:@"playerAge"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 
 - (NSString *) getPlayerInterests {
 return [[NSUserDefaults standardUserDefaults] objectForKey:@"playerInterests"];
 }
 - (void)setPlayerInterests:(NSString *)interests {
 [[NSUserDefaults standardUserDefaults] setObject:interests forKey:@"playerInterests"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 */


/*
 - (void)groupId:(NSString*)gId playerId:(NSString *)pId {
 [[NSUserDefaults standardUserDefaults] setObject:gId forKey:@"groupId"];
 [[NSUserDefaults standardUserDefaults] setObject:pId forKey:@"playerId"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 */
/*
 - (void)groupId:(NSString*)gId {
 [[NSUserDefaults standardUserDefaults] setObject:gId forKey:@"groupId"];
 [[NSUserDefaults standardUserDefaults] synchronize];
 }
 */

- (void) playClick {
    // Play a sound!
    AudioServicesPlaySystemSound(soundFileObject);
}

-(USAVClient*)init {

	if (nil != usavClient) {
		return usavClient;
	}
	else {
		if (self = [super init]) {
			usavClient = self;
            self.userHasLogin = NO;
			self.api = [[API alloc] initWithURLPrefix:URL_PREFIX];
			self.progressViewController = [[ProgressViewController alloc] initWithNibName:nil bundle:nil];
			self.progressViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
			// self.processor = [[EventProcessor alloc] init];
            
            dateFormatter = [[NSDateFormatter alloc] init];
            
            [dateFormatter setLocale:[NSLocale systemLocale]];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
            
             /*
             NSString *url = [NSString stringWithFormat:@"%@/event", URL_PREFIX];
             self.eventListener = [[EventListener alloc] initWithURL:url];
             self.eventListener.delegate = self.processor;
             */
            
            /*
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)([NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tap" ofType:@"caf"]]), &soundFileObject);
            */
            /*
             NSString *tapPath = [[NSBundle mainBundle] pathForResource:@"tap"  ofType:@"caf"];
             CFURLRef tapURL = (__bridge CFURLRef ) [NSURL fileURLWithPath:tapPath];
             AudioServicesCreateSystemSoundID (tapURL, &soundFileObject);
             AudioServicesPlaySystemSound (soundFileObject);
             */
			return self;
		}
		else {
			return nil;
		}
	}
}

+(USAVClient*) current {
    
	return usavClient;
}

/*
 -(void)startListenToEvents:(id)target {
 if (self.eventListener == nil) {
 NSString *url = [NSString stringWithFormat:@"%@/usav/event2", URL_PREFIX];
 self.eventListener = [[EventListener alloc] initWithURL:url];
 }
 //self.eventListener.delegate = self.processor;
 self.eventListener.delegate = target;
 }
 
 -(void)stopListenToEvent {
 [self.eventListener stopToListen];
 self.eventListener = nil;
 }
 
 -(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
 }
 
 -(void)alert:(NSString*)title message:(NSString*)message {
 alertView.title = title;
 alertView.message = message;
 [alertView show];
 }
 */

#pragma mark 2014-09-04注释
//
//-(void)startProgress {
//	USAVAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//	[progressViewController.activity startAnimating];
//	[delegate.window addSubview:progressViewController.view];
//	
//}

//-(void)stopProgress {
//	[progressViewController.activity stopAnimating];
//	[progressViewController.view removeFromSuperview];
//}

// - (NSDictionary*)getLoginObjFromStorage {
/*
 NSDictionary *loginObject = [NSDictionary dictionaryWithObjectsAndKeys:
 self.usernameTextField.text, @"username",
 self.passwordTextField.text, @"password",
 self.nicknameTextField.text, @"nickname",
 [NSNumber numberWithBool:self.autoLoginFlag], @"autoLoginFlag",
 [NSNumber numberWithBool:self.saveInfoFlag], @"saveInfoFlag",
 dict, @"userObj", nil];
 */

/*
 NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
 
 NSDictionary *tmp_d = [ud objectForKey:@"LoginObj"];
 NSDictionary *p;
 if (tmp_d == nil) {
 p = [[NSDictionary alloc] init];
 [ud setObject:p forKey:@"LoginObj"];
 [ud synchronize];
 return p;
 }
 else {
 p = [[NSDictionary alloc] initWithDictionary:tmp_d ];
 }
 */
/*
 NSDictionary *p = [NSDictionary dictionaryWithObjectsAndKeys:
 [self username], @"username",
 [self password], @"password",
 [self nickname], @"nickname",
 [self autoLoginFlag], @"autoLoginFlag",
 [self saveInfoFlag], @"saveInfoFlag", nil];
 
 return p;
 */
// }

/*
 - (void)saveLoginObjToStorage:(NSDictionary*)c {
 NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
 [ud setObject:c forKey:@"LoginObj"];
 [ud synchronize];
 }
 */

@end

