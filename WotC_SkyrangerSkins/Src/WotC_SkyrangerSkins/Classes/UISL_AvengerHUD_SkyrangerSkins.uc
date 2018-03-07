class UISL_AvengerHUD_SkyrangerSkins extends UIScreenListener;

event OnInit(UIScreen Screen)
{
    local UIAvengerShortcuts Shortcuts;
	local UIAvengerShortcutMessage Message;
	// TODO: Change version requirement?
	if (UIAvengerHUD(Screen) != none && class'Helpers_SkyrangerSkins'.static.IsCHHLMinVersionInstalled(1, 9))
	{
		// Make use of the Highlander functionality that allows us to insert list items
		Shortcuts = `HQPRES.m_kAvengerHUD.Shortcuts;
		Message.Label = class'Helpers_SkyrangerSkins'.default.strCustomizeSkyranger;
		Message.Description = class'Helpers_SkyrangerSkins'.default.strCustomizeSkyranger;
		//Message.HotLinkRef = none;
		Message.Urgency = eUIAvengerShortcutMsgUrgency_Low;
		Message.OnItemClicked = MsgCallback;
		Message.bDisabled = false;
		Shortcuts.ModSubMenus[eUIAvengerShortcutCat_Barracks].SubMenuItems.Add(1);
		Shortcuts.ModSubMenus[eUIAvengerShortcutCat_Barracks].SubMenuItems[Shortcuts.ModSubMenus[eUIAvengerShortcutCat_Barracks].SubMenuItems.Length - 1].Message = Message;

	}
	else if (UIFacility_Armory(Screen) != none && !class'Helpers_SkyrangerSkins'.static.IsCHHLMinVersionInstalled(1, 8))
	{
		// Random ugly button until highlander updated
		Screen.Spawn(class'UIButton', Screen).InitButton('', class'Helpers_SkyrangerSkins'.default.strCustomizeSkyranger, OnButtonClicked).SetPosition(130, 30);
	}

	// Also stream in our cinematic map
	if (UIAvengerHUD(Screen) != none)
	{
		`MAPS.AddStreamingMap("CIN_SkyrangerCustomization", vect(0, 0, 0), Rot(0, 0, 0), true, false, true);
		class'XComGameState_SkyrangerOptions'.static.ApplyToAll();
	}
}

simulated function OnButtonClicked(UIButton button)
{
	MsgCallback();
}


function MsgCallback(optional StateObjectReference Facility)
{
	`HQPRES.ScreenStack.Push( `HQPRES.Spawn(class'UICustomizeSkyranger_Main', `HQPRES), `HQPRES.Get3DMovie());
}