# NSThreadDemo

# 一、什么是NSThread

NSThread是基于线程使用，轻量级的多线程编程方法（相对GCD和NSOperation），一个NSThread对象代表一个线程，需要手动管理线程的生命周期，处理线程同步等问题。

# 二、NSThread方法介绍

1）动态创建

NSThread * newThread = [[NSThread alloc]initWithTarget:self selector:@selector(threadRun) object:nil];

动态方法返回一个新的thread对象，需要调用start方法来启动线程

2）静态创建

[NSThread detachNewThreadSelector:@selector(threadRun) toTarget:self withObject:nil];

由于静态方法没有返回值，如果需要获取新创建的thread，需要在selector中调用获取当前线程的方法

3）线程开启

[newThread start];

4）线程暂停

[NSThread sleepForTimeInterval:1.0];　（以暂停一秒为例）
[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];

NSThread的暂停会有阻塞当前线程的效果

5）线程取消

[newThread cancel];

取消线程并不会马上停止并退出线程，仅仅只作（线程是否需要退出）状态记录

6）线程停止

[NSThread exit];

停止方法会立即终止除主线程以外所有线程（无论是否在执行任务）并退出，需要在掌控所有线程状态的情况下调用此方法，否则可能会导致内存问题。

7）获取当前线程

[NSThread currentThread];

8）获取主线程

[NSThread mainThread];

9）线程优先级设置

iOS 8以前使用

[NSThread setThreadPriority:1.0];

这个方法的优先级的数值设置让人困惑，因为你不知道你应该设置多大的值是比较合适的，因此在iOS8之后，threadPriority添加了一句注释：To be deprecated; use qualityOfService below

意思就是iOS 8以后推荐使用qualityOfService属性，通过量化的优先级枚举值来设置

qualityOfService的枚举值如下：

NSQualityOfServiceUserInteractive：最高优先级，用于用户交互事件
NSQualityOfServiceUserInitiated：次高优先级，用于用户需要马上执行的事件
NSQualityOfServiceDefault：默认优先级，主线程和没有设置优先级的线程都默认为这个优先级
NSQualityOfServiceUtility：普通优先级，用于普通任务
NSQualityOfServiceBackground：最低优先级，用于不重要的任务

比如给线程设置次高优先级：

[newThread setQualityOfService:NSQualityOfServiceUserInitiated];

# 三、线程间通信

常用的有三种：

1、指定当前线程执行操作

[self performSelector:@selector(threadRun)];
[self performSelector:@selector(threadRun) withObject:nil];
[self performSelector:@selector(threadRun) withObject:nil afterDelay:2.0];

2、（在其他线程中）指定主线程执行操作

[self performSelectorOnMainThread:@selector(threadRun) withObject:nil waitUntilDone:YES];

注意：更新UI要在主线程中进行

3、（在主线程中）指定其他线程执行操作

[self performSelector:@selector(threadRun) onThread:newThread withObject:nil waitUntilDone:YES]; //这里指定为某个线程
[self performSelectorInBackground:@selector(threadRun) withObject:nil];//这里指定为后台线程

# 四、线程同步

线程和其他线程可能会共享一些资源，当多个线程同时读写同一份共享资源的时候，可能会引起冲突。线程同步是指是指在一定的时间内只允许某一个线程访问某个资源

iOS实现线程加锁有NSLock和@synchronized两种方式。

# 五、线程的创建和使用实例：模拟售票

情景：某演唱会门票发售，在广州和北京均开设窗口进行销售，以下是代码实现

先监听线程退出的通知，以便知道线程什么时候退出

[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(threadExitNotice) name:NSThreadWillExitNotification object:nil];

设置演唱会的门票数量

_ticketCount = 50;

新建两个子线程（代表两个窗口同时销售门票）

