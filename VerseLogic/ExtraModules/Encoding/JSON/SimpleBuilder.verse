SimpleBuilder<public> := module {
    (JSONValue:json_value).AsUEValue<public>()<decides><transacts> : UE_JSON.value = UE_JSON.Parse[JSONValue.Value]

    json_value<public> := class<internal><abstract><allocates><computes> { var<protected> Value<public> : string = "" }

    json_array<public> := class<final><allocates><computes>(json_value) {
        AddInternal<private>(NewValue:string)<transacts>:json_array = {
            set Value = if (Value.Length <= 2) { "[{NewValue}]" } else {
                (Value.Slice[0, Value.Length - 1] or "") + ",{NewValue}]"
            }; Self
        }

        Add<public>(NewValue:string)<transacts>:json_array = AddInternal("\"{NewValue}\"")
        Add<public>(NewValue:int)<transacts>:json_array = AddInternal("{NewValue}")
        Add<public>(NewValue:float)<transacts>:json_array = AddInternal("{NewValue}")
        Add<public>(JSONValue:json_value)<transacts>:json_array = AddInternal("{JSONValue.Value}")
        AddNull<public>()<transacts>:json_array = AddInternal("null")
    }

    json_object<public> := class<final><allocates><computes>(json_value) {
        AddInternal<private>(Key:string, NewValue:string)<transacts>:json_object = {
            set Value = if (Value.Length <= 2) { "\{\"{Key}\":{NewValue}\}" } else {
                (Value.Slice[0, Value.Length - 1] or "") + ",\"{Key}\":{NewValue}\}"
            }; Self
        }

        Add<public>(Key:string, NewValue:string)<transacts>:json_object = AddInternal(Key, "\"{NewValue}\"")
        Add<public>(Key:string, NewValue:int)<transacts>:json_object = AddInternal(Key, "{NewValue}")
        Add<public>(Key:string, NewValue:float)<transacts>:json_object = AddInternal(Key, "{NewValue}")
        Add<public>(Key:string, JSONValue:json_value)<transacts>:json_object = AddInternal(Key, "{JSONValue.Value}")
        AddNull<public>(Key:string)<transacts>:json_object = AddInternal(Key, "null")
    }
}