local gui = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/z4gs/scripts/master/testtttt.lua"))():AddWindow("Ro-Ghoul", {
	main_color = Color3.fromRGB(0,0,0),
	min_size = Vector2.new(373, 400),
	can_resize = false
})

local get = setmetatable({}, {
	__index = function(a, b)
		return game:GetService(b) or game[b]
	end
})

local tab1, tab2, tab3, tab4 = gui:AddTab("Main"), gui:AddTab("Farm Options"), gui:AddTab("Trainer"), gui:AddTab("Misc")
local btn, btn2, btn3, key, nmc, trainers, labels
local findobj, findobjofclass, waitforobj, fire, invoke = get.FindFirstChild, get.FindFirstChildOfClass, get.WaitForChild, Instance.new("RemoteEvent").FireServer, Instance.new("RemoteFunction").InvokeServer
local player = get.Players.LocalPlayer

repeat wait() until player:FindFirstChild("PlayerFolder")

local team, remotes, stat = player.PlayerFolder.Customization.Team.Value, get.ReplicatedStorage.Remotes, player.PlayerFolder.StatsFunction
local oldtick, farmtick = 0, 0
local camera = workspace.CurrentCamera
local myData = loadstring(game:HttpGet("https://raw.githubusercontent.com/z4gs/scripts/master/Settings.lua"))()("Ro-Ghoul Autofarm", {
	Skills = {
		E = false,
		F = false,
		C = false,
		R = false
	},
	Boss = {
		["Kishou Arima"] = false,
		["Gyakusatsu"] = false,
		["Eto Yoshimura"] = false,
		["Young Eto Yoshimura"] = false,
		["Koutarou Amon"] = false,
		["Nishiki Nishio"] = false
	},
	DistanceFromNpc = 5,
	DistanceFromBoss = 8,
	TeleportSpeed = 300,
	ReputationFarm = false,
	ReputationCashout = false,
	AutoKickWhitelist = ""
})

local array = {
	boss = {
		["Kishou Arima"] = 1250,
		["Gyakusatsu"] = 1250,
		["Eto Yoshimura"] = 1250,
		["Young Eto Yoshimura"] = 750,
		["Koutarou Amon"] = 750,
		["Nishiki Nishio"] = 250
	},

	npcs = {["Aogiri Members"] = "GhoulSpawns", Investigators = "CCGSpawns", Humans = "HumanSpawns"},

	stages = {"One", "Two", "Three", "Four", "Five", "Six"},

	skills = {
		E = player.PlayerFolder.Special1CD,
		F = player.PlayerFolder.Special3CD,
		C = player.PlayerFolder.SpecialBonusCD,
		R = player.PlayerFolder.Special2CD
	}
}

tab1:AddLabel("Target")

local drop = tab1:AddDropdown("Select", function(opt)
	array.targ = array.npcs[opt]
end)

btn = tab1:AddButton("Start", function()
	if not array.autofarm then
		if key then
			btn.Text, array.autofarm = "Stop", true
			local farmtick = tick()
			while array.autofarm do
				labels("tfarm", "Time elapsed: "..os.date("!%H:%M:%S", tick() - farmtick))
				wait(1)
			end
		else
			player:Kick("Failed to get the Remote key, please try to execute the script again")
		end
	else
		btn.Text, array.autofarm, array.died = "Start", false, false
	end
end)

local function format(number)
	local i, k, j = tostring(number):match("(%-?%d?)(%d*)(%.?.*)")
	return i..k:reverse():gsub("(%d%d%d)", "%1,"):reverse()..j
end

