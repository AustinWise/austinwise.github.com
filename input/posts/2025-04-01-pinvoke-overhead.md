---
layout: post.liquid
title: P/Invoke Overhead in .NET
published_date: 2025-04-01 01:01:00 -0700
description: TODO
data:
  nolist: true
---


Other post: https://richardcocks.github.io/2025-03-30-FasterThanMemCmp.html

Comments: https://news.ycombinator.com/item?id=43524665

Other repo: https://github.com/richardcocks/memcomparison

My code: https://github.com/AustinWise/MemCompare

Disassembly using a checked .NET JIT for version 9.0.3:

```asm
; Assembly listing for method Benchmarks:CompareBytes(ubyte[],ubyte[]):ubyte (FullOpts)
; Emitting BLENDED_CODE for X64 with AVX - Windows
; FullOpts code
; optimized code
; rbp based frame
; partially interruptible
; No PGO data
; Final local variable assignments
;
;  V00 arg0         [V00,T00] (  5,  4   )     ref  ->  rbx         class-hnd single-def <ubyte[]>
;  V01 arg1         [V01,T01] (  5,  4   )     ref  ->  rsi         class-hnd single-def <ubyte[]>
;  V02 loc0         [V02,T08] (  3,  1.50)    long  ->  rbx        
;  V03 loc1         [V03,T09] (  3,  1.50)    long  ->  rdx        
;  V04 loc2         [V04    ] (  1,  0.50)     ref  ->  [rbp-0x40]  must-init pinned class-hnd single-def <ubyte[]>
;  V05 loc3         [V05    ] (  1,  0.50)     ref  ->  [rbp-0x48]  must-init pinned class-hnd single-def <ubyte[]>
;* V06 loc4         [V06    ] (  0,  0   )     int  ->  zero-ref   
;  V07 OutArgs      [V07    ] (  1,  1   )  struct (32) [rsp+0x00]  do-not-enreg[XS] addr-exposed "OutgoingArgSpace"
;  V08 tmp1         [V08,T03] (  3,  4   )     int  ->  rax         "Single return block return value"
;  V09 FramesRoot   [V09,T02] (  6,  4   )    long  ->  rdi         "Pinvoke FrameListRoot"
;  V10 PInvokeFrame [V10    ] (  8,  6   )  struct (64) [rbp-0x88]  do-not-enreg[XS] addr-exposed "Pinvoke FrameVar"
;  V11 tmp4         [V11,T06] (  2,  2   )    long  ->  rbx         "Cast away GC"
;  V12 tmp5         [V12,T07] (  2,  2   )    long  ->  rdx         "Cast away GC"
;  V13 cse0         [V13,T04] (  4,  3   )     int  ->   r8         "CSE #01: aggressive"
;  V14 cse1         [V14,T05] (  3,  2.50)     int  ->  rcx         "CSE #02: aggressive"
;
; Lcl frame size = 120

G_M62994_IG01:  ;; offset=0x0000
       push     rbp
       push     r15
       push     r14
       push     r13
       push     r12
       push     rdi
       push     rsi
       push     rbx
       sub      rsp, 120
       vzeroupper 
       lea      rbp, [rsp+0xB0]
       xor      eax, eax
       mov      qword ptr [rbp-0x40], rax
       mov      qword ptr [rbp-0x48], rax
       mov      rbx, rcx
       mov      rsi, rdx
						;; size=43 bbWeight=1 PerfScore 12.50
G_M62994_IG02:  ;; offset=0x002B
       lea      rcx, [rbp-0x80]
       call     CORINFO_HELP_INIT_PINVOKE_FRAME
       mov      rdi, rax
       mov      r8, rsp
       mov      qword ptr [rbp-0x68], r8
       mov      r8, rbp
       mov      qword ptr [rbp-0x58], r8
       mov      r8d, dword ptr [rbx+0x08]
       mov      ecx, dword ptr [rsi+0x08]
       cmp      r8d, ecx
       jne      SHORT G_M62994_IG11
						;; size=38 bbWeight=1 PerfScore 9.50
G_M62994_IG03:  ;; offset=0x0051
       mov      gword ptr [rbp-0x40], rbx
       test     r8d, r8d
       je       SHORT G_M62994_IG04
       add      rbx, 16
       jmp      SHORT G_M62994_IG05
						;; size=15 bbWeight=0.50 PerfScore 2.25
G_M62994_IG04:  ;; offset=0x0060
       xor      ebx, ebx
						;; size=2 bbWeight=0.50 PerfScore 0.12
G_M62994_IG05:  ;; offset=0x0062
       mov      gword ptr [rbp-0x48], rsi
       test     ecx, ecx
       je       SHORT G_M62994_IG06
       add      rsi, 16
       mov      rdx, rsi
       jmp      SHORT G_M62994_IG07
						;; size=17 bbWeight=0.50 PerfScore 2.38
G_M62994_IG06:  ;; offset=0x0073
       xor      edx, edx
						;; size=2 bbWeight=0.50 PerfScore 0.12
G_M62994_IG07:  ;; offset=0x0075
       mov      r8d, r8d
       mov      rcx, rbx
       mov      rax, 0x7FF9435A6050      ; function address
       mov      qword ptr [rbp-0x70], rax
       lea      rax, G_M62994_IG09
       mov      qword ptr [rbp-0x60], rax
       lea      rax, [rbp-0x80]
       mov      qword ptr [rdi+0x08], rax
       mov      byte  ptr [rdi+0x04], 0
						;; size=43 bbWeight=0.50 PerfScore 3.12
G_M62994_IG08:  ;; offset=0x00A0
       call     [Benchmarks:memcmp(ulong,ulong,long):int]
						;; size=6 bbWeight=0.50 PerfScore 1.50
G_M62994_IG09:  ;; offset=0x00A6
       mov      byte  ptr [rdi+0x04], 1
       cmp      dword ptr [(reloc 0x7ff9a339d6a4)], 0
       je       SHORT G_M62994_IG10
       call     [CORINFO_HELP_STOP_FOR_GC]
						;; size=19 bbWeight=0.50 PerfScore 4.00
G_M62994_IG10:  ;; offset=0x00B9
       mov      rcx, qword ptr [rbp-0x78]
       mov      qword ptr [rdi+0x08], rcx
       test     eax, eax
       sete     al
       movzx    rax, al
       jmp      SHORT G_M62994_IG12
						;; size=18 bbWeight=0.50 PerfScore 2.75
G_M62994_IG11:  ;; offset=0x00CB
       xor      eax, eax
						;; size=2 bbWeight=0.50 PerfScore 0.12
G_M62994_IG12:  ;; offset=0x00CD
       movzx    rax, al
						;; size=3 bbWeight=1 PerfScore 0.25
G_M62994_IG13:  ;; offset=0x00D0
       add      rsp, 120
       pop      rbx
       pop      rsi
       pop      rdi
       pop      r12
       pop      r13
       pop      r14
       pop      r15
       pop      rbp
       ret      
						;; size=17 bbWeight=1 PerfScore 5.25

; Total bytes of code 225, prolog size 37, PerfScore 43.88, instruction count 72, allocated bytes for code 225 (MethodHash=9c4609ed) for method Benchmarks:CompareBytes(ubyte[],ubyte[]):ubyte (FullOpts)
; ============================================================
```