NSThread * window1 = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicket) object:nil];
window1.name = @"北京售票窗口";
[window1 start];
NSThread * window2 = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicket) object:nil];
window2.name = @"广州售票窗口";
[window2 start];
线程启动后，执行saleTicket，执行完毕后就会退出，为了模拟持续售票的过程，我们需要给它加一个循环
- (void)saleTicket {
while (1) {
//如果还有票，继续售卖
if (_ticketCount > 0) {
_ticketCount --;
NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", _ticketCount, [NSThread currentThread].name]);
[NSThread sleepForTimeInterval:0.2];
}
//如果已卖完，关闭售票窗口
else {
break;
}
}
}

执行结果：

2016-04-06 19:25:36.637 MutiThread[4705:1371666] 剩余票数：9 窗口：广州售票窗口

2016-04-06 19:25:36.637 MutiThread[4705:1371665] 剩余票数：8 窗口：北京售票窗口

2016-04-06 19:25:36.839 MutiThread[4705:1371666] 剩余票数：7 窗口：广州售票窗口

2016-04-06 19:25:36.839 MutiThread[4705:1371665] 剩余票数：7 窗口：北京售票窗口

2016-04-06 19:25:37.045 MutiThread[4705:1371666] 剩余票数：5 窗口：广州售票窗口

2016-04-06 19:25:37.045 MutiThread[4705:1371665] 剩余票数：6 窗口：北京售票窗口

2016-04-06 19:25:37.250 MutiThread[4705:1371665] 剩余票数：4 窗口：北京售票窗口

2016-04-06 19:25:37.250 MutiThread[4705:1371666] 剩余票数：4 窗口：广州售票窗口

2016-04-06 19:25:37.456 MutiThread[4705:1371666] 剩余票数：2 窗口：广州售票窗口

2016-04-06 19:25:37.456 MutiThread[4705:1371665] 剩余票数：3 窗口：北京售票窗口

2016-04-06 19:25:37.661 MutiThread[4705:1371665] 剩余票数：1 窗口：北京售票窗口

2016-04-06 19:25:37.661 MutiThread[4705:1371666] 剩余票数：1 窗口：广州售票窗口

2016-04-06 19:25:37.866 MutiThread[4705:1371665] 剩余票数：0 窗口：北京售票窗口

2016-04-06 19:25:37.867 MutiThread[4705:1371666] <nsthread: 0x7fdc91e289f0>{number = 3, name = 广州售票窗口} Will Exit

2016-04-06 19:25:38.070 MutiThread[4705:1371665] <nsthread: 0x7fdc91e24d60>{number = 2, name = 北京售票窗口} Will Exit</nsthread: 0x7fdc91e24d60></nsthread: 0x7fdc91e289f0>

可以看到，票的销售过程中出现了剩余数量错乱的情况，这就是前面提到的线程同步问题。

售票是一个典型的需要线程同步的场景，由于售票渠道有很多，而票的资源是有限的，当多个渠道在短时间内卖出大量的票的时候，如果没有同步机制来管理票的数量，将会导致票的总数和售出票数对应不上的错误。

我们在售票的过程中给票加上同步锁：同一时间内，只有一个线程能对票的数量进行操作，当操作完成之后，其他线程才能继续对票的数量进行操作。

- (void)saleTicket {
while (1) {
@synchronized(self) {
//如果还有票，继续售卖
if (_ticketCount > 0) {
_ticketCount --;
NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", _ticketCount, [NSThread currentThread].name]);
[NSThread sleepForTimeInterval:0.2];
}
//如果已卖完，关闭售票窗口
else {
break;
}
}
}
}


运行结果：

2016-04-06 19:31:27.913 MutiThread[4718:1406865] 剩余票数：11 窗口：北京售票窗口

2016-04-06 19:31:28.115 MutiThread[4718:1406866] 剩余票数：10 窗口：广州售票窗口

2016-04-06 19:31:28.317 MutiThread[4718:1406865] 剩余票数：9 窗口：北京售票窗口

2016-04-06 19:31:28.522 MutiThread[4718:1406866] 剩余票数：8 窗口：广州售票窗口

