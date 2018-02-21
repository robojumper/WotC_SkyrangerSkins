class UICustomizeSkyrangerItem extends UIPanel;

var ESkyrangerCustomizationTrait Trait;

var X2SkyrangerCustomizationTemplate Template;

simulated function UICustomizeSkyrangerItem InitCustomizeItem(X2SkyrangerCustomizationTemplate InTemplate, ESkyrangerCustomizationTrait InTrait)
{
	InitPanel();

	Trait = InTrait;
	Template = InTemplate;

	MC.FunctionBool("setInfinite", false);
	MC.FunctionBool("setLocked", false);
	MC.SetBool("showClearButton", false);
	MC.FunctionString("setTitle", Template.DisplayName);
	MC.BeginFunctionOp("setImages");
	MC.QueueBoolean(false); // always first
	MC.QueueString(Template.Image);
	MC.EndOp();

	MC.FunctionVoid("realize");

	return self;

}

simulated function OnReceiveFocus()
{
	if( !bIsFocused )
	{
		bIsFocused = true;
		MC.FunctionVoid("onReceiveFocus");
	}
}

simulated function OnLoseFocus()
{
	if( bIsFocused )
	{
		bIsFocused = false;
		MC.FunctionVoid("onLoseFocus");
	}
}






defaultproperties
{
	Width = 342;
	Height = 145;
	bAnimateOnInit = false;
	bProcessesMouseEvents = false;
	LibID = "LoadoutListItem";
}