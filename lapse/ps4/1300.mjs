/* Copyright (C) 2025 anonymous
 * This file is part of PSFree.
 */

import { shellcodes } from "../../kpatch/shellcodes.mjs";

// 13.00, 13.02

export const pthread_offsets = new Map(
    Object.entries({
        // TODO: Verify pthread offsets for 13.00
        pthread_create: 0x25510,
        pthread_join: 0xafa0,
        pthread_barrier_init: 0x273d0,
        pthread_barrier_wait: 0xa320,
        pthread_barrier_destroy: 0xfea0,
        pthread_exit: 0x77a0,
    }),
);

export const off_kstr = 0x0; // Not known
export const off_cpuid_to_pcpu = 0x2136210; // ROOTVNODE (0x2136e90) - 0xC80

export const off_sysent_661 = 0x110a760;
export const jmp_rsi = 0x47b31;

export const shellcode = shellcodes["13.00"];
