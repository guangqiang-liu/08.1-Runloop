# 08.1-Runloop的实际应用场景

我们在平时开发过程中涉及到runloop相关的应用场景大致有如下几种：

* NSTimer创建的定时器在滑动过程中失效
* 控制线程的生命周期
* 多线程
* AutoreleasePool释放对象
* ...

我们先来验证`NSTimer`创建的定时器，在滚动`ScrollView`时，定时器就会停止工作的问题，示例代码如下：

```
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    static int num = 0;
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"-----%d",num ++);
    }];
}
```

我们在当前控制器View上添加一个`UITextView`控件，然后在`viewDidLoad`函数中创建一个定时器，当我们运行项目，定时器可以正常的工作，打印结果如图：

![](https://imgs-1257778377.cos.ap-shanghai.myqcloud.com/QQ20200210-144908@2x.png)

当我们滚动`UITextView`时，发现定时器打印就停止了，如图：

![](https://imgs-1257778377.cos.ap-shanghai.myqcloud.com/QQ20200210-145001@2x.png)

这是因为当没有`ScrollView`滚动事件时，此时的runloop模式为默认模式`kCFRunLoopDefaultMode`，当我们滚动`ScrollView`时，这时runloop的模式就由`kCFRunLoopDefaultMode`切换为`UITrackingRunLoopMode`，`UITrackingRunLoopMode`只处理滚动相关的任务，所以此时的`NSTimer`定时器就失效不能正常工作了，那我们怎么处理即可以让Timer能正常工作，又可以滚动TextView尼?

这时我们可以切换当前runloop的模式，将`kCFRunLoopDefaultMode`改为`kCFRunLoopCommonModes`模式，代码如下：

```
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    static int num = 0;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"-----%d",num ++);
    }];
    
    // 将kCFRunLoopDefaultMode改为kCFRunLoopCommonModes
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
```

从打印可以看出，当我们滚动`UITextView`时，Timer定时器还是可以正常的工作

![](https://imgs-1257778377.cos.ap-shanghai.myqcloud.com/QQ20200210-151006@2x.png)

关于`NSTimer`在runloop中的运用，还有一点需要注意，这时我们换一种创建`Timer`的方式，代码如下：

```
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    static int num = 0;
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"---%d", num ++);
    }];    
}
```

此时我们发现，使用`timerWithTimeInterval:`方式创建的Timer，运行项目发现定时器不工作，而使用`scheduledTimerWithTimeInterval:`方式创建的Timer，直接运行项目Timer是可以正常的工作的，这又是因为什么?

系统提供的两种创建Timer的方式：

```
/// Creates and returns a new NSTimer object initialized with the specified block object. This timer needs to be scheduled on a run loop (via -[NSRunLoop addTimer:]) before it will fire.

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block API_AVAILABLE(macosx(10.12), ios(10.0), watchos(3.0), tvos(10.0));
```

```
/// Creates and returns a new NSTimer object initialized with the specified block object and schedules it on the current run loop in the default mode.

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block API_AVAILABLE(macosx(10.12), ios(10.0), watchos(3.0), tvos(10.0));
```

我们从上面两种创建Timer的官方文档注释中可以看出，`scheduledTimerWithTimeInterval:`是经过定制化的，此函数创建出来的Timer已经自动添加到当前的runloop中了，并且是在默认的模式下的，而`timerWithTimeInterval:`创建出来的Timer并没有自动添加到runloop中，需要开发者手动创建runloop并将timer添加到runloop中timer才可以正常运行，我们修改代码如下：

```
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    static int num = 0;
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"---%d", num ++);
    }];
   
   	// 创建一个runloop，并将timer添加到创建的runloop中
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
```

我们再次运行项目，发现此时timer就可以正常运行了，并且我们滚动`TextView`也可以正常打印而不会导致timer停止工作


讲解示例Demo地址：[https://github.com/guangqiang-liu/08.1-RunloopDemo2]()


## 更多文章
* ReactNative开源项目OneM(1200+star)：**[https://github.com/guangqiang-liu/OneM](https://github.com/guangqiang-liu/OneM)**：欢迎小伙伴们 **star**
* iOS组件化开发实战项目(500+star)：**[https://github.com/guangqiang-liu/iOS-Component-Pro]()**：欢迎小伙伴们 **star**
* 简书主页：包含多篇iOS和RN开发相关的技术文章[http://www.jianshu.com/u/023338566ca5](http://www.jianshu.com/u/023338566ca5) 欢迎小伙伴们：**多多关注，点赞**
* ReactNative QQ技术交流群(2000人)：**620792950** 欢迎小伙伴进群交流学习
* iOS QQ技术交流群：**678441305** 欢迎小伙伴进群交流学习