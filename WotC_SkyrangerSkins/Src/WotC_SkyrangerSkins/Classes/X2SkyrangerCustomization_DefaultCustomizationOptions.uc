class X2SkyrangerCustomization_DefaultCustomizationOptions extends X2SkyrangerCustomization config(SkyrangerSkins);

struct SkyrangerCustomizationConfig
{
	var name TemplateName;
	var name PartType;

	// If PartType == 'Material'
	var string Mat_Zero;
	var string Mat_Hull;
	var string Mat_Glass;
	var string Mat_Interior;
	var string Mat_Engine;
	var string Mat_Landing;
	var string Mat_Int_Floor;
	var string Mat_Int_Wall;
	var string Mat_Int_Three;
	var string Mat_Int_Four;
	var bool AllowPattern;
	var bool AllowDecal;
	var bool AllowMaterialPrimaryTinting;
	var bool AllowMaterialSecondaryTinting;

	// If PartType == 'Decal'
	var string TexturePath;
	var bool AllowDecalTinting;
	var bool ForceAlpha;
};


var config array<SkyrangerCustomizationConfig> TemplateConfig;

/// <summary>
/// Override this method in sub classes to create new templates by creating new X2<Type>Template
/// objects and filling them out.
/// </summary>
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local X2SkyrangerCustomizationTemplate Template;
	local SkyrangerCustomizationConfig Cnf;
	
	foreach default.TemplateConfig(Cnf)
	{
		Template = new (none, string(Cnf.TemplateName)) class'X2SkyrangerCustomizationTemplate'; Template.SetTemplateName(Cnf.TemplateName);
		Template.PartType = Cnf.PartType;

		// If PartType == 'Material'
		Template.Mat_Zero = Cnf.Mat_Zero;
		Template.Mat_Hull = Cnf.Mat_Hull;
		Template.Mat_Glass = Cnf.Mat_Glass;
		Template.Mat_Interior = Cnf.Mat_Interior;
		Template.Mat_Engine = Cnf.Mat_Engine;
		Template.Mat_Landing = Cnf.Mat_Landing;
		Template.Mat_Int_Floor = Cnf.Mat_Int_Floor;
		Template.Mat_Int_Wall = Cnf.Mat_Int_Wall;
		Template.Mat_Int_Three = Cnf.Mat_Int_Three;
		Template.Mat_Int_Four = Cnf.Mat_Int_Four;
		Template.AllowPattern = Cnf.AllowPattern;
		Template.AllowDecal = Cnf.AllowDecal;
		Template.AllowMaterialPrimaryTinting = Cnf.AllowMaterialPrimaryTinting;
		Template.AllowMaterialSecondaryTinting = Cnf.AllowMaterialSecondaryTinting;

		// If PartType == 'Decal'
		Template.TexturePath = Cnf.TexturePath;
		Template.AllowDecalTinting = Cnf.AllowDecalTinting;
		Template.ForceAlpha = Cnf.ForceAlpha;

		Templates.AddItem(Template);
	}

	return Templates;
}