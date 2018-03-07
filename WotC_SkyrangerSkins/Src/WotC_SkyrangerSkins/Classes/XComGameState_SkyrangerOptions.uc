class XComGameState_SkyrangerOptions extends XComGameState_BaseObject;

`define MAKE_MIC(VarName, Path, Arrname) `VarName = new class'MaterialInstanceConstant'; `VarName.SetParent(MaterialInterface(`CONTENT.RequestGameArchetype(`Path))); `ArrName.AddItem(`VarName);

var name MaterialsName;
var int PrimaryColor, SecondaryColor; // Index into the Armor color palette. If -1, tinting will be disabled
var name PatternName, DecalName;
var int DecalColor;

event OnCreation( optional X2DataTemplate InitTemplate )
{
	ValidateAppearance();
}

// Hardcoded defaults here
function ValidateAppearance()
{
	if (GetSpecificTemplate(MaterialsName) == none)
	{
		PrimaryColor = -1;
		SecondaryColor = -1;
		MaterialsName = 'Material_Default';
	}

	if (!GetSpecificTemplate(MaterialsName).AllowMaterialPrimaryTinting)
		PrimaryColor = -1;

	if (!GetSpecificTemplate(MaterialsName).AllowMaterialSecondaryTinting)
		SecondaryColor = -1;

	if (!GetSpecificTemplate(MaterialsName).AllowPattern)
		PatternName = '';
	else if (GetPatternTemplate() == none)
		PatternName = 'Pat_Nothing';

	if (!GetSpecificTemplate(MaterialsName).AllowDecal)
		DecalName = '';
	else if (GetDecalTemplate() == none)
		DecalName = 'Decal_Default';

	if (GetSpecificTemplate(DecalName) == none || !GetSpecificTemplate(DecalName).AllowDecalTinting)
		DecalColor = -1;
}




function ApplyToSkyrangers(array<MeshComponent> Hulls, array<MeshComponent> Interiors)
{
	local MaterialInstanceConstant Mat_Zero, Mat_Hull, Mat_Glass, Mat_Interior, Mat_Engine, Mat_Landing, Mat_Int_Floor, Mat_Int_Wall, Mat_Int_Three, Mat_Int_Four;
	local array<MaterialInstance> Materials;
	local X2SkyrangerCustomizationTemplate Mat;
	local X2SkyrangerCustomizationTemplate DecalTemplate;
	local X2BodyPartTemplate Pattern;
	local XComPatternsContent PatCont;
	local XComLinearColorPalette Palette;
	local LinearColor DumbColor;
	local int i;

	Mat = GetSpecificTemplate(MaterialsName);
	DecalTemplate = GetSpecificTemplate(DecalName);
	Pattern = GetPatternTemplate();
	Palette = `CONTENT.GetColorPalette(ePalette_ArmorTint);
	

	`MAKE_MIC(Mat_Zero, Mat.Mat_Zero, Materials)
	`MAKE_MIC(Mat_Hull, Mat.Mat_Hull, Materials)
	`MAKE_MIC(Mat_Glass, Mat.Mat_Glass, Materials)
	`MAKE_MIC(Mat_Interior, Mat.Mat_Interior, Materials)
	`MAKE_MIC(Mat_Engine, Mat.Mat_Engine, Materials)
	`MAKE_MIC(Mat_Landing, Mat.Mat_Landing, Materials)
	`MAKE_MIC(Mat_Int_Floor, Mat.Mat_Int_Floor, Materials)
	`MAKE_MIC(Mat_Int_Wall, Mat.Mat_Int_Wall, Materials)
	`MAKE_MIC(Mat_Int_Three, Mat.Mat_Int_Three, Materials)
	`MAKE_MIC(Mat_Int_Four, Mat.Mat_Int_Four, Materials)

	for (i = 0; i < Materials.Length; i++)
	{
		Materials[i].SetScalarParameterValue('Use Tint', (PrimaryColor > -1) ? 1 : 0);
		if (PrimaryColor > -1)
		{
			DumbColor = Palette.Entries[PrimaryColor].Primary;
			Materials[i].SetVectorParameterValue('Primary Color', DumbColor);
		}

		Materials[i].SetScalarParameterValue('Use Secondary Tint', (SecondaryColor > -1) ? 1 : 0);
		if (SecondaryColor > -1)
		{
			DumbColor = Palette.Entries[SecondaryColor].Primary;
			Materials[i].SetVectorParameterValue('Secondary Color', DumbColor);
		}
		
		Materials[i].SetScalarParameterValue('DecalTintable', (DecalColor > -1) ? 1 : 0);
		if (DecalColor > -1)
		{
			DumbColor = Palette.Entries[DecalColor].Primary;
			Materials[i].SetVectorParameterValue('Decal Color', DumbColor);
		}

		Materials[i].SetScalarParameterValue('DecalUse', (DecalTemplate != none && DecalTemplate.TexturePath != "") ? 1 : 0);
		if (DecalTemplate != none)
		{
			Materials[i].SetScalarParameterValue('DecalForceAlpha', (DecalTemplate.ForceAlpha) ? 1 : 0);
			if (DecalTemplate.TexturePath != "")
			{
				Materials[i].SetTextureParameterValue('Decal', Texture(`CONTENT.RequestGameArchetype(DecalTemplate.TexturePath)));
			}
		}
		PatCont = (Pattern != none && Pattern.ArchetypeName != "") ? XComPatternsContent(`CONTENT.RequestGameArchetype(Pattern.ArchetypeName)) : none;
		Materials[i].SetScalarParameterValue('PatternUse', (PatCont != none && PatCont.Texture != none) ? 1 : 0);
		if (Pattern != none && PatCont.Texture != none)
		{
			Materials[i].SetTextureParameterValue('Pattern', PatCont.Texture);
		}
	}

	for (i = 0; i < Hulls.Length; i++)
	{
		Hulls[i].SetMaterial(0, Mat_Zero);
		Hulls[i].SetMaterial(1, Mat_Hull);
		Hulls[i].SetMaterial(2, Mat_Glass);
		Hulls[i].SetMaterial(3, Mat_Interior);
		Hulls[i].SetMaterial(4, Mat_Engine);
		Hulls[i].SetMaterial(5, Mat_Landing);
	}

	for (i = 0; i < Interiors.Length; i++)
	{
		Interiors[i].SetMaterial(0, Mat_Int_Floor);
		Interiors[i].SetMaterial(1, Mat_Int_Wall);
		Interiors[i].SetMaterial(2, Mat_Int_Three);
		Interiors[i].SetMaterial(3, Mat_Int_Four);
	}

}

static function ApplyToAll()
{
	local array<MeshComponent> Exts, Ints;
	class'Helpers_SkyrangerSkins'.static.FindMeshes(Exts, Ints);
	GetOrCreate().ApplyToSkyrangers(Exts, Ints);
}

static function XComGameState_SkyrangerOptions GetOrCreate(optional XComGameState NewGameState = none)
{
	local XComGameState_SkyrangerOptions Options;
	local bool SubmitLocally;
	if (NewGameState != none)
	{
		foreach NewGameState.IterateByClassType(class'XComGameState_SkyrangerOptions', Options)
		{
			break;
		}
	}

	if (Options == none)
	{
		Options = XComGameState_SkyrangerOptions(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_SkyrangerOptions', true));
	}

	if (Options == none)
	{
		if (NewGameState == none)
		{
			NewGameState = `XCOMHISTORY.GetStartState();
			if (NewGameState == none)
			{
				NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Create Skyranger Options");
				SubmitLocally = true;
			}
		}
		Options = XComGameState_SkyrangerOptions(NewGameState.CreateNewStateObject(class'XComGameState_SkyrangerOptions'));
		if (SubmitLocally)
		{
			`XCOMHISTORY.AddGameStateToHistory(NewGameState);
		}
	}
	return Options;
}


///// Customization Code /////
function X2SkyrangerCustomizationTemplate GetMaterialsTemplate()
{
	return GetSpecificTemplate(MaterialsName);
}

function X2BodyPartTemplate GetPatternTemplate()
{
	if (PatternName != '')
	{
		return class'X2BodyPartTemplateManager'.static.GetBodyPartTemplateManager().FindUberTemplate("Patterns", PatternName);
	}
	return none;
}

function X2SkyrangerCustomizationTemplate GetDecalTemplate()
{
	if (DecalName != '')
	{
		return GetSpecificTemplate(DecalName);
	}
	return none;
}

private function X2SkyrangerCustomizationTemplate GetSpecificTemplate(name nm)
{
	return class'X2SkyrangerCustomizationTemplateManager'.static.GetSkyrangerCustomizationTemplateManager().FindSkyrangerCustomizationTemplate(nm);
}