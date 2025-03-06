# double_free_race_mre

Only seems to be reproducible on MacOS, so: 
1. `make run.macos`
2. Close flutter application via close button (Ctrl+C wont proc segfault).

And if you are lucky enough you might catch a segfault like this:
```
Code Type:             ARM-64 (Native)
OS Version:            macOS 15.3.1 (24D70)

Crashed Thread:        7

Exception Type:        EXC_CRASH (SIGABRT)
Exception Codes:       0x0000000000000000, 0x0000000000000000

Termination Reason:    Namespace SIGNAL, Code 6 Abort trap: 6
Terminating Process:   double_free_race_mre_example [56429]

Application Specific Information:
abort() called

Thread 7 Crashed:
0   libsystem_kernel.dylib        	       0x1904ab720 __pthread_kill + 8
1   libsystem_pthread.dylib       	       0x1904e3f70 pthread_kill + 288
2   libsystem_c.dylib             	       0x1903f0908 abort + 128
3   libsystem_malloc.dylib        	       0x1902f9e38 malloc_vreport + 896
4   libsystem_malloc.dylib        	       0x1902fd9bc malloc_report + 64
5   libsystem_malloc.dylib        	       0x19031c144 find_zone_and_free + 528
6   libnative.dylib               	       0x11dc8fc38 core::ptr::drop_in_place$LT$alloc..raw_vec..RawVec$LT$u8$GT$$GT$::had19fecd612a4f11 + 24 (mod.rs:523)
7   libnative.dylib               	       0x11dc8fb9c core::ptr::drop_in_place$LT$alloc..vec..Vec$LT$u8$GT$$GT$::he793ee35b78a4d04 + 68 (mod.rs:523)
8   libnative.dylib               	       0x11dc8ff20 core::ptr::drop_in_place$LT$alloc..boxed..Box$LT$alloc..vec..Vec$LT$u8$GT$$GT$$GT$::h38b1af20c97178e0 + 32 (mod.rs:523)
9   libnative.dylib               	       0x11dc8c550 reclaim_vec_cb + 136 (lib.rs:58)
10  libnative.dylib               	       0x11dc8c420 native::start_send_loop::_$u7b$$u7b$closure$u7d$$u7d$::h11dc6a3ac52a4154 + 740 (lib.rs:44)
11  libnative.dylib               	       0x11dc8dbc4 std::sys::backtrace::__rust_begin_short_backtrace::h0a698d84c9b5da9b + 20 (backtrace.rs:152)
12  libnative.dylib               	       0x11dc8f068 std::thread::Builder::spawn_unchecked_::_$u7b$$u7b$closure$u7d$$u7d$::_$u7b$$u7b$closure$u7d$$u7d$::hc92fd16253bffd90 + 100 (mod.rs:564)
13  libnative.dylib               	       0x11dc8c114 _$LT$core..panic..unwind_safe..AssertUnwindSafe$LT$F$GT$$u20$as$u20$core..ops..function..FnOnce$LT$$LP$$RP$$GT$$GT$::call_once::h439a05af6f738271 + 44 (unwind_safe.rs:272)
14  libnative.dylib               	       0x11dc8f3d4 std::panicking::try::do_call::h293a3858da0ccd6d + 68 (panicking.rs:584)
15  libnative.dylib               	       0x11dc8f14c __rust_try + 32
16  libnative.dylib               	       0x11dc8ebc4 std::panicking::try::h97b5d4c69c25eab8 + 56 (panicking.rs:547) [inlined]
17  libnative.dylib               	       0x11dc8ebc4 std::panic::catch_unwind::hc5f9783d8a134b10 + 56 (panic.rs:358) [inlined]
18  libnative.dylib               	       0x11dc8ebc4 std::thread::Builder::spawn_unchecked_::_$u7b$$u7b$closure$u7d$$u7d$::h655074382a3aa36f + 604 (mod.rs:562)
19  libnative.dylib               	       0x11dc8f52c core::ops::function::FnOnce::call_once$u7b$$u7b$vtable.shim$u7d$$u7d$::h21b0c2e6d6e1d81b + 24 (function.rs:250)
20  libnative.dylib               	       0x11dcb32f8 std::sys::pal::unix::thread::Thread::new::thread_start::h02b173395cbbc15c + 52
21  libsystem_pthread.dylib       	       0x1904e42e4 _pthread_start + 136
22  libsystem_pthread.dylib       	       0x1904df0fc thread_start + 8


Thread 7 crashed with ARM Thread State (64-bit):
    x0: 0x0000000000000000   x1: 0x0000000000000000   x2: 0x0000000000000000   x3: 0x0000000000000000
    x4: 0x0000000000000073   x5: 0x000000000000002e   x6: 0x0000000000000001   x7: 0x00000000000008e0
    x8: 0x58ff6d4811b3b4e2   x9: 0x58ff6d497ebd84e2  x10: 0x000000000000000a  x11: 0x0000000000000000
   x12: 0x0000000000000035  x13: 0x000000000000000a  x14: 0x0000000000000030  x15: 0xffe0f8fffffeffff
   x16: 0x0000000000000148  x17: 0x00000002024962c0  x18: 0x0000000000000000  x19: 0x0000000000000006
   x20: 0x000000000000bc37  x21: 0x000000016f0e30e0  x22: 0x000000019032937a  x23: 0x000000016f0e27c0
   x24: 0x0000000000000000  x25: 0x0000000000000000  x26: 0x000000016db6b62c  x27: 0x000000016f0e3000
   x28: 0x0000000000000000   fp: 0x000000016f0e2110   lr: 0x00000001904e3f70
    sp: 0x000000016f0e20f0   pc: 0x00000001904ab720 cpsr: 0x40001000
   far: 0x0000000000000000  esr: 0x56000080  Address size fault
```

Logs:
```
reclaim_cb 0x6000034e4830
reclaim_cb 0x6000034e4860
reclaim_cb 0x6000034e8790
reclaim_cb 0x6000034ec700
reclaim_cb 0x6000034ec730
reclaim_cb 0x6000034d9e00
reclaim_cb 0x6000034ec640
Dart_PostCObject_DL == false for 0x6000034ec640, so cleaning from native code
reclaim_cb 0x6000034ec640
Lost connection to device.
```

So it seems that despite `Dart_PostCObject_DL` returning `false` Dart VM calls `reclaim_cb 0x6000034ec640` anyway. Which is not supposed to happend according to docs:

> If true is returned, the message was enqueued, and finalizers for external
> typed data will eventually run, even if the receiving isolate shuts down
> before processing the message. If false is returned, the message was not
> enqueued and ownership of external typed data in the message remains with the
> caller.