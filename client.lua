local camps            = {}
local spawnedCampProps = {}
local placement        = {
    active   = false,
    basePos  = nil,
    heading  = 0.0,
    ghosts   = {},
    campType = nil 
}

local BuildPromptGroup = GetRandomIntInRange(0, 0xffffff)
local BuildPrompts     = {}

-- =============================================================================
-- 1. HELPERS & DEBUG
-- =============================================================================

local function ClientLog(msg)
    print('^5[CLIENT-DEBUG] ' .. msg .. '^0')
end

local function Notify(msg)
    if Config.framework == 'RSG' then
        TriggerEvent('ox_lib:notify', msg, 'primary')
    else
        local str = CreateVarString(10, "LITERAL_STRING", msg)
        Citizen.InvokeNative(0xFA233F8FE190514C, str)
    end
end

RegisterNetEvent('lyver_camp:client:notify', function(msg) Notify(msg) end)

local function RotationToDirection(rotation)
    local radX, radZ = math.rad(rotation.x), math.rad(rotation.z)
    return vector3(-math.sin(radZ) * math.abs(math.cos(radX)), math.cos(radZ) * math.abs(math.cos(radX)), math.sin(radX))
end

local function RotateOffset(offset, headingDegrees)
    local rad = math.rad(headingDegrees)
    local sinH, cosH = math.sin(rad), math.cos(rad)
    return vector3(offset.x * cosH - offset.y * sinH, offset.x * sinH + offset.y * cosH, offset.z)
end

local function LoadModel(model)
    local hash = GetHashKey(model)
    if not IsModelInCdimage(hash) then
        ClientLog("Model bulunamadi: " .. tostring(model))
        return nil
    end
    RequestModel(hash)
    local t = 0
    while not HasModelLoaded(hash) and t < 50 do
        Wait(10)
        t = t + 1
    end
    if not HasModelLoaded(hash) then return nil end
    return hash
end

local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
end

-- =============================================================================
-- 2. PROP SPAWN 
-- =============================================================================

local function DeleteCampProps(campId)
    if spawnedCampProps[campId] then
        for _, entity in ipairs(spawnedCampProps[campId]) do
            if DoesEntityExist(entity) then
                SetEntityAsMissionEntity(entity, true, true)
                DeleteObject(entity)
            end
        end
    end
    spawnedCampProps[campId] = nil
end

local function SpawnCampPropsForCamp(camp)
    CreateThread(function()
        DeleteCampProps(camp.id)

        local cType = camp.type or 'Small'
        local propList = Config[cType .. 'CampProps']

        if not propList then return end

        local x, y, z = tonumber(camp.coords.x), tonumber(camp.coords.y), tonumber(camp.coords.z)
        if not x or not y or not z then return end

        local campCenter = vector3(x, y, z)
        local campHeading = tonumber(camp.heading) or 0.0
        local spawned = {}

        for i, propData in ipairs(propList) do
            local hash = LoadModel(propData.model)
            if hash then
                local rotatedOffset = RotateOffset(propData.offset, campHeading)
                local targetX = campCenter.x + rotatedOffset.x
                local targetY = campCenter.y + rotatedOffset.y

                local searchStartZ = campCenter.z + 2.0
                local foundGround, groundZ = GetGroundZFor_3dCoord(targetX, targetY, searchStartZ, false)

                local finalZ = campCenter.z
                if foundGround then
                    finalZ = groundZ
                else
                    local foundGround2, groundZ2 = GetGroundZFor_3dCoord(targetX, targetY, campCenter.z + 50.0, false)
                    if foundGround2 then finalZ = groundZ2 end
                end

                local obj = CreateObject(hash, targetX, targetY, finalZ, false, false, false)

                if DoesEntityExist(obj) then
                    SetEntityAsMissionEntity(obj, true, true)
                    SetModelAsNoLongerNeeded(hash)

                    local finalHeading = campHeading + (propData.heading or 0.0)
                    SetEntityHeading(obj, finalHeading)

                    PlaceObjectOnGroundProperly(obj)
                    FreezeEntityPosition(obj, true)

                    table.insert(spawned, obj)
                end
            end
        end
        spawnedCampProps[camp.id] = spawned
    end)
end

-- =============================================================================
-- 3. EVENTS
-- =============================================================================

RegisterNetEvent('lyver_camp:client:syncCamps', function(serverCamps)
    camps = serverCamps or {}
    for id, campData in pairs(camps) do SpawnCampPropsForCamp(campData) end
end)

RegisterNetEvent('lyver_camp:client:addCamp', function(campData)
    camps[campData.id] = campData
    SpawnCampPropsForCamp(campData)
end)

RegisterNetEvent('lyver_camp:client:removeCamp', function(campId)
    DeleteCampProps(campId)
    camps[campId] = nil
end)

RegisterCommand('fixcamp', function()
    placement.active = false
    FreezeEntityPosition(PlayerPedId(), false)
    for _, obj in ipairs(placement.ghosts) do DeleteEntity(obj.entity) end
    placement.ghosts = {}
end)

-- =============================================================================
-- 4. PLACEMENT LOGIC
-- =============================================================================

RegisterNetEvent('lyver_camp:client:startPlacement', function(campType)
    ClientLog("Placement Eventi Geldi: " .. tostring(campType))

    if placement.active then
        Notify("Zaten kurulum modundasin!")
        return
    end

    local ped = PlayerPedId()

    placement.campType = campType or 'Small'
    local propsToUse = Config[placement.campType .. 'CampProps']

    if not propsToUse then
        Notify("HATA: Config bulunamadi (" .. placement.campType .. ")")
        return
    end

    Notify("Setup: Mouse ile yerlestir, E ile kur.")
    FreezeEntityPosition(ped, true)

    placement.active = true
    local coords = GetEntityCoords(ped)
    local fwd = GetEntityForwardVector(ped)
    placement.basePos = coords + (fwd * 2.0)
    placement.heading = GetEntityHeading(ped)

    CreateThread(function()
        if #placement.ghosts > 0 then for _, obj in ipairs(placement.ghosts) do DeleteEntity(obj.entity) end end
        placement.ghosts = {}

        for _, propData in ipairs(propsToUse) do
            local hash = LoadModel(propData.model)
            if hash then
                local obj = CreateObject(hash, placement.basePos.x, placement.basePos.y, placement.basePos.z, false,
                    false, false, false)
                SetEntityAlpha(obj, 150, false)
                SetEntityCollision(obj, false, false)
                FreezeEntityPosition(obj, true)
                table.insert(placement.ghosts, { entity = obj, data = propData })
            end
        end

        local function SetupBuildPrompts()
            local str = placement.campType .. ' Camp Setup'
            local promptGroupName = CreateVarString(10, 'LITERAL_STRING', str)
            PromptSetActiveGroupThisFrame(BuildPromptGroup, promptGroupName)
            if not BuildPrompts.Place then
                BuildPrompts.Place = PromptRegisterBegin()
                PromptSetControlAction(BuildPrompts.Place, Config[placement.campType .. 'Camp'].PlaceKey or 0xCEFD9220)
                local label = CreateVarString(10, 'LITERAL_STRING', 'Place')
                PromptSetText(BuildPrompts.Place, label)
                PromptSetEnabled(BuildPrompts.Place, true)
                PromptSetVisible(BuildPrompts.Place, true)
                PromptSetStandardMode(BuildPrompts.Place, 1)
                PromptSetGroup(BuildPrompts.Place, BuildPromptGroup)
                PromptRegisterEnd(BuildPrompts.Place)
            end
            if not BuildPrompts.Cancel then
                BuildPrompts.Cancel = PromptRegisterBegin()
                PromptSetControlAction(BuildPrompts.Cancel, Config[placement.campType .. 'Camp'].CancelKey or 0x156F7119)
                local label = CreateVarString(10, 'LITERAL_STRING', 'Cancel')
                PromptSetText(BuildPrompts.Cancel, label)
                PromptSetEnabled(BuildPrompts.Cancel, true)
                PromptSetVisible(BuildPrompts.Cancel, true)
                PromptSetStandardMode(BuildPrompts.Cancel, 1)
                PromptSetGroup(BuildPrompts.Cancel, BuildPromptGroup)
                PromptRegisterEnd(BuildPrompts.Cancel)
            end
        end

        while placement.active do
            Wait(0)
            SetupBuildPrompts()

            local rotateSpeed = 2.0
            if IsControlPressed(0, 0x308588E6) or IsControlPressed(0, 0xDE794E3E) then placement.heading = placement
                .heading + rotateSpeed end
            if IsControlPressed(0, 0x24D00D98) or IsControlPressed(0, 0xE30CD707) then placement.heading = placement
                .heading - rotateSpeed end

            local camRot = GetGameplayCamRot(0)
            local camCoords = GetGameplayCamCoord()
            local direction = RotationToDirection(camRot)
            local dest = vector3(camCoords.x + direction.x * 20.0, camCoords.y + direction.y * 20.0,
                camCoords.z + direction.z * 20.0)
            local shapeTest = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, dest.x, dest.y, dest.z, 1, ped, 0)
            local _, hit, hitCoords, _, _ = GetShapeTestResult(shapeTest)
            if hit == 1 then placement.basePos = hitCoords end

            for _, ghost in ipairs(placement.ghosts) do
                local entity, data = ghost.entity, ghost.data
                local rotatedOffset = RotateOffset(data.offset, placement.heading)
                local targetX = placement.basePos.x + rotatedOffset.x
                local targetY = placement.basePos.y + rotatedOffset.y

                local foundGround, groundZ = GetGroundZFor_3dCoord(targetX, targetY, placement.basePos.z + 5.0, false)
                local targetZ = foundGround and groundZ or placement.basePos.z

                SetEntityCoordsNoOffset(entity, targetX, targetY, targetZ, false, false, false)
                SetEntityHeading(entity, placement.heading + (data.heading or 0.0))
            end

            local placeKey = Config[placement.campType .. 'Camp'].PlaceKey or 0xCEFD9220
            if PromptHasHoldModeCompleted(BuildPrompts.Place) or IsControlJustPressed(0, placeKey) then
                local tooClose = false
                local minDist = Config[placement.campType .. 'Camp'].MinDistanceBetweenCamps or 3.0

                for id, camp in pairs(camps) do
                    local campPos = vector3(camp.coords.x, camp.coords.y, camp.coords.z)
                    if #(placement.basePos - campPos) < minDist then
                        tooClose = true
                        break
                    end
                end

                if tooClose then
                    Notify("Too close!")
                else
                    placement.active = false

                    for _, obj in ipairs(placement.ghosts) do DeleteEntity(obj.entity) end
                    placement.ghosts = {}

                    local animDict = "mini_games@story@beechers@build_floor@john"
                    LoadAnimDict(animDict)
                    TaskTurnPedToFaceCoord(ped, placement.basePos.x, placement.basePos.y, placement.basePos.z, 1000)
                    Wait(500)
                    TaskPlayAnim(ped, animDict, "hammer_loop_good", 8.0, -8.0, -1, 1, 0, false, false, false)

                    Wait(4000)
                    ClearPedTasks(ped)

                    TriggerServerEvent('lyver_camp:server:placeCamp', placement.basePos, placement.heading,
                        placement.campType)
                    FreezeEntityPosition(ped, false)
                end
            end

            local cancelKey = Config[placement.campType .. 'Camp'].CancelKey or 0x156F7119
            if IsControlJustPressed(0, cancelKey) then
                placement.active = false
                for _, obj in ipairs(placement.ghosts) do DeleteEntity(obj.entity) end
                placement.ghosts = {}
                FreezeEntityPosition(ped, false)
                Notify("Canceled.")
            end
        end
    end)
end)

-- INIT
CreateThread(function()
    Wait(2000)
    TriggerServerEvent('lyver_camp:server:requestCamps')
end)

AddEventHandler('onResourceStop', function(resName)
    if (GetCurrentResourceName() ~= resName) then return end
    for _, obj in ipairs(placement.ghosts) do DeleteEntity(obj.entity) end
    for id, _ in pairs(camps) do DeleteCampProps(id) end
    FreezeEntityPosition(PlayerPedId(), false)
end)
