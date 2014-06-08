/**
 * Touch Code Titanium Project
 * Copyright (c) 2014 by Benjamin Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiTouchcodeTouchIDProxy.h"
#import "TiUtils.h"

@import LocalAuthentication;

@implementation TiTouchcodeTouchIDProxy


-(NSNumber*) isSupported: (id)unused
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    return NUMBOOL(self.canEvaluatePolicy);
#else
    return NUMBOOL(NO);
#endif

}

-(void) showDialog : (id)args
{
    ENSURE_SINGLE_ARG(args,NSDictionary);

    if (![args objectForKey:@"completed"]) {
        NSLog(@"[ERROR] completed callback is required");
        return;
    }

    if (![args objectForKey:@"reason"]) {
        NSLog(@"[ERROR] Reason is required");
        return;
    }

    __block  KrollCallback* callback = [args objectForKey:@"completed"];

    NSString* reason = [TiUtils stringValue:@"reason" properties:args];

    LAContext *context = [[LAContext alloc] init];

    // show the authentication UI with our reason string
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:
     ^(BOOL success, NSError *authenticationError) {

         NSMutableDictionary *event = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  NUMBOOL(success), @"success",
                                  nil
                                  ];

         if (success == NO) {
             [event setObject:authenticationError.localizedDescription forKey:@"message"];
         }

         if(callback){
             [self _fireEventToListener:@"completed"
                             withObject:eventOk listener:callback thisObject:nil];
         }

     }];

}
#pragma mark - Tests

- (BOOL)canEvaluatePolicy
{
    LAContext *context = [[LAContext alloc] init];
    NSError *error;

    // test if we can evaluate the policy, this test will tell us if Touch ID is available and enrolled
    BOOL success = [context canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    return success;
}


@end