Basic disasm:

```assembly
; Benchmarks.CompareBytes(Byte[], Byte[])
       push      rbp
       push      r15
       push      r14
       push      r13
       push      r12
       push      rdi
       push      rsi
       push      rbx
       sub       rsp,78
       vzeroupper
       lea       rbp,[rsp+0B0]
       xor       eax,eax
       mov       [rbp-40],rax
       mov       [rbp-48],rax
       mov       rsi,rcx
       mov       rbx,rdx
       lea       rcx,[rbp-80]
       call      CORINFO_HELP_INIT_PINVOKE_FRAME
       mov       rdi,rax
       mov       r8,rsp
       mov       [rbp-68],r8
       mov       r8,rbp
       mov       [rbp-58],r8
       mov       r14d,[rsi+8]
       mov       r8d,[rbx+8]
       cmp       r14d,r8d
       jne       near ptr M01_L07
       mov       [rbp-40],rsi
       test      r14d,r14d
       je        near ptr M01_L05
       add       rsi,10
       mov       rcx,rsi
M01_L00:
       mov       [rbp-48],rbx
       test      r8d,r8d
       je        short M01_L06
       add       rbx,10
       mov       rdx,rbx
M01_L01:
       mov       r8d,r14d
       mov       rax,7FF8DC797798
       mov       [rbp-70],rax
       lea       rax,[M01_L02]
       mov       [rbp-60],rax
       lea       rax,[rbp-80]
       mov       [rdi+8],rax
       mov       byte ptr [rdi+4],0
       mov       rax,7FFA50C612F0
       call      rax
M01_L02:
       mov       byte ptr [rdi+4],1
       cmp       dword ptr [7FF93C44D6A4],0
       je        short M01_L03
       call      qword ptr [7FF93C43B3F8]; CORINFO_HELP_STOP_FOR_GC
M01_L03:
       mov       rcx,[rbp-78]
       mov       [rdi+8],rcx
       test      eax,eax
       sete      cl
       movzx     ecx,cl
M01_L04:
       movzx     eax,cl
       add       rsp,78
       pop       rbx
       pop       rsi
       pop       rdi
       pop       r12
       pop       r13
       pop       r14
       pop       r15
       pop       rbp
       ret
M01_L05:
       xor       ecx,ecx
       jmp       short M01_L00
M01_L06:
       xor       edx,edx
       jmp       short M01_L01
M01_L07:
       xor       ecx,ecx
       jmp       short M01_L04
; Total bytes of code 241
```

Wrapper of sequence equals:

```assembly
; Benchmarks.SequenceEqualWrapper(Byte[], Byte[])
       push      rbx
       sub       rsp,20
       test      rcx,rcx
       je        short M01_L04
       lea       rax,[rcx+10]
       mov       ebx,[rcx+8]
M01_L00:
       test      rdx,rdx
       je        short M01_L03
       lea       r10,[rdx+10]
       mov       r8d,[rdx+8]
M01_L01:
       cmp       ebx,r8d
       jne       short M01_L05
       mov       r8d,r8d
       mov       rcx,rax
       mov       rdx,r10
       call      qword ptr [7FF8DC4DC180]; System.SpanHelpers.SequenceEqual(Byte ByRef, Byte ByRef, UIntPtr)
M01_L02:
       nop
       add       rsp,20
       pop       rbx
       ret
M01_L03:
       xor       r10d,r10d
       xor       r8d,r8d
       jmp       short M01_L01
M01_L04:
       xor       eax,eax
       xor       ebx,ebx
       jmp       short M01_L00
M01_L05:
       xor       eax,eax
       jmp       short M01_L02
; Total bytes of code 75
```
