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

// Here you can redefine symbols exported by this library so it doesn't clash with
// other library or the host app that would embed its own reachability library.
// You may use the full name of you library as a prefix.
#undef $SDReachability
#define $SDReachability SDReachability
#undef $SDReachabilityStatus
#define $SDReachabilityStatus SDReachabilityStatus
#undef $SDNotReachable
#define $SDNotReachable SDNotReachable
#undef $SDReachableViaWiFi
#define $SDReachableViaWiFi SDReachableViaWiFi
#undef $SDReachableViaWWAN
#define $SDReachableViaWWAN SDReachableViaWWAN

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
     
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

typedef enum
{
    $SDNotReachable = 0,
    $SDReachableViaWiFi,
    $SDReachableViaWWAN
} $SDReachabilityStatus;

@interface $SDReachability : NSObject

@property (assign, nonatomic, readonly) SCNetworkReachabilityFlags reachabilityFlags;
@property (assign, nonatomic, readonly) $SDReachabilityStatus reachabilityStatus;

@property (assign, nonatomic, readonly, getter=isReachable) BOOL reachable;
@property (assign, nonatomic, readonly, getter=isReachableViaWWAN) BOOL reachableViaWWAN;
@property (assign, nonatomic, readonly, getter=isReachableViaWiFi) BOOL reachableViaWiFi;

/**
 * WWAN may be available, but not active until a connection has been established.
 * WiFi may require a connection for VPN on Demand.
 */
@property (assign, nonatomic, readonly, getter=isConnectionRequired) BOOL connectionRequired;
@property (assign, nonatomic, readonly, getter=isConnectionOnDemand) BOOL connectionOnDemand;
/**
 * Is user intervention required?
 */
@property (assign, nonatomic, readonly, getter=isInterventionRequired) BOOL interventionRequired;

+ ($SDReachability *)reachability;
+ ($SDReachability *)reachabilityWithHostname:(NSString*)hostname;
+ ($SDReachability *)reachabilityWithAddress:(const struct sockaddr_in*)hostAddress;

+ ($SDReachability *)reachabilityWithTarget:(id)target action:(SEL)action;
+ ($SDReachability *)reachabilityWithHostname:(NSString *)hostname target:(id)target action:(SEL)action;
+ ($SDReachability *)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress target:(id)target action:(SEL)action;

- (void)setTarget:(id)target action:(SEL)action;

@end
