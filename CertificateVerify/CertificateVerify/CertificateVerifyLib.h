//
//  CertificateVerifyLib.h
//  CertificateVerify
//
//  Created by Luca on 28/5/15.
//  Copyright (c) 2015 Luca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CertificateVerifyLib : NSObject

+ (BOOL)getIndentity: (SecIdentityRef *)outIdentity andTrust:(SecTrustRef *)outTrust fromPKCS12Data:(NSData *)inPKCS12Data withPassword: (CFStringRef)certPassword;

//load certificate from local "Documents" path
- (NSData *)loadPKCS12CertificateDataFromURL: (NSURL *)certURL;

@end
