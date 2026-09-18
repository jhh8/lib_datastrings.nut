# lib_datastrings.nut

a vscript library for rd_computer_vscript entity for storing and sending large amounts of data from server to client

Purpose:
allows to store and send 999999 strings and 999 arrays from server to client opposed to default only one 256-byte string and array functionality being non-existant

Usage:
- add **IncludeScript( "lib_datastrings.nut" );** to the *end* of your server and client script files
- normally on server we do self.SetString( 0, str ), with this we do SetString( x, str ). Or if you are setting data outside of the entity itself and have the handle for the entity, do hVscriptHack.GetScriptScope().SetString( x, str ). On client we do self.GetString(0), here we do GetString(x)
- new feature: SetArray( x, arr ) and GetArray( x )

Notes:
- this library reserves the int 63, do not use int 63. Same for the string 0
- the strings will be a bit shorter than 256 bytes because of some info we have to add to the strings themselves, depending on the index of the string and how many have been sent before (~240 string length is safe, 230 is very safe)
- DC1 character (ascii = 17) is used in datastrings as a stringinfo seperator, using it in your string will cut it (treated as null terminator basically, todo: fix this)
- the array functionality only supports arrays that contain integers, floats, strings (smaller than ~240 length) and null. Nested arrays, tables and instances turn to null
- arrays do have an arbitrary maximum length, exceeding it will lead to collisions with other arrays. Maximum length is all elements turned to strings being over ~240000 bytes
