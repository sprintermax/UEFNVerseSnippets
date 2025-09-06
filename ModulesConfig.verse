# Verse Modules Folders
VerseLogic<public> := module{
    ExtraModules<public> := module{}
    GameFeatures<public> := module{
        DataDefinitions<public> := module{}
        DataManagement<public> := module{}
        GameplayClasses<public> := module{
            CoreComponents<public> := module{}
            CreativeDevices<public> := module{}
            UILibrary<public> := module{
                Screens<public> := module{}
                Events<public> := module{}
                (UILibrary:)Components<public> := module{
                    Buttons<public> := module{}
                    HUDElements<public> := module{}
                    Primitives<public> := module{}
                    Toggles<public> := module{}
                }
            }
        }
        GameplayCore<public> := module{
            PlayerEvents<public> := module{}
        }
        GameplayInterfaces<public> := module{}
    }
}

# Asset Files
CommonAssets<public> := module{
    Materials<public> := module{
        Instances<public> := module{}
        Functions<public> := module{}
    }
    Meshes<public> := module{}
    Textures<public> := module{
        Icons<public> := module{}
    }
}

CustomProps<public> := module{
    BaseAnchor<public> := module{
        Blueprints<public> := module{}
        Materials<public> := module{}
    }
    CreativeDevice<public> := module{
        Materials<public> := module{
            Instances<public> := module{}
        }
        Meshes<public> := module{}
        Textures<public> := module{
            DeviceIcons<public> := module{}
        }
    }
}

UserInterface<public> := module{
    Materials<public> := module{
        Icons<public> := module{}
        UIComponents<public> := module{
            Instances<public> := module{}
        }
    }
    Textures<public> := module{
        Icons<public> := module{
            Achievements<public> := module{}
            Cosmetics<public> := module{}
            Currencies<public> := module{}
            PermissionTags<public> := module{}
            Statistics<public> := module{}
        }
    }
    Widgets<public> := module{
        Templates<public> := module{}
    }
}