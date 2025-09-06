LevelingMath<public> := module {

    # Parametric Leveling Curve Interface
    # https://www.desmos.com/calculator/bqb0hvzg1l
    custom_curve_leveling_interface<public> := interface {
        Base<public> : float = 1.0
        Exponent<public> : float = 2.0
        MaxLevel<public> : float = Inf

        GetCurrentLevel<public>(CurrentXP:float)<computes><reads>:float = Min(Pow(CurrentXP / Base, 1.0 / Exponent), MaxLevel)
        GetTotalXPNeededForLevel<public>(Level:float)<computes><reads>:float = Base * Pow(Level, Exponent)
        GetXPNeededToLevelUp<public>(CurrentLevel:float, CurrentXP:float)<computes><reads>:float = GetTotalXPNeededForLevel(CurrentLevel + 1.0) - CurrentXP
    }

    # Base Class with Parametric Leveling Curve where you can override its parameters
    custom_curve_leveling<public> := class<computes>(custom_curve_leveling_interface) {
        # Base<override> : float = 5.0
        # Exponent<override> : float = 2.5
        # MaxLevel<override> : float = 100.0
    }

    ### Quadratic Deterministic Leveling System
    QuadraticLeveling<public> := module {
        # Returns the total XP needed to reach the next level
        GetXPNeededToNextLevel<public>(CurrentLevel:float)<computes><reads>:float = {
            # if (CurrentLevel >= 0.0) {
                Pow(CurrentLevel, 2.0) + 100.0
            # } else. 0.0
        }

        # Returns the total XP needed to reach a specific level
        GetTotalXPNeededForLevel<public>(Level:float)<computes>:float = {
            # if (Level > 0.0) {
                (Level - 1.0) * Level * (2.0 * Level - 1.0) / 6.0 + 100.0 * Level
            # } else. 0.0
        }

        # Returns the remaining XP needed to reach the next level
        GetXPNeededToLevelUp<public>(CurrentLevel:float, CurrentXP:float)<computes>:float = {
            TotalXP := GetTotalXPNeededForLevel(CurrentLevel + 1.0)
            return TotalXP - CurrentXP
        }

        # Returns the current level based on the total XP with a binary search
        GetCurrentLevel<public>(CurrentTotalXP:float)<transacts>:float = {
            var LowerBounds : float = 0.0
            var HigherBounds : float = Pow(3.0 * CurrentTotalXP, 1.0 / 3.0) + 10.0
            var ResultingLevel : float = 0.0

            loop {
                if (LowerBounds > HigherBounds). break

                if (MiddlePoint := Floor[(LowerBounds + HigherBounds) / 2.0] * 1.0) {
                    TotalXPAtMiddle := GetTotalXPNeededForLevel(MiddlePoint)

                    if (TotalXPAtMiddle <= CurrentTotalXP) {
                        set ResultingLevel = MiddlePoint
                        set LowerBounds = MiddlePoint + 1.0
                    } else {
                        set HigherBounds = MiddlePoint - 1.0
                    }
                } else {
                    set ResultingLevel = CurrentTotalXP
                    break
                }
            }

            ResultingLevel
        }
    }
}