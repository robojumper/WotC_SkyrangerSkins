class UISL_TacticalHUD_SkyrangerSkins extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	if (UITacticalHUD(Screen) != none || UIDropShipBriefingBase(Screen) != none)
	{
		// TODO: For UIDropShipBriefingBase, this triggers too early!
		class'XComGameState_SkyrangerOptions'.static.ApplyToAll();
	}
}