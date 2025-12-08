local Camps = {}
local RSGCore = nil
local VORPInv = nil
local VORPCore = nil

-- =============================================================================
-- FRAMEWORK LOADING & INIT
-- =============================================================================

CreateThread(function()
    Wait(1000) 

    if Config.framework == 'RSG' then
        RSGCore = exports['rsg-core']:GetCoreObject()
        print('^2[lyver_camp] RSG Core yuklendi.^0')
        RegisterUsableItems() -- RSG Itemlerini Kaydet
    elseif Config.framework == 'VORP' then
        if exports.vorp_inventory then
            VORPInv = exports.vorp_inventory:vorp_inventoryApi()
        end

        TriggerEvent("getCore", function(core)
            VORPCore = core
        end)

        if not VORPCore and exports.vorp_core then
            pcall(function()
                VORPCore = exports.vorp_core:GetCore()
            end)
        end

        if VORPCore then
            print('^2[lyver_camp] VORP Core basariyla yuklendi.^0')
            RegisterUsableItems() 
        else
            print('^1[lyver_camp] HATA: VORP Core bulunamadi!^0')
        end
    end
end)

local function ServerLog(msg)
    print('^3[SERVER-DEBUG] ' .. msg .. '^0')
end

-- =============================================================================
-- UTILS & HELPERS
-- =============================================================================

local function GetIdentifier(src)
    local _src = tonumber(src)

    if Config.framework == 'RSG' then
        if RSGCore then
            local Player = RSGCore.Functions.GetPlayer(_src)
            if Player then return Player.PlayerData.citizenid end
        end
    elseif Config.framework == 'VORP' then
        if VORPCore then
            local user = VORPCore.getUser(_src)
            if not user and VORPCore.GetUser then user = VORPCore.GetUser(_src) end

            if user then return user.getIdentifier() end
        end
    end

    local identifiers = GetPlayerIdentifiers(src)
    for _, id in ipairs(identifiers) do
        if string.find(id, "steam:") or string.find(id, "license:") then
            return id
        end
    end
    return identifiers[1]
end

local function PlayerHasItem(src, item, amount)
    local _src = tonumber(src)

    if not item or item == "" then
        print('^3[lyver_camp] UYARI: Item ismi bos oldugu icin kontrol yapilamadi.^0')
        return false
    end

    if Config.framework == 'RSG' then
        if not RSGCore then return false end
        local Player = RSGCore.Functions.GetPlayer(_src)
        if not Player then return false end
        local itemData = Player.Functions.GetItemByName(item)
        return (itemData and itemData.amount >= amount)
    elseif Config.framework == 'VORP' then
        if not exports.vorp_inventory then return false end

        local inventory = exports.vorp_inventory:getUserInventoryItems(_src)

        if not inventory then return false end

        local totalCount = 0
        for _, invItem in pairs(inventory) do
            if invItem.name == item then
                local count = invItem.count or invItem.amount or 0
                totalCount = totalCount + count
            end
        end

        return totalCount >= amount
    end
    return true
end

local function RemoveItem(src, item, amount)
    local _src = tonumber(src)
    if Config.framework == 'RSG' then
        local Player = RSGCore.Functions.GetPlayer(_src)
        if Player then Player.Functions.RemoveItem(item, amount) end
    elseif Config.framework == 'VORP' then
        exports.vorp_inventory:subItem(_src, item, amount)
    end
end

local function GiveItem(src, item, amount)
    local _src = tonumber(src)
    if Config.framework == 'RSG' then
        local Player = RSGCore.Functions.GetPlayer(_src)
        if Player then Player.Functions.AddItem(item, amount) end
    elseif Config.framework == 'VORP' then
        exports.vorp_inventory:addItem(_src, item, amount)
    end
end

local function Notify(src, msg)
    if Config.framework == 'RSG' then
        TriggerClientEvent('RSGCore:Notify', src, msg, 'primary')
    else
        TriggerClientEvent('lyver_camp:client:notify', src, msg)
    end
end

local function GetCampByOwner(identifier)
    for _, camp in pairs(Camps) do
        if camp.owner == identifier then return camp end
    end
    return nil
end

local function CanPlayerPlaceCamp(identifier, campType)
    local count = 0
    local limit = Config[campType .. 'Camp'].MaxPerPlayer or 1

    for _, camp in pairs(Camps) do
        if camp.owner == identifier then count = count + 1 end
    end
    return count < limit
end

-- =============================================================================
-- USABLE ITEMS
-- =============================================================================

function RegisterUsableItems()
    local campTypes = { 'Small', 'Mid', 'Pro' }

    for _, typeName in ipairs(campTypes) do
        local configData = Config[typeName .. 'Camp']
        local itemName = configData.ItemName

        if Config.framework == 'RSG' then
            RSGCore.Functions.CreateUseableItem(itemName, function(source, item)
                local src = source
                TriggerClientEvent('lyver_camp:client:startPlacement', src, typeName)
            end)
        elseif Config.framework == 'VORP' then
            if VORPInv then
                VORPInv.RegisterUsableItem(itemName, function(data)
                    local src = data.source
                    TriggerClientEvent('lyver_camp:client:startPlacement', src, typeName)
                end)
            end
        end
    end
    print('^2[lyver_camp] [' .. Config.framework .. '] Usable items registered.^0')
end

-- =============================================================================
-- DATABASE & EVENTS
-- =============================================================================

local function CreateCampInDatabase(owner, coords, heading, campType, cb)
    exports.oxmysql:insert(
        'INSERT INTO lyver_camps (owner, x, y, z, heading, type) VALUES (?, ?, ?, ?, ?, ?)',
        { owner, coords.x, coords.y, coords.z, heading or 0.0, campType },
        function(insertId)
            if not insertId then
                if cb then cb(nil) end
                return
            end

            local camp = {
                id      = insertId,
                owner   = owner,
                coords  = { x = coords.x, y = coords.y, z = coords.z },
                heading = heading or 0.0,
                type    = campType
            }
            Camps[insertId] = camp
            if cb then cb(camp) end
        end
    )
end

local function DeleteCampFromDatabase(campId)
    exports.oxmysql:update('DELETE FROM lyver_camps WHERE id = ?', { campId })
end

RegisterCommand('rcamp', function(source, args)
    local src = source
    local iden = GetIdentifier(src)
    if not iden then return end

    local myCamp = GetCampByOwner(iden)

    if not myCamp then
        Notify(src, "Kurulu bir kampin yok.")
        return
    end

    Camps[myCamp.id] = nil
    DeleteCampFromDatabase(myCamp.id)
    TriggerClientEvent('lyver_camp:client:removeCamp', -1, myCamp.id)

    -- Kamp türüne göre eşyayı geri ver
    local campType = myCamp.type or 'Small'
    local itemToGive = Config[campType .. 'Camp'].ItemName

    GiveItem(src, itemToGive, 1)
    Notify(src, "Kamp toplandi ve esya geri verildi.")
end)

RegisterNetEvent('lyver_camp:server:placeCamp', function(coords, heading, campType)
    local src = source
    local iden = GetIdentifier(src)

    if not campType then
        campType = 'Small'
        print('^3[UYARI] Client campType gondermedi, varsayilan (Small) kullaniliyor.^0')
    end

    local configData = Config[campType .. 'Camp']
    if not configData then
        print('^1[HATA] Config dosyasinda boyle bir kamp turu yok: ' .. tostring(campType) .. 'Camp^0')
        return
    end

    local requiredItem = configData.ItemName
    if not requiredItem then
        print('^1[HATA] Config.' .. campType .. 'Camp icinde "ItemName" tanimli degil!^0')
        Notify(src, 'Sunucu hatasi: ItemName bulunamadi.')
        return
    end

    if not iden or not coords then return end

    if not PlayerHasItem(src, requiredItem, 1) then
        Notify(src, 'Uzerinde gerekli esya yok: ' .. requiredItem)
        return
    end

    if not CanPlayerPlaceCamp(iden, campType) then
        Notify(src, 'Bu turden daha fazla kamp kuramazsin!')
        return
    end

    RemoveItem(src, requiredItem, 1)

    CreateCampInDatabase(iden, coords, heading or 0.0, campType, function(camp)
        if not camp then return end
        TriggerClientEvent('lyver_camp:client:addCamp', -1, camp)
        Notify(src, campType .. ' kamp kuruldu.')
    end)
end)
RegisterNetEvent('lyver_camp:server:requestCamps', function()
    local src = source
    TriggerClientEvent('lyver_camp:client:syncCamps', src, Camps)
end)

AddEventHandler('onResourceStart', function(resName)
    if (GetCurrentResourceName() ~= resName) then return end

    exports.oxmysql:query('SELECT * FROM lyver_camps', {}, function(rows)
        Camps = {}
        for _, row in ipairs(rows or {}) do
            Camps[row.id] = {
                id      = row.id,
                owner   = row.owner,
                coords  = { x = row.x, y = row.y, z = row.z },
                heading = row.heading or 0.0,
                type    = row.type or 'Small'
            }
        end
        print('^2[lyver_camp] Yuklenen kamp sayisi: ' .. tostring(#rows or 0) .. '^0')
    end)
end)
