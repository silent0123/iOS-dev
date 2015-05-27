/* Copyright (c) 2012 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#import "SGDUtilities.h"

@implementation SGDUtilities

+ (XHHUDView *) convertRFC822TimeStringToLocalTime:(NSString *)rfc822TimeStr
{
    NSDateFormatter *rfc3339TimestampFormatterWithTimeZone = [[NSDateFormatter alloc] init];
    [rfc3339TimestampFormatterWithTimeZone setLocale:[NSLocale systemLocale]];
    [rfc3339TimestampFormatterWithTimeZone setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    NSDate *theDate = nil;
    NSError *error = nil;
    if (![rfc3339TimestampFormatterWithTimeZone getObjectValue:&theDate forString:rfc822TimeStr range:nil error:&error]) {
        NSLog(@"Date '%@' could not be parsed: %@", rfc822TimeStr, error);
    }
    
    NSInteger seconds = [[NSTimeZone systemTimeZone] secondsFromGMT];
    NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
    [localDateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    [localDateFormatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: seconds]];
    return [localDateFormatter stringFromDate: theDate];
}

+ (XHHUDView *)showLoadingMessageWithTitle:(NSString *)title
                                    delegate:(id)delegate {
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *systemVersion = currentDevice.systemVersion;
    float iosVersion = systemVersion.floatValue;
    
    if (iosVersion) {
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil, nil];
        
        
        [alert show];
        
         */
        
         /*
        UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        progressView.center = CGPointMake(alert.window.bounds.size.width/2,
                                          alert.window.bounds.size.height/2 - 70);
        progressView.trackTintColor=[UIColor blackColor];
        [alert.window addSubview:progressView];
          */
        
        //
        UIView *viewForAlert = [[UIView alloc] initWithFrame:((UIViewController *)delegate).view.frame];
        XHHUDView *alert = [viewForAlert showHUDWithText:@"" hudType: kXHHUDLoading animationType:kXHHUDFade];

        [((UIViewController *)delegate).view addSubview:alert];
        
        return alert;
        
        
        
    }
    /*
    else {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [delegate presentViewController:alert animated:YES completion:nil];
        
        return alert;
    }
     */
    
}

+ (UIAlertView *)showLoadingMessageWithTitle:(NSString *)title
                                     message:(NSString *)message
                                    delegate:(id)delegate {
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *systemVersion = currentDevice.systemVersion;
    float iosVersion = systemVersion.floatValue;
    
    if (iosVersion) {
        
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil, nil];
        
        
        [alert show];
        
        
        UIActivityIndicatorView *indicator= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.center = CGPointMake(alert.window.bounds.size.width/2,
                                       alert.window.bounds.size.height/2 - 70);
        [indicator startAnimating];
        [alert.window addSubview:indicator];
        
        UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        progressView.center = CGPointMake(alert.window.bounds.size.width/2,
                                            alert.window.bounds.size.height/2 - 70);
        progressView.trackTintColor=[UIColor blackColor];
        [alert.window addSubview:progressView];
          */
        
        UIView *viewForAlert = [[UIView alloc] initWithFrame:((UIViewController *)delegate).view.frame];
        XHHUDView *alert = [viewForAlert showHUDWithText:@"" hudType: kXHHUDLoading animationType:kXHHUDFade];
        [((UIViewController *)delegate).view addSubview:alert];
        
        return alert;

        
    }
    
    /*
    else {
    
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [delegate presentViewController:alert animated:YES completion:nil];
        
        return alert;
    }
     */
    
}


+ (void)showErrorMessageWithTitle:(NSString *)title
                          message:(NSString*)message
                         delegate:(id)delegate {

    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *systemVersion = currentDevice.systemVersion;
    float iosVersion = systemVersion.floatValue;
    
    if (iosVersion) {
        
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
         */
        
        UIView *viewForAlert = [[UIView alloc] initWithFrame:((UIViewController *)delegate).view.frame];
        XHHUDView *alert = [viewForAlert showHUDWithText:title hudType: kXHHUDError animationType:kXHHUDFade];
        [((UIViewController *)delegate).view addSubview:alert];

        
    }
    
    /*
    else {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            [alert removeFromParentViewController];
        }]];

        [delegate presentViewController:alert animated:YES completion:nil];
    }
         */
}

+ (void)showSuccessMessageWithTitle:(NSString *)title
                            message:(NSString *)message
                           delegate:(id)delegate {
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *systemVersion = currentDevice.systemVersion;
    float iosVersion = systemVersion.floatValue;
    
    if (iosVersion) {
        
        /*
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
         message:message
         delegate:self
         cancelButtonTitle:@"Dismiss"
         otherButtonTitles:nil];
         [alert show];
         */
        
        UIView *viewForAlert = [[UIView alloc] initWithFrame:((UIViewController *)delegate).view.frame];
        XHHUDView *alert = [viewForAlert showHUDWithText:title hudType:kXHHUDSuccess animationType:kXHHUDFade delay:0.4];
        [((UIViewController *)delegate).view addSubview:alert];
        
        
    }
}



@end
