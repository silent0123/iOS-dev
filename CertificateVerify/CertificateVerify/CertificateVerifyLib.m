//
//  CertificateVerifyLib.m
//  CertificateVerify
//
//  Created by Luca on 28/5/15.
//  Copyright (c) 2015 Luca. All rights reserved.
//

#import "CertificateVerifyLib.h"

@implementation CertificateVerifyLib


+ (BOOL)getIndentity: (SecIdentityRef *)outIdentity andTrust:(SecTrustRef *)outTrust fromPKCS12Data:(NSData *)inPKCS12Data withPassword: (CFStringRef)certPassword{

    OSStatus securityError = errSecSuccess;
    
    //certificate password - now set as server certificate password
    CFStringRef password = certPassword;
    const void *keys[] = { kSecImportExportPassphrase };    //this password is used during Import/Export this certificate
    const void *values[] = { password };
    
    //import PKCS12 certificate from "inPKCS12Data"
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(kCFAllocatorDefault, keys, values, 1, NULL, NULL);   //set options (password...)
    CFArrayRef items = CFArrayCreate(kCFAllocatorDefault, 0, 0, NULL); //allocate an array to store the certificate items
    securityError = SecPKCS12Import((__bridge CFDataRef)inPKCS12Data, (CFDictionaryRef)optionsDictionary, &items);  //saved in &items
    
    if (!securityError) {
        
        //get items from certificate successful
        CFDictionaryRef identityAndTrust = CFArrayGetValueAtIndex(items, 0);    //get item 0 from items -> contains: identiy & trust
        
        //get identity & trust from items
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue(identityAndTrust, kSecImportItemIdentity);  //get identity
        *outIdentity = (SecIdentityRef)tempIdentity;    //save in outIdentity's memory
        
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue(identityAndTrust, kSecImportItemTrust);    //get trust
        *outTrust = (SecTrustRef)tempTrust;
        
        
    } else {
        NSLog(@"Error occured during get data from PKCS12 certificate, ERROR CODE: %d", securityError);
        return NO;
    }
    
    
    return YES;
}

//from local
- (NSData *)loadPKCS12CertificateDataFromURL: (NSURL *)certURL {
    
    //load from file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *certData = [fileManager contentsAtPath:[certURL path]];
    
    
    return certData;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    
    BOOL  result = [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
    
    NSLog(@"<%p %@: %s line:%d> Result:%s", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __PRETTY_FUNCTION__, __LINE__, (result == YES) ? "YES" : "NO");
    
    return result;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    NSArray *trustedHosts = [NSArray arrayWithObject:@"encrypted.google.com"];  //the root trust CA. can modify by ourselves
    BOOL isAuthMethodServerTrust = [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
    
    NSLog(@"<%p %@: %s line:%d> Result:%s", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __PRETTY_FUNCTION__, __LINE__, (isAuthMethodServerTrust == YES) ? "YES" : "NO");
    
    
    if (isAuthMethodServerTrust)
    {
        if ([trustedHosts containsObject:challenge.protectionSpace.host])
        {
            NSLog(@"<%p %@: %s line:%d> trustedHosts containsObject:challenge.protectionSpace.host", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __PRETTY_FUNCTION__, __LINE__);
            
            NSURLCredential* urlCredential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            NSLog(@"<%p %@: %s line:%d> Url credential", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __PRETTY_FUNCTION__, __LINE__);
            [challenge.sender useCredential:urlCredential forAuthenticationChallenge:challenge];
            
            //verify certificate info
            SecTrustRef trustRef = [[challenge protectionSpace] serverTrust];
            CFIndex count = SecTrustGetCertificateCount(trustRef);
            
            //get all infos
            for (CFIndex i = 0; i < count; i++)
            {
                SecCertificateRef certRef = SecTrustGetCertificateAtIndex(trustRef, i);
                CFStringRef certSummary = SecCertificateCopySubjectSummary(certRef);
                CFDataRef certData = SecCertificateCopyData(certRef);
                NSLog(@"<%p %@: %s line:%d> Certificate summary:%@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __PRETTY_FUNCTION__, __LINE__, (__bridge NSString*) certSummary);
                NSLog(@"<%p %@: %s line:%d> Certificate data:%@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __PRETTY_FUNCTION__, __LINE__, (__bridge NSData*) certData);
                CFRelease(certData);
            }
        }
    }
}

@end
