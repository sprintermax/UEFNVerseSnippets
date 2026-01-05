# Verse Modules Folders
VerseLogic<public> := module{
    Algorithms<public> := module{}
    ExtraModules<public> := module{
        BitMath<public> := module{}
        Crypto<public> := module{}
        DateTime<public> := module{}
        Encoding<public> := module{
            UUID<public> := module{}
        }
        Hashing<public> := module{
            MD5<public> := module{}
        }
        StringProcessing<public> := module{
            Regex<public> := module{
                Syntax<public> := module{}
            }
        }
    }
    GameFeatures<public> := module{
        DataDefinitions<public> := module{}
        DataManagement<public> := module{}
        GameplayClasses<public> := module{
            CoreComponents<public> := module{
                DebugDraw<public> := module{}
            }
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
        Functions<public> := module{
            MathLogic<public> := module{
                FloatBool<public> := module{}
            }
            Utils<public> := module{}
        }
    }
    Meshes<public> := module{}
    Metasound<public> := module{}
    Textures<public> := module{
        Icons<public> := module{}
        WorldGrid<public> := module{}
    }
    Particles<public> := module{
        DebugDraw<public> := module{}
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
    WidgetBlueprints<public> := module{
        Templates<public> := module{}
    }
}