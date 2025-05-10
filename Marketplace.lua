local _f = require(script.Parent)
local serverstorage = game:GetService("ServerStorage"):WaitForChild("src")
local assets = require(serverstorage:WaitForChild("Assets"))
local marketplaceService = game:GetService('MarketplaceService')
local players = game:GetService('Players')
local Network = _f.Network
local purchaseHistory = {}

local productNames = {
	[assets.productId["Random-Shiny"]] = "**Random Shiny** for **50** Robux",
	[assets.productId["Bidoof-Rainbow"]] = "**Rainbow Bidoof** for **100** Robux",
	[assets.productId["Random-6x31"]] = "**Random 6x31** for **150** Robux",
	[assets.productId["Mew-Rainbow"]] = "**Rainbow Mew** for **200** Robux",
	[assets.productId["Random-Shiny-6x31"]] = "**Random Shiny 6x31** for **399** Robux",	
	[assets.productId["Mewtwo-Shadow"]] = "**Shadow Mewtwo** for **500** Robux",		
	[assets.productId.Starter] = "**Starter** for **15** Robux",
	[assets.productId.TenBP] = "**TenBP** for **10** Robux",
	[assets.productId.FiftyBP] = "**FiftyBP** for **20** Robux",
	[assets.productId.TwoHundredBP] = "**TwoHundredBP** for **75** Robux",
	[assets.productId.TwoThousandBP] = "**TwoThousandBP** for **200** Robux",
	[assets.productId.UMV1] = "**UMV1** for **5** Robux",
	[assets.productId.UMV3] = "**UMV3** for **10** Robux",
	[assets.productId.UMV6] = "**UMV6** for **15** Robux",
	[assets.productId._10kP] = "**_10kp** for **10** Robux",
	[assets.productId._50kP] = "**_50kP** for **40** Robux",
	[assets.productId._100kP] = "**_100kP** for **75** Robux",
	[assets.productId._200kP] = "**_200kP** for **120** Robux",
	[assets.productId.PBSpins1] = "**PBSpins1** for **5** Robux",
	[assets.productId.PBSpins5] = "**PBSpins5** for **20** Robux",
	[assets.productId.PBSpins10] = "**PBSpins10** for **30** Robux",
	[assets.productId.AshGreninja] = "**AshGreninja** for **100** Robux",
	[assets.productId.Hoverboard] = "**Hoverboard** for **10** Robux",
	[assets.productId.MasterBall] = "**MasterBall** for **10** Robux",
	[assets.productId.LottoTicket] = "**LottoTicket** for **30** Robux",
	[assets.productId.TixPurchase] = "**TixPurchase** for **125** Robux",
	[assets.productId.RouletteSpinBasic] = "**RouletteSpinBasic** for **10** Robux",
	[assets.productId.RouletteSpinBronze] = "**RouletteSpinBronze** for **25** Robux",
	[assets.productId.RouletteSpinSilver] = "**RouletteSpinSilver** for **50** Robux",
	[assets.productId.RouletteSpinGold] = "**RouletteSpinGold** for **100** Robux",
	[assets.productId.RouletteSpinDiamond] = "**RouletteSpinDiamond** for **150** Robux",
	[1151933123] = "**RoPowerXP1** for **15** Robux",
	[1151121193] = "**RoPowerXP2** for **20** Robux",
	[1152925085] = "**RoPowerHatching1** for **15** Robux",
	[1151711078] = "**RoPowerHatching2** for **20** Robux",
	[1150605201] = "**RoPowerPokedollars1** for **20** Robux",
	[1151165104] = "**RoPowerPokedollars2** for **35** Robux",
	[1151765125] = "**RoPowerEvs1** for **15** Robux",
	[1152859073] = "**RoPowerEvs2** for **20** Robux",
	[1152331195] = "**RoPowerShinyBoost** for **10** Robux",
	[1149961352] = "**RoPowerLegendaryBoost** for **20** Robux"

}



marketplaceService.ProcessReceipt = function(receiptInfo)
	local purchaseId = receiptInfo.PlayerId .. '_' .. receiptInfo.PurchaseId
	if purchaseHistory[purchaseId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	for _, p in pairs(players:GetPlayers()) do
		if p.UserId == receiptInfo.PlayerId and _f.PlayerDataService[p] then
			_f.PlayerDataService[p]:onDevProductPurchased(receiptInfo.ProductId)
			purchaseHistory[purchaseId] = true
			local productName = productNames[receiptInfo.ProductId] or "Unknown Product"
			_f.Logger:logPurchase(p, { Name = productName })
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end


marketplaceService.PromptPurchaseFinished:connect(function(player, assetId, isPurchased)
	if isPurchased then
		_f.PlayerDataService[player]:onAssetPurchased(assetId)
	end
	--	Network:post('PromptPurchaseFinished', player, assetId, isPurchased)
end)

return 0