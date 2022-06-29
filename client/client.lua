ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(5000)
	end
end)

local open = false


local msoins = RageUI.CreateMenu("Ambulancier", "AIDE À LA PERSONNE", 1350, -5)
local callamb = RageUI.CreateSubMenu(msoins, "Ambulancier", "AIDE À LA PERSONNE")

local payamb = RageUI.CreateSubMenu(msoins, "Ambulancier", "AIDE À LA PERSONNE", 1350, -5)

local payfin = RageUI.CreateSubMenu(msoins, "Ambulancier", "AIDE À LA PERSONNE", 1350, -5)

msoins.Closed = function()
	open = false
end


local typeSoins = nil

local prix = nil

local descsoins = nil

local descrevive = nil

local payementMode = "money"


local MoyenPay = {"Espèce", "Carte bancaire"}
local listIndex = 1


function MSoins()
	if open then 
		open = false
		RageUI.Visible(msoins, false)
		return
	else
		open = true 
		RageUI.Visible(msoins, true)
		CreateThread(function()
		while open do
			Wait(5)
			RageUI.IsVisible(msoins,function() 
				RageUI.Separator("")
				if #player == 0 then
					RageUI.Separator("🚑  Ambulancier en ville : ~r~ Aucun")
				else
					RageUI.Separator("🚑  Ambulancier en ville : ~g~" ..#player)
				end
				RageUI.Separator("")
				RageUI.Button("Parler à l'ambulancier", nil, {RightBadge = RageUI.BadgeStyle.Heart}, Validate, {
					onSelected = function()  

						
					end
				}, callamb)

			end)
			RageUI.IsVisible(callamb,function() 
				RageUI.Separator("")
				RageUI.Separator("🚑  Actions ambulancier")
				RageUI.Separator("")

				local playerPed = PlayerPedId()

				local health = GetEntityHealth(playerPed)

				local maxhealth = GetEntityMaxHealth(playerPed)

				if health > 0 then
					if health ~= maxhealth then
						vieplayeraffiche = true
					else
						vieplayeraffiche = false
					end
				else
					vieplayeraffiche = false
				end

				if vieplayeraffiche then 
					descsoins = nil
				else
					descsoins = "Vous n'avez pas besoin de soins"
				end

				RageUI.Button("Soins blessure superficielle", descsoins, {RightBadge = RageUI.BadgeStyle.Heart}, vieplayeraffiche, {
					onSelected = function()

						prix = Config.PrixBlessureSuperficielle
						typeSoins = "blessuresuperficielle"
						RageUI.Visible(payamb, true)

					end
				})
				RageUI.Button("Soins blessure grave", descsoins, {RightBadge = RageUI.BadgeStyle.Heart}, vieplayeraffiche, {
					onSelected = function()  

						prix = Config.PrixBlessureGrave
						typeSoins = "blessuregrave"
						RageUI.Visible(payamb, true)

					end
				})
				if IsPlayerDead(PlayerId()) then
					dead = true
				else
					dead = false
				end


				if not dead then 
					descrevive = "Vous n'êtes pas inconscient"

				else
					descrevive =nil
				end

				RageUI.Button("Se faire réanimer", descrevive, {RightBadge = RageUI.BadgeStyle.Alert}, dead, {
					onSelected = function()  

						prix = Config.PrixReanimation
						typeSoins = "reanimation"
						RageUI.Visible(payamb, true)
						
					end
				})
			end)
			RageUI.IsVisible(payamb,function() 
				if prix ~= nil then
					RageUI.Separator("")
					RageUI.Separator("🚑  Prix à payer : ~b~~h~"..prix.." $")
					RageUI.Separator("")
				end
					RageUI.Separator("💵  Payer par :")
					RageUI.Separator("")

					if Config.PayementList then
						RageUI.List("Moyen de payement :", MoyenPay, listIndex, nil, {}, true, {
							onListChange = function(list) listIndex = list end,

							onSelected = function(list)

								if list == 1 then

									payementMode = "money"


									ESX.TriggerServerCallback('MVente:canPay', function(CanPay) 
										if CanPay >= prix then
											RageUI.Visible(payfin, true)
										else
											ESX.ShowAdvancedNotification('Hopital', 'Ambulancier', "Vous n'avez pas assez d'argent dans votre portefeuille !", 'CHAR_AMBULANCE', 1)
										end
									end, payementMode)

								end

								if list == 2 then

									payementMode = "bank"

									ESX.TriggerServerCallback('MVente:canPay', function(CanPay)
										if CanPay >= prix then
											RageUI.Visible(payfin, true)
										else
											ESX.ShowAdvancedNotification('Hopital', 'Ambulancier', "Vous n'avez pas assez d'argent sur votre compte bancaire !", 'CHAR_AMBULANCE', 1)
										end
									end, payementMode)

								end

							end
						})
					else
						RageUI.Button("Espèce", nil, {RightLabel = "💸"}, true, {
							onSelected = function()  

								payementMode = "money"

								ESX.TriggerServerCallback('MVente:canPay', function(CanPay)
									if CanPay >= prix then
										RageUI.Visible(payfin, true)
									else
										ESX.ShowAdvancedNotification('Hopital', 'Ambulancier', "Vous n'avez pas assez d'argent sur votre compte bancaire !", 'CHAR_AMBULANCE', 1)
									end
								end, payementMode)
									
							end
						})
						RageUI.Button("Carte bancaire", nil, {RightLabel = "💳"}, true, {
							onSelected = function()  

								payementMode = "bank"

								ESX.TriggerServerCallback('MVente:canPay', function(CanPay)
									if CanPay >= prix then
										RageUI.Visible(payfin, true)
									else
										ESX.ShowAdvancedNotification('Hopital', 'Ambulancier', "Vous n'avez pas assez d'argent sur votre compte bancaire !", 'CHAR_AMBULANCE', 1)
									end
								end, payementMode)
							end
						})
					end

			end)
			RageUI.IsVisible(payfin,function() 
				if payementMode == "money" then

					payementModeLabel = "espèce"

				end
				if payementMode == "bank" then

					payementModeLabel = "carte bancaire"

				end

				RageUI.Separator("")
				RageUI.Separator("Confirmer le payement en "..payementModeLabel )
				RageUI.Separator("")
				RageUI.Button("Accepter", nil, {Color = { BackgroundColor = { 0, 128, 0, 200 } }}, true, {
					onSelected = function()  
	
						TriggerServerEvent('MVente:Pay', prix, payementMode)


						local playerPed = PlayerPedId()

						if typeSoins == "blessuresuperficielle" then

							local health = GetEntityHealth(playerPed)

							local maxhealth = GetEntityMaxHealth(playerPed)

							if health > 0 then
								if health ~= maxhealth then

									TriggerEvent('MVente:heal', 'small')
									ESX.ShowAdvancedNotification('Hopital', 'Ambulancier', "Vous avez été soigné !", 'CHAR_AMBULANCE', 1)
								else
									ESX.ShowAdvancedNotification('Hopital', 'Ambulancier', "Vous n'avez pas besoin de soins !", 'CHAR_AMBULANCE', 1)
								end
							else
								ESX.ShowAdvancedNotification('Hopital', 'Ambulancier', "Vous êtes inconscient !", 'CHAR_AMBULANCE', 1)
							end

						elseif typeSoins == "blessuregrave" then

							local health = GetEntityHealth(playerPed)

							local maxhealth = GetEntityMaxHealth(playerPed)

							if health > 0 then
								if health ~= maxhealth then
									TriggerEvent('MVente:heal', 'big')
									ESX.ShowAdvancedNotification('Hopital', 'Ambulancier', "Vous avez été soigné !", 'CHAR_AMBULANCE', 1)
								else
									ESX.ShowAdvancedNotification('Hopital', 'Ambulancier', "Vous n'avez pas besoin de soins !", 'CHAR_AMBULANCE', 1)
								end
							else
								ESX.ShowAdvancedNotification('Hopital', 'Ambulancier', "Vous êtes inconscient !", 'CHAR_AMBULANCE', 1)
							end

						elseif typeSoins == "reanimation" then
							ESX.ShowAdvancedNotification('Hopital', 'Ambulancier', "Vous avez été réanimé !", 'CHAR_AMBULANCE', 1)
							TriggerEvent('esx_ambulancejob:revive')
						end

						open = false
							
					end
				})
				RageUI.Button("Refuser", nil, {Color = { BackgroundColor = { 255, 0, 0, 200 } }}, true, {
					onSelected = function()  
	
						RageUI.Visible(callamb, true)
							
					end
				})

			end)
		end
	end)
 end
end



RegisterNetEvent('MVente:heal')
AddEventHandler('MVente:heal', function(healType)
	local playerPed = PlayerPedId()
	local maxHealth = GetEntityMaxHealth(playerPed)


	if healType == 'small' then
		local health = GetEntityHealth(playerPed)
		local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 8))
		SetEntityHealth(playerPed, newHealth)
	elseif healType == 'big' then
		SetEntityHealth(playerPed, maxHealth)
	end
