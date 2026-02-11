
import { init_primitives, BigInt } from './netctrl/types.mjs';

function log(msg) {
    console.log("[NetCtrl Loader] " + msg);
    if (window.log) window.log("[NetCtrl Loader] " + msg);
}

export async function load(expl_master, expl_slave, leak_obj_ref, leak_addr_int) {
    log("Initializing primitives...");

    // leak_addr_int is Int from module/int64.mjs which has .lo and .hi
    let la_bigint = new BigInt(leak_addr_int.hi, leak_addr_int.lo);

    init_primitives(expl_master, expl_slave, leak_obj_ref, la_bigint);

    log("Primitives initialized. Loading Userland Offsets...");
    try {
        await import('./netctrl/userland.mjs');
    } catch (e) {
        log("Error loading userland.mjs: " + e);
        throw e;
    }

    log("Userland loaded. Running Exploit...");
    try {
        await import('./netctrl/netctrl_c0w_twins.mjs');
    } catch (e) {
        log("Error running exploit: " + e);
        throw e;
    }

    log("Exploit finished.");
}
