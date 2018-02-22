//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_WotC_SkyrangerSkins.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_WotC_SkyrangerSkins extends X2DownloadableContentInfo;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{
	class'XComGameState_SkyrangerOptions'.static.GetOrCreate();
}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{
	class'XComGameState_SkyrangerOptions'.static.GetOrCreate(StartState);
}


// Helper console command that writes the current camera settings to the log file
exec function LogCameraTPOV()
{
	local TPOV CamTPOV;
	CamTPOV = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().PlayerCamera.CameraCache.POV;
	`log(`showvar(CamTPOV.Location.X));
	`log(`showvar(CamTPOV.Location.Y));
	`log(`showvar(CamTPOV.Location.Z));
	`log(`showvar(CamTPOV.Rotation.Pitch));
	`log(`showvar(CamTPOV.Rotation.Roll));
	`log(`showvar(CamTPOV.Rotation.Yaw));
}

exec function DoRemoteEvent(name EventName)
{
	`XCOMGRI.DoRemoteEvent(EventName);
}

exec function ApplyToAll()
{
	class'XComGameState_SkyrangerOptions'.static.ApplyToAll();
}
