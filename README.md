# lib_datastrings.nut

a vscript "library" for rd_computer_vscript entity for storing and sending large amounts of data from server to client

Purpose:
allows to store and send as many strings as you want from server to client opposed to default only one 256-byte string

Usage:
- add **IncludeScript( "lib_datastrings.nut" );** to the *end* of your server and client script files
- normally on server we do self.SetString( 0, str ), with this we do SetString( x, str ). Or if you are setting data outside of the entity itself and have the handle for the entity, do hVscriptHack.GetScriptScope().SetString( x, str ). On client we do self.GetString(0), here we do GetString(x)

Notes:
- this library reserves the int 63, do not use int 63. Same for the string 0
- the strings will be a bit shorter than 256 bytes because of some info we have to add to the strings themselves, depending on the index of the string and how many have been sent before (~240 string length is safe, 230 is very safe)
