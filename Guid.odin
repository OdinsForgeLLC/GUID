package GUID


import "core:fmt"
import "core:math"
import "core:strings"
import "core:sys/windows"
import utf16 "core:unicode/utf16"
import utf8 "core:unicode/utf8"


foreign import Ole32 "system:Ole32.lib"

foreign Ole32
{
	CoCreateGuid :: proc(pguid: ^GUID) -> windows.HRESULT ---
	StringFromGUID2 :: proc(rclsid: windows.REFCLSID, lplpsz: windows.LPOLESTR, cchMax: windows.INT) -> windows.INT --- // https://docs.microsoft.com/en-us/windows/win32/api/combaseapi/nf-combaseapi-stringfromguid2
}


GUID :: struct {
	Data1, Data2, Data3: u32,
	Data4:               [8]u8,
}


New_GUID :: proc() -> GUID {
	guid := GUID{}
	hr := CoCreateGuid(&guid)
	return guid
}

GUID_To_String_Alloc :: proc(guid: ^GUID) -> string {
	buffer: [39]u16
	runes: [39]rune
	length := GUID_To_String(guid, buffer[:])
	if length > 0 {
		rune_count := utf16.decode(runes[:], buffer[:length])
		if rune_count > 0 && runes[rune_count - 1] == 0 {
			rune_count -= 1
		}
		str := utf8.runes_to_string(runes[:rune_count])
		return Remove_Brackets(str)
	}
	return ""
}

GUID_To_String :: proc(guid: ^GUID, buffer: []u16) -> (length: int) {
	return int(
		windows.StringFromGUID2(
			windows.REFCLSID(guid),
			windows.LPOLESTR(raw_data(buffer)),
			windows.INT(len(buffer)),
		),
	)
}

Remove_From_Start :: proc(s: string, count: int) -> string {
	return s[count:]
}

Remove_From_End :: proc(s: string, count: int) -> string {
	return s[:len(s) - count]
}

Remove_Brackets :: proc(s: string) -> string {
	return Remove_From_Start(Remove_From_End(s, 1), 1)
}

GUID_Equal :: proc(a, b: ^GUID) -> bool {
	return a.Data1 == b.Data1 && a.Data2 == b.Data2 && a.Data3 == b.Data3 && a.Data4 == b.Data4
}

GUID_Not_Equal :: proc(a, b: ^GUID) -> bool {
	return !GUID_Equal(a, b)
}
