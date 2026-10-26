-- [NW Hub] Scripts are currently disabled.
warn("[NW Hub] Free scripts on GitHub are currently disabled.")
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "NW Hub",
        Text = "Scripts are currently disabled.",
        Duration = 8
    })
end)
return
