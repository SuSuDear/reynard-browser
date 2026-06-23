//
//  GeckoRuntimeBridge.mm
//  Reynard
//
//  Created by Minh Ton on 24/5/26.
//

#import "GeckoRuntimeBridge.h"

#import "mozilla-config.h"

#include "mozilla/Preferences.h"
#include "nsString.h"

@implementation GeckoRuntimeBridge

+ (NSString *)version {
    return @MOZILLA_VERSION;
}

+ (void)setAcceptLanguages:(NSString *)value {
    if (!value) {
        return;
    }
    mozilla::Preferences::SetCString("intl.accept_languages", nsDependentCString(value.UTF8String));
}

@end
