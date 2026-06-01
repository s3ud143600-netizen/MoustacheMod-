#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <dlfcn.h>
#include <mach/mach_time.h>

// تعريف دوال IOKit للنقر الحقيقي
typedef void* (*IOHIDEventSystemClientCreate_t)(CFAllocatorRef);
typedef void (*IOHIDEventSystemClientDispatchEvent_t)(void *, void *);
typedef void* (*IOHIDEventCreateDigitizerFingerEvent_t)(CFAllocatorRef, uint64_t, uint32_t, uint32_t, uint32_t, float, float, float, float, bool, bool);

static void* get_iohid_func(const char* name) {
    void* handle = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_GLOBAL);
    return dlsym(handle, name);
}

@interface MoustacheManager : NSObject
+ (void)createFloatingButton;
@end

@implementation MoustacheManager

+ (void)createFloatingButton {
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(50, 200, 70, 70);
    btn.layer.cornerRadius = 35;
    btn.backgroundColor = [UIColor blackColor];
    [btn setTitle:@"👑" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:30];
    
    // إضافة خاصية السحب للزر
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [btn addGestureRecognizer:pan];
    
    // إضافة ضغطة الزر لبدء النقر
    [btn addTarget:self action:@selector(startClicking) forControlEvents:UIControlEventTouchUpInside];
    
    [win addSubview:btn];
}

+ (void)handlePan:(UIPanGestureRecognizer *)p {
    UIView *btn = p.view;
    CGPoint trans = [p translationInView:btn.superview];
    btn.center = CGPointMake(btn.center.x + trans.x, btn.center.y + trans.y);
    [p setTranslation:CGPointZero inView:btn.superview];
}

+ (void)startClicking {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        void* client = ((IOHIDEventSystemClientCreate_t)get_iohid_func("IOHIDEventSystemClientCreate"))(kCFAllocatorDefault);
        auto CreateEvent = (IOHIDEventCreateDigitizerFingerEvent_t)get_iohid_func("IOHIDEventCreateDigitizerFingerEvent");
        auto DispatchEvent = (IOHIDEventSystemClientDispatchEvent_t)get_iohid_func("IOHIDEventSystemClientDispatchEvent");
        
        // حلقة تكرار للنقر (كل 0.5 ثانية)
        while(true) {
            uint64_t ts = mach_absolute_time();
            void* down = CreateEvent(kCFAllocatorDefault, ts, 1, 1, 1, 500, 500, 1.0, 1.0, true, true);
            void* up = CreateEvent(kCFAllocatorDefault, ts, 1, 1, 1, 500, 500, 0.0, 1.0, false, true);
            DispatchEvent(client, down);
            DispatchEvent(client, up);
            [NSThread sleepForTimeInterval:0.5];
        }
    });
} 
@end

// نقطة تشغيل الأداة عند فتح اللعبة
__attribute__((constructor)) static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MoustacheManager createFloatingButton];
    });
}