labels = setmetatable({
	text = {label = tab1:AddLabel("")},
	tfarm = {label = tab1:AddLabel("")},
	space = {label = tab1:AddLabel("")},
	Quest = {prefix = "Quest - ", label = tab1:AddLabel("Unknow")},
	Yen = {prefix = "Yen: ", label = tab1:AddLabel("Yen: 0"), value = 0, oldval = player.PlayerFolder.Stats.Yen.Value},
	RC = {prefix = "RC: ", label = tab1:AddLabel("RC: 0"), value = 0, oldval = player.PlayerFolder.Stats.RC.Value},
	Kills = {prefix = "Kills: ", label = tab1:AddLabel("Kills: 0"), value = 0} 
}, {
	__call = function (self, typ, newv, oldv)
		if typ and newv then
			local object = self[typ]
			if type(newv) == "number" then
				object.value = object.value + newv
				object.label.Text = object.prefix..format(object.value)
				if oldv then
					object.oldval = oldv
				end
			elseif object.prefix then
				object.label.Text = object.prefix..newv
			else
				object.label.Text = newv
			end
			return
		end
		for i,v in pairs(labels) do
			v.value = 0
			v.label.Text = v.prefix.."0"
		end
	end
})

local function getLabel(la)
	return labels[la].value and labels[la].value or labels[la].label.Text
end

btn3 = tab1:AddButton("Reset", function() labels() end)

if team == "CCG" then tab2:AddLabel("Quinque Stage") else tab2:AddLabel("Kagune Stage") end

local drop2 = tab2:AddDropdown("[ 1 ]", function(opt)
	array.stage = array.stages[tonumber(opt)]
end)

array.stage = "One"

tab2:AddSwitch("Reputation Farm", function(bool) 
	myData.ReputationFarm = bool
end):Set(myData.ReputationFarm)

tab2:AddSwitch("Auto Reputation Cashout", function(bool)
	myData.ReputationCashout = bool
end):Set(myData.ReputationCashout)

for i,v in pairs(array.boss) do
	tab2:AddSwitch(i.." Boss Farm ".."(".."lvl "..v.."+)", function(bool)
		myData.Boss[i] = bool
	end):Set(myData.Boss[i])
end

tab2:AddSlider("TP Speed", function(x)
	myData.TeleportSpeed = x
end, {min = 90, max = 250}):Set(45)

tab2:AddSlider("Distance from NPC", function(x)
	myData.DistanceFromNpc = x * -1
end, {min = 0, max = 8}):Set(65)

tab2:AddSlider("Distance from Bosses", function(x)
	myData.DistanceFromBoss = x * -1
end, {min = 0, max = 15}):Set(55)

labels.p = {label = tab3:AddLabel("Current trainer: "..player.PlayerFolder.Trainers[team.."Trainer"].Value)}

local progress = tab3:AddSlider("Progress", nil, {min = 0, max = 100, readonly = true})

progress:Set(player.PlayerFolder.Trainers[player.PlayerFolder.Trainers[team.."Trainer"].Value].Progress.Value)

player.PlayerFolder.Trainers[team.."Trainer"].Changed:connect(function()
	labels("p", "Current trainer: "..player.PlayerFolder.Trainers[team.."Trainer"].Value)
	progress:Set(player.PlayerFolder.Trainers[player.PlayerFolder.Trainers[team.."Trainer"].Value].Progress.Value)
end)

btn2 = tab3:AddButton("Start", function()
	if not array.trainer then
		array.trainer, btn2.Text = true, "Stop"
		local connection, time

		while array.trainer do
			if connection and connection.Connected then
				connection:Disconnect()
			end

			local tkey, result

			connection = player.Backpack.DescendantAdded:Connect(function(obj)
				if tostring(obj) == "TSCodeVal" and obj:IsA("StringValue") then
					tkey = obj.Value
				end
			end)

			result = invoke(remotes.Trainers.RequestTraining)

			if result == "TRAINING" then
				for i,v in pairs(workspace.TrainingSessions:GetChildren()) do
					if waitforobj(v, "Player").Value == player then
						fire(waitforobj(v, "Comm"), "Finished", tkey, false)
						break
					end
				end
			elseif result == "TRAINING COMPLETE" then
				labels("time", "Switching to other trainer...")
				for i,v in pairs(player.PlayerFolder.Trainers:GetDescendants()) do
					if table.find(trainers, v.Name) and findobj(v, "Progress") and tonumber(v.Progress.Value) < 100 and tonumber(player.PlayerFolder.Trainers[player.PlayerFolder.Trainers[team.."Trainer"].Value].Progress.Value) == 100 then
						invoke(remotes.Trainers.ChangeTrainer, v.Name)
						wait(1.5)
					end
				end
			else
				labels("time", "Time until the next training: "..result)
			end
			wait(1)
		end
		labels("time", "")
	else
		array.trainer, btn2.Text = false, "Start"
	end
end)

