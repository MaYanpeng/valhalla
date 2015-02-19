access = {
["no"] = "false",
["official"] = "false",
["private"] = "false",
["destination"] = "false",
["yes"] = "true",
["permissive"] = "true",
["agricultural"] = "false",
["customers"] = "true"
}

motor_vehicle = {
["no"] = 0,
["yes"] = 1,
["agricultural"] = 0,
["destination"] = 0,
["private"] = 0,
["forestry"] = 0,
["designated"] = 1,
["permissive"] = 1
}

bicycle = {
["yes"] = 4,
["designated"] = 4,
["dismount"] = 4,
["no"] = 0,
["lane"] = 4,
["track"] = 4,
["shared"] = 4,
["shared_lane"] = 4,
["sidepath"] = 4,
["share_busway"] = 4,
["none"] = 0
}

foot = {
["no"] = 0,
["yes"] = 2,
["designated"] = 2,
["permissive"] = 2,
["crossing"] = 2
}

function nodes_proc (kv, nokeys)
  --normalize a few tags that we care about
  local access = access[kv["access"]] or "true"
  local foot = foot[kv["foot"]] or 0
  local bike = bicycle[kv["bicycle"]] or 0
  local auto = motor_vehicle[kv["motor_vehicle"]]
  if auto == nil then
    auto = motor_vehicle[kv["motorcar"]]
  end
  auto = auto or 0

  --access was set, but foot, bike, and auto tags were not.
  if access == "true" and bit32.bor(auto, bike, foot) == 0 then
    bike = 4
    foot = 2
    auto = 1
  end 

  --check for gates and bollards
  local gate = kv["barrier"] == "gate" or kv["barrier"] == "lift_gate"
  local bollard = false
  if gate == false then
    --if there was a bollard cars can't get through it
    bollard = kv["barrier"] == "bollard" or kv["barrier"] == "block"

    --save the following as gates.
    if (bollard and (kv["bollard"] == "rising" or kv["bollard"] == "removable")) then
      gate = true
      bollard = false
    end

    auto = (bollard and 0) or 1

  end

  --store the gate and bollard info
  kv["gate"] = tostring(gate)
  kv["bollard"] = tostring(bollard)

  if kv["amenity"] == "bicycle_rental" or (kv["shop"] == "bicycle" and kv["service:bicycle:rental"] == "yes") then
    kv["bicycle_rental"] = "true"
  end

  --store a mask denoting access
  kv["access_mask"] = bit32.bor(auto, bike, foot)

  return 0, kv
end

function ways_proc (keyvalues, nokeys)
  --we dont care about ways at all so filter all of them
  return 1, keyvalues, 0, 0
end

function rels_proc (keyvalues, nokeys)
  --we dont care about rels at all so filter all of them
  return 1, keyvalues
end

function rel_members_proc (keyvalues, keyvaluemembers, roles, membercount)
  --because we filter all rels we never call this function
  membersuperseeded = {}
  for i = 1, membercount do
    membersuperseeded[i] = 0
  end

  return 1, keyvalues, membersuperseeded, 0, 0, 0
end

