local placeId = game.PlaceId
local setclipboard = setclipboard or toclipboard -- Executor desteğine göre kopyalama komutu

if setclipboard then
    setclipboard(tostring(placeId))
    
    -- Ekrana bildirim gönderir (MacLib tarzı veya Roblox sistemi)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ID Kopyalandı!",
        Text = "Game ID: " .. tostring(placeId) .. " panoya eklendi.",
        Duration = 5
    })
    print("Kopyalanan ID: " .. placeId)
else
    print("Executor'ın kopyalama özelliğini desteklemiyor! ID: " .. placeId)
end