labels.time = {label = tab3:AddLabel("")}

tab4:AddSwitch("Auto add kagune/quinque stats", function(bool) array.weapon = bool end)
tab4:AddSwitch("Auto add durability stats", function(bool) array.dura = bool end)
tab4:AddSwitch("Auto kick", function(bool) array.kick = bool end)
tab4:AddLabel("Auto kick whitelist (type 1 name per line)")

local console = tab4:AddConsole({
	["y"] = 50,
	["source"] = "Text",
})

console:Set(myData.AutoKickWhitelist)

console:OnChange(function(newtext)
	myData.AutoKickWhitelist = newtext
end)

for i,v in pairs(array.skills) do
	tab4:AddSwitch("Auto use "..i.." skill (on bosses)", function(bool)
		myData.Skills[i] = bool
	end):Set(myData.Skills[i])
end

do
	local count = 0
	for i,v in pairs(player.PlayerGui.HUD.StagesFrame.InfoScroll:GetChildren()) do
		if v.ClassName == "Frame" and v.Name ~= "Example" then
			count = count + 1
			drop2:Add(count)
		end
	end
end

for i,v in pairs(array.npcs) do drop:Add(i) end

tab1:Show()
local WaitingForCharacter = false
local function tp(pos)
	if array.died then
		player.Character.HumanoidRootPart.CFrame = pos
		array.died = false
		return
	end

	local val = Instance.new("CFrameValue")
	val.Value = player.Character.HumanoidRootPart.CFrame

	local tween = game:GetService("TweenService"):Create(
		val, 
		TweenInfo.new((player.Character.HumanoidRootPart.Position - pos.p).magnitude / myData.TeleportSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), 
		{Value = pos}
	)

	tween:Play()

	local completed
	tween.Completed:Connect(function()
		completed = true
	end)

	while not completed and not WaitingForCharacter do
		if array.found or not array.autofarm or player.Character.Humanoid.Health <= 0 then tween:Cancel() break end
		player.Character.HumanoidRootPart.CFrame = val.Value
		task.wait()
	end

	val:Destroy()
end

local function getNPC()
	local nearestnpc, nearest = nil, math.huge

	if myData.Boss.Gyakusatsu and tonumber(player.PlayerFolder.Stats.Level.Value) > array.boss["Gyakusatsu"] and findobj(workspace.NPCSpawns["GyakusatsuSpawn"], "Gyakusatsu") then
		local lowesthealth, lowestNpcModel = math.huge, nil

		for i,v in pairs(workspace.NPCSpawns["GyakusatsuSpawn"]:GetChildren()) do
			if v.Name ~= "Mob" and findobj(v, "Humanoid") and v.Humanoid.Health < lowesthealth then
				lowesthealth = v.Humanoid.Health
				lowestNpcModel = v
			end
		end

		if not lowestNpcModel then
			return workspace.NPCSpawns.GyakusatsuSpawn.Gyakusatsu
		end

		return lowestNpcModel
	end

	for i,v in pairs(workspace.NPCSpawns:GetChildren()) do
		local npc = findobjofclass(v, "Model")

		if npc and findobj(npc, "Head") and not findobj(npc, "AC") then
			if npc.Parent.Name == array.targ then
				local magnitude = (npc.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).magnitude

				if magnitude < nearest then
					nearestnpc, nearest = npc, magnitude
				end
			elseif myData.Boss[npc.Name] and tonumber(player.PlayerFolder.Stats.Level.Value) >= array.boss[npc.Name] then
				return npc
			end
		end
	end
	return nearestnpc
