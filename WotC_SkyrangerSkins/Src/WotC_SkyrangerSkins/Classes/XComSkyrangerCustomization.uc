class XComSkyrangerCustomization extends Object;

var XComGameState NewGameState;
var XComGameState_SkyrangerOptions SkyrangerState;
var X2SkyrangerCustomizationTemplateManager TemplateManager;

// Cache them because it's faster this way
var array<MeshComponent> Exts, Ints;

simulated function Init()
{
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Skyranger Customization");
	SkyrangerState = class'XComGameState_SkyrangerOptions'.static.GetOrCreate(NewGameState);
	SkyrangerState = XComGameState_SkyrangerOptions(NewGameState.ModifyStateObject(class'XComGameState_SkyrangerOptions', SkyrangerState.ObjectID));
	class'Helpers_SkyrangerSkins'.static.FindMeshes(Exts, Ints);
	TemplateManager = class'X2SkyrangerCustomizationTemplateManager'.static.GetSkyrangerCustomizationTemplateManager();
}

simulated function Close()
{
	`GAMERULES.SubmitGameState(NewGameState);
}

simulated function PreviewVisuals()
{
	SkyrangerState.ValidateAppearance();
	SkyrangerState.ApplyToSkyrangers(Exts, Ints);
}

simulated function bool HasMaterialOptions()
{
	local array<X2SkyrangerCustomizationTemplate> arr;
	TemplateManager.GetFilteredTemplates('Material', none, arr);
	assert(arr.Length > 0);
	return arr.Length > 1;
}

simulated function bool HasDecalOptions()
{
	local array<X2SkyrangerCustomizationTemplate> arr;
	TemplateManager.GetFilteredTemplates('Decal', none, arr);
	assert(arr.Length > 0);
	return arr.Length > 1;
}

simulated function bool HasPatternOptions()
{
	local array<X2BodyPartTemplate> arr;
	class'X2BodyPartTemplateManager'.static.GetBodyPartTemplateManager().GetUberTemplates("Patterns", arr);
	assert(arr.Length > 0);
	return arr.Length > 1;
}