--[[
	


--]]

local ZERO = Vector3.new(0, 0, 0)
local UNIT_X = Vector3.new(1, 0, 0)
local UNIT_Y = Vector3.new(0, 1, 0)
local UNIT_Z = Vector3.new(0, 0, 1)
local VEC_XY = Vector3.new(1, 0, 1)

local IDENTITYCF = CFrame.new()

local JUMPMODIFIER = 1.2
local TRANSITION = 0.15
local WALKF = 200 / 3

local UIS = game:GetService("UserInputService")
local RUNSERVICE = game:GetService("RunService")

local InitObjects = require(script:WaitForChild("InitObjects"))
local CameraModifier = require(script:WaitForChild("CameraModifier"))
local AnimationHandler = require(script:WaitForChild("AnimationHandler"))
local StateTracker = require(script:WaitForChild("StateTracker"))

-- Class

local GravityController = {}
GravityController.__index = GravityController

-- Private Functions

local function getRotationBetween(u, v, axis)
	local dot, uxv = u:Dot(v), u:Cross(v)
	if (dot < -0.99999) then return CFrame.fromAxisAngle(axis, math.pi) end
	return CFrame.new(0, 0, 0, uxv.x, uxv.y, uxv.z, 1 + dot)
end

local function lookAt(pos, forward, up)
	local r = forward:Cross(up)
	local u = r:Cross(forward)
	return CFrame.fromMatrix(pos, r.Unit, u.Unit)
end

local function getMass(array)
	local mass = 0
	for _, part in next, array do
		if (part:IsA("BasePart")) then
			mass = mass + part:GetMass()
		end
	end
	return mass
end

local function getPointVelocity(part, point)
	local pcf = part.CFrame
	local lp = pcf:PointToObjectSpace(point)
	local angularVelocity = pcf:VectorToObjectSpace(part.RotVelocity)
	local cross = angularVelocity:Cross(lp)
	return part.Velocity + pcf:VectorToWorldSpace(cross)
end

-- Public Constructor

function GravityController.new(player)
	local self = setmetatable({}, GravityController)

	-- Camera
	local loaded = player.PlayerScripts:WaitForChild("PlayerScriptsLoader"):WaitForChild("Loaded")
	if (not loaded.Value) then
		loaded.Changed:Wait()
	end

	local playerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))
	self.Controls = playerModule:GetControls()
	self.Camera = playerModule:GetCameras()

	self.CameraModifier = CameraModifier.new(player)

	-- Player and character
	self.Player = player
	self.Character = player.Character
	self.Humanoid = player.Character:WaitForChild("Humanoid")
	self.HRP = player.Character:WaitForChild("HumanoidRootPart")

	-- Animation
	self.AnimationHandler = AnimationHandler.new(self.Humanoid, self.Character:WaitForChild("Animate"))
	self.AnimationHandler:EnableDefault(false)

	local soundState = player.PlayerScripts:WaitForChild("RbxCharacterSounds"):WaitForChild("SetState")

	self.StateTracker = StateTracker.new(self.Humanoid, soundState)
	self.StateTracker.Changed:Connect(function(name, speed)
		self.AnimationHandler:Run(name, speed)
	end)

	-- Collider and forces
	local collider, gyro, vForce, floor = InitObjects(self)

	floor.Touched:Connect(function() end)

	self.Collider = collider
	self.VForce = vForce
	self.Gyro = gyro
	self.Floor = floor

	-- Gravity properties
	self.GravityUp = UNIT_Y
	self.FloorVelocity = ZERO
	self.Ignores = {self.Character}

	function self.Camera.GetUpVector(this, oldUpVector)
		return self.GravityUp
	end

	-- Events etc
	self.Humanoid.PlatformStand = true

	self.CharacterMass = getMass(self.Character:GetDescendants())
	self.Character.AncestryChanged:Connect(function() self.CharacterMass = getMass(self.Character:GetDescendants()) end)

	self.JumpCon = UIS.JumpRequest:Connect(function() self:OnJumpRequest() end)
	self.DeathCon = self.Humanoid.Died:Connect(function() self:Remove() end)
	self.SeatCon = self.Humanoid.Seated:Connect(function(active) if (active) then self:Remove() end end)
	RUNSERVICE:BindToRenderStep("GravityStep", Enum.RenderPriority.Input.Value + 1, function(dt) self:OnGravityStep(dt) end)

	return self
end

-- Public Methods

