using. /Verse.org/SceneGraph

component_group_interface<public> := interface<public> {

    ComponentGroups<public> : [string][]component = map{}

    HasComponentGroup<public><final>(ComponentGroup:string)<computes><decides>:void = ComponentGroups[ComponentGroup]

    (Entity:entity).AddComponentGroup<public><final>(ComponentGroup:string):void = {
        if (Components := ComponentGroups[ComponentGroup]) {
            Entity.AddComponents(Components)
        }
    }

    (Entity:entity).RemoveComponentGroup<public><final>(ComponentGroup:string):void = {
        for (Component : ComponentGroups[ComponentGroup]) {
            Component.RemoveFromEntity()
        }
    }
}