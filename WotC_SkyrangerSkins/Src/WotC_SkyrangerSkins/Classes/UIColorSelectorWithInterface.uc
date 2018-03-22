class UIColorSelectorWithInterface extends UIPanel implements(ISkyrangerCustomizeSelector);

var UIColorSelector Selector;

simulated function ISkyrangerCustomizeSelector InitSelector(optional name InitName, 
															 optional float initX = 500,
															 optional float initY = 500,
															 optional float initWidth = 500,
															 optional float initHeight = 500,
												 			 optional array<string> initOptions,
												 			 optional delegate<Helpers_SkyrangerSkins.SelectorOnPreviewDelegate> initPreviewDelegate,
															 optional delegate<Helpers_SkyrangerSkins.SelectorOnSetDelegate> initSetDelegate,
															 optional int initSelection = 0)
{
	InitPanel();
	Selector = Spawn(class'UIColorSelector', self).InitColorSelector(InitName, initX, initY, initWidth, initHeight, initOptions, initPreviewDelegate, initSetDelegate, initSelection);
	return self;
}


simulated function CancelSelection()
{
	Selector.OnCancelColor();
}


simulated function array<string> GetOptions()
{
	return Selector.Colors;
}

simulated function OnChildMouseEvent( UIPanel control, int cmd )
{
	Selector.OnChildMouseEvent(control, cmd);
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	return Selector.OnUnrealCommand(cmd, arg);
}

defaultproperties
{
	bIsNavigable = true;
	bAnimateOnInit = false;
	bCascadeFocus = false;
}