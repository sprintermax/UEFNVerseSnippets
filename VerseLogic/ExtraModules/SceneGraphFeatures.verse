using. /Fortnite.com/Characters
using. /Verse.org/SceneGraph
using. /Verse.org/Simulation
using. /Verse.org/SpatialMath

# OldSpatialMath<public> := import(/UnrealEngine.com/Temporary/SpatialMath)

<#> NOTE: Scene Graph is under constant development by epic, with lots of features changing over time.
    Expect this file to have lots of breaking changes until reaching a more stable state.

SceneGraphFeatures<public> := module {

    # If Strict is set to true, will force a fail when no agent was found
    (Entity:entity).GetAgentsInVolume<public>(GlobalTransform:transform, Volume:collision_volume, (?Strict:logic=false))<decides><transacts>:[]agent = {

        var AgentsInVolume : []agent = array{}

        for (
            OverlapHit : Entity.FindOverlapHits(GlobalTransform, Volume)
            TargetEntity := OverlapHit.TargetComponent.Entity
            EntityAgent := agent[TargetEntity]
            not AgentsInVolume.Find[EntityAgent]
        ) {
            set AgentsInVolume += array{EntityAgent}
        }

        AgentsInVolume.Length > 0 or not Strict?

        AgentsInVolume
    }


    <#> A custom Line Trace function with optional fixed ground plane height.
        Expect changes in the future to improve optimization and usability.
    LineTraceRaycast<public> := module {
        line_trace_target_type<public> := enum<open> {
            Undefined
            Component
            GroundPlane
            TraceStart
            TraceEnd
        }

        line_trace_target_info<public> := struct {
            Type<public> : line_trace_target_type

            Position<public> : vector3
            NormalizedDistance<public> : float

            RawHitData<public> : ?sweep_hit = false

            Component<public> : ?component = false
            ContactNormal<public> : ?vector3 = false
        }

        (Entity:entity).LineTrace<public>(
            StartPosition:vector3,
            Direction:vector3,
            (local:)Distance:float,
            ?GroundHeight:?float = false
        ):[]line_trace_target_info = {

            var HitResults : []line_trace_target_info = array{
                line_trace_target_info{
                    Type := line_trace_target_type.TraceStart
                    Position := StartPosition
                    NormalizedDistance := 0.0
                }
            }

            TraceDisplacement := Direction * (local:)Distance
            TraceEndPosition := StartPosition + TraceDisplacement

            _GroundPlaneTarget := option{
                TraceEndPosition.Up < (_GroundHeight := GroundHeight?)
                HeightDifference := TraceDisplacement.Up <> 0.0
                PlaneDistanceDelta := (_GroundHeight - StartPosition.Up) / HeightDifference
                0.0 <= PlaneDistanceDelta <= 1.0
                line_trace_target_info{
                    Type := line_trace_target_type.GroundPlane
                    Position := StartPosition + TraceDisplacement * PlaneDistanceDelta
                    NormalizedDistance := PlaneDistanceDelta
                }
            }

            SweepHitResults := Entity.FindSweepHits(
                TraceDisplacement,
                transform{Translation := StartPosition},
                collision_point{CollisionProfile := CollisionProfiles.StationaryOverlapAll}
            )

            var _GroundPlaneTargetIndex : ?int = false

            for (SweepHitResult : SweepHitResults) {
                ComponentDistanceDelta := SweepHitResult.SourceHitDistance / (local:)Distance

                option {
                    not _GroundPlaneTargetIndex?
                    ComponentDistanceDelta > _GroundPlaneTarget?.NormalizedDistance
                    set _GroundPlaneTargetIndex = option{HitResults.Length}
                }

                set HitResults += array{line_trace_target_info{
                    Type := line_trace_target_type.Component
                    Position := SweepHitResult.ContactPosition
                    NormalizedDistance := ComponentDistanceDelta
                    RawHitData := option{SweepHitResult}
                    Component := option{SweepHitResult.TargetComponent}
                    ContactNormal := option{SweepHitResult.ContactFaceNormal}
                }}
            }

            option{
                GroundPlaneTarget := _GroundPlaneTarget?
                GroundPlaneTargetIndex := _GroundPlaneTargetIndex? or HitResults.Length
                HitResultsBeforeGroundPlane := HitResults.Slice[0, GroundPlaneTargetIndex]
                HitResultsAfterGroundPlane := HitResults.Slice[GroundPlaneTargetIndex, HitResults.Length]
                set HitResults = HitResultsBeforeGroundPlane + array{GroundPlaneTarget} + HitResultsAfterGroundPlane
            }

            set HitResults += array{line_trace_target_info{
                Type := line_trace_target_type.TraceEnd
                Position := TraceEndPosition
                NormalizedDistance := 1.0
            }}

            HitResults
        }

        # Conditional filtering functions to be used on Line Trace Result Array (See VerseFeatures -> Array Operations -> Find/Filter Functions)
        (LineTraceRaycast:)filter_by_entity_type<public>(TraceTargetInfo:line_trace_target_info, entity_type:castable_subtype(entity))<computes><decides>:void = {
            entity_type[TraceTargetInfo.Component?.Entity]
        }

        (LineTraceRaycast:)filter_by_component_type<public>(TraceTargetInfo:line_trace_target_info, component_type:castable_subtype(component))<computes><decides>:void = {
            component_type[TraceTargetInfo.Component?]
        }

        (LineTraceRaycast:)filter_by_entity_implements_component<public>(TraceTargetInfo:line_trace_target_info, component_type:castable_subtype(component))<computes><decides><reads>:void = {
            TraceTargetInfo.Component?.Entity.GetComponent[component_type]
        }

        (LineTraceRaycast:)filter_by_traceinfo_type<public>(TraceTargetInfo:line_trace_target_info, TargetType:line_trace_target_type)<computes><decides>:void = {
            TraceTargetInfo.Type = TargetType
        }
    }

    # Conditional filtering functions to be used on
    filter_by_entity_type<public>(InEntity:entity, entity_type:castable_subtype(entity))<computes><decides>:void = {
        entity_type[InEntity]
    }

    # filter_by_entity_implements_interface<public>(InEntity:entity, interface_type:castable_subtype(interface))<computes><decides>:void = {
    #     interface_type[InEntity]
    # }

    filter_by_component_type<public>(InComponent:component, component_type:castable_subtype(component))<computes><decides>:void = {
        component_type[InComponent]
    }

    # filter_by_component_implements_interface<public>(InComponent:component, interface_type:castable_subtype(interface))<computes><decides>:void = {
    #     interface_type[InComponent]
    # }

    filter_by_entity_implements_component<public>(InEntity:entity, component_type:castable_subtype(component))<computes><decides><reads>:void = {
        InEntity.GetComponent[component_type]
    }

    # filter_by_entity_implements_component_with_interface<public>(InEntity:entity, interface_type:castable_subtype(interface))<computes><decides><reads>:void = {
    #     (for (
    #         Component : InEntity.GetComponents()
    #         interface_type[InComponent]
    #     ) {
    #         Component
    #     }).Length > 0
    # }
}