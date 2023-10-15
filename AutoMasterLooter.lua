-- Events
AutoMasterLooter = CreateFrame("Frame","AutoMasterLooter",UIParent)
AutoMasterLooter:RegisterEvent("PLAYER_ENTERING_WORLD")
AutoMasterLooter:RegisterEvent("LOOT_OPENED")
AutoMasterLooter:SetScript("OnEvent", function() OpenLoot_OnEvent(event, arg1) end)

-- Rares and epics that are subject to autoloot. ["exact ingame name of the item"] = "nickname (does nothing)"
LootedItemsTable = {}
LootedItemsTable["Wartorn Plate Scrap"] = "Plate scrap"
LootedItemsTable["Wartorn Chain Scrap"] = "Mail Scrap"
LootedItemsTable["Wartorn Leather Scrap"] = "leather Scrap"
LootedItemsTable["Wartorn Cloth Scrap"] = "Cloth Scrap"
LootedItemsTable["Frozen Rune"] = "Frozen Rune"
LootedItemsTable["Idol of Death"] = "Idol of Death"
LootedItemsTable["Idol of Life"] = "Idol of Life"
LootedItemsTable["Idol of Night"] = "Idol of Night"
LootedItemsTable["Idol of Rebirth"] = "Idol of Rebirth"
LootedItemsTable["Idol of Strife"] = "Idol of Strife"
LootedItemsTable["Idol of War"] = "Idol of War "
LootedItemsTable["Idol of the Sage"] = "Idol of the Sage "
LootedItemsTable["Idol of the Sun"] = "Idol of the Sun"
LootedItemsTable["Elementium Ore"] = "Elementium Ore"
LootedItemsTable["Fiery Core"] = "Fiery Core"
LootedItemsTable["Lava Core"] = "Lava Core"

-- Whites and greens that are excluded from autoloot.
ExcludedItemsTable = {}
ExcludedItemsTable["Tome of Tranquilizing Shot"] = "Tranq Shot book"
ExcludedItemsTable["Onyxia Hide Backpack"] = "Onyxia bag"
ExcludedItemsTable["Hazza'rah's Dream Thread"] = "Hazzarah"
ExcludedItemsTable["Gri'lek's Blood"] = "Grilek"
ExcludedItemsTable["Wushoolay's Mane"] = "Wushoolay"
ExcludedItemsTable["Renataki's Tooth"] = "Renataki"
ExcludedItemsTable["Mr. Bigglesworth"] = "KT cat"


local AutoMasterLooter = 0

function AutoMasterLooterSwitch(cmd)
	if AutoMasterLooter == 0 then
		DEFAULT_CHAT_FRAME:AddMessage("AutoMasterLooter |cffFF0000ON")
		AutoMasterLooter = 1
	else
		DEFAULT_CHAT_FRAME:AddMessage("AutoMasterLooter |cffFF0000OFF")
		AutoMasterLooter = 0
	end
end

SLASH_AUTOMASTERLOOTER1 = '/automasterlooter'
SLASH_AUTOMASTERLOOTER2 = '/automl'
SLASH_AUTOMASTERLOOTER3 = '/automasterloot'
SlashCmdList.AUTOMASTERLOOTER = AutoMasterLooterSwitch

function OpenLoot_OnEvent()
	lootmethod, masterlooterID = GetLootMethod()
	if masterlooterID == 0 and AutoMasterLooter == 1 then -- Only run if the player is the masterlooter.
		local announcestring = "Epic inside! " -- Generate announce message
		for looterindex = 1, 40 do
			if (GetMasterLootCandidate(looterindex) == UnitName("player")) then
				for lootedindex = 1, GetNumLootItems() do
					lootIcon, lootName, lootQuantity, rarity = GetLootSlotInfo(lootedindex)
					if rarity == 4 and lootName ~= "Elementium Ore" then
						announcestring = announcestring..lootName.." ! " -- Add any found epics to the announce message. Except Elementium Ore, because it's automatically looted to the player.
					end 
					if rarity < 3 then
						local IsExcludedItem = 0
						for ExcludedTableName,ExcludedTableAnnounce in pairs(ExcludedItemsTable) do			
							if ExcludedTableName == lootName then
								IsExcludedItem = 1 -- Found a white/green item that shouldn't be masterlooted
							elseif next(ExcludedItemsTable,ExcludedTableName) == nil and IsExcludedItem == 0 then
								GiveMasterLoot(lootedindex, looterindex) -- If we went through all the items that should be excluded and none of them matched, loot the item.
							end
						end
					else
						for LootTableName,LootTableAnnounce in pairs(LootedItemsTable) do
							if LootTableName == lootName or rarity <3 then
								GiveMasterLoot(lootedindex, looterindex) -- loot item if it's gray/white/green/listed blue
							end
						end
					end
				end
			end
		end
		if announcestring ~= "Epic inside! " then
			DEFAULT_CHAT_FRAME:AddMessage(announcestring) -- Announce the message if any epics were added into it.
			PlaySound("AuctionWindowClose") -- Play a warning sound. I chose auction house close, you can choose any sound you want from https://wowwiki-archive.fandom.com/wiki/API_PlaySound?oldid=313344 
		end
	end
end