2016-04-06 19:31:28.728 MutiThread[4718:1406865] 剩余票数：7 窗口：北京售票窗口

2016-04-06 19:31:28.929 MutiThread[4718:1406866] 剩余票数：6 窗口：广州售票窗口

2016-04-06 19:31:29.134 MutiThread[4718:1406865] 剩余票数：5 窗口：北京售票窗口

2016-04-06 19:31:29.339 MutiThread[4718:1406866] 剩余票数：4 窗口：广州售票窗口

2016-04-06 19:31:29.545 MutiThread[4718:1406865] 剩余票数：3 窗口：北京售票窗口

2016-04-06 19:31:29.751 MutiThread[4718:1406866] 剩余票数：2 窗口：广州售票窗口

2016-04-06 19:31:29.952 MutiThread[4718:1406865] 剩余票数：1 窗口：北京售票窗口

2016-04-06 19:31:30.158 MutiThread[4718:1406866] 剩余票数：0 窗口：广州售票窗口

2016-04-06 19:31:30.363 MutiThread[4718:1406866] <nsthread: 0x7ff0c1637320>{number = 3, name = 广州售票窗口} Will Exit

2016-04-06 19:31:30.363 MutiThread[4718:1406865] <nsthread: 0x7ff0c1420cb0>{number = 2, name = 北京售票窗口} Will Exit</nsthread: 0x7ff0c1420cb0></nsthread: 0x7ff0c1637320>


可以看到，票的数量没有出现错乱的情况。

线程的持续运行和退出

我们注意到，线程启动后，执行saleTicket完毕后就马上退出了，怎样能让线程一直运行呢（窗口一直开放，可以随时指派其卖演唱会的门票的任务），答案就是给线程加上runLoop

//先监听线程退出的通知，以便知道线程什么时候退出
[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(threadExitNotice) name:NSThreadWillExitNotification object:nil];
//设置演唱会的门票数量
_ticketCount = 50;

新建两个子线程（代表两个窗口同时销售门票）

NSThread * window1 = [[NSThread alloc]initWithTarget:self selector:@selector(thread1) object:nil];
[window1 start];
NSThread * window2 = [[NSThread alloc]initWithTarget:self selector:@selector(thread2) object:nil];
[window2 start];

接着我们给线程创建一个runLoop

- (void)thread1 {
[NSThread currentThread].name = @"北京售票窗口";
NSRunLoop * runLoop1 = [NSRunLoop currentRunLoop];
[runLoop1 runUntilDate:[NSDate date]]; //一直运行
}
- (void)thread2 {
[NSThread currentThread].name = @"广州售票窗口";
NSRunLoop * runLoop2 = [NSRunLoop currentRunLoop];
[runLoop2 runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10.0]]; //自定义运行时间
}

然后就可以指派任务给线程了，这里我们让两个线程都执行相同的任务（售票）

[self performSelector:@selector(saleTicket) onThread:window1 withObject:nil waitUntilDone:NO];
[self performSelector:@selector(saleTicket) onThread:window2 withObject:nil waitUntilDone:NO];

运行结果：

2016-04-06 19:43:22.585 MutiThread[4762:1478200] 剩余票数：11 窗口：北京售票窗口

2016-04-06 19:43:22.788 MutiThread[4762:1478201] 剩余票数：10 窗口：广州售票窗口

2016-04-06 19:43:22.993 MutiThread[4762:1478200] 剩余票数：9 窗口：北京售票窗口

2016-04-06 19:43:23.198 MutiThread[4762:1478201] 剩余票数：8 窗口：广州售票窗口

2016-04-06 19:43:23.404 MutiThread[4762:1478200] 剩余票数：7 窗口：北京售票窗口

2016-04-06 19:43:23.609 MutiThread[4762:1478201] 剩余票数：6 窗口：广州售票窗口

