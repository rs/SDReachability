/*
 * Copyright (c) 2012 Olivier Poitrey <rs@dailymotion.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is furnished
 * to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#ifdef __OBJC_GC__
#error SDReachability does not support Objective-C Garbage Collection
#endif

#if !__has_feature(objc_arc)
#error SDReachability is ARC only. Either turn on ARC for the project or use -fobjc-arc flag on this file
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
#error SDReachability doesn't support Deployement Target version < 5.0
#endif

#import "SDReachability.h"
#import <objc/message.h>

@interface $SDReachability ()

@property (assign, nonatomic) SCNetworkReachabilityRef reachabilityRef;
@property (assign, nonatomic, readwrite) SCNetworkReachabilityFlags reachabilityFlags;
@property (weak, nonatomic) id target;
@property (assign, nonatomic) SEL action;

@end

@implementation $SDReachability

+ ($SDReachability *)reachability
{
    return self.new;
}

+ ($SDReachability *)reachabilityWithTarget:(id)target action:(SEL)action
{
    $SDReachability *reachability = self.new;
    [reachability setTarget:target action:action];
    return reachability;
}

+ ($SDReachability *)reachabilityWithHostname:(NSString*)hostname
{
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [hostname UTF8String]);
    return ref ? [self.alloc initWithReachabilityRef:ref] : nil;
}

+ ($SDReachability *)reachabilityWithHostname:(NSString*)hostname target:(id)target action:(SEL)action
{
    $SDReachability *reachability = [self reachabilityWithHostname:hostname];
    [reachability setTarget:target action:action];
    return reachability;
}

+ ($SDReachability *)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress
{
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);
    return ref ? [[self alloc] initWithReachabilityRef:ref] : nil;
}

+ ($SDReachability *)reachabilityWithAddress:(const struct sockaddr_in*)hostAddress target:(id)target action:(SEL)action
{
    $SDReachability *reachability = [self reachabilityWithAddress:hostAddress];
    [reachability setTarget:target action:action];
    return reachability;
}

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info)
{
#pragma unused (target, flags)
    // We're on the main RunLoop, so an NSAutoreleasePool is not necessary, but is added defensively
    // in case someon uses the Reachablity object in a different thread.
    @autoreleasepool
    {
        __strong $SDReachability *reachability = ((__bridge $SDReachability *)info);
        if (reachability)
        {
            objc_msgSend(reachability.target, reachability.action, reachability);
        }
    }
}

- (id)init
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
    return ref ? [self initWithReachabilityRef:ref] : nil;
}

- (id)initWithReachabilityRef:(SCNetworkReachabilityRef)ref
{
    if ((self = [super init]))
    {
        self.reachabilityRef = ref;
    }

    return self;
}

- (void)setTarget:(id)target action:(SEL)action;
{
    if (target)
    {
        NSParameterAssert(action != nil);
    }

    if (!self.target && target)
    {
        SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
        if(SCNetworkReachabilitySetCallback(self.reachabilityRef, ReachabilityCallback, &context))
        {
            SCNetworkReachabilityScheduleWithRunLoop(self.reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        }
    }
    else if (self.target && !target)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(self.reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }

    self.target = target;
    self.action = action;
}

- (void)dealloc
{
    [self setTarget:nil action:nil]; // triggers runloop unscheduling
    CFRelease(self.reachabilityRef);
}

- (SCNetworkReachabilityFlags)reachabilityFlags
{
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags);
    return flags;
}

- ($SDReachabilityStatus)reachabilityStatus
{
    SCNetworkReachabilityFlags flags = self.reachabilityFlags;
    if (flags)
    {
        if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
        {
            // if target host is not reachable
            return $SDNotReachable;
        }

        $SDReachabilityStatus status = $SDNotReachable;

        if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
        {
            // if target host is reachable and no connection is required
            //  then we'll assume (for now) that your on Wi-Fi
            status = $SDReachableViaWiFi;
        }


        if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
             (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
        {
            // ... and the connection is on-demand (or on-traffic) if the
            //     calling application is using the CFSocketStream or higher APIs
            if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
            {
                // ... and no [user] intervention is needed
                status = $SDReachableViaWiFi;
            }
        }

        if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
        {
            // ... but WWAN connections are OK if the calling application
            //     is using the CFNetwork (CFSocketStream?) APIs.
            status = $SDReachableViaWWAN;
        }

        return status;
    }
    else
    {
        return $SDNotReachable;
    }
}

- (BOOL)isReachable
{
    return self.reachabilityStatus != $SDNotReachable;
}

- (BOOL)isReachableViaWiFi
{
    return self.reachabilityStatus == $SDReachableViaWiFi;
}

- (BOOL)isReachableViaWWAN
{
    return self.reachabilityStatus == $SDReachableViaWWAN;
}

- (BOOL)isConnectionRequired
{
    SCNetworkReachabilityFlags flags = self.reachabilityFlags;
    return flags && (self.reachabilityFlags & kSCNetworkReachabilityFlagsConnectionRequired);
}

- (BOOL)isConnectionOnDemand
{
    SCNetworkReachabilityFlags flags = self.reachabilityFlags;
    return flags && (flags & kSCNetworkReachabilityFlagsConnectionRequired) && (flags & (kSCNetworkReachabilityFlagsConnectionOnTraffic | kSCNetworkReachabilityFlagsConnectionOnDemand));
}

- (BOOL)isInterventionRequired
{
    SCNetworkReachabilityFlags flags = self.reachabilityFlags;
    return flags && (flags & kSCNetworkReachabilityFlagsConnectionRequired) && (flags & kSCNetworkReachabilityFlagsInterventionRequired);
}

@end