end)



function CombienAmbulance()
    local clientPlayers = false;
    ESX.TriggerServerCallback('ambulance:retrievePlayersEMS', function(players)
        clientPlayers = players
    end)
    while not clientPlayers do
        Citizen.Wait(0)
    end
    return clientPlayers
end


function Text(text)
	SetTextColour(186, 186, 186, 255)
	SetTextFont(0)
	SetTextScale(0.500, 0.500)
	SetTextWrap(0.0, 1.0)
	SetTextCentre(false)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 205)
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	
	EndTextCommandDisplayText(0.270, 0.91)
end


Citizen.CreateThread(function()

	local pedmodel = Config.PedModel
	local pedtype = Config.PedType

	local hash = GetHashKey(pedmodel)
	RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(1)
        end

    ped = CreatePed(pedtype, pedmodel, Config.Position, Config.OrientationPed, false, true) 

	--------------------------------------------

	SetBlockingOfNonTemporaryEvents(ped, true)
	FreezeEntityPosition(ped, true)
	SetBlockingOfNonTemporaryEvents(dj, true)
	SetPedDiesWhenInjured(ped, false)
	SetPedComponentVariation(ped, 0, i, 0, 0)
	SetPedCanPlayAmbientAnims(ped, true)
	SetPedCanRagdollFromPlayerImpact(ped, false)
	SetEntityInvincible(ped, true)

	while true do
		local Timer = 800
		local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
		local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Config.Position)
		if dist3 <= 2.0 then
			Timer = 0   
			Text("~w~Appyuer de ~b~[E]~w~ pour acceder aux services de l'ambulancier")
			if IsControlJustPressed(1,51) then
				player = CombienAmbulance()   
				if #player >= 1 then
					Validate = false
				else
					Validate = true
				end
				MSoins()
			end   
		end
		Citizen.Wait(Timer)
	end
end)
