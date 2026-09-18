# lib_datastrings.nut

a vscript library for rd_computer_vscript entity for storing and sending large amounts of data from server to client

Purpose:
allows to store and send 999999 strings and 999 arrays from server to client opposed to default only one 256-byte string and array functionality being non-existant

Usage:
- add **IncludeScript( "lib_datastrings.nut" );** to the *end* of your server and client script files (unless you want to use SetString and SetArray early, outside of functions, when the file is still being initially parsed)
- normally on server we do self.SetString( 0, str ), with this we do SetString( x, str ). Or if you are setting data outside of the entity itself and have the handle for the entity, do hVscriptHack.GetScriptScope().SetString( x, str ). On client we do self.GetString(0), here we do GetString(x)
- new feature: SetArray( x, arr ) and GetArray( x )

Notes:
- this library reserves the int 63, do not use int 63. Same for the native self.SetString(0)
- the strings will be a bit shorter than 256 bytes because of some info we have to add to the strings themselves, depending on the index of the string and how many have been sent before (~240 string length is safe, 230 is very safe)
- DC1 character (ascii = 17) is used in datastrings as a stringinfo seperator, using it in your string will cut it (treated as null terminator basically, todo: fix this)
- the array functionality only supports arrays that contain integers, floats, strings (smaller than ~240 length) and null. Nested arrays, tables and instances turn to null
- arrays do have an arbitrary maximum length, exceeding it will lead to collisions with other arrays. Maximum length is all elements turned to strings (referred to as "string length" in the next note) being over ~240000 bytes
- clients send an input as a data request which by default won't get sent to your Input function, you can make it be sent regardless by setting bIgnoreDataStringInput to false. The data request inputs are integers with value INPUTKEY + amount of total SetString calls (SetArray does multiple, can range from 2 to >1000 depending on the string length of your array) (INPUTKEY = 1503699741)
