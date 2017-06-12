// Generated by Apple Swift version 3.0 (swiftlang-800.0.46.2 clang-800.0.38)
#pragma clang diagnostic push

#if defined(__has_include) && __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if defined(__has_include) && __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if defined(__has_attribute) && __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if defined(__has_attribute) && __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if defined(__has_attribute) && __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if defined(__has_attribute) && __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name) enum _name : _type _name; enum SWIFT_ENUM_EXTRA _name : _type
# if defined(__has_feature) && __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) SWIFT_ENUM(_type, _name)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if defined(__has_feature) && __has_feature(modules)
@import ObjectiveC;
@import ClockKit;
@import Foundation;
@import WatchKit;
@import WatchConnectivity;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
@class CLKComplication;
@class CLKComplicationTimelineEntry;
@class CLKComplicationTemplate;

SWIFT_CLASS("_TtC28wiredline_WatchKit_Extension22ComplicationController")
@interface ComplicationController : NSObject <CLKComplicationDataSource>
- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication * _Nonnull)complication withHandler:(void (^ _Nonnull)(CLKComplicationTimeTravelDirections))handler;
- (void)getTimelineStartDateForComplication:(CLKComplication * _Nonnull)complication withHandler:(void (^ _Nonnull)(NSDate * _Nullable))handler;
- (void)getTimelineEndDateForComplication:(CLKComplication * _Nonnull)complication withHandler:(void (^ _Nonnull)(NSDate * _Nullable))handler;
- (void)getPrivacyBehaviorForComplication:(CLKComplication * _Nonnull)complication withHandler:(void (^ _Nonnull)(CLKComplicationPrivacyBehavior))handler;
- (void)getCurrentTimelineEntryForComplication:(CLKComplication * _Nonnull)complication withHandler:(void (^ _Nonnull)(CLKComplicationTimelineEntry * _Nullable))handler;
- (void)getTimelineEntriesForComplication:(CLKComplication * _Nonnull)complication beforeDate:(NSDate * _Nonnull)date limit:(NSInteger)limit withHandler:(void (^ _Nonnull)(NSArray<CLKComplicationTimelineEntry *> * _Nullable))handler;
- (void)getTimelineEntriesForComplication:(CLKComplication * _Nonnull)complication afterDate:(NSDate * _Nonnull)date limit:(NSInteger)limit withHandler:(void (^ _Nonnull)(NSArray<CLKComplicationTimelineEntry *> * _Nullable))handler;
- (void)getNextRequestedUpdateDateWithHandler:(void (^ _Nonnull)(NSDate * _Nullable))handler;
- (void)getPlaceholderTemplateForComplication:(CLKComplication * _Nonnull)complication withHandler:(void (^ _Nonnull)(CLKComplicationTemplate * _Nullable))handler;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC28wiredline_WatchKit_Extension17ExtensionDelegate")
@interface ExtensionDelegate : NSObject <WKExtensionDelegate>
- (void)applicationDidFinishLaunching;
- (void)applicationDidBecomeActive;
- (void)applicationWillResignActive;
- (void)DisconnectServer;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class WCSession;
@class WKInterfaceButton;
@class WKInterfaceLabel;

SWIFT_CLASS("_TtC28wiredline_WatchKit_Extension19InterfaceController")
@interface InterfaceController : WKInterfaceController <WCSessionDelegate>
/**
  Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details.
*/
- (void)session:(WCSession * _Nonnull)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError * _Nullable)error;
@property (nonatomic, strong) IBOutlet WKInterfaceButton * _Nullable disbutton;
@property (nonatomic, strong) IBOutlet WKInterfaceLabel * _Nullable serverlabel;
@property (nonatomic, strong) WCSession * _Null_unspecified session;
- (void)awakeWithContext:(id _Nullable)context;
- (IBAction)pushDisConnect:(id _Nonnull)sender;
- (void)willActivate;
- (void)didDeactivate;
- (void)session:(WCSession * _Nonnull)session didReceiveMessage:(NSDictionary<NSString *, id> * _Nonnull)message replyHandler:(void (^ _Nonnull)(NSDictionary<NSString *, id> * _Nonnull))replyHandler;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end


SWIFT_CLASS("_TtC28wiredline_WatchKit_Extension22NotificationController")
@interface NotificationController : WKUserNotificationInterfaceController
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
- (void)willActivate;
- (void)didDeactivate;
@end

@class WKInterfaceTable;

SWIFT_CLASS("_TtC28wiredline_WatchKit_Extension13watchUserlist")
@interface watchUserlist : WKInterfaceController <WCSessionDelegate>
/**
  Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details.
*/
- (void)session:(WCSession * _Nonnull)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError * _Nullable)error;
@property (nonatomic, strong) IBOutlet WKInterfaceTable * _Null_unspecified userlisttable;
@property (nonatomic, copy) NSArray<NSString *> * _Nonnull userlist;
@property (nonatomic, copy) NSArray<NSString *> * _Nonnull wiredcolor;
@property (nonatomic, strong) WCSession * _Null_unspecified session;
- (void)willActivate;
- (void)watchuserlistreload:(NSNotification * _Nonnull)nf;
- (void)loadTableData;
- (void)session:(WCSession * _Nonnull)session didReceiveMessage:(NSDictionary<NSString *, id> * _Nonnull)message replyHandler:(void (^ _Nonnull)(NSDictionary<NSString *, id> * _Nonnull))replyHandler;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

@class WKInterfaceImage;

SWIFT_CLASS("_TtC28wiredline_WatchKit_Extension23watchUserlistController")
@interface watchUserlistController : NSObject
@property (nonatomic, strong) IBOutlet WKInterfaceLabel * _Null_unspecified userlabel;
@property (nonatomic, strong) IBOutlet WKInterfaceImage * _Null_unspecified iconimage;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end

#pragma clang diagnostic pop