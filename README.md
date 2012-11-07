# SDReachability

SDReachability is a lightweight rewrite of Apple's Reachability example library focused on easy embedability and usage simplicity.

Most network based library needs Reachability feature but can't embed the Apple implementation without taking the risk to name class with the same library embeded by another library or the hosted app itself. SDReachability solve this issue by letting embeders easily modify symbols exported by the library by adding their own prefix. Additionnaly, SDReachability doesn't relies on global NSNotification but uses target/action pattern.

SDReachability API is revisited in order to be simpler to use. You just have to instanciate it and give it a target object with an action selector. You must store the resulting instance. You don't have to start/stop the notif(i)er, it's started immediatly after initialization and is stopped as soon as its instance is deallocated — which should happen when the host object will be deallocated itself.

## Installation

- Copy the .h/.m files into your project
- In you application project application's target settings, find the "Build Phases" section and open the "Link Binary With Libraries" block
- Click the "+" button again and select the `SystemConfiguration.framework`

## Usage

Check if Internet is reachable:

    SDReachability reach = SDReachability.new;
    if (reach.isReachable)
    {
        NSLog(@"Connected with %@", reach.isReachableViaWWAN ? @"3G" : @"WiFi");
    }
    else
    {
        NSLog(@"Not Connected");
    }

Subscribe to connectivity changes

    @interface MyObject ()

    @property (strong, nonatomic) SDReachability *reachability;

    @end


    @implementation MyObject

    - (void)monitorReachability
    {
        self.reachability = [SDReachability reachabilityWithTarget:self action:@selector(reachabilityChanged:)];
    }

    - (void)reachabilityChanged:(SDReachability *)reachability
    {
        switch (reachability.reachabilityStatus)
        {
            case SDNotReachable:
                NSLog(@"Connection lost");
                break;

            case SDReachableViaWiFi:
                NSLog(@"Connected via WiFi");
                break;

            case SDReachableViaWWAN:
                NSLog(@"Connected via WWAN");
                break;
        }
    }

    @end

## Embedding

If you want to distribute a static library with reachability support, it's a bad idea to just copy the Apple provided Reachability demo class. Chances are that your users will already use this class either directly or through another library, leading to name claching and compilation headache.

SDReachability helps you with embedding by providing an easy way to rename all exported symbols so they won't clash. To embed SDReachability into your project, copy the .h and .m files and modify the `#define` instructions at the top of the .h file like this:

    #undef $SDReachability
    #define $SDReachability MyLibraryReachability
    #undef $SDReachabilityStatus
    #define $SDReachabilityStatus MyLibraryReachabilityStatus
    #undef $SDNotReachable
    #define $SDNotReachable MyLibraryNotReachable
    #undef $SDReachableViaWiFi
    #define $SDReachableViaWiFi MyLibraryReachableViaWiFi
    #undef $SDReachableViaWWAN
    #define $SDReachableViaWWAN MyLibraryReachableViaWWAN

In your library, use MyLibraryReachability instead of SDReachability, same for all other redefined symboles.

## License

All source code is licensed under the [MIT License](https://raw.github.com/rs/SDReachability/master/LICENSE).
