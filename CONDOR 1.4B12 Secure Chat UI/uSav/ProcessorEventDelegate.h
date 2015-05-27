//
//  ProcessorEventDelegate.h
//  atloco
//
//  Created by liudian on 10-7-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EventProcessor;
@protocol ProcessorEventDelegate

- (void) eventProcessor:(EventProcessor*)ep connectIn:(NSDictionary*)peer;
- (void) eventProcessor:(EventProcessor*)ep connectOut:(NSDictionary*)peer;
- (void) eventProcessor:(EventProcessor*)ep message:(NSDictionary*)msg;
- (void) eventProcessor:(EventProcessor*)ep image:(NSDictionary*)img;
- (void) eventProcessor:(EventProcessor*)ep person:(NSDictionary*)ps;

@end
