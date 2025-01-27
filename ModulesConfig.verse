# Verse Files
VerseLogic<public> := module{
    CreativeDevices<public> := module{}
    CustomClasses<public> := module{}
    ExtraModules<public> := module{}
    GameplayLogic<public> := module{}
    SceneGraph<public> := module{
        Components<public> := module{}
    }
}

# Asset Files
Props<public> := module{
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
    Textures<public> := module{
        Icons<public> := module{}
    }
    Widgets<public> := module{
        Templates<public> := module{}
    }
}