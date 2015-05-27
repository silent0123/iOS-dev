//
//  JSONUtil.h
//  atloco
//
//  Created by liudian on 10-7-4.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JSONUtil : NSObject {

}
+ (NSDictionary*)stringToObject:(NSString*)string;
+ (NSString*)objectToString:(NSDictionary*)object;
@end
