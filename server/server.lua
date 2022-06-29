ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterServerCallback('ambulance:retrievePlayersEMS', function(playerId, cb)
    local players = {}
    local xPlayers = ESX.GetPlayers()

    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        if xPlayer.getJob().name == Config.JobName then
            table.insert(players, {
                id = "0",
                group = xPlayer.getGroup(),
                source = xPlayer.source,
                jobs = xPlayer.getJob().name,
                name = xPlayer.getName()
            })
        end
    end

    cb(players)
end)


ESX.RegisterServerCallback('MVente:canPay', function(source, cb, type)
    local xPlayer = ESX.GetPlayerFromId(source)

    if type == "money" then
        local moneyPay = xPlayer.getMoney()
        cb(moneyPay)
    elseif type == "bank" then
        local moneyPay = xPlayer.getAccount('bank').money
        cb(moneyPay)
    end
end)


RegisterServerEvent('MVente:Pay')
AddEventHandler('MVente:Pay', function(price, type)

    local xPlayer = ESX.GetPlayerFromId(source)

	local society = Config.SocietyName

    if type == "money" then
		TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
			account.addMoney(price)
		end)
        xPlayer.removeMoney(price)

    elseif type == "bank" then
		TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
			account.addMoney(price)
		end)
        xPlayer.removeAccountMoney('bank', price)

    end
end)


RegisterNetEvent('MVente:revive')
AddEventHandler('MVente:revive', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	TriggerServerEvent('esx_ambulance:setDeathStatus', false)

	Citizen.CreateThread(function()

		RageUI.GoBack()
		RageUI.CloseAll()
		menuambulancejoblol = false

		DoScreenFadeOut(800)
		StopScreenEffect('Dont_tazeme_bro')
		StopScreenEffect('MenuMGIn')
		SendNUIMessage({ sound = "audio_hearth", volume = 1.0})


		while not IsScreenFadedOut() do
			Citizen.Wait(50)
		end

		local formattedCoords = {
			x = ESX.Math.Round(coords.x, 1),
			y = ESX.Math.Round(coords.y, 1),
			z = ESX.Math.Round(coords.z, 1)
		}
		
		ESX.SetPlayerData('lastPosition', formattedCoords)
		TriggerServerEvent('esx:updateLastPosition', formattedCoords)
		RespawnPed(playerPed, formattedCoords, 0.0)

		StopScreenEffect('DeathFailOut')
		SetTimecycleModifier('')

		DoScreenFadeIn(800)

		StartScreenEffect('MenuMGIn', 1, false)
		Wait(3000)
		DoScreenFadeOut(800)
		Wait(1000)
		DoScreenFadeIn(800)
		StopScreenEffect('MenuMGIn')
end)
end)