function GravityController:Remove()
	self.JumpCon:Disconnect()
	self.DeathCon:Disconnect()
	self.SeatCon:Disconnect()

	RUNSERVICE:UnbindFromRenderStep("GravityStep")

	self.CameraModifier:Remove()
	self.Collider:Remove()
	self.VForce:Remove()
	self.Gyro:Remove()
	self.StateTracker:Remove()

	self.Humanoid.PlatformStand = false
	self.AnimationHandler:EnableDefault(true)

	self.GravityUp = UNIT_Y
end

function GravityController:GetGravityUp(oldGravity)
	return oldGravity
end

function GravityController:IsGrounded()
	local parts = self.Floor:GetTouchingParts()
	for _, part in next, parts do
		if (not part:IsDescendantOf(self.Character)) then
			return true
		end
	end
	return false
end

function GravityController:OnJumpRequest()
	if (not self.StateTracker.Jumped and self:IsGrounded()) then
		local hrpVel = self.HRP.Velocity
		self.HRP.Velocity = hrpVel + self.GravityUp*self.Humanoid.JumpPower*JUMPMODIFIER
		self.StateTracker.Jumped = true
	end
end

function GravityController:GetFloorVelocity()
	local ray = Ray.new(self.Collider.Position, -1.1*self.GravityUp)
	local hit, pos, normal = workspace:FindPartOnRayWithIgnoreList(ray, self.Ignores)

	local velocity = ZERO
	if (hit and hit:isA("BasePart")) then
		-- assumes the center of mass of the part is part.CFrame.p
		velocity = getPointVelocity(hit, self.HRP.Position)
	end

	return velocity
end

function GravityController:OnGravityStep(dt)
	-- update gravity up vector
	local oldGravity = self.GravityUp
	local newGravity = self:GetGravityUp(oldGravity)

	local rotation = getRotationBetween(oldGravity, newGravity, workspace.CurrentCamera.CFrame.RightVector)
	rotation = IDENTITYCF:Lerp(rotation, TRANSITION)

	self.GravityUp = rotation * oldGravity

	-- get world move vector
	local camCF = workspace.CurrentCamera.CFrame
	local fDot = camCF.LookVector:Dot(newGravity)
	local cForward = math.abs(fDot) > 0.5 and -math.sign(fDot)*camCF.UpVector or camCF.LookVector

	local left = cForward:Cross(-newGravity).Unit
	local forward = -left:Cross(newGravity).Unit

	local move = self.Controls:GetMoveVector()
	local worldMove = forward*move.z - left*move.x
	worldMove = worldMove:Dot(worldMove) > 1 and worldMove.Unit or worldMove

	local isInputMoving = worldMove:Dot(worldMove) > 0

	-- get the desired character cframe
	local hrpCFLook = self.HRP.CFrame.LookVector
	local charF = hrpCFLook:Dot(forward)*forward + hrpCFLook:Dot(left)*left
	local charR = charF:Cross(newGravity).Unit
	local newCharCF = CFrame.fromMatrix(ZERO, charR, newGravity, -charF)

	local newCharRotation = IDENTITYCF
	if (isInputMoving) then
		newCharRotation = IDENTITYCF:Lerp(getRotationBetween(charF, worldMove, newGravity), 0.7)	
	end

	-- calculate forces
	local g = workspace.Gravity
	local gForce = g * self.CharacterMass * (UNIT_Y - newGravity)

	local cVelocity = self.HRP.Velocity
	local tVelocity = self.Humanoid.WalkSpeed * worldMove
	local gVelocity = cVelocity:Dot(newGravity)*newGravity
	local hVelocity = cVelocity - gVelocity
	local fVelocity = self:GetFloorVelocity()

	if (hVelocity:Dot(hVelocity) < 1) then
		hVelocity = ZERO
	end

	local dVelocity = tVelocity - hVelocity + fVelocity
	local walkForceM = math.min(10000, WALKF * self.CharacterMass * dVelocity.Magnitude)
	local walkForce = walkForceM > 0 and dVelocity.Unit*walkForceM or ZERO

	-- mouse lock
	local charRotation = newCharRotation * newCharCF
	if (self.CameraModifier.IsCamLocked) then
		local lv = workspace.CurrentCamera.CFrame.LookVector
		local hlv = lv - charRotation.UpVector:Dot(lv)*charRotation.UpVector
		charRotation = lookAt(ZERO, hlv, charRotation.UpVector)
	end

	-- get state
	self.StateTracker:OnStep(self.GravityUp, self:IsGrounded(), isInputMoving)

	-- update values
	self.VForce.Force = walkForce + gForce
	self.Gyro.CFrame = charRotation
end


return GravityController
