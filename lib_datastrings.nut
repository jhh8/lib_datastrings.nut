SERVER <- "Entities" in getroottable();
const INPUTKEY = 1503699741;

DataStrings_t <- [];
StringHashmap_t <- {};

if ( SERVER )
{

function SetString( nIndex, str )
{
	AddDataString( nIndex, str );
}

function SetArray( nIndex, arr )
{
	if ( !arr.len() )
		return;
	
	local nArrayStorageLength = 1;
	local str = "";
	for ( local i = 0; i < arr.len(); i++ )
	{
		local strElement = arr[i] ? arr[i].tostring() : "nnull";
		if ( strElement.len() > 240 )
			return printl( "lib_datastrings error: SetArray used on an array with an element string length > 240 (array index = " + nIndex.tostring() + ", element index = " + i.tostring() + ")" );
			
		if ( str.len() + strElement.len() > 240 )
		{
			SetString( 1000000 + 1000 * ( nIndex + 1 ) + nArrayStorageLength - 1, str );
			nArrayStorageLength++;
			
			str = "";
			i--;
			continue;
		}
		
		str += (typeof( arr[i] ))[0].tochar().tostring() + strElement + ",";
	}
	
	SetString( 1000000 + nIndex, nArrayStorageLength.tostring() );
	SetString( 1000000 + 1000 * ( nIndex + 1 ) + nArrayStorageLength - 1, str );
}

function DataRequested( nArrayIndex )
{
	self.SetString( 0, DataStrings_t[ nArrayIndex ][1] );
}

function DS_Think()
{
	if ( self.GetInt( 63 ) < DataStrings_t.len() )
		self.SetInt( 63, DataStrings_t.len() );

	EntFireByHandle( self, "RunScriptCode", "DS_Think()", FrameTime() * 0.9 + 0.0001, null, null );
}
DS_Think();

if ( "Input" in self.GetScriptScope() )
	BaseInput <- Input;
else 
	BaseInput <- function(_){}
	
function Input( nInput )
{
	local nRequestedArrayIndex = nInput - INPUTKEY;
	if ( nRequestedArrayIndex > DataStrings_t.len() || nRequestedArrayIndex < 0 )
		return BaseInput( nInput );
		
	DataRequested( nRequestedArrayIndex );
	
	BaseInput( nInput );
}

}		// SERVER ^
else	// CLIENT v
{

try { BaseOnUpdate <- OnUpdate }catch(e){ BaseOnUpdate <- function(){} }
try { BasePaint <- Paint }catch(e){ BasePaint <- function(){} }
try { BaseControl <- Control }catch(e){ BaseControl <- function(_){} }

function OnUpdate()
{
	if ( self.GetInt( 63 ) <= DataStrings_t.len() )
		return BaseOnUpdate();
	
	local nMissingArrayIndex = GetFirstMissingStringArrayIndex();
	local StringInfo_t = GetStringInfo( self.GetString(0) );
	if ( StringInfo_t && ( StringInfo_t[1].tointeger() == nMissingArrayIndex ) )
	{
		AddDataString( StringInfo_t[0], StringInfo_t[ StringInfo_t.len() - 1 ] );
		
		nMissingArrayIndex = GetFirstMissingStringArrayIndex();
		if ( nMissingArrayIndex >= self.GetInt( 63 ) )
			return BaseOnUpdate();
	}

	RequestData( nMissingArrayIndex );
	
	BaseOnUpdate();
}

function Paint()
{
	if ( self.GetInt( 63 ) > DataStrings_t.len() )
		RequestData( GetFirstMissingStringArrayIndex() );

	BasePaint();
}

function GetFirstMissingStringArrayIndex()
{
	return DataStrings_t.len();
}

function RequestData( nArrayIndex )
{
	nDataRequest <- nArrayIndex + INPUTKEY;
}

nDataRequest <- INPUTKEY - 1;
function Control( Inputs_t )
{
	if ( nDataRequest >= INPUTKEY )
	{
		self.SendInput( nDataRequest );
		nDataRequest <- INPUTKEY - 1;
	}
	
	self.ForceSync();
	
	BaseControl( Inputs_t );
}

}		// CLIENT ^
		// SHARED v

function GetDataStringArrayIndex( nIndex )
{
	if ( nIndex in StringHashmap_t )
		return StringHashmap_t[ nIndex.tointeger() ];
	
	function Search( nIndex, DataStrings_t )
	{
		local nArrayIndex = -1;
		
		for( local i = 0; i < DataStrings_t.len(); i++ )
			if ( DataStrings_t[i][0] == nIndex )
				nArrayIndex = i;
				
		return nArrayIndex;
	}
	
	return newthread( Search ).call( nIndex, DataStrings_t );
}

function GetDataString( nIndex )
{
	local nArrayIndex = GetDataStringArrayIndex( nIndex );
	
	return nArrayIndex < 0 ? null : DataStrings_t[ nArrayIndex ][1];
}

function GetStringInfo( datastr )
{
	if ( !datastr )
		return null;
	
	local StringInfo_t = split( datastr, "" );
	if ( StringInfo_t.len() <= 1 )
		return null;

	local str = StringInfo_t[1];

	StringInfo_t = split( StringInfo_t[0], "|" );
	if ( StringInfo_t.len() == 1 )
		return null;
		
	StringInfo_t[0] = StringInfo_t[0].tointeger();
		
	StringInfo_t.push( str );
	
	return StringInfo_t;
}

function GetString( nIndex )
{
	local StringInfo_t = GetStringInfo( GetDataString( nIndex ) );
	
	return StringInfo_t ? StringInfo_t[ StringInfo_t.len() - 1 ] : null;
}

function GetArray( nIndex )
{
	local arr = [];
	local strArrayStorageLength = GetString( 1000000 + nIndex );
	if ( !strArrayStorageLength )
		return arr;
	
	local nArrayStorageLength = strArrayStorageLength.tointeger();
	for ( local n = 0; n < nArrayStorageLength; n++ )
	{
		local strElements = GetString( 1000000 + 1000 * ( nIndex + 1 ) + n );
		if ( !strElements )
			return arr;

		local Elements_t = split( GetString( 1000000 + 1000 * ( nIndex + 1 ) + n ), "," );
		
		for ( local i = 0; i < Elements_t.len(); i++ )
		{
			local strElement = Elements_t[i];
			switch( strElement[0].tochar().tostring() )
			{
				case "i":
				{
					arr.push( strElement.slice( 1, strElement.len() ).tointeger() );
					break;
				}
				case "f":
				{
					arr.push( strElement.slice( 1, strElement.len() ).tofloat() );
					break;
				}
				case "s":
				{
					arr.push( strElement.slice( 1, strElement.len() ) );
					break;
				}
				case "n":
				{
					arr.push( null );
					break;
				}
				default:
				{
					printl( "lib_datastrings error: unsupported typeof element in array index = " + nIndex.tostring() + ", element index = " + ( arr.len() - 1 ).tostring() + ", setting to null" );
					arr.push( null );
					break;
				}
			}
		}
	}
	
	return arr;
}

function AddDataString( nIndex, str )
{
	StringHashmap_t[ nIndex ] <- DataStrings_t.len();
	DataStrings_t.push( [ nIndex, nIndex.tostring() + "|" + DataStrings_t.len() + "" + str ] );
}
