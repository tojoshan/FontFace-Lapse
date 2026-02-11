/* Copyright (C) 2025 anonymous
 * This file is part of PSFree.
 */

import { shellcodes } from "../../kpatch/shellcodes.mjs";

// 9.03, 9.04

export const pthread_offsets = new Map(
  Object.entries({
    // TODO: Verify pthread offsets for 9.03/9.04
    pthread_create: 0x25510,
    pthread_join: 0xafa0,
    pthread_barrier_init: 0x273d0,
    pthread_barrier_wait: 0xa320,
    pthread_barrier_destroy: 0xfea0,
    pthread_exit: 0x77a0,
  }),
);

export const off_kstr = 0x7f4ce7;
export const off_cpuid_to_pcpu = 0x21EB2A0; // ROOTVNODE (0x21EBF20) - 0xC80

export const off_sysent_661 = 0x1103f00;
export const jmp_rsi = 0x5325b;

export const shellcode = shellcodes["9.03"];