end

local function getQuest(typ)
	labels("text", "Moving to quest NPC")

	local npc = team == "Ghoul" and workspace.Anteiku.Yoshimura or workspace.CCGBuilding.Yoshitoki

	tp(npc.HumanoidRootPart.CFrame)
	invoke(game:GetService("ReplicatedStorage").Remotes.Ally.AllyInfo)
	wait()
	fireclickdetector(npc.TaskIndicator.ClickDetector)

	if array.autofarm and not array.died and (npc.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude <= 20 then
		if typ then 
			labels("text", "Getting quest...")
			invoke(remotes[npc.Name].Task)
			invoke(remotes[npc.Name].Task)
			local quest = waitforobj(player.PlayerFolder.CurrentQuest.Complete, "Aogiri Member")
			labels("Quest", ("%c/%c"):format("0", quest:WaitForChild("Max").Value))
			quest.Changed:Connect(function(change) 
				labels("Quest", ("%c/%c"):format(change, quest.Max.Value)) 
			end)
		else
			labels("text", "Withdrawing reputation")
			invoke(remotes.ReputationCashOut)
			oldtick = tick()
		end
	end
end

local function collect(npc)
	local timer = tick()
	local model = waitforobj(npc, npc.Name.." Corpse", 2)
	local clickpart = waitforobj(model, "ClickPart", 2)

	player.Character.HumanoidRootPart.CFrame = clickpart.CFrame * CFrame.new(0,1.7,0)

	waitforobj(clickpart, "")
	repeat
		if tick() - timer > 4 then
			break
		end
		player.Character.Humanoid:MoveTo(clickpart.Position)
		wait()
		fireclickdetector(clickpart[""], 1)
	until not model.Parent.Parent or not findobj(model, "ClickPart") or not array.autofarm or player.Character.Humanoid.Health <= 0
end

local function pressKey(topress)
	fire(player.Character.Remotes.KeyEvent, key, topress, "Down", player:GetMouse().Hit, nil, workspace.Camera.CFrame)
end

player.PlayerFolder.Stats.RC.Changed:Connect(function(value)
	if array.autofarm then
		labels("RC", value - labels.RC.oldval, value)
	end
end)

player.PlayerFolder.Stats.Yen.Changed:Connect(function(value)
	if array.autofarm then
		labels("Yen", value - labels.Yen.oldval, value)
	end
end)

getconnections(player.Idled)[1]:Disable()

get.Players.PlayerAdded:Connect(function(plr)
	if array.kick then
		local splittedarray = console:Get():split("\n")

		if not table.find(splittedarray, plr.Name) then
			player:Kick("Player joined, name: "..plr.Name) 
		end
	end
end)

player.PlayerFolder.Trainers[player.PlayerFolder.Trainers[team.."Trainer"].Value].Progress.Changed:Connect(function(c)
	progress:Set(tonumber(c))
end)

coroutine.wrap(function()
	while wait() do
		if tonumber(player.PlayerFolder.Stats.Focus.Value) > 0 then
			if array.weapon then
				invoke(stat, "Focus", "WeaponAddButton", 1)
			end
			if array.dura then
				invoke(stat, "Focus", "DurabilityAddButton", 1)
			end
		end
	end
end)()

-- remote Key grabber + grab updated trainers table
do
	fireclickdetector(workspace.TrainerModel.ClickIndicator.ClickDetector)
	waitforobj(waitforobj(player.PlayerGui, "TrainersGui"), "TrainersGuiScript")
	player.PlayerGui.TrainersGui:Destroy()

	repeat 
		for i,v in pairs(getgc(true)) do
			if not key and type(v) == "function" and getinfo(v).source:find(".ClientControl") then
				for i2,v2 in pairs(getconstants(v)) do
					if v2 == "KeyEvent" then
						local keyfound = getconstant(v, i2 + 1)
						if #keyfound >= 100 then
							key = keyfound
							break
						end
					end
				end
			elseif type(v) == "table" and ((table.find(v, "(S1) Kureo Mado") and team == "CCG") or (table.find(v, "(S1) Ken Kaneki"))) then
				trainers = v
			end
		end
		wait()
	until key
end

local AttackingCooldown = false
local WaitingForCharacter = false
local GetquestCooldown = false
local IsTweened = false

game.Players.LocalPlayer.CharacterAdded:Connect(function()
	wait(8)
	WaitingForCharacter = false
end)
-- auto farm

local Enabled_Hop = false
local IsHoped = false
local MoveToVal = Instance.new("CFrameValue")

local RuntimeMoveProcessor = Instance.new("NumberValue")
RuntimeMoveProcessor.Changed:Connect(function()
	if not player.Character
		or not player.Character:FindFirstChildOfClass("Humanoid")
		or player.Character:FindFirstChildOfClass("Humanoid").Health < 0
		or not player.Character:FindFirstChild("HumanoidRootPart")
		or WaitingForCharacter
	then
		return
	end
	local Hum = player.Character:FindFirstChildOfClass("Humanoid")
	local Root = player.Character.HumanoidRootPart
	if Enabled_Hop then
		IsHoped = true
		local TargetMagnitude = (Root.Position - MoveToVal.Value.Position).Magnitude
		if TargetMagnitude > 10 then
			game:GetService("TweenService"):Create(Root,TweenInfo.new(TargetMagnitude / myData.TeleportSpeed,Enum.EasingStyle.Linear),{CFrame = CFrame.new(MoveToVal.Value.Position)}):Play()
		else
			Root.CFrame = MoveToVal.Value
		end
	elseif IsHoped then
		IsHoped = false
		game:GetService("TweenService"):Create(Root,TweenInfo.new(0),{CFrame = Root.CFrame + Vector3.new(0,1,0)}):Play()
	end
end)

local ReruntimeCooldown = false
local RemotesFolder:Instance = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")

local CurrentTarget = nil

game:GetService("RunService").Stepped:Connect(function()
	if not ReruntimeCooldown then
		ReruntimeCooldown = true
		task.delay(1,function()
			ReruntimeCooldown = false
		end)
		RuntimeMoveProcessor.Value = 0
		game:GetService("TweenService"):Create(RuntimeMoveProcessor,TweenInfo.new(3,Enum.EasingStyle.Linear),{Value = 10}):Play()
	end
	if not RemotesFolder then
		labels("text", "Waiting for remotes folder")
		return
	end
	local QuestViewerText = nil
	if player:FindFirstChild("PlayerFolder")
		and player.PlayerFolder:FindFirstChild("CurrentQuest")
		and player.PlayerFolder.CurrentQuest:FindFirstChild("Complete")
	then
		local asdfg,CurrentQuestInstance:Instance = pcall(function()
			return player.PlayerFolder.CurrentQuest.Complete:GetChildren()[1]
		end)
		if typeof(CurrentQuestInstance) == "Instance" and CurrentQuestInstance:IsA("ValueBase") then
			QuestViewerText = CurrentQuestInstance.Name..": "..tostring(CurrentQuestInstance.Value)
			if CurrentQuestInstance:FindFirstChild("Max") and CurrentQuestInstance:FindFirstChild("Max"):IsA("ValueBase") then
				QuestViewerText = QuestViewerText.." / "..tostring(CurrentQuestInstance:FindFirstChild("Max").Value)
			end
		end
	end
	if typeof(QuestViewerText) == "string" then
		labels("Quest", QuestViewerText)
	else
		labels("Quest", "None")
	end
	if array.autofarm then
		if not player.Character
			or not player.Character:FindFirstChildOfClass("Humanoid")
			or not player.Character:FindFirstChild("HumanoidRootPart")
		then
			labels("text", "Waiting for character")
			return
		end
		if player.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
			WaitingForCharacter = true
			labels("text", "Waiting for character respawn")
			RemotesFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
			return
		end
		
		local Request_QuestStage = ""
		if myData.ReputationFarm and (not findobj(player.PlayerFolder.CurrentQuest.Complete, "Aogiri Member") or player.PlayerFolder.CurrentQuest.Complete["Aogiri Member"].Value == player.PlayerFolder.CurrentQuest.Complete["Aogiri Member"].Max.Value) then
			Request_QuestStage = "Request"
		elseif myData.ReputationCashout and tick() - oldtick > 7200 then
			Request_QuestStage = "Reward"
		end
		if table.find({"Request","Reward"},Request_QuestStage) then
			local npc = team == "Ghoul" and workspace.Anteiku.Yoshimura or workspace.CCGBuilding.Yoshitoki
			MoveToVal.Value = npc.HumanoidRootPart.CFrame
			Enabled_Hop = true
			if (npc.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude <= 10 then
				if Request_QuestStage == "Request" then
					labels("text", "Getting quest...")
					if RemotesFolder:FindFirstChild(npc.Name) and RemotesFolder:FindFirstChild(npc.Name):FindFirstChild("Task") then
						RemotesFolder:FindFirstChild(npc.Name):FindFirstChild("Task"):InvokeServer()
					end
				elseif Request_QuestStage == "Reward" then
					labels("text", "Withdrawing reputation")
					invoke(remotes.ReputationCashOut)
					oldtick = tick()
				end
			end
		elseif not AttackingCooldown then
			if not CurrentTarget or typeof(CurrentTarget) ~= "Instance" or not CurrentTarget.Parent then
				CurrentTarget = getNPC()
			end
			if typeof(CurrentTarget) == "Instance"
				and CurrentTarget:FindFirstChildOfClass("Humanoid")
				and CurrentTarget:FindFirstChild("HumanoidRootPart")
			then
				AttackingCooldown = true
				if not findobj(player.Character, "Kagune") and not findobj(player.Character, "Quinque")  then
					pressKey(array.stage)
				end
				local TargetMagnitude = (player.Character.HumanoidRootPart.Position - CurrentTarget.HumanoidRootPart.Position).Magnitude
				if TargetMagnitude > 15 then
					labels("text", "Moving to: "..CurrentTarget.Name)
					MoveToVal.Value = CurrentTarget.HumanoidRootPart.CFrame
					Enabled_Hop = true
				else
					labels("text", "Attacking: "..CurrentTarget.Name)
					local TargetCFrame:CFrame = nil
					if myData.Boss[CurrentTarget.Name] or CurrentTarget.Parent.Name == "GyakusatsuSpawn" then 
						for x,y in pairs(myData.Skills) do
							if player.PlayerFolder.CanAct.Value and y and array.skills[x].Value ~= "DownTime" then
								pressKey(x)
							end
						end
						TargetCFrame = CFrame.new(CurrentTarget.HumanoidRootPart.Position + Vector3.new(0,-myData.DistanceFromBoss,0), CurrentTarget.HumanoidRootPart.Position)
					else
						TargetCFrame = CurrentTarget.HumanoidRootPart.CFrame + CurrentTarget.HumanoidRootPart.CFrame.lookVector * myData.DistanceFromNpc 
					end
					if typeof(TargetCFrame) == "CFrame" then
						MoveToVal.Value = TargetCFrame
						Enabled_Hop = true
					end
					if player.PlayerFolder.CanAct.Value then
						pressKey("Mouse1")
					end
					labels("Kills", 1)
					if CurrentTarget:FindFirstChild(CurrentTarget.Name.." Corpse")
						and CurrentTarget.Name ~= "Eto Yoshimura"
						and not findobj(CurrentTarget.Parent, "Gyakusatsu")
						and CurrentTarget.Name ~= "Gyakusatsu"
					then
						labels("text", "Collecting Corpse: "..CurrentTarget.Name)
						collect(CurrentTarget)
						wait(3)
					end
				end
				AttackingCooldown = false
			end
		end
	else
		labels("text", "")
		Enabled_Hop = false
	end
end)