2016-04-06 19:43:23.810 MutiThread[4762:1478200] 剩余票数：5 窗口：北京售票窗口

2016-04-06 19:43:24.011 MutiThread[4762:1478201] 剩余票数：4 窗口：广州售票窗口

2016-04-06 19:43:24.216 MutiThread[4762:1478200] 剩余票数：3 窗口：北京售票窗口

2016-04-06 19:43:24.422 MutiThread[4762:1478201] 剩余票数：2 窗口：广州售票窗口

2016-04-06 19:43:24.628 MutiThread[4762:1478200] 剩余票数：1 窗口：北京售票窗口

2016-04-06 19:43:24.833 MutiThread[4762:1478201] 剩余票数：0 窗口：广州售票窗口

2016-04-06 19:43:25.039 MutiThread[4762:1478201] <nsthread: 0x7fe0d3c24360>{number = 3, name = 广州售票窗口} Will Exit</nsthread: 0x7fe0d3c24360>

可以看到，当票卖完后，两个线程并没有退出，仍在继续运行，当到达指定时间后，线程2退出了，如果需要让线程1退出，需要我们手动管理。

比如我们让线程完成任务（售票）后自行退出，可以这样操作

- (void)saleTicket {
while (1) {
@synchronized(self) {
//如果还有票，继续售卖
if (_ticketCount > 0) {
_ticketCount --;
NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@", _ticketCount, [NSThread currentThread].name]);
[NSThread sleepForTimeInterval:0.2];
}
//如果已卖完，关闭售票窗口
else {
if ([NSThread currentThread].isCancelled) {
break;
}else {
NSLog(@"售卖完毕");
//给当前线程标记为取消状态
[[NSThread currentThread] cancel];
//停止当前线程的runLoop
CFRunLoopStop(CFRunLoopGetCurrent());
}
}
}
}
}

运行结果：

2016-04-06 20:08:38.287 MutiThread[4927:1577193] 剩余票数：10 窗口：北京售票窗口

2016-04-06 20:08:38.489 MutiThread[4927:1577194] 剩余票数：9 窗口：广州售票窗口

2016-04-06 20:08:38.690 MutiThread[4927:1577193] 剩余票数：8 窗口：北京售票窗口

2016-04-06 20:08:38.892 MutiThread[4927:1577194] 剩余票数：7 窗口：广州售票窗口

2016-04-06 20:08:39.094 MutiThread[4927:1577193] 剩余票数：6 窗口：北京售票窗口

2016-04-06 20:08:39.294 MutiThread[4927:1577194] 剩余票数：5 窗口：广州售票窗口

2016-04-06 20:08:39.499 MutiThread[4927:1577193] 剩余票数：4 窗口：北京售票窗口

2016-04-06 20:08:39.700 MutiThread[4927:1577194] 剩余票数：3 窗口：广州售票窗口

2016-04-06 20:08:39.905 MutiThread[4927:1577193] 剩余票数：2 窗口：北京售票窗口

2016-04-06 20:08:40.106 MutiThread[4927:1577194] 剩余票数：1 窗口：广州售票窗口

2016-04-06 20:08:40.312 MutiThread[4927:1577193] 剩余票数：0 窗口：北京售票窗口

2016-04-06 20:08:40.516 MutiThread[4927:1577194] 售卖完毕

2016-04-06 20:08:40.516 MutiThread[4927:1577193] 售卖完毕

2016-04-06 20:08:40.517 MutiThread[4927:1577193] <nsthread: 0x7fb719d54000>{number = 2, name = 北京售票窗口} Will Exit

2016-04-06 20:08:40.517 MutiThread[4927:1577194] <nsthread: 0x7fb719d552f0>{number = 3, name = 广州售票窗口} Will Exit</nsthread: 0x7fb719d552f0></nsthread: 0x7fb719d54000>

如果确定两个线程都是isCancelled状态，可以调用[NSThread exit]方法来终止线程。

# Next

接下来将更新GCD和NSOperation篇。