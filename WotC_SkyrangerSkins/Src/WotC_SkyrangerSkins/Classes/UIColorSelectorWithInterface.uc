class UIColorSelectorWithInterface extends UIColorSelector implements(ISkyrangerCustomizeSelector);


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
	InitColorSelector(InitName, initX, initY, initWidth, initHeight, initOptions, initPreviewDelegate, initSetDelegate, initSelection);
	return self;
}


simulated function CancelSelection()
{
	OnCancelColor();
}


simulated function array<string> GetOptions()
{
	return Colors;
}