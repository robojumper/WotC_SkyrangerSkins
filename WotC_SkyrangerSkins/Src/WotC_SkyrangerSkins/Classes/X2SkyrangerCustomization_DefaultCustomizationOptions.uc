class X2SkyrangerCustomization_DefaultCustomizationOptions extends X2SkyrangerCustomization config(SkyrangerSkins);

var config array<name> MaterialOptions;

/// <summary>
/// Override this method in sub classes to create new templates by creating new X2<Type>Template
/// objects and filling them out.
/// </summary>
static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local name TemplateName;
	local X2DataTemplate Template;

	foreach default.MaterialOptions(TemplateName)
	{
		`CREATE_X2TEMPLATE(class'X2SkyrangerMaterialsTemplate', Template, TemplateName);
		Templates.AddItem(Template);
	}

	return Templates;
}