class X2SkyrangerCustomizationTemplateManager extends X2DataTemplateManager;

static function X2SkyrangerCustomizationTemplateManager GetSkyrangerCustomizationTemplateManager()
{
	return X2SkyrangerCustomizationTemplateManager(class'Engine'.static.GetTemplateManager(class'X2SkyrangerCustomizationTemplateManager'));
}

function bool AddSkyrangerCustomizationTemplate(X2SkyrangerCustomizationTemplate Template, bool ReplaceDuplicate = false)
{
	return AddDataTemplate(Template, ReplaceDuplicate);
}

function X2SkyrangerCustomizationTemplate FindSkyrangerCustomizationTemplate(name DataName)
{
	return X2SkyrangerCustomizationTemplate(FindDataTemplate(DataName));
}


function array<X2SkyrangerCustomizationTemplate> GetAllTemplatesOfClass(class<X2SkyrangerCustomizationTemplate> TemplateClass, optional int UseTemplateGameArea=-1)
{
	local array<X2SkyrangerCustomizationTemplate> arrTemplates;
	local X2DataTemplate Template;

	foreach IterateTemplates(Template, none)
	{
		if ((UseTemplateGameArea > -1) && !Template.IsTemplateAvailableToAllAreas(UseTemplateGameArea))
			continue;

		if (ClassIsChildOf(Template.Class, TemplateClass))
		{
			arrTemplates.AddItem(X2SkyrangerCustomizationTemplate(Template));
		}
	}

	return arrTemplates;
}

DefaultProperties
{
	TemplateDefinitionClass=class'X2SkyrangerCustomization'
	ManagedTemplateClass=class'X2SkyrangerCustomizationTemplate'
}