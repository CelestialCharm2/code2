local PLUGIN_NAME = "GitHub Script Sync"
local GITHUB_API_URL = "https://api.github.com/repos/%s/%s/contents/%s"
local RAW_GITHUB_URL = "https://raw.githubusercontent.com/%s/%s/%s/%s"

local plugin = plugin
if not plugin then error("Must run as a plugin.") end
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Input dialog helper
local function inputDialog(title, description, defaultValue)
	local dialog = Instance.new("ScreenGui")
	dialog.Name = "InputDialog"
	dialog.Parent = game:GetService("CoreGui")

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0.4, 0, 0.3, 0)
	frame.Position = UDim2.new(0.3, 0, 0.35, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	frame.BorderSizePixel = 1
	frame.Parent = dialog

	local titleLabel = Instance.new("TextLabel", frame)
	titleLabel.Size = UDim2.new(1, 0, 0.2, 0)
	titleLabel.Text = title
	titleLabel.Font = Enum.Font.SourceSans
	titleLabel.TextScaled = true
	titleLabel.BackgroundTransparency = 1

	local descriptionLabel = Instance.new("TextLabel", frame)
	descriptionLabel.Size = UDim2.new(1, 0, 0.3, 0)
	descriptionLabel.Position = UDim2.new(0, 0, 0.2, 0)
	descriptionLabel.Text = description
	descriptionLabel.Font = Enum.Font.SourceSans
	descriptionLabel.TextWrapped = true
	descriptionLabel.TextScaled = true
	descriptionLabel.BackgroundTransparency = 1

	local textBox = Instance.new("TextBox", frame)
	textBox.Size = UDim2.new(0.8, 0, 0.2, 0)
	textBox.Position = UDim2.new(0.1, 0, 0.55, 0)
	textBox.Text = defaultValue
	textBox.Font = Enum.Font.SourceSans
	textBox.TextScaled = true
	textBox.ClearTextOnFocus = false

	local confirmButton = Instance.new("TextButton", frame)
	confirmButton.Size = UDim2.new(0.4, 0, 0.15, 0)
	confirmButton.Position = UDim2.new(0.05, 0, 0.82, 0)
	confirmButton.Text = "Confirm"
	confirmButton.BackgroundColor3 = Color3.fromRGB(140, 230, 150)

	local cancelButton = Instance.new("TextButton", frame)
	cancelButton.Size = UDim2.new(0.4, 0, 0.15, 0)
	cancelButton.Position = UDim2.new(0.55, 0, 0.82, 0)
	cancelButton.Text = "Cancel"
	cancelButton.BackgroundColor3 = Color3.fromRGB(240, 150, 150)

	local result = nil
	confirmButton.MouseButton1Click:Connect(function()
		result = textBox.Text
		dialog:Destroy()
	end)
	cancelButton.MouseButton1Click:Connect(function()
		dialog:Destroy()
	end)

	while dialog.Parent do RunService.Heartbeat:Wait() end
	return result
end

local function httpRequest(url, method, headers, body)
	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = method,
			Headers = headers,
			Body = body,
		})
	end)
	return success, response
end

local function base64Encode(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	return ((data:gsub('.', function(x)
		local r, bval = '', x:byte()
		for i = 8, 1, -1 do r = r .. (bval % 2^i - bval % 2^(i-1) > 0 and '1' or '0') end
		return r
	end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if #x < 6 then return '' end
		local c = 0
		for i = 1, 6 do c = c + (x:sub(i,i) == '1' and 2^(6-i) or 0) end
		return b:sub(c+1, c+1)
	end) .. ({ '', '==', '=' })[#data%3+1])
end

local function uploadScriptToGitHub(user, repo, token, branch, script, path)
	local url = string.format(GITHUB_API_URL, user, repo, path)
	local getSuccess, getResponse = httpRequest(url, "GET", {
		["Authorization"] = "token " .. token,
		["Accept"] = "application/vnd.github+json",
	}, nil)

	local exists = getSuccess and getResponse.StatusCode == 200
	local sha = exists and HttpService:JSONDecode(getResponse.Body).sha or nil

	local body = HttpService:JSONEncode({
		message = "Auto-sync from Roblox Studio",
		content = base64Encode(script.Source),
		branch = branch,
		sha = sha
	})

	local headers = {
		["Authorization"] = "token " .. token,
		["Content-Type"] = "application/json",
		["Accept"] = "application/vnd.github+json",
	}

	local uploadSuccess, uploadResponse = httpRequest(url, "PUT", headers, body)
	if uploadSuccess and (uploadResponse.StatusCode == 200 or uploadResponse.StatusCode == 201) then
		return true
	else
		warn("Upload failed: " .. (uploadResponse and uploadResponse.Body or "unknown"))
		return false
	end
end

local function replaceScriptWithLoader(user, repo, branch, script, path)
	local rawUrl = string.format(RAW_GITHUB_URL, user, repo, branch, path)
	local loader = ([[
local HttpService = game:GetService("HttpService")
local url = "%s"
local success, content = pcall(function()
    return HttpService:GetAsync(url)
end)
if success then
    local func = loadstring(content)
    if func then func() end
else
    warn("Failed to load script from GitHub: " .. url)
end
]]):format(rawUrl)
	script.Source = loader
end

local toolbar = plugin:CreateToolbar(PLUGIN_NAME)
local syncButton = toolbar:CreateButton("Sync All Scripts", "Upload & Replace All Scripts from Services", "")

syncButton.Click:Connect(function()
	local user = inputDialog("GitHub Username", "Enter your GitHub username", "")
	local repo = inputDialog("GitHub Repo", "Enter the repository name", "")
	local token = inputDialog("GitHub Token", "Paste your personal access token", "")
	local branch = inputDialog("GitHub Branch", "Enter the branch (default: main)", "main")

	if not user or not repo or not token then
		warn("Missing input.")
		return
	end

	local servicesToScan = {
		game:GetService("Workspace"),
		game:GetService("ReplicatedStorage"),
		game:GetService("ServerStorage"),
		game:GetService("ServerScriptService"),
		game:GetService("ReplicatedFirst"),
		game:GetService("StarterGui"),
		game:GetService("StarterPack"),
		game:GetService("Lighting")
	}

	local scriptFiles = {}
	for _, service in ipairs(servicesToScan) do
		for _, obj in ipairs(service:GetDescendants()) do
			if obj:IsA("LuaSourceContainer") and obj.Name ~= "interact" then
				table.insert(scriptFiles, obj)
			end
		end
	end

	if #scriptFiles == 0 then
		warn("No scripts found in the selected services.")
		return
	end

	local scriptNameCount = {}
	for _, script in ipairs(scriptFiles) do
		local originalName = script.Name
		local newName = originalName
		local count = scriptNameCount[originalName] or 0

		if count > 0 then
			newName = originalName .. " (" .. count .. ")"
		end
		scriptNameCount[originalName] = count + 1

		local path = newName .. ".lua" -- ensure .lua extension

		local uploaded = uploadScriptToGitHub(user, repo, token, branch, script, path)
		if uploaded then
			replaceScriptWithLoader(user, repo, branch, script, path)
			print("Synced and replaced: " .. script.Name)
		else
			warn("Failed to upload script: " .. script.Name)
		end
	end
end)
