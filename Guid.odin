package GUID


import "core:fmt"
import "core:os"
import win32 "core:sys/windows"
import "core:strings"

foreign import Ole32 "system:Ole32.lib"

foreign Ole32 {
	CoCreateGuid :: proc(pguid: ^GUID) -> win32.HRESULT ---
}

// We dont really need this Context or what it does as Windows the API makes sure it's unique but you never know.
GUID_Context :: struct {
    GUIDRegistry: [dynamic]GUID,
}

GUID :: struct {
    Data1: u32,
    Data2: u16,
    Data3: u16,
    Data4: [8]u8,
	Inuse: b32,
}

gc : GUID_Context = GUID_Context{
}

New_GUID :: proc() -> GUID {
	guid := GUID{}
	hr := CoCreateGuid(&guid)
	if hr != 0 {
		return GUID{}
	}
	guid.Inuse = true
	append(&gc.GUIDRegistry, guid)
	return guid
}

GUID_To_String :: proc(guid: GUID) -> string {
    s := fmt.tprintf("%08x-%04x-%04x-%02x%02x-%02x%02x-%02x%02x-%02x%02x",
        int(guid.Data1), int(guid.Data2), int(guid.Data3),
        int(guid.Data4[0]), int(guid.Data4[1]), int(guid.Data4[2]), int(guid.Data4[3]),
        int(guid.Data4[4]), int(guid.Data4[5]), int(guid.Data4[6]), int(guid.Data4[7]))
    return strings.concatenate({"", s, ""})
}

GUID_Is_Registered :: proc(guid: GUID) -> bool {
    for g in gc.GUIDRegistry {
        if GUID_Equal(g, guid) {
            return true
        }
    }
    return false
}

GUID_Register :: proc(guid: GUID) {
    if !GUID_Is_Registered(guid) {
        append(&gc.GUIDRegistry, guid)
    }
}


GUID_Unregister :: proc(guid: GUID) {
    for i in 0..<len(gc.GUIDRegistry) {
        if GUID_Equal(gc.GUIDRegistry[i], guid) {
            unordered_remove(&gc.GUIDRegistry, i)
            break
        }
    }
}

GUID_Equal :: proc(a, b: GUID) -> bool {
    return a.Data1 == b.Data1 && a.Data2 == b.Data2 && a.Data3 == b.Data3 && a.Data4 == b.Data4
}

GUID_Not_Equal :: proc(a, b: GUID) -> bool {
    return !GUID_Equal(a, b)
}


GUID_Get_Registry :: proc() -> []GUID {
    return gc.GUIDRegistry[:]
}

GUID_Get_Registry_Length :: proc() -> int {
    return int(len(gc.GUIDRegistry))
}

GUID_Get_Registry_Index :: proc(guid: GUID) -> int {
    for i in 0..<len(gc.GUIDRegistry) {
        if GUID_Equal(gc.GUIDRegistry[i], guid) {
            return i
        }
    }
    return -1
}
