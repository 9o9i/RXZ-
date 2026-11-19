local function main()
local VERSION = "5.7.3"
local GUI_NAME = "RXZ_UI"
local AIM_BIND = "RXZ_Aim"
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local player = Players.LocalPlayer
if not player then return end
local playerGui = player:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild(GUI_NAME)
if oldGui then oldGui:Destroy() end
local oldTr = playerGui:FindFirstChild("RXZ_Tracers")
if oldTr then oldTr:Destroy() end
pcall(function() RunService:UnbindFromRenderStep(AIM_BIND) end)
local CONFIG = {
DhabTag = "Dhab",
NamePatterns = { dhab = { "ضب", "dhab", "lizard" } },
BigSize = 3000,
MaxDhabStuds = 50000,
TraderTag = "Trader", VehicleTag = "Vehicle",
TraderWords = { "تاجر", "trader", "merchant" },
VillageWords = { "قرية", "قريه", "village", "ديرة", "ديره", "town" },
CampWords = { "مخيم", "camp" },
RarityAttribute = "Rarity",
HideAttribute = "HideFromRadar",
NameAttribute = "DisplayName",
LogoImage = "",
SpeedMin = 8, SpeedMax = 100,
JumpMin = 20, JumpMax = 150,
RadarInterval = 0.02,
MaxRows = 6,
MaxMarkers = 600,
MaxTracers = 200,
MarkerMin = 4, MarkerMax = 30,
}
local THEME = {
Bg = Color3.fromRGB(5, 8, 20),
BgMid = Color3.fromRGB(8, 13, 32),
Panel = Color3.fromRGB(9, 14, 32),
Row = Color3.fromRGB(15, 22, 46),
RowSel = Color3.fromRGB(22, 36, 74),
Line = Color3.fromRGB(34, 50, 92),
Accent = Color3.fromRGB(60, 150, 245),
Cyan = Color3.fromRGB(60, 210, 250),
On = Color3.fromRGB(76, 200, 110),
Off = Color3.fromRGB(58, 66, 92),
Danger = Color3.fromRGB(190, 55, 65),
Text = Color3.new(1, 1, 1),
}
local FONT = Enum.Font.SourceSansBold
local EASE = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local RARITIES = {
rainbow = { label = "مستقل", color = Color3.fromRGB(255, 120, 200), keys = {} },
mythic = { label = "خرافي", color = Color3.fromRGB(235, 45, 55), keys = { "mythic", "myth", "خرافي" } },
legendary = { label = "أسطوري", color = Color3.fromRGB(255, 208, 40), keys = { "legendary", "legend", "أسطوري", "اسطوري" } },
epic = { label = "فاخر", color = Color3.fromRGB(170, 90, 255), keys = { "epic", "فاخر", "luxury", "premium" } },
rare = { label = "نادر", color = Color3.fromRGB(70, 150, 255), keys = { "rare", "نادر" } },
special = { label = "مميز", color = Color3.fromRGB(80, 220, 100), keys = { "special", "uncommon", "unique", "مميز" } },
}
local RARITY_ORDER = { "rainbow", "mythic", "legendary", "epic", "rare", "special" }
local RARITY_BY_NUMBER = { [2] = "special", [3] = "rare", [4] = "epic", [5] = "legendary", [6] = "mythic" }
local RARITY_TIER = { rainbow = 6, special = 2, rare = 3, epic = 4, legendary = 5, mythic = 6 }
local function tierCode(text)
local n = string.match(text, "%f[%w]t([1-6])%f[%W]")
return n and RARITY_BY_NUMBER[tonumber(n)] or nil
end
local state = {
speedOn = false, speed = 16,
jumpOn = false, jump = 50,
fogOn = false, clearBlur = false,
visOn = false, brightness = 2, ambientBoost = 30,
range = 2000, hudSize = 8, espOn = true, tracersOn = true,
anyNpc = false,
effects = true, notifications = true,
userScale = 1, bgTransparency = 0.02,
hideTrees = false, hideRocks = false,
aimOn = false, aimBtn = true, aimFov = 40, aimRange = 2000, aimSmooth = 25,
nitroOn = false, nitroPower = 300, nitroMax = 130,
flyOn = false, flySpeed = 5,
carJump = 120, carSpin = 16,
suspOn = false, flipOn = false,
modOn = false, hp = 50000, maxKmh = 300, push = "awd", climbOn = false, ghostOn = false,
}
state.suspPower = 100
state.farStream = true
state.stableOn = false
state.glideSpeed = 300
state.navSpeed = 3000
state.navRamp = 1.2
state.navUseCar = true
state.dhabCompass = false
state.jumpBtn = false
state.padJumpX, state.padJumpY = 0.62, 0.80
state.dhabCarry = false
state.autoKill = false
state.fireBtn = true
state.farmBtn = true
state.goBtn = true
state.farmOn = false
state.dhabAlert = false
state.padEdit = false
state.walkOn = false
state.walkSpeed = 12
state.padDriveX, state.padDriveY = 0.90, 0.77
state.padBrakeX, state.padBrakeY = 0.77, 0.87
state.padStableX, state.padStableY = 0.34, 0.30
state.padFireX, state.padFireY = 0.62, 0.80
state.padFarmX, state.padFarmY = 0.62, 0.64
state.padGoX, state.padGoY = 0.62, 0.50
state.padAimX, state.padAimY = 0.06, 0.62
state.padUpX, state.padUpY = 0.79, 0.48
state.padDownX, state.padDownY = 0.79, 0.69
state.padNitroX, state.padNitroY = 0.23, 0.30
state.padCompassX, state.padCompassY = 0.5, 0.09
state.padFwdX, state.padFwdY = 0.23, 0.49
state.padBackX, state.padBackY = 0.23, 0.68
state.fovCircle = true
state.aimCircle = 150
state.carColorOn, state.carR, state.carG, state.carB = false, 255, 40, 40
state.carRainbow, state.carBlink, state.carAnimSpeed = false, false, 5
state.carShine, state.carShinePulse, state.carShinePower = false, false, 70
state.carMat, state.carTrans = "orig", 0
state.carGlow, state.carGlowPower = false, 5
state.carWheelColor = false
state.wheelOn, state.wheelW, state.wheelS = false, 100, 100
state.liftOn, state.liftLvl = false, 0
state.viewMode = false
state.aimHead = true
state.aimPredict = true
state.magicOn = false
state.aimPart = "head"
state.noclip, state.pFly, state.infJump = false, false, false
state.pFlySpeed = 60
state.aimLift = 5
state.magicRange = 3000
state.magicRangeV2 = false
state.magicMouse = false
state.huntBtn, state.huntShoot = true, true
state.padHuntX, state.padHuntY = 0.06, 0.46
state.farmSpeed, state.farmDist, state.farmHeight = 150, 25, 10
state.fireBtnPath, state.fireX, state.fireY = "", 0, 0
state.noAutoSit = true
state.strictDhab = true
state.showDead = false
for _, k in ipairs({ "Up", "Down", "Nitro", "Fwd", "Back", "Drive", "Stable", "Jump", "Brake", "Aim", "Farm", "Go", "Compass" }) do
state["padScale" .. k] = 1
state["padAlpha" .. k] = 0
end
local DEFAULTS = {}
for k, v in pairs(state) do DEFAULTS[k] = v end
local T = {
rainbow = setmetatable({}, { __mode = "k" }),
nameInfo = {},
carLabels = setmetatable({}, { __mode = "k" }),
spot = 1, car = nil,
learned = {}, rbn = {}, rsel = "mythic",
ignore = {},
lastSeatSeen = nil, lastCharSeen = nil,
}
-- حجم صندوق العلامة يتناسب مع حجم الخط (عند 8 = 240x60 مثل السابق)
T.moveInfo = setmetatable({}, { __mode = "k" })
T.DHAB_HIDE = 2000
function T.updateMove(e, now)
local m = T.moveInfo[e.root]
local pos = e.root.Position
if not m then
T.moveInfo[e.root] = { pos = pos, last = -1000 }
return
end
if (pos - m.pos).Magnitude > 0.4 then
m.last = now
m.pos = pos
end
end
function T.isMoving(e, now)
if e.creature then return true end
local m = T.moveInfo[e.root]
return m ~= nil and now - m.last < 8
end
function T.stripSize(t)
if type(t) ~= "string" then return t end
for _, w in ipairs({ "كجم", "كغم", "كيلو", "kg", "KG", "Kg", "الوزن", "وزن", "الحجم", "حجم", "weight", "Weight", "size", "Size" }) do
t = string.gsub(t, "[%d%.,]+%s*" .. w, "")
t = string.gsub(t, w .. "%s*[:：]?%s*[%d%.,]*", "")
end
t = string.gsub(t, "  +", " ")
return t
end
function T.markerBox()
return math.max(150, state.hudSize * 11), math.max(36, state.hudSize * 2.7)
end
local HttpService = game:GetService("HttpService")
local SETTINGS_FILE = "RXZ_settings.json"
local canFile = (typeof(readfile) == "function" and typeof(writefile) == "function")
local savedData = {}
if canFile then
local ok, data = pcall(function()
if typeof(isfile) == "function" and not isfile(SETTINGS_FILE) then return nil end
return HttpService:JSONDecode(readfile(SETTINGS_FILE))
end)
if ok and typeof(data) == "table" then savedData = data end
end
if typeof(savedData.state) == "table" then
for k, v in pairs(savedData.state) do
if DEFAULTS[k] ~= nil and typeof(v) == typeof(DEFAULTS[k]) then state[k] = v end
end
end
state.flipOn = false
state.strictDhab = true
state.aimHead, state.aimPredict = true, true
state.noclip, state.pFly, state.infJump = false, false, false
state.speedOn, state.jumpOn = false, false
state.aimLift = math.clamp(state.aimLift, 0, 10)
if not state.magicRangeV2 then state.magicRange = 3000 state.magicRangeV2 = true end
state.magicRange = math.clamp(state.magicRange, 100, 3000)
state.magicMouse = false
if state.aimPart ~= "neck" and state.aimPart ~= "body" then state.aimPart = "head" end
state.navSpeed = 3000
state.farmOn = false
state.farmSpeed = math.clamp(state.farmSpeed, 50, 600)
state.farmDist = math.clamp(state.farmDist, 10, 60)
state.farmHeight = math.clamp(state.farmHeight, 3, 30)
if typeof(state.fireBtnPath) ~= "string" then state.fireBtnPath = "" end
state.fireX = math.clamp(state.fireX, 0, 1)
state.fireY = math.clamp(state.fireY, 0, 1)
state.range = 2000
state.aimRange = math.clamp(state.aimRange, 50, 5000)
state.aimCircle = math.clamp(state.aimCircle, 20, 1000)
state.hudSize = math.clamp(state.hudSize, CONFIG.MarkerMin, CONFIG.MarkerMax)
if typeof(savedData.patterns) == "table" then
for _, pat in ipairs(savedData.patterns) do
if typeof(pat) == "string" and pat ~= "animal" and not table.find(CONFIG.NamePatterns.dhab, pat) then
table.insert(CONFIG.NamePatterns.dhab, pat)
end
end
end
if typeof(savedData.learned) == "table" then
for _, n in ipairs(savedData.learned) do
if typeof(n) == "string" and n ~= "" and not table.find(T.learned, n) then table.insert(T.learned, n) end
end
end
if typeof(savedData.rbn) == "table" then
for k, v in pairs(savedData.rbn) do
if typeof(k) == "string" and typeof(v) == "string" and RARITIES[v] then T.rbn[k] = v end
end
end
if typeof(savedData.ignore) == "table" then
for _, n in ipairs(savedData.ignore) do
if typeof(n) == "string" and n ~= "" then T.ignore[n] = true end
end
end
T.seenUpdate = savedData.seenUpdate
-- أسماء الأشجار/الصخور اللي علّمتها بنفسك (تنحفظ)
T.natureLearn = { trees = {}, rocks = {} }
if typeof(savedData.natureLearn) == "table" then
for _, kind in ipairs({ "trees", "rocks" }) do
local l = savedData.natureLearn[kind]
if typeof(l) == "table" then
for _, n in ipairs(l) do
if typeof(n) == "string" and n ~= "" then T.natureLearn[kind][n] = true end
end
end
end
end
function T.natureLearnPack()
local r = { trees = {}, rocks = {} }
for _, kind in ipairs({ "trees", "rocks" }) do
for n in pairs(T.natureLearn[kind]) do r[kind][#r[kind] + 1] = n end
end
return r
end
local teleportSpots = {}
if typeof(savedData.spots) == "table" then
for _, sp in ipairs(savedData.spots) do
if typeof(sp) == "table" and typeof(sp.name) == "string" and typeof(sp.x) == "number"
and typeof(sp.y) == "number" and typeof(sp.z) == "number" then
table.insert(teleportSpots, { name = sp.name, x = sp.x, y = sp.y, z = sp.z })
end
end
end
do
local pn = { ["القرية"] = true, ["نقرة الفيروز"] = true, ["حزم الياقوت"] = true, ["قارة التبر"] = true,
["ديار العماليق"] = true, ["وادي النقوش"] = true, ["بوابة ابو النفود"] = true, ["خان العقيلات"] = true }
for i = #teleportSpots, 1, -1 do
local sp = teleportSpots[i]
if pn[sp.name] and sp.y == 300 then table.remove(teleportSpots, i) end
end
end
-- مواقع الديرة/المخيم/التاجر المحفوظة (تنحفظ لما تنشاف مرة، فتقدر تنتقل لها حتى لو بعيدة)
T.places = {}
if typeof(savedData.places) == "table" then
for _, k in ipairs({ "village", "camp", "trader", "house", "sheikh", "villageC" }) do
local p = savedData.places[k]
if typeof(p) == "table" and typeof(p.x) == "number" and typeof(p.y) == "number" and typeof(p.z) == "number" then
T.places[k] = Vector3.new(p.x, p.y, p.z)
end
end
end
function T.placesPack()
local r = {}
for k, v in pairs(T.places) do
if typeof(v) == "Vector3" then r[k] = { x = v.X, y = v.Y, z = v.Z } end
end
return r
end
local connections = {}
local function track(conn)
table.insert(connections, conn)
return conn
end
local function make(className, props, parent)
local inst = Instance.new(className)
for k, v in pairs(props) do inst[k] = v end
inst.Parent = parent
return inst
end
local function addCorner(inst, r) return make("UICorner", { CornerRadius = UDim.new(0, r) }, inst) end
local function addStroke(inst, color, thickness, transparency)
return make("UIStroke", {
Color = color, Thickness = thickness, Transparency = transparency or 0,
ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}, inst)
end
local function addGradient(inst, c0, c1, rotation)
return make("UIGradient", { Color = ColorSequence.new(c0, c1), Rotation = rotation or 0 }, inst)
end
local orderCounter = 0
local function nextOrder()
orderCounter += 1
return orderCounter
end
-- ===== مكتبة الأيقونات المرسومة (بدل الإيموجي): كلها أشكال Frame فتظهر بنفس الجودة على أي جهاز =====
T.ICONS = {}
do
local ICONS = T.ICONS
local function line(p, x1, y1, x2, y2, th, col)
local dx, dy = x2 - x1, y2 - y1
local len = math.sqrt(dx * dx + dy * dy)
local f = make("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale((x1 + x2) / 2, (y1 + y2) / 2),
Size = UDim2.fromScale(len + th, th), Rotation = math.deg(math.atan2(dy, dx)),
BackgroundColor3 = col, BorderSizePixel = 0,
}, p)
make("UICorner", { CornerRadius = UDim.new(0.5, 0) }, f)
return f
end
local function path(p, pts, th, col, closed)
for i = 1, #pts - 1 do
line(p, pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2], th, col)
end
if closed then line(p, pts[#pts][1], pts[#pts][2], pts[1][1], pts[1][2], th, col) end
end
local function ring(p, cx, cy, d, px, col, fill)
local f = make("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(cx, cy), Size = UDim2.fromScale(d, d),
BorderSizePixel = 0, BackgroundColor3 = col, BackgroundTransparency = fill and 0 or 1,
}, p)
make("UICorner", { CornerRadius = UDim.new(0.5, 0) }, f)
if not fill then
make("UIStroke", { Color = col, Thickness = px, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
end
return f
end
local function fillPoly(p, pts, col)
local ymin, ymax = 1, 0
for _, q in ipairs(pts) do
ymin = math.min(ymin, q[2])
ymax = math.max(ymax, q[2])
end
local step = 0.025
local y = ymin + 0.004
while y < ymax do
local xs = {}
for i = 1, #pts do
local a, b = pts[i], pts[i % #pts + 1]
if (a[2] <= y and b[2] > y) or (b[2] <= y and a[2] > y) then
xs[#xs + 1] = a[1] + (y - a[2]) / (b[2] - a[2]) * (b[1] - a[1])
end
end
table.sort(xs)
for k = 1, #xs - 1, 2 do
make("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale((xs[k] + xs[k + 1]) / 2, y),
Size = UDim2.fromScale(xs[k + 1] - xs[k], step + 0.012), BackgroundColor3 = col, BorderSizePixel = 0,
}, p)
end
y += step
end
end
local function box(p, cx, cy, w, h, col, rad, fill, px)
local f = make("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(cx, cy), Size = UDim2.fromScale(w, h),
BorderSizePixel = 0, BackgroundColor3 = col, BackgroundTransparency = fill and 0 or 1,
}, p)
make("UICorner", { CornerRadius = UDim.new(rad, 0) }, f)
if not fill then
make("UIStroke", { Color = col, Thickness = px, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
end
return f
end
-- كل أيقونة: (الحاوية، اللون الأساسي، لون التمييز، سماكة الحلقات بالبكسل، سماكة الخطوط)
ICONS.close = function(p, c, c2, px, th)
line(p, .26, .26, .74, .74, th * 1.3, c)
line(p, .74, .26, .26, .74, th * 1.3, c)
end
ICONS.radar = function(p, c, c2, px, th)
ring(p, .5, .5, .74, px, c)
ring(p, .5, .5, .38, px, c)
line(p, .5, .5, .8, .2, th, c2)
ring(p, .5, .5, .14, px, c2, true)
end
ICONS.bolt = function(p, c, c2, px, th)
local pts = { { .6, .08 }, { .26, .56 }, { .47, .56 }, { .4, .92 }, { .76, .42 }, { .54, .42 } }
fillPoly(p, pts, c2)
path(p, pts, th, c, true)
end
ICONS.car = function(p, c, c2, px, th)
path(p, { { .1, .68 }, { .1, .56 }, { .24, .52 }, { .36, .32 }, { .64, .32 }, { .76, .52 }, { .9, .56 }, { .9, .68 } }, th, c, true)
line(p, .5, .34, .5, .52, th * .8, c)
ring(p, .3, .72, .24, px, c2, true)
ring(p, .7, .72, .24, px, c2, true)
end
ICONS.navigate = function(p, c, c2, px, th)
path(p, { { .5, .08 }, { .8, .9 }, { .5, .7 }, { .2, .9 } }, th, c, true)
line(p, .5, .1, .5, .68, th * .7, c2)
end
ICONS.clef = function(p, c, c2, px, th)
-- مفتاح صول
line(p, .52, .08, .47, .86, th * 1.1, c)
path(p, { { .52, .08 }, { .6, .16 }, { .6, .28 }, { .5, .38 }, { .38, .5 }, { .34, .62 }, { .4, .74 }, { .52, .76 }, { .62, .68 }, { .62, .56 }, { .52, .5 }, { .43, .56 }, { .44, .64 } }, th * 1.1, c)
path(p, { { .47, .86 }, { .44, .93 }, { .36, .93 }, { .33, .87 } }, th * 1.1, c)
ring(p, .34, .84, .1, px, c2, true)
end
ICONS.target = function(p, c, c2, px, th)
ring(p, .5, .5, .58, px, c)
ring(p, .5, .5, .12, px, c2, true)
line(p, .5, .06, .5, .26, th * .9, c)
line(p, .5, .74, .5, .94, th * .9, c)
line(p, .06, .5, .26, .5, th * .9, c)
line(p, .74, .5, .94, .5, th * .9, c)
end
ICONS.widgets = function(p, c, c2, px, th)
box(p, .3, .3, .3, .3, c, .25, false, px)
box(p, .7, .3, .3, .3, c, .25, false, px)
box(p, .3, .7, .3, .3, c, .25, false, px)
box(p, .7, .7, .3, .3, c2, .25, true, px)
end
ICONS.info = function(p, c, c2, px, th)
ring(p, .5, .5, .74, px, c)
ring(p, .5, .31, .11, px, c2, true)
line(p, .5, .47, .5, .7, th * 1.1, c)
end
ICONS.search = function(p, c, c2, px, th)
ring(p, .42, .42, .54, px, c)
line(p, .66, .66, .88, .88, th * 1.3, c2)
end
ICONS.chev_up = function(p, c, c2, px, th)
path(p, { { .2, .64 }, { .5, .34 }, { .8, .64 } }, th * 1.4, c)
end
ICONS.chev_down = function(p, c, c2, px, th)
path(p, { { .2, .36 }, { .5, .66 }, { .8, .36 } }, th * 1.4, c)
end
ICONS.chev_up2 = function(p, c, c2, px, th)
path(p, { { .2, .52 }, { .5, .24 }, { .8, .52 } }, th * 1.3, c2)
path(p, { { .2, .8 }, { .5, .52 }, { .8, .8 } }, th * 1.3, c)
end
ICONS.updown = function(p, c, c2, px, th)
path(p, { { .3, .4 }, { .5, .2 }, { .7, .4 } }, th * 1.2, c)
path(p, { { .3, .6 }, { .5, .8 }, { .7, .6 } }, th * 1.2, c)
end
ICONS.arrow_up = function(p, c, c2, px, th)
line(p, .5, .86, .5, .2, th * 1.3, c)
path(p, { { .24, .46 }, { .5, .2 }, { .76, .46 } }, th * 1.3, c)
end
ICONS.arrow_down = function(p, c, c2, px, th)
line(p, .5, .14, .5, .8, th * 1.3, c)
path(p, { { .24, .54 }, { .5, .8 }, { .76, .54 } }, th * 1.3, c)
end
ICONS.flame = function(p, c, c2, px, th)
local pts = { { .5, .06 } }
for a = 200, -20, -20 do
local r = math.rad(a)
pts[#pts + 1] = { .5 + .26 * math.cos(r), .62 + .26 * math.sin(r) }
end
path(p, pts, th * 1.1, c, true)
ring(p, .5, .7, .22, px, c2, true)
end
ICONS.compass = function(p, c, c2, px, th)
ring(p, .5, .5, .74, px, c)
line(p, .5, .5, .67, .33, th * 1.3, c2)
line(p, .5, .5, .33, .67, th * 1.3, c)
ring(p, .5, .5, .13, px, c, true)
end
ICONS.stop = function(p, c, c2, px, th)
ring(p, .5, .5, .74, px, c)
box(p, .5, .5, .3, .3, c2, .2, true, px)
end
ICONS.check = function(p, c, c2, px, th)
path(p, { { .2, .54 }, { .42, .76 }, { .82, .28 } }, th * 1.5, c)
end
ICONS.grip = function(p, c, c2, px, th)
line(p, .86, .3, .3, .86, th * .9, c)
line(p, .86, .56, .56, .86, th * .9, c)
line(p, .86, .8, .8, .86, th * .9, c)
end
ICONS.village = function(p, c, c2, px, th)
path(p, { { .08, .5 }, { .5, .14 }, { .92, .5 } }, th, c)
path(p, { { .2, .44 }, { .2, .88 }, { .8, .88 }, { .8, .44 } }, th, c)
path(p, { { .42, .88 }, { .42, .64 }, { .58, .64 }, { .58, .88 } }, th, c2)
end
ICONS.camp = function(p, c, c2, px, th)
path(p, { { .5, .14 }, { .92, .86 }, { .08, .86 } }, th, c, true)
path(p, { { .36, .86 }, { .5, .54 }, { .64, .86 } }, th, c2)
end
ICONS.cart = function(p, c, c2, px, th)
path(p, { { .06, .2 }, { .22, .2 }, { .36, .64 }, { .8, .64 }, { .9, .3 }, { .26, .3 } }, th, c)
ring(p, .42, .82, .15, px, c2, true)
ring(p, .76, .82, .15, px, c2, true)
end
function T.icon(name, parent, size, col, col2)
col = col or Color3.new(1, 1, 1)
col2 = col2 or col
local holder = make("Frame", {
Name = "Icon", Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1, BorderSizePixel = 0,
}, parent)
local fn = ICONS[name]
if fn and (name == "check" or name == "navigate") then fn(holder, col, col2, math.max(1.3, size * 0.085), 0.095) end
return holder
end
end
local function isPointer(input)
return input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch
end
local function isMove(input)
return input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch
end
local function getCharacter() return player.Character end
local function getHumanoid()
local char = getCharacter()
return char and char:FindFirstChildOfClass("Humanoid") or nil
end
local function getRootPart()
local char = getCharacter()
if not char then return nil end
local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
return (root and root:IsA("BasePart")) and root or nil
end
local function getBasePart(inst)
if inst:IsA("BasePart") then return inst end
if inst:IsA("Model") then
local hrp = inst:FindFirstChild("HumanoidRootPart")
if hrp and hrp:IsA("BasePart") then return hrp end
if inst.PrimaryPart then return inst.PrimaryPart end
local head = inst:FindFirstChild("Head")
if head and head:IsA("BasePart") then return head end
return inst:FindFirstChildWhichIsA("BasePart", true)
end
return nil
end
local gui = make("ScreenGui", {
Name = GUI_NAME, ResetOnSpawn = false,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets, DisplayOrder = 2147483647,
}, playerGui)
local markerFolder = make("Folder", { Name = "Markers" }, gui)
local tracerGui = make("ScreenGui", {
Name = "RXZ_Tracers", ResetOnSpawn = false, IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ScreenInsets = Enum.ScreenInsets.None, DisplayOrder = 100000,
}, playerGui)
local cam0 = workspace.CurrentCamera
local view = cam0 and cam0.ViewportSize or Vector2.new(800, 400)
T.isPC = not UserInputService.TouchEnabled
if view.X < 300 or view.Y < 200 then
local gsz = gui.AbsoluteSize
if gsz.X >= 300 and gsz.Y >= 200 then
view = gsz
else
view = Vector2.new(1280, 720)
end
end
local toastGui = make("ScreenGui", {
Name = "RXZ_Toast", ResetOnSpawn = false,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets, DisplayOrder = 2147483647,
}, playerGui)
local toast = make("TextLabel", {
Size = UDim2.fromOffset(260, 34), AnchorPoint = Vector2.new(0.5, 0),
Position = UDim2.new(0.5, 0, 0, 10), BackgroundColor3 = THEME.RowSel, BackgroundTransparency = 0.05,
TextColor3 = Color3.new(1, 1, 1), TextSize = 15, Font = FONT, TextWrapped = true, Visible = false, ZIndex = 5000,
}, toastGui)
addCorner(toast, 10)
local toastStroke = addStroke(toast, THEME.Accent, 1, 0.3)
local toastToken = 0
local function notify(text, kind, dur)
if kind ~= "error" and kind ~= "force" and not state.notifications then return end
if kind == "force" then
toast.AnchorPoint = Vector2.new(0.5, 0.5)
toast.Position = UDim2.new(0.5, 0, 0.5, 0)
toast.Size = UDim2.fromOffset(250, 96)
toast.TextSize = 14
toastStroke.Color, toastStroke.Thickness, toastStroke.Transparency = Color3.fromRGB(255, 40, 40), 2.5, 0
else
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 10)
toast.Size = UDim2.fromOffset(260, 34)
toast.TextSize = 15
toastStroke.Color, toastStroke.Thickness, toastStroke.Transparency = THEME.Accent, 1, 0.3
end
toastToken += 1
local mine = toastToken
toast.Text = text
toast.BackgroundColor3 = (kind == "error") and THEME.Danger or THEME.RowSel
toast.Visible = true
task.delay(dur or (kind == "force" and 10 or 2.5), function()
if mine == toastToken then toast.Visible = false end
end)
end
local lastErrorTime = {}
local function safe(name, fn, ...)
local ok, err = pcall(fn, ...)
if not ok then
warn("[RXZ] " .. tostring(name) .. ": " .. tostring(err))
local now = os.clock()
if not lastErrorTime[name] or now - lastErrorTime[name] > 5 then
lastErrorTime[name] = now
notify("تعذّر تنفيذ: " .. tostring(name), "error")
end
end
return ok
end
local function clampFrame(frame)
local screen = gui.AbsoluteSize
if screen.X <= 0 or screen.Y <= 0 then return end
local size = frame.AbsoluteSize
local pos = frame.AbsolutePosition - gui.AbsolutePosition
frame.Position = UDim2.fromOffset(
math.clamp(pos.X, 0, math.max(screen.X - size.X, 0)),
math.clamp(pos.Y, 0, math.max(screen.Y - size.Y, 0)))
end
local function makeDragger(handle, onStart, onDelta, onEnd)
local dragging, startInput, moved = false, nil, false
handle.InputBegan:Connect(function(input)
if isPointer(input) then
dragging, moved, startInput = true, false, input.Position
onStart()
local c
c = input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
c:Disconnect()
if onEnd then safe("السحب", onEnd, moved) end
end
end)
end
end)
track(UserInputService.InputChanged:Connect(function(input)
if dragging and isMove(input) then
local d = input.Position - startInput
if d.Magnitude > 8 then moved = true end
safe("السحب", onDelta, d, moved)
end
end))
end
-- ===== تعديل الأزرار: شريطين ثابتين بالنص فوق كل شي (حجم + شفافية) للزر المحدد + زر حفظ =====
do
T.pads, T.padOrder, T.padSel = {}, {}, nil
T.padHold, T.padHoldT = false, 0
T.ALPHA_MAX = 0.9
T.PAD_LABELS = {
Up = "صعود", Down = "نزول", Nitro = "نيترو", Fwd = "أمام", Back = "خلف", Drive = "امش",
Stable = "ثبات", Jump = "قفز", Brake = "وقوف", Aim = "ايم", Farm = "فارم", Go = "انتقال", Compass = "البوصلات",
}
local fadeOrig = setmetatable({}, { __mode = "k" })
local function fadeOne(o, a)
local rec = fadeOrig[o]
if not rec then
rec = {}
if o:IsA("GuiObject") then rec.bg = o.BackgroundTransparency end
if o:IsA("TextLabel") or o:IsA("TextButton") then rec.tx = o.TextTransparency end
if o:IsA("ImageLabel") or o:IsA("ImageButton") then rec.im = o.ImageTransparency end
if o:IsA("UIStroke") then rec.st = o.Transparency end
fadeOrig[o] = rec
end
if rec.bg then o.BackgroundTransparency = rec.bg + (1 - rec.bg) * a end
if rec.tx then o.TextTransparency = rec.tx + (1 - rec.tx) * a end
if rec.im then o.ImageTransparency = rec.im + (1 - rec.im) * a end
if rec.st then o.Transparency = rec.st + (1 - rec.st) * a end
end
function T.padApply(e)
if not e.obj or not e.obj.Parent then return end
e.scale.Scale = math.clamp(state["padScale" .. e.key] or 1, 0.5, 2)
local a = math.clamp(state["padAlpha" .. e.key] or 0, 0, T.ALPHA_MAX)
fadeOne(e.obj, a)
for _, d in ipairs(e.obj:GetDescendants()) do fadeOne(d, a) end
end
function T.padApplyAll()
for _, e in ipairs(T.padOrder) do T.padApply(e) end
end
local oldBar = playerGui:FindFirstChild("RXZ_EditBar")
if oldBar then oldBar:Destroy() end
-- واجهة مستقلة بأعلى أولوية عرض عشان ما تغطيها أزرار اللعبة
local barGui = make("ScreenGui", {
Name = "RXZ_EditBar", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets, DisplayOrder = 2147483647, Enabled = false,
}, playerGui)
pcall(function()
local hui = (typeof(gethui) == "function") and gethui() or nil
if hui then
for _, c in ipairs(hui:GetChildren()) do
if c.Name == "RXZ_EditBar" then c:Destroy() end
end
barGui.Parent = hui
end
end)
T.barGui = barGui
local editBar = make("Frame", {
Name = "PadEditBar", AnchorPoint = Vector2.new(0, 0), Position = UDim2.fromOffset(8, 8),
Size = UDim2.fromOffset(240, 136), BackgroundTransparency = 1, Active = false,
}, barGui)
make("UIListLayout", { Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder }, editBar)
local function mkSlider(order, title)
local row = make("Frame", {
Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = THEME.Row, BackgroundTransparency = 0.4, LayoutOrder = order, Active = true,
}, editBar)
addCorner(row, 8)
addStroke(row, THEME.Line, 1, 0.2)
make("TextLabel", {
Position = UDim2.fromOffset(10, 3), Size = UDim2.new(1, -70, 0, 20), BackgroundTransparency = 1,
Text = title, TextColor3 = THEME.Text, TextSize = 15, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left,
}, row)
local val = make("TextLabel", {
AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 3), Size = UDim2.fromOffset(56, 20),
BackgroundTransparency = 1, Text = "", TextColor3 = THEME.Text, TextSize = 14, Font = FONT,
TextXAlignment = Enum.TextXAlignment.Right,
}, row)
local trackF = make("Frame", {
Position = UDim2.new(0, 12, 1, -17), Size = UDim2.new(1, -24, 0, 6), BackgroundColor3 = THEME.Off,
}, row)
addCorner(trackF, 3)
local fill = make("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = THEME.Accent }, trackF)
addCorner(fill, 3)
local knob = make("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(20, 20),
BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 3,
}, trackF)
addCorner(knob, 10)
return row, trackF, fill, knob, val
end
local sizeRow, sizeTrack, sizeFill, sizeKnob, sizeVal = mkSlider(1, "حجم الزر")
local alphaRow, alphaTrack, alphaFill, alphaKnob, alphaVal = mkSlider(2, "شفافية الزر")
local botRow = make("Frame", {
Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = THEME.Row, BackgroundTransparency = 0.4, LayoutOrder = 3, Active = true,
}, editBar)
addCorner(botRow, 8)
addStroke(botRow, THEME.Line, 1, 0.2)
local nameLbl = make("TextLabel", {
Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -84, 1, 0), BackgroundTransparency = 1, Text = "",
TextColor3 = THEME.Text, TextSize = 14, Font = FONT, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
}, botRow)
local saveBtn = make("TextButton", {
AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -5, 0.5, 0), Size = UDim2.fromOffset(68, 28),
BackgroundColor3 = THEME.On, Text = "حفظ", TextColor3 = THEME.Text, TextSize = 16, Font = FONT, AutoButtonColor = true,
}, botRow)
addCorner(saveBtn, 6)
local ring = make("Frame", {
Name = "PadSelRing", AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1,
Visible = false, ZIndex = 4000, Active = false,
}, gui)
make("UICorner", { CornerRadius = UDim.new(0, 18) }, ring)
addStroke(ring, THEME.Accent, 3, 0)
function T.padRefreshBar()
local e = T.padSel and T.pads[T.padSel]
if e then
local sc = math.clamp(state["padScale" .. e.key] or 1, 0.5, 2)
local al = math.clamp(state["padAlpha" .. e.key] or 0, 0, T.ALPHA_MAX)
local r1, r2 = (sc - 0.5) / 1.5, al / T.ALPHA_MAX
sizeFill.Size, sizeKnob.Position = UDim2.fromScale(r1, 1), UDim2.fromScale(r1, 0.5)
alphaFill.Size, alphaKnob.Position = UDim2.fromScale(r2, 1), UDim2.fromScale(r2, 0.5)
sizeVal.Text = ("%d%%"):format(math.floor(sc * 100 + 0.5))
alphaVal.Text = ("%d%%"):format(math.floor(al * 100 + 0.5))
nameLbl.Text = e.label
else
sizeFill.Size, sizeKnob.Position = UDim2.fromScale(0, 1), UDim2.fromScale(0, 0.5)
alphaFill.Size, alphaKnob.Position = UDim2.fromScale(0, 1), UDim2.fromScale(0, 0.5)
sizeVal.Text, alphaVal.Text = "", ""
nameLbl.Text = "اختر زراً"
end
end
function T.padSelect(key)
T.padSel = key
T.padRefreshBar()
local e = T.pads[key]
if e then
local cr = ring:FindFirstChildOfClass("UICorner")
local sz = e.obj.AbsoluteSize
if cr then cr.CornerRadius = (math.abs(sz.X - sz.Y) < 6) and UDim.new(0.5, 0) or UDim.new(0, 18) end
end
end
function T.regPad(key, obj, label)
local sc = make("UIScale", { Name = "PadScale", Scale = math.clamp(state["padScale" .. key] or 1, 0.5, 2) }, obj)
local e = { key = key, obj = obj, label = label or T.PAD_LABELS[key] or key, scale = sc }
T.pads[key] = e
table.insert(T.padOrder, e)
-- أول زر تضغط عليه يتحدد ويتقفل: لو لمس أزرار ثانية وأنت ماسكه ما ينتقل التحديد لها
obj.InputBegan:Connect(function(input)
if not (state.padEdit and not T.menuOpen and isPointer(input)) then return end
if T.padHold and os.clock() - T.padHoldT < 10 then return end
T.padHold, T.padHoldT = true, os.clock()
T.padSelect(key)
local c
c = input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
T.padHold = false
c:Disconnect()
end
end)
end)
task.defer(T.padApply, e)
return e
end
local function bindBar(row, trackF, getRatio, setRatio)
local dragging, x0, r0 = false, 0, 0
row.InputBegan:Connect(function(input)
if not isPointer(input) then return end
if not T.padSel then
notify("اضغط على زر أول عشان تعدّله", "error")
return
end
dragging, x0, r0 = true, input.Position.X, getRatio()
local c
c = input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
c:Disconnect()
end
end)
end)
track(UserInputService.InputChanged:Connect(function(input)
if dragging and isMove(input) and T.padSel then
local w = math.max(trackF.AbsoluteSize.X, 1)
setRatio(math.clamp(r0 + (input.Position.X - x0) / w, 0, 1))
end
end))
end
bindBar(sizeRow, sizeTrack, function()
local e = T.pads[T.padSel]
return e and (math.clamp(state["padScale" .. e.key] or 1, 0.5, 2) - 0.5) / 1.5 or 0
end, function(r)
local e = T.pads[T.padSel]
if not e then return end
state["padScale" .. e.key] = math.floor((0.5 + r * 1.5) / 0.05 + 0.5) * 0.05
T.padApply(e)
T.padRefreshBar()
end)
bindBar(alphaRow, alphaTrack, function()
local e = T.pads[T.padSel]
return e and math.clamp(state["padAlpha" .. e.key] or 0, 0, T.ALPHA_MAX) / T.ALPHA_MAX or 0
end, function(r)
local e = T.pads[T.padSel]
if not e then return end
state["padAlpha" .. e.key] = math.floor(r * T.ALPHA_MAX / 0.05 + 0.5) * 0.05
T.padApply(e)
T.padRefreshBar()
end)
saveBtn.Activated:Connect(function()
state.padEdit = false
T.padSel, T.padHold = nil, false
T.padRefreshBar()
if T.saveNow then pcall(T.saveNow) end
if T.refreshAll then pcall(T.refreshAll) end
notify("تم حفظ الأزرار وإغلاق التعديل")
end)
track(RunService.RenderStepped:Connect(function()
local show = state.padEdit and not T.menuOpen
if barGui.Enabled ~= show then barGui.Enabled = show end
if not state.padEdit then
T.padHold = false
if T.padSel then
T.padSel = nil
T.padRefreshBar()
end
end
local e = T.padSel and T.pads[T.padSel]
if show and e and e.obj.Parent and e.obj.Visible then
local ap = e.obj.AbsolutePosition - gui.AbsolutePosition
local sz = e.obj.AbsoluteSize
ring.Position = UDim2.fromOffset(ap.X + sz.X / 2, ap.Y + sz.Y / 2)
ring.Size = UDim2.fromOffset(sz.X + 10, sz.Y + 10)
ring.Visible = true
else
ring.Visible = false
end
end))
T.padRefreshBar()
end
do
local oldPet = playerGui:FindFirstChild("RXZ_PadEditToggle")
if oldPet then oldPet:Destroy() end
end
local originals = {}
local function ensureOriginals(hum)
if originals.hum ~= hum then
originals.hum = hum
originals.walk = hum.WalkSpeed
originals.useJumpPower = hum.UseJumpPower
originals.jumpPower = hum.JumpPower
originals.speedTouched, originals.jumpTouched = false, false
end
end
local function applyMovement()
local hum = getHumanoid()
if not hum then return false end
ensureOriginals(hum)
if state.speedOn then
if hum.WalkSpeed ~= state.speed then hum.WalkSpeed = state.speed end
originals.speedTouched = true
elseif originals.speedTouched then
hum.WalkSpeed = originals.walk
originals.speedTouched = false
end
if state.jumpOn then
if not hum.UseJumpPower then hum.UseJumpPower = true end
if hum.JumpPower ~= state.jump then hum.JumpPower = state.jump end
originals.jumpTouched = true
elseif originals.jumpTouched then
hum.UseJumpPower = originals.useJumpPower
hum.JumpPower = originals.jumpPower
originals.jumpTouched = false
end
return true
end
local function onCharacterAdded(char)
task.spawn(function()
local hum = char:WaitForChild("Humanoid", 10)
if not hum or not char.Parent then return end
safe("تطبيق الحركة", applyMovement)
end)
end
track(player.CharacterAdded:Connect(onCharacterAdded))
if player.Character then onCharacterAdded(player.Character) end
local applyVision
do
local lightGroups = { fog = { touched = false }, vis = { touched = false } }
local atmoOrig = setmetatable({}, { __mode = "k" })
local effectOrig = setmetatable({}, { __mode = "k" })
local applying = false
function applyVision()
applying = true
local fog, vis = lightGroups.fog, lightGroups.vis
if state.fogOn then
if not fog.touched then
fog.touched = true
fog.FogEnd, fog.FogStart = Lighting.FogEnd, Lighting.FogStart
end
Lighting.FogEnd = 100000
elseif fog.touched then
Lighting.FogEnd, Lighting.FogStart = fog.FogEnd, fog.FogStart
fog.touched = false
end
if state.visOn then
if not vis.touched then
vis.touched = true
vis.Brightness = Lighting.Brightness
vis.Ambient = Lighting.Ambient
vis.Outdoor = Lighting.OutdoorAmbient
end
local t = state.ambientBoost / 100
Lighting.Brightness = state.brightness
Lighting.Ambient = vis.Ambient:Lerp(Color3.new(1, 1, 1), t)
Lighting.OutdoorAmbient = vis.Outdoor:Lerp(Color3.new(1, 1, 1), t)
elseif vis.touched then
Lighting.Brightness = vis.Brightness
Lighting.Ambient = vis.Ambient
Lighting.OutdoorAmbient = vis.Outdoor
vis.touched = false
end
for _, child in ipairs(Lighting:GetChildren()) do
if child:IsA("Atmosphere") then
local o = atmoOrig[child]
if state.fogOn then
if not o then
o = { Density = child.Density, Haze = child.Haze }
atmoOrig[child] = o
end
child.Density = o.Density * 0.15
child.Haze = 0
elseif o then
child.Density, child.Haze = o.Density, o.Haze
atmoOrig[child] = nil
end
elseif child:IsA("BlurEffect") or child:IsA("DepthOfFieldEffect") then
local o = effectOrig[child]
if state.clearBlur then
if o == nil then
o = child.Enabled
effectOrig[child] = o
end
child.Enabled = false
elseif o ~= nil then
child.Enabled = o
effectOrig[child] = nil
end
end
end
applying = false
end
local reapplyPending = false
local function scheduleReapply()
if applying or reapplyPending then return end
if not (state.fogOn or state.visOn or state.clearBlur) then return end
reapplyPending = true
task.defer(function()
reapplyPending = false
safe("الإضاءة", applyVision)
end)
end
for _, prop in ipairs({ "Brightness", "Ambient", "OutdoorAmbient", "FogEnd", "FogStart" }) do
track(Lighting:GetPropertyChangedSignal(prop):Connect(scheduleReapply))
end
track(Lighting.ChildAdded:Connect(scheduleReapply))
end
local function matches(name, patterns)
local lower = string.lower(name)
for _, p in ipairs(patterns) do
if string.find(lower, string.lower(p), 1, true) then return true end
end
return false
end
local RARITY_KEYS = { "rarity", "tier", "grade", "quality", "class", "type", "level", "الندرة", "ندرة", "درجة" }
local SIZE_KEYS = { "size", "weight", "kg", "الحجم", "حجم", "الوزن", "وزن", "كجم" }
local SHOP_WORDS = { "shop", "store", "ezba", "market", "عزبة", "محل", "متجر", "سوق" }
local SIZE_TEXT_WORDS = { "حجم", "size", "كجم", "kg", "كيلو", "وزن", "weight" }
local function stripTags(t)
return (tostring(t):gsub("<[^>]->", ""))
end
local function hasDigit(t)
return string.find(t, "%d") ~= nil or string.find(t, "\217[\160-\169]") ~= nil
end
local function hasArabic(t)
if type(t) ~= "string" then return false end
return string.find(t, "[\216-\219]") ~= nil
end
T.billText = setmetatable({}, { __mode = "k" })
-- توحيد النص العربي: حذف التشكيل والتطويل، وتوحيد الألف والياء والتاء المربوطة
T.normCache, T.normCount = {}, 0
function T.arNorm(t)
local hit = T.normCache[t]
if hit then return hit end
local raw = t
t = string.lower(stripTags(tostring(t)))
local ok, res = pcall(function()
local out = {}
for _, cp in utf8.codes(t) do
if (cp >= 0x064B and cp <= 0x065F) or cp == 0x0670 or cp == 0x0640
or (cp >= 0x200B and cp <= 0x200F) or (cp >= 0x202A and cp <= 0x202E)
or (cp >= 0x2066 and cp <= 0x2069) or cp == 0xFEFF then
-- تشكيل/تطويل: يُحذف
else
if cp == 0x0623 or cp == 0x0625 or cp == 0x0622 then cp = 0x0627
elseif cp == 0x0649 then cp = 0x064A
elseif cp == 0x0629 then cp = 0x0647
elseif cp == 0x06CC then cp = 0x064A
elseif cp == 0x06A9 then cp = 0x0643
elseif cp == 0x00A0 then cp = 0x20 end
out[#out + 1] = utf8.char(cp)
end
end
return (string.gsub(table.concat(out), "%s+", " "))
end)
res = ok and res or t
if T.normCount > 4000 then T.normCache, T.normCount = {}, 0 end
T.normCache[raw] = res
T.normCount += 1
return res
end
-- الضبان الملوّنة المستقلة (من الصور)
T.specialNames = {}
T.specialDisplay = {}
for _, nm in ipairs({
{ "ضب الياقوت", "الياقوت" },
"ضب الكهرمان",
"ضب التبر",
"ضب الفيروز",
"ضب الألماس",
"الضب الملبوس",
"الجلمود",
"الفَرْقَد",
"ضب الحِمَم",
"ضب العَسجد",
"ضب اللُّجين",
"أبو مشلح",
"ضب الصهير",
"ضب الأبيض",
"أبو جمرة",
"ضب الشاهد",
"ضب العقيان",
"أبو نفود",
"أبو صخر",
}) do
if type(nm) == "table" then
table.insert(T.specialNames, T.arNorm(nm[2]))
table.insert(T.specialDisplay, nm[1])
else
table.insert(T.specialNames, T.arNorm(nm))
table.insert(T.specialDisplay, nm)
end
end
-- الاسم الجوهري: بدون "ضب" و"ال" والمسافات (لمطابقة نص يحمل الاسم فقط مثل "الفضي")
function T.coreOf(nt)
nt = string.gsub(nt, "[%s_%-]+", "")
nt = string.gsub(nt, "^الضب", "")
nt = string.gsub(nt, "^ضب", "")
nt = string.gsub(nt, "^ال", "")
return nt
end
-- كل الأسماء المعروفة (للعرض على العلامة مهما كانت الندرة)
T.knownNames, T.knownDisplay = {}, {}
for _, nm in ipairs({
"ضب أصفر",
"ضب أبو نقط",
"ضب الغضا",
"ضب الحزم",
"ضب الشيح",
"ضب جوفي",
"ضب الهبوب",
"ضب الوسم",
"ضب المرتع",
"ضب الكاهل",
"ضب الفيضة",
"ضب الخزامى",
"ضب الردع",
"ضب السوم",
"ضب الشقعة",
"ضب العصاري",
"ضب الغبار",
"ضب القضى",
"ضب النخل",
"ضب قصيمي",
"ضب نقودي",
"ضب أبو ذيل",
"ضب الأرط",
"ضب البلق",
"ضب البطحاء",
"ضب النمام",
"ضب الدهناء",
"ضب صمّاني",
"ضب الدحول",
"ضب مزخرف",
"ضب حايلي",
"ضب الشفق",
"ضب الثويرات",
"ضب الحنظل",
"ضب الأفلاج",
"ضب الأحساء",
"ضب جبلي",
"سيول الوديان",
"ضب الشاهق",
"أبو صخر",
"ضب العجاج",
"ضب الخشم",
"ضب الجرف",
"ضب الغدير",
"ضب الهضبة",
"ضب الدخان",
"ضب القليب",
"ضب التوييرات",
"ضب الحماد",
"ضب السهباء",
"ضب السيل",
"ضب الموسع",
"ضب العين",
"ضب الكثيب",
"ضب أحمد",
"ضب أحمر",
"ضب السبخة",
"ضب طويق",
"ضب الحرّة",
"ضب القمر",
"ضب العروق",
"ضب الدبدبة",
"ضب القارة",
"ضب الهجير",
"ضب العارض",
"ضب النقا",
"ضب الملح",
"ضب الدرع",
"ضب الترس",
"ضب السيف",
"ضب الرمح",
"ضب الكهف",
"ضب الدلّة",
"ضب الهيل",
"ضب الخفّاف",
"ضب الرمضاء",
"ضب المنجل",
"ضب الحجير",
"ضب الحديد",
"ضب الحصن",
"ضب الخفاف",
"ضب أبو نايف",
"ضب البرج",
"ضب النرس",
"ضب الرماد",
"ضب أبو قرنين",
"ضب البرج",
"ضب العود",
"ضب الكبريت",
"ضب الطوق",
"ضب اللابة",
"ضب الربع الخالي",
"ضب وبار",
"الضب الذهبي",
"ضب حسمى",
"ضب السراب",
"ضب سهيل",
"ضب الحافة",
"ضب القدر",
"ضب حنيفة",
"ضب أبو شراع",
"ضب الجوزاء",
"ضب المرزم",
"ضب الشولة",
"ضب المجرّة",
"ضب البرّاق",
"ضب الزمرد",
"ضب الصدى",
"ضب الزعفران",
"ضب الخنجر",
"ضب الجمشت",
"ضب السبج",
"ضب الشرار",
"ضب الزوبعة",
"ضب الأصيل",
"ضب الوهج",
"ضب العقيق",
"ضب الجافورة",
"ضب النحاس",
"ضب النعام",
"ضب السدو",
"ضب الثريا",
"ضب الوعبة",
"ضب طميّة",
"أبو الضبان",
"ضب الدبران",
"ضب الشعرى",
"الطود",
"ضب التنين",
"سلطان الأقاصي",
"ضب الصوّان",
"ضب اللازورد",
"ضب البِلّور",
"ضب الياقوت",
"ضب الكهرمان",
"ضب التبر",
"ضب الفيروز",
"ضب الألماس",
"الضب الملبوس",
"الجلمود",
"الفَرْقَد",
"ضب الحِمَم",
"ضب العَسجد",
"ضب اللُّجين",
"أبو مشلح",
"ضب الصهير",
"ضب الأبيض",
"أبو جمرة",
"ضب الشاهد",
"ضب العقيان",
"أبو نفود",
}) do
local nn = T.arNorm(nm)
T.coreMap = T.coreMap or {}
T.coreMap[T.coreOf(nn)] = nm
local dup = false
for _, x in ipairs(T.knownNames) do if x == nn then dup = true break end end
if not dup then
table.insert(T.knownNames, nn)
table.insert(T.knownDisplay, nm)
end
end
-- أسماء الضبان مع ندرتها (T1..T6): تُضاف للأسماء المعروفة وتحدد الندرة بالاسم
T.nameTier = T.nameTier or {}
for line in string.gmatch([==[
ضب أصفر - T2
ضب أبو نقط - T2
ضب الغضا - T2
ضب الحزم - T2
ضب الشيح - T2
ضب جوفي - T2
ضب الهبوب - T2
ضب الوسم - T2
ضب المرتع - T2
ضب الكاهل - T2
ضب الفيضة - T2
ضب الخزامى - T2
ضب الردع - T2
ضب السوم - T2
ضب الشقعة - T2
ضب العصاري - T2
ضب الغبار - T2
ضب القضى - T2
ضب النخل - T2
ضب قصيمي - T2
ضب نقودي - T2
ضب أبو ذيل - T2
ضب الأرط - T2
ضب البلق - T2
ضب البطحاء - T2
ضب النمام - T2
ضب الدهناء - T3
ضب صمّاني - T3
ضب الدحول - T3
ضب مزخرف - T3
ضب حايلي - T3
ضب الشفق - T3
ضب الثويرات - T3
ضب الحنظل - T3
ضب الأفلاج - T3
ضب الأحساء - T3
ضب جبلي - T3
سيول الوديان - T3
ضب الشاهق - T3
أبو صخر - T3
ضب العجاج - T3
ضب الخشم - T3
ضب الجرف - T3
ضب الغدير - T3
ضب الهضبة - T3
ضب الدخان - T3
ضب القليب - T3
ضب التوييرات - T3
ضب الحماد - T3
ضب السهباء - T3
ضب السيل - T3
ضب الموسع - T3
ضب العين - T3
ضب الكثيب - T3
ضب أحمد - T3
ضب أحمر - T3
ضب السبخة - T4
ضب طويق - T4
ضب الحرّة - T4
ضب القمر - T4
ضب العروق - T4
ضب الدبدبة - T4
ضب القارة - T4
ضب الهجير - T4
ضب العارض - T4
ضب النقا - T4
ضب الملح - T4
ضب الدرع - T4
ضب الترس - T4
ضب السيف - T4
ضب الرمح - T4
ضب الكهف - T4
ضب الدلّة - T4
ضب الهيل - T4
ضب الخفّاف - T4
ضب الرمضاء - T4
ضب المنجل - T4
ضب الحجير - T4
ضب الحديد - T4
ضب الحصن - T4
ضب الخفاف - T4
ضب أبو نايف - T4
ضب البرج - T4
ضب النرس - T4
ضب الرماد - T4
ضب أبو قرنين - T4
ضب البرج - T4
ضب العود - T4
ضب الكبريت - T4
ضب الطوق - T4
ضب اللابة - T4
ضب الربع الخالي - T5
ضب وبار - T5
الضب الذهبي - T5
ضب حسمى - T5
ضب السراب - T5
ضب سهيل - T5
ضب الحافة - T5
ضب القدر - T5
ضب حنيفة - T5
ضب أبو شراع - T5
ضب الجوزاء - T5
ضب المرزم - T5
ضب الشولة - T5
ضب المجرّة - T5
ضب البرّاق - T5
ضب الزمرد - T5
ضب الصدى - T5
ضب الزعفران - T5
ضب الخنجر - T5
ضب الجمشت - T5
ضب السبج - T5
ضب الشرار - T5
ضب الزوبعة - T5
ضب الأصيل - T5
ضب الوهج - T5
ضب العقيق - T5
ضب الجافورة - T5
ضب النحاس - T5
ضب النعام - T5
ضب السدو - T6
ضب الثريا - T6
ضب الوعبة - T6
ضب طميّة - T6
أبو الضبان - T6
ضب الدبران - T6
ضب الشعرى - T6
الطود - T6
ضب التنين - T6
سلطان الأقاصي - T6
ضب الصوّان - T6
ضب اللازورد - T6
ضب البِلّور - T6
]==], "[^\n]+") do
local nm, tr = string.match(line, "^(.-)%s*%-%s*T(%d)%s*$")
if nm and tr then
local nn = T.arNorm(nm)
T.coreMap = T.coreMap or {}
T.coreMap[T.coreOf(nn)] = nm
T.nameTier[T.coreOf(nn)] = tonumber(tr)
local dup = false
for _, x in ipairs(T.knownNames) do if x == nn then dup = true break end end
if not dup then
table.insert(T.knownNames, nn)
table.insert(T.knownDisplay, nm)
end
end
end
-- الأطول أولاً حتى لا يغطي اسم قصير على اسم أطول يحتويه
do
local idxs = {}
for i = 1, #T.knownNames do idxs[i] = i end
table.sort(idxs, function(a, b) return #T.knownNames[a] > #T.knownNames[b] end)
local kn, kd = {}, {}
for i, j in ipairs(idxs) do kn[i], kd[i] = T.knownNames[j], T.knownDisplay[j] end
T.knownNames, T.knownDisplay = kn, kd
end
-- يستخرج اسم الضب من نص لوحة مثل "[T6] ضب الألماس" (يشيل وسم الندرة والأرقام والحجم)
function T.extractName(raw)
local t = stripTags(raw)
t = string.gsub(t, "%[[^%]]*%]", " ")
t = string.gsub(t, "%f[%w][tT]%d%f[%W]", " ")
t = string.gsub(t, "^%s+", "")
t = string.gsub(t, "%s+$", "")
if t == "" or #t > 40 or hasDigit(t) or not hasArabic(t) then return nil end
local lt = string.lower(t)
if matches(lt, SIZE_TEXT_WORDS) then return nil end
for _, key in ipairs(RARITY_ORDER) do
if lt == string.lower(RARITIES[key].label) then return nil end
for _, w in ipairs(RARITIES[key].keys) do
if lt == string.lower(w) then return nil end
end
end
return t
end
local function textLooksDhab(raw, needHumanoidForRarity, model)
if type(raw) ~= "string" or raw == "" then return false end
local t = string.lower(stripTags(raw))
if #t > 90 then return false end
if hasDigit(t) and matches(t, SIZE_TEXT_WORDS) then return true end
if tierCode(t) then
return model ~= nil and model:FindFirstChildOfClass("Humanoid") ~= nil
end
for _, key in ipairs(RARITY_ORDER) do
for _, w in ipairs(RARITIES[key].keys) do
if string.find(t, w, 1, true) then
if needHumanoidForRarity then
return model ~= nil and model:FindFirstChildOfClass("Humanoid") ~= nil
end
return true
end
end
end
return false
end
local HUE_RARITY = { mythic = 0, legendary = 0.13, special = 0.357, rare = 0.594, epic = 0.747 }
local function colorRarity(col)
local h, sat, v = col:ToHSV()
if sat < 0.35 or v < 0.5 then return nil end
local best, bd
for key, hh in pairs(HUE_RARITY) do
local d = math.abs(h - hh)
d = math.min(d, 1 - d)
if not bd or d < bd then best, bd = key, d end
end
if bd and bd <= 0.08 then return best end
return nil
end
T.lifeInfo = setmetatable({}, { __mode = "k" })
function T.lifeCached(inst, now)
local c = T.lifeInfo[inst]
if c and now - c.t < 10 then return c.v end
local v = T.lifeLike(inst)
T.lifeInfo[inst] = { t = now - math.random() * 5, v = v }
return v
end
-- هل الموديل "كائن حي"؟ (له Humanoid أو AnimationController أو Animator أو مفاصل Motor6D أو عظام Bone)
-- الجدران والطاولات والأقفاص ما فيها هذي الأشياء
function T.lifeLike(m)
if not m:IsA("Model") then return false end
return m:FindFirstChildOfClass("Humanoid") ~= nil
or m:FindFirstChildOfClass("AnimationController") ~= nil
or m:FindFirstChildWhichIsA("Animator", true) ~= nil
or m:FindFirstChildWhichIsA("Motor6D", true) ~= nil
or m:FindFirstChildWhichIsA("Bone", true) ~= nil
end
local scanState = { list = {}, t = -100, busy = false, dirty = false }
local function getDhabMatches()
local s = scanState
local now = os.clock()
-- فحص كامل للخريطة: كل 5 ثوانٍ، أو بعد 1.5 ثانية إذا ظهر كائن جديد (بدل 2 / 0.8 سابقاً لتخفيف الحمل)
if not s.busy and (now - s.t > 8 or (s.dirty and now - s.t > 5)) then
s.busy = true
s.dirty = false
task.spawn(function()
local startT = os.clock()
local list, seen, accepted = {}, {}, {}
local vcache, bcache = {}, {}
local patterns = CONFIG.NamePatterns.dhab
local hasLearned = #T.learned > 0
local function isVehicleModel(m)
local c = vcache[m]
if c == nil then
c = false
if m:FindFirstChildWhichIsA("VehicleSeat", true) or m:FindFirstChildWhichIsA("Seat", true) then
local ok, sz = pcall(function() return m:GetExtentsSize() end)
c = not (ok and math.max(sz.X, sz.Y, sz.Z) > 80)
end
vcache[m] = c
end
return c
end
local function badChain(inst)
local m = inst:IsA("Model") and inst or inst:FindFirstAncestorOfClass("Model")
local depth = 0
while m and depth < 6 do
local c = bcache[m]
if c == nil then
c = Players:GetPlayerFromCharacter(m) ~= nil or isVehicleModel(m)
bcache[m] = c
end
if c then return true end
m = m:FindFirstAncestorOfClass("Model")
depth += 1
end
return false
end
local function consider(inst)
if seen[inst] then return end
seen[inst] = true
if T.ignore[inst.Name] then return end
if badChain(inst) then return end
local p, d = inst.Parent, 0
while p and p ~= workspace and d < 8 do
if accepted[p] then return end
p = p.Parent
d += 1
end
local ok, sz = pcall(function()
if inst:IsA("Model") then return inst:GetExtentsSize() end
return inst.Size
end)
if ok and sz and math.max(sz.X, sz.Y, sz.Z) > CONFIG.MaxDhabStuds then return end
accepted[inst] = true
list[#list + 1] = inst
end
local function modelOf(inst)
local m = inst:FindFirstAncestorOfClass("Model")
if not m then return nil end
while true do
local p = m.Parent
if p and p:IsA("Model") and (p:FindFirstChildOfClass("Humanoid") or p:FindFirstChildOfClass("AnimationController")) then m = p else break end
end
return m
end
local function pickTarget(t)
if t:IsA("BasePart") then
local pm = t:FindFirstAncestorOfClass("Model")
if pm then
local okz, sz = pcall(function() return pm:GetExtentsSize() end)
if okz and math.max(sz.X, sz.Y, sz.Z) <= CONFIG.MaxDhabStuds then return pm end
end
end
return t
end
local function labelCheck(inst)
do
local bb0 = inst:FindFirstAncestorWhichIsA("BillboardGui") or inst:FindFirstAncestorWhichIsA("SurfaceGui")
if bb0 and #inst.Text > 0 and #inst.Text <= 80 then
local tg = bb0.Adornee or bb0.Parent
if tg and tg:IsA("Attachment") then tg = tg.Parent end
if tg and tg:IsDescendantOf(workspace) then
local rec = T.billText[tg]
if not rec then rec = setmetatable({}, { __mode = "k" }) T.billText[tg] = rec end
rec[inst] = true
end
end
end
local tt = string.lower(stripTags(inst.Text))
if #tt <= 60 and ((hasDigit(tt) and matches(tt, SIZE_TEXT_WORDS)) or tierCode(tt)) then
local bb = inst:FindFirstAncestorWhichIsA("BillboardGui") or inst:FindFirstAncestorWhichIsA("SurfaceGui")
local tgt = bb and (bb.Adornee or bb.Parent) or nil
if tgt and tgt:IsA("Attachment") then tgt = tgt.Parent end
if tgt and (tgt:IsA("BasePart") or tgt:IsA("Model")) and tgt:IsDescendantOf(workspace) then
consider(pickTarget(tgt))
return
end
end
local m = modelOf(inst)
if m and not seen[m] and textLooksDhab(inst.Text, true, m) then consider(m) end
end
local ok = pcall(function()
local descendants = workspace:GetDescendants()
local metadataModels = {}
local t0 = os.clock()
for mi, d in ipairs(descendants) do
if mi % 64 == 0 and os.clock() - t0 > 0.002 then task.wait() t0 = os.clock() end
local hasMeta = false
if d:IsA("ValueBase") then
local k = string.lower(d.Name)
hasMeta = matches(k, SIZE_KEYS) or matches(k, RARITY_KEYS)
end
for k in pairs(d:GetAttributes()) do
k = string.lower(k)
if matches(k, SIZE_KEYS) or matches(k, RARITY_KEYS) then hasMeta = true break end
end
if hasMeta then
local m = d:IsA("Model") and d or d:FindFirstAncestorOfClass("Model")
while m do
metadataModels[m] = true
local parent = m.Parent
m = parent and parent:FindFirstAncestorOfClass("Model") or nil
end
end
end
for i, inst in ipairs(descendants) do
if inst:IsA("Model") then
if not Players:GetPlayerFromCharacter(inst) then
local nm = inst.Name
local hit = CollectionService:HasTag(inst, CONFIG.DhabTag)
or matches(nm, patterns) or (hasLearned and matches(nm, T.learned))
or inst:GetAttribute(CONFIG.RarityAttribute) ~= nil
or metadataModels[inst] == true
if not hit and (inst:FindFirstChildOfClass("Humanoid") or inst:FindFirstChildOfClass("AnimationController")) then hit = true end
if hit and not matches(nm, CONFIG.TraderWords) and not matches(nm, SHOP_WORDS) then consider(inst) end
end
elseif inst:IsA("BasePart") then
if not inst:FindFirstAncestorOfClass("Model")
and (matches(inst.Name, patterns) or (hasLearned and matches(inst.Name, T.learned))) then
consider(inst)
end
elseif inst:IsA("TextLabel") then
labelCheck(inst)
end
if i % 64 == 0 and os.clock() - t0 > 0.002 then task.wait() t0 = os.clock() end
end
for _, d in ipairs(playerGui:GetDescendants()) do
if d:IsA("TextLabel") and not d:IsDescendantOf(gui) then labelCheck(d) end
end
end)
if ok then
s.list = list
for k, ts in pairs(T.fast) do if ts < startT then T.fast[k] = nil end end
end
s.t, s.busy = os.clock(), false
end)
end
return s.list
end
T.fast = setmetatable({}, { __mode = "k" })
track(workspace.DescendantAdded:Connect(function(inst)
if inst:IsA("Humanoid") or inst:IsA("AnimationController") then
local m = inst.Parent
if m and m:IsA("Model") and not Players:GetPlayerFromCharacter(m) then T.fast[m] = os.clock() end
scanState.dirty = true
elseif inst:IsA("Model") then
if matches(inst.Name, CONFIG.NamePatterns.dhab) and not Players:GetPlayerFromCharacter(inst) then
T.fast[inst] = os.clock()
scanState.dirty = true
end
elseif inst:IsA("TextLabel") then
if tierCode(string.lower(stripTags(inst.Text))) then scanState.dirty = true end
end
end))
track(CollectionService:GetInstanceAddedSignal(CONFIG.DhabTag):Connect(function()
scanState.dirty = true
scanState.t = -100
end))
track(CollectionService:GetInstanceRemovedSignal(CONFIG.DhabTag):Connect(function()
scanState.dirty = true
scanState.t = -100
end))
local TYPE_KEYWORDS = { "الفرقد", "الملكي", "الذهبي", "الأسود", "الأبيض", "الأحمر", "الأزرق", "الفضي", "الناري", "الصحراوي", "الخرافي" }
local TYPE_ATTRS = { "DisplayName", "DhabName", "TypeName", "Species", "Name", "Type" }
local function cleanTypeName(raw)
if type(raw) ~= "string" then return nil end
local t = stripTags(raw):gsub("^%s+", ""):gsub("%s+$", "")
if t == "" or #t > 40 or hasDigit(t) or not hasArabic(t) then return nil end
local lt = string.lower(t)
if tierCode(lt) then return nil end
for _, w in ipairs(SIZE_TEXT_WORDS) do
if lt == w then return nil end
end
for _, key in ipairs(RARITY_ORDER) do
if lt == string.lower(RARITIES[key].label) then return nil end
for _, w in ipairs(RARITIES[key].keys) do
if lt == string.lower(w) then return nil end
end
end
return t
end
-- استخراج اسم نوع الضب (مثل: الضب الفرقد) من بيانات اللعبة نفسها: خصائص، نصوص اللوحات، ثم اسم الموديل.
-- الكلمات المعروفة تُقدَّم، وإذا ما وُجدت يؤخذ أول اسم عربي حقيقي (فلا نعتمد على قائمة ثابتة فقط).
function T.typeName(inst)
local cands = {}
local function add(raw)
local t = cleanTypeName(raw)
if t then cands[#cands + 1] = t end
end
for _, a in ipairs(TYPE_ATTRS) do add(inst:GetAttribute(a)) end
local n = 0
for _, d in ipairs(inst:GetDescendants()) do
n += 1
if n > 500 then break end
if d:IsA("TextLabel") or d:IsA("TextButton") then
add(d.Text)
elseif d:IsA("StringValue") then
add(d.Value)
end
for _, a in ipairs(TYPE_ATTRS) do add(d:GetAttribute(a)) end
end
add(inst.Name)
for _, t in ipairs(cands) do
for _, kw in ipairs(TYPE_KEYWORDS) do
if string.find(t, kw, 1, true) then return t end
end
end
return cands[1]
end
local infoCache = setmetatable({}, { __mode = "k" })
local function getInfo(inst, force)
local c = infoCache[inst]
if not force then
if c then
local fa = T.fast and T.fast[inst]
local ttl = c.rarity and ((c.specialName or c.knownName or c.labelName or c.nameText) and 5 or 1.5) or ((fa and os.clock() - fa < 8) and 0.4 or 8)
if os.clock() - c.t < ttl then return c end
end
if (T.infoBudget or 0) <= 0 then return c end
T.infoBudget -= 1
end
local cands = {}
local numTier, sizeNum
local function addText(t)
if type(t) == "string" and t ~= "" then
cands[#cands + 1] = string.lower(stripTags(t))
end
end
local function parseNumber(t)
for i = 0, 9 do t = string.gsub(t, utf8.char(0x660 + i), tostring(i)) end
local best
for n in string.gmatch(t, "[%d%.,]+") do
n = string.gsub(n, ",", "")
n = string.gsub(n, "%.+$", "")
local v = tonumber(n)
if v and (not best or v > best) then best = v end
end
return best
end
for k, v in pairs(inst:GetAttributes()) do
local lk = string.lower(k)
if type(v) == "string" then
addText(v)
if not sizeNum and matches(lk, SIZE_KEYS) then sizeNum = parseNumber(v) end
elseif type(v) == "number" then
if matches(lk, SIZE_KEYS) then sizeNum = sizeNum or v
elseif matches(lk, RARITY_KEYS) then numTier = numTier or v end
end
end
for _, ch in ipairs(inst:GetChildren()) do
if ch:IsA("ValueBase") then
local lk = string.lower(ch.Name)
local v = ch.Value
if type(v) == "string" then
addText(v)
if not sizeNum and matches(lk, SIZE_KEYS) then sizeNum = parseNumber(v) end
elseif type(v) == "number" then
if matches(lk, SIZE_KEYS) then sizeNum = sizeNum or v
elseif matches(lk, RARITY_KEYS) then numTier = numTier or v end
end
end
end
local n = 0
local nameText
local labelName
local colors = {}
for _, d in ipairs(inst:GetDescendants()) do
n += 1
if n > 500 then break end
if d:IsA("TextLabel") or d:IsA("TextButton") then
local t = stripTags(d.Text)
if t ~= "" then
addText(t)
if not labelName then labelName = T.extractName(t) end
if not sizeNum and (matches(t, SIZE_TEXT_WORDS) or matches(string.lower(d.Name), SIZE_KEYS)) then
sizeNum = parseNumber(t)
end
if not nameText and #t <= 40 and not hasDigit(t) then
local lt = string.lower(t)
local bad = tierCode(lt) ~= nil or matches(lt, SIZE_TEXT_WORDS)
or lt == "name" or lt == "dhab" or lt == "animal" or lt == "creature"
if not bad then
for _, key in ipairs(RARITY_ORDER) do
for _, w in ipairs(RARITIES[key].keys) do
if string.find(lt, w, 1, true) then bad = true end
end
end
end
if not bad then nameText = t end
end
colors[#colors + 1] = d.TextColor3
end
elseif d:IsA("Highlight") then
colors[#colors + 1] = d.FillColor
colors[#colors + 1] = d.OutlineColor
elseif d:IsA("ProximityPrompt") then
addText(d.ObjectText)
addText(d.ActionText)
end
-- بيانات بعض الضبان الجديدة تكون داخل أجزاء فرعية.
if d:IsA("ValueBase") then
local lk = string.lower(d.Name)
local v = d.Value
if type(v) == "string" then
addText(v)
if not sizeNum and matches(lk, SIZE_KEYS) then sizeNum = parseNumber(v) end
elseif type(v) == "number" then
if matches(lk, SIZE_KEYS) then sizeNum = sizeNum or v
elseif matches(lk, RARITY_KEYS) then numTier = numTier or v end
end
end
for ak, av in pairs(d:GetAttributes()) do
local lk = string.lower(ak)
if type(av) == "string" then
addText(av)
if not sizeNum and matches(lk, SIZE_KEYS) then sizeNum = parseNumber(av) end
elseif type(av) == "number" then
if matches(lk, SIZE_KEYS) then sizeNum = sizeNum or av
elseif matches(lk, RARITY_KEYS) then numTier = numTier or av end
end
end
end
do
local function addBill(t)
local rec = t and T.billText[t]
if rec then
for lb in pairs(rec) do
if lb.Parent then
local bt = stripTags(lb.Text)
addText(bt)
labelName = labelName or T.extractName(bt)
if not sizeNum and matches(bt, SIZE_TEXT_WORDS) then sizeNum = parseNumber(bt) end
end
end
end
end
addBill(inst)
if inst:IsA("Model") then
addBill(inst.PrimaryPart)
addBill(inst:FindFirstChild("HumanoidRootPart"))
addBill(inst:FindFirstChild("Head"))
end
do
local pc = 0
for _, d in ipairs(inst:GetDescendants()) do
if d:IsA("BasePart") then
pc += 1
if pc > 40 then break end
addBill(d)
end
end
end
end
addText(inst.Name)
local nameCands = {}
for i = 1, #cands do nameCands[i] = cands[i] end
local p = inst.Parent
for _ = 1, 3 do
if p and p ~= workspace then
local before = #cands
addText(p.Name)
if #cands > before and #p:GetChildren() <= 1 then nameCands[#nameCands + 1] = cands[#cands] end
p = p.Parent
end
end
local special, specialName = false, nil
for _, text in ipairs(nameCands) do
if #text <= 80 and hasArabic(text) then
local nt = T.arNorm(text)
for idx, nm in ipairs(T.specialNames) do
if string.find(nt, nm, 1, true) then special, specialName = true, T.specialDisplay[idx] break end
end
if special then break end
end
end
local knownName
if not special then
for _, text in ipairs(nameCands) do
if #text <= 80 and hasArabic(text) then
local nt = T.arNorm(text)
for idx, nm in ipairs(T.knownNames) do
if string.find(nt, nm, 1, true) then knownName = T.knownDisplay[idx] break end
end
if knownName then break end
end
end
if not knownName and T.coreMap then
for _, text in ipairs(nameCands) do
if #text <= 40 and hasArabic(text) then
local hit = T.coreMap[T.coreOf(T.arNorm(text))]
if hit then knownName = hit break end
end
end
end
end
local rarity
local textRarity = false
if sizeNum and sizeNum >= CONFIG.BigSize then rarity = "mythic" end
if not rarity then
for _, text in ipairs(cands) do
local r = tierCode(text)
if r then rarity = r textRarity = true break end
end
end
if not rarity then
for _, text in ipairs(cands) do
for _, key in ipairs(RARITY_ORDER) do
for _, w in ipairs(RARITIES[key].keys) do
if string.find(text, w, 1, true) then rarity = key textRarity = true break end
end
if rarity then break end
end
if rarity then break end
end
end
if not rarity and numTier then
rarity = RARITY_BY_NUMBER[math.floor(numTier)]
if rarity then textRarity = true end
end
if not rarity then
for _, col in ipairs(colors) do
local r = colorRarity(col)
if r then rarity = r break end
end
end
-- الدليل: وسم/اسم ضب، أو نص ندرة صريح، أو كائن حي عليه بيانات ندرة/حجم. أي كائن بلا ندرة معروفة يُتجاهل.
local creature = T.lifeLike(inst)
local named = CollectionService:HasTag(inst, CONFIG.DhabTag)
or (matches(inst.Name, CONFIG.NamePatterns.dhab) and not matches(inst.Name, SHOP_WORDS))
or (#T.learned > 0 and matches(inst.Name, T.learned))
local metadata = sizeNum ~= nil or numTier ~= nil
-- ضب فقط: وسم/اسم ضب، أو اسم أبيه ضب، أو اسم ضب معروف، أو كلمة ضب في نصوصه. غير كذا (سيارة/لاعب/حيوان) يُستبعد
local dhabWord = false
local notDhab = false
do
-- أي شي داخل شخصية لاعب (حتى الضب اللي يشيله) أو عامل/تاجر/حارس = مو علامة ضب
local anc = inst
for _ = 1, 8 do
if not anc or anc == workspace or anc == game then break end
if anc:IsA("Model") and Players:GetPlayerFromCharacter(anc) then notDhab = true break end
anc = anc.Parent
end
if not notDhab then
-- أي كائن له مالك (كلب/صقر/حيوان أليف للاعب) مو ضب
for k in pairs(inst:GetAttributes()) do
local lk = string.lower(k)
if string.find(lk, "owner", 1, true) or string.find(lk, "userid", 1, true) or string.find(lk, "playerid", 1, true) then notDhab = true break end
end
end
if not notDhab then
local bad = { "عامل", "عمال", "عاملة", "worker", "تاجر", "trader", "merchant", "شيخ", "حارس", "guard", "بائع", "seller", "npc_", "villager", "كلب", "صقر", "dog", "falcon", "hawk", "eagle", "bird", "طير", "حمام" }
for _, text in ipairs(nameCands) do
if #text <= 80 then
local lt = string.lower(T.arNorm(text))
for _, w in ipairs(bad) do
if string.find(lt, T.arNorm(w), 1, true) then notDhab = true break end
end
if notDhab then break end
end
end
end
if not notDhab then
local vm = inst:IsA("Model") and inst or inst:FindFirstAncestorOfClass("Model")
for _ = 1, 3 do
if not vm then break end
if vm:FindFirstChildWhichIsA("VehicleSeat", true) or vm:FindFirstChildWhichIsA("Seat", true) then
local okv, vsz = pcall(function() return vm:GetExtentsSize() end)
if okv and math.max(vsz.X, vsz.Y, vsz.Z) <= 80 then notDhab = true break end
end
vm = vm.Parent and vm.Parent:IsA("Model") and vm.Parent or nil
end
end
if not notDhab and CollectionService:HasTag(inst, CONFIG.VehicleTag) then notDhab = true end
if not notDhab then
local rp = inst:IsA("BasePart") and inst or (inst:IsA("Model") and (inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)) or nil)
if rp then
local okc, parts = pcall(function() return rp:GetConnectedParts(true) end)
if okc and parts then
for i, pt in ipairs(parts) do
if i > 80 then break end
if pt:IsA("VehicleSeat") or pt:IsA("Seat") then notDhab = true break end
end
end
end
end
end
local evidence = (named or special or knownName ~= nil or dhabWord) and not notDhab
if sizeNum and sizeNum >= CONFIG.BigSize then rarity = "mythic" end
if special then rarity = "rainbow" end
local sizeText
if sizeNum then
sizeText = (math.floor(sizeNum + 0.5) == sizeNum) and tostring(sizeNum) or string.format("%.1f", sizeNum)
else
local ok, sz = pcall(function()
if inst:IsA("Model") then return inst:GetExtentsSize() end
return inst.Size
end)
sizeText = (ok and sz) and string.format("%.1f", math.max(sz.X, sz.Y, sz.Z)) or "?"
end
c = { t = os.clock() - math.random() * 2, specialName = specialName, knownName = knownName, labelName = labelName, creature = (creature == true), rarity = rarity, sizeNum = sizeNum, sizeText = sizeText, nameText = nameText, evidence = evidence, typeName = (rarity ~= nil) and T.typeName(inst) or nil }
infoCache[inst] = c
return c
end
function T.realName(t)
if t and T.coreOf(T.arNorm(t)) ~= "" then return t end
return nil
end
function T.computeTypeName(e, info)
local realName = T.realName
return info.specialName or realName(T.extractName(e.name)) or realName(T.extractName(e.inst.Name)) or info.knownName or realName(info.labelName) or realName(info.typeName)
end
local function applyDhabInfo(e)
if e.rarity then
-- الاسم يتجدد: إذا ما عُرف بعد، نعيد القراءة كل ثانية ونصف حتى يظهر
if not e.typeName and (not e.nameT or os.clock() - e.nameT > 1.5) then
e.nameT = os.clock()
local info2 = getInfo(e.inst)
if info2 then
e.typeName = T.computeTypeName(e, info2)
if not e.dispName then
local cn = e.inst:GetAttribute(CONFIG.NameAttribute)
e.dispName = (typeof(cn) == "string" and cn ~= "") and cn or info2.nameText or nil
end
end
end
return
end
local info = getInfo(e.inst)
if not info then
e.skip = true
return
end
local r = T.rbn[e.name] or T.rbn[e.inst.Name] or info.rarity
e.evidence = info.evidence
e.creature = info.creature
if info.sizeNum and info.sizeNum >= CONFIG.BigSize and r ~= "rainbow" then r = "mythic" end
if not r or not RARITIES[r] then
e.skip = true
return
end
e.skip = false
e.rarity = r
e.hasSize = info.sizeNum ~= nil
local customName = e.inst:GetAttribute(CONFIG.NameAttribute)
e.dispName = (typeof(customName) == "string" and customName ~= "") and customName
or info.nameText or ((e.name and e.name ~= "") and e.name or nil)
e.color = RARITIES[r].color
e.rarityLabel = RARITIES[r].label
e.sizeText = info.sizeText
e.typeName = T.computeTypeName(e, info)
e.big = info.sizeNum ~= nil and info.sizeNum >= CONFIG.BigSize
end
local function dumpInfo(inst)
local lines = { "الاسم: " .. inst.Name .. " (" .. inst.ClassName .. ")" }
local chain, p = {}, inst.Parent
for _ = 1, 4 do
if p and p ~= workspace then
table.insert(chain, p.Name)
p = p.Parent
end
end
if #chain > 0 then lines[#lines + 1] = "داخل: " .. table.concat(chain, " < ") end
for k, v in pairs(inst:GetAttributes()) do
lines[#lines + 1] = "خاصية " .. k .. " = " .. tostring(v)
end
local n = 0
for _, ch in ipairs(inst:GetChildren()) do
if ch:IsA("ValueBase") then
n += 1
if n <= 10 then lines[#lines + 1] = "قيمة " .. ch.Name .. " = " .. tostring(ch.Value) end
end
end
n = 0
for _, d in ipairs(inst:GetDescendants()) do
if d:IsA("TextLabel") and d.Text ~= "" then
n += 1
if n <= 10 then lines[#lines + 1] = "نص: " .. stripTags(d.Text) end
end
end
n = 0
for _, d in ipairs(inst:GetDescendants()) do
if d:IsA("TextLabel") and d.Text ~= "" then
n += 1
if n <= 6 then
local c3 = d.TextColor3
lines[#lines + 1] = string.format("لون النص %d: %d,%d,%d", n, math.floor(c3.R * 255 + 0.5), math.floor(c3.G * 255 + 0.5), math.floor(c3.B * 255 + 0.5))
end
end
end
lines[#lines + 1] = "اسم معتمد: " .. ((#T.learned > 0 and matches(inst.Name, T.learned)) and "نعم" or "لا")
local info = getInfo(inst, true)
lines[#lines + 1] = "النتيجة: " .. (info.rarity and RARITIES[info.rarity].label or "-") .. " | الحجم " .. tostring(info.sizeText) .. " | دليل: " .. tostring(info.evidence)
return table.concat(lines, "\n")
end
function T.isDeadRaw(inst)
if not inst or not inst.Parent then return true end
if not inst:IsA("Model") then return false end
local hum = inst:FindFirstChildOfClass("Humanoid")
if hum and hum.MaxHealth > 0 and (hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead) then return true end
for _, a in ipairs({ "Dead", "IsDead", "Died", "dead", "isDead" }) do
if inst:GetAttribute(a) == true then return true end
end
for _, a in ipairs({ "Health", "HP", "health", "hp" }) do
local v = inst:GetAttribute(a)
if type(v) == "number" and v <= 0 then return true end
end
return false
end
T.deadCache = setmetatable({}, { __mode = "k" })
function T.isDead(inst)
if not inst or not inst.Parent then return true end
local now = os.clock()
local c = T.deadCache[inst]
if c and now - c.t < 0.4 then return c.v end
local v = T.isDeadRaw(inst)
T.deadCache[inst] = { t = now, v = v }
return v
end
function T.collectDhabRaw()
local result, seen, rootSeen = {}, {}, {}
-- استبعاد كل ما يخص شخصيتي وسيارتي (المصدر المحتمل للعلامات حول السيارة أثناء القيادة)
local char = getCharacter()
local hum = getHumanoid()
local seat = hum and hum.SeatPart
local mineAsm = seat and seat.AssemblyRootPart or nil
local mineModel
if seat then
mineModel = seat:FindFirstAncestorOfClass("Model")
while mineModel and mineModel.Parent and mineModel.Parent:IsA("Model") do mineModel = mineModel.Parent end
end
local function consider(inst)
if seen[inst] then return end
seen[inst] = true
if T.ignore[inst.Name] then return end
if T.isDead(inst) then return end
if inst:IsDescendantOf(workspace) and inst:GetAttribute(CONFIG.HideAttribute) ~= true then
if char and (inst == char or inst:IsDescendantOf(char)) then return end
if mineModel and (inst == mineModel or inst:IsDescendantOf(mineModel)) then return end
local root = getBasePart(inst)
if root and root.Parent and not rootSeen[root] and not (mineAsm and root.AssemblyRootPart == mineAsm) then
rootSeen[root] = true
local custom = inst:GetAttribute(CONFIG.NameAttribute)
table.insert(result, {
inst = inst, root = root,
name = (typeof(custom) == "string" and custom ~= "") and custom or inst.Name,
})
end
end
end
for _, inst in ipairs(CollectionService:GetTagged(CONFIG.DhabTag)) do consider(inst) end
for _, inst in ipairs(getDhabMatches()) do consider(inst) end
for inst in pairs(T.fast) do
if inst.Parent then consider(inst) else T.fast[inst] = nil end
end
return result, "لا ضبان"
end
T.dhabCache = { t = -100 }
local function collectDhab()
local now = os.clock()
local hum0 = getHumanoid()
local seat0 = hum0 and hum0.SeatPart or nil
local c = T.dhabCache
if c.v and now - c.t < 0.1 and c.seat == seat0 and c.char == getCharacter() then return c.v, "لا ضبان" end
local res = T.collectDhabRaw()
c.t, c.v, c.seat, c.char = now, res, seat0, getCharacter()
return res, "لا ضبان"
end
local function collectPlayers()
local result = {}
for _, plr in ipairs(Players:GetPlayers()) do
if plr ~= player and plr:GetAttribute(CONFIG.HideAttribute) ~= true then
local char = plr.Character
local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or char:FindFirstChild("Head"))
if root and root:IsA("BasePart") then
table.insert(result, { inst = plr, root = root, name = plr.DisplayName, color = Color3.fromRGB(120, 255, 160) })
end
end
end
return result, "لا لاعبين"
end
local function matchPlace(inst, words)
if not (inst:IsA("Model") or inst:IsA("BasePart")) then return false end
if not matches(inst.Name, words) then return false end
if Players:GetPlayerFromCharacter(inst) then return false end
local pm = inst:FindFirstAncestorOfClass("Model")
if pm then
if inst:IsA("BasePart") then return false end
if matches(pm.Name, words) or Players:GetPlayerFromCharacter(pm) then return false end
end
return true
end
local function makeScanner(matcher)
local s = { list = {}, t = -100, busy = false }
local function get()
if not s.busy and os.clock() - s.t > 8 then
s.busy = true
task.spawn(function()
local list = {}
local ok = pcall(function()
for i, inst in ipairs(workspace:GetDescendants()) do
if matcher(inst) then list[#list + 1] = inst end
if i % 1500 == 0 then task.wait() end
end
end)
if ok then s.list = list end
s.t, s.busy = os.clock(), false
end)
end
return s.list
end
return get, s
end
local traderGet, traderScan = makeScanner(function(inst) return matchPlace(inst, CONFIG.TraderWords) end)
local PLACE_WORDS = {}
for _, w in ipairs(CONFIG.VillageWords) do table.insert(PLACE_WORDS, w) end
for _, w in ipairs(CONFIG.CampWords) do table.insert(PLACE_WORDS, w) end
local villageGet, villageScan = makeScanner(function(inst) return matchPlace(inst, PLACE_WORDS) end)
local carGet, carScan = makeScanner(function(inst) return inst:IsA("VehicleSeat") end)
local function buildCollector(getList, tag, color, hint, mapFn)
return function()
local result, seen = {}, {}
local function consider(inst)
if mapFn then inst = mapFn(inst) end
if not inst or seen[inst] then return end
seen[inst] = true
if inst:IsDescendantOf(workspace) and inst:GetAttribute(CONFIG.HideAttribute) ~= true then
local root = getBasePart(inst)
if root then
local custom = inst:GetAttribute(CONFIG.NameAttribute)
table.insert(result, {
inst = inst, root = root, color = color,
name = (typeof(custom) == "string" and custom ~= "") and custom or inst.Name,
})
end
end
end
if tag then
for _, inst in ipairs(CollectionService:GetTagged(tag)) do consider(inst) end
end
for _, inst in ipairs(getList()) do consider(inst) end
return result, hint
end
end
local function carMap(inst)
local hum = getHumanoid()
local mySeat = hum and hum.SeatPart
local model = inst:IsA("VehicleSeat") and (inst:FindFirstAncestorOfClass("Model") or inst) or inst
if mySeat and (model == mySeat or model:IsAncestorOf(mySeat)) then return nil end
return model
end
-- ===== شيخ النفود: كشف + رادار خاص + تنبيه الرسبنة =====
T.sk = { alert = true, waiting = false, present = nil, lastAlert = -100, busy = false }
do
local function sheikhName(s)
local l = string.lower(tostring(s))
if not (string.find(l, "شيخ", 1, true) or string.find(l, "sheik", 1, true) or string.find(l, "shaik", 1, true)) then return false end
local n = string.gsub(l, "[%s_%-%.]+", "")
if string.find(n, "شيخالنفود", 1, true) or string.find(n, "شيخنفود", 1, true) or string.find(n, "شيخالنفوذ", 1, true) then return true end
local a = string.find(n, "sheikh", 1, true) or string.find(n, "shaikh", 1, true) or string.find(n, "sheik", 1, true) or string.find(n, "شيخ", 1, true)
local b = string.find(n, "nafud", 1, true) or string.find(n, "nufud", 1, true) or string.find(n, "nafoud", 1, true) or string.find(n, "نفود", 1, true) or string.find(n, "نفوذ", 1, true)
return a ~= nil and b ~= nil
end
T.sheikhName = sheikhName
-- يحوّل أي عنصر مطابق (مجسم / جزء / نص / زر تفاعل) إلى المجسم الحقيقي للشيخ
local function sheikhTarget(inst)
if inst:IsA("Model") then
if Players:GetPlayerFromCharacter(inst) then return nil end
return inst
end
local hum, small
local m, depth = inst:FindFirstAncestorOfClass("Model"), 0
while m and depth < 6 do
if Players:GetPlayerFromCharacter(m) then return nil end
if not hum and m:FindFirstChildOfClass("Humanoid") then hum = m end
if not small then
local ok, sz = pcall(function() return m:GetExtentsSize() end)
if ok and math.max(sz.X, sz.Y, sz.Z) <= 40 then small = m end
end
m = m:FindFirstAncestorOfClass("Model")
depth += 1
end
local t = hum or small
if t then return t end
if inst:IsA("BasePart") then return inst end
return inst:FindFirstAncestorWhichIsA("BasePart")
end
local function matcher(inst)
if inst:IsA("BasePart") or inst:IsA("Model") then
return sheikhName(inst.Name)
elseif inst:IsA("TextLabel") then
local t = inst.Text
return t ~= "" and #t < 80 and sheikhName(stripTags(t))
elseif inst:IsA("ProximityPrompt") then
return sheikhName(inst.ObjectText)
end
return false
end
T.sheikhGet, T.sheikhScan = makeScanner(matcher)
function T.notSheikh(inst)
if sheikhName(inst.Name) then return nil end
return inst
end
function T.collectSheikh()
local result, seen = {}, {}
for _, inst in ipairs(T.sheikhGet()) do
local tg = inst.Parent and sheikhTarget(inst)
if tg and not seen[tg] and tg:IsDescendantOf(workspace) and tg:GetAttribute(CONFIG.HideAttribute) ~= true then
seen[tg] = true
local root = getBasePart(tg)
if root then
result[#result + 1] = { inst = tg, root = root, color = Color3.fromRGB(255, 120, 220), name = "شيخ النفود" }
end
end
end
return result, "ما رسبن"
end
-- مراقب الرسبنة: يرسل رسالة لما يظهر الشيخ، ويحفظ آخر مكان له، ويبقي منطقته محمّلة لرادار بعيد
function T.startSheikhWatch()
task.spawn(function()
while gui.Parent do
local sk = T.sk
if sk.alert or sk.waiting or (T.sheikhRadar and T.sheikhRadar.enabled) then
pcall(function()
local list = T.collectSheikh()
local present = #list > 0
if present then T.places.sheikh = list[1].root.Position end
if sk.present ~= nil and present and not sk.present and os.clock() - sk.lastAlert > 20 then
sk.lastAlert, sk.waiting = os.clock(), false
notify("شيخ النفود رسبن ويمكنك التنقل إليه", "force")
end
sk.present = present
local pos = T.places.sheikh
if pos and (sk.waiting or (T.sheikhRadar and T.sheikhRadar.enabled)) then
local okS, st = pcall(function() return workspace.StreamingEnabled end)
if okS and st == true then
task.spawn(function() pcall(function() player:RequestStreamAroundAsync(pos, 1.5) end) end)
end
end
end)
end
task.wait(5)
end
end)
end
end
local collectTrader = buildCollector(traderGet, CONFIG.TraderTag, Color3.fromRGB(255, 210, 90), "لا تاجر", T.notSheikh)
local collectCars = buildCollector(carGet, CONFIG.VehicleTag, Color3.fromRGB(90, 220, 255), "لا سيارات", carMap)
local collectVillage = buildCollector(villageGet, nil, Color3.fromRGB(255, 170, 60), "لا أماكن")
local radars = {
{ key = "dhab", short = "الضبان", title = "رادار الضبان", hasRarity = true, collect = collectDhab },
{ key = "players", short = "اللاعبون", title = "كشف اللاعبين", collect = collectPlayers },
{ key = "cars", short = "السيارات", title = "كشف السيارات", collect = collectCars },
{ key = "trader", short = "تاجر الخلا", title = "كشف تاجر الخلا", collect = collectTrader },
{ key = "sheikh", short = "شيخ النفود", title = "رادار شيخ النفود", collect = T.collectSheikh, fixedRange = 100000 },
}
local dhabRadar, playersRadar, carsRadar, traderRadar = radars[1], radars[2], radars[3], radars[4]
T.sheikhRadar = radars[5]
local function resetRadarState(radar)
radar.enabled = false
radar.markers = true
radar.visible = {}
radar.rarityFilter = false
radar.rarityPick = "all"
radar.rarities = {}
radar.pickOn = false
radar.pickName = ""
end
for _, radar in ipairs(radars) do
radar.markerMap = {}
resetRadarState(radar)
end
local function passFilters(radar, e)
if radar.rarityFilter and radar.rarities and next(radar.rarities) ~= nil and not radar.rarities[e.rarity] then return false end
if radar.pickOn and radar.pickName ~= "" and e.name ~= radar.pickName then return false end
return true
end
local function dhabNameOptions()
local opts = { { key = "", label = "كل الأسماء" } }
local names, arr = {}, {}
for _, e in ipairs(collectDhab()) do
if not names[e.name] then
names[e.name] = true
applyDhabInfo(e)
if not e.skip then
T.nameInfo[e.name] = { color = e.color }
arr[#arr + 1] = { key = e.name, label = e.name, color = e.color }
end
end
end
table.sort(arr, function(a, b) return a.label < b.label end)
for _, o in ipairs(arr) do opts[#opts + 1] = o end
return opts
end
local entryColor, clearMarkers, clearRadar, updateRadar
do
local ARROWS = { "↑", "↗", "→", "↘", "↓", "↙", "←", "↖" }
local function directionArrow(fwd, right, from, to)
local delta = to - from
local flat = Vector3.new(delta.X, 0, delta.Z)
if flat.Magnitude < 2 then return "•" end
local angle = math.deg(math.atan2(flat:Dot(right), flat:Dot(fwd)))
return ARROWS[math.floor((angle + 22.5) / 45) % 8 + 1]
end
local function cameraBasis()
local cam = workspace.CurrentCamera
local fwd = Vector3.new(0, 0, -1)
if cam then
local look = cam.CFrame.LookVector
local flat = Vector3.new(look.X, 0, look.Z)
if flat.Magnitude > 1e-3 then fwd = flat.Unit end
end
return fwd, fwd:Cross(Vector3.yAxis)
end
function entryColor(e)
if e.rarity == "rainbow" then return Color3.fromHSV((os.clock() * 0.5) % 1, 0.8, 1) end
return e.color or Color3.new(1, 1, 1)
end
local function esc(str)
return (tostring(str):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end
function clearMarkers(radar)
for inst, m in pairs(radar.markerMap) do
m.gui:Destroy()
radar.markerMap[inst] = nil
end
end
function clearRadar(radar)
clearMarkers(radar)
radar.visible = {}
if radar.status then radar.status.Text = radar.short .. ": متوقف" end
end
-- الوزن الحقيقي بالكيلو (منقول من السكربت القديم)
T.factsCache = setmetatable({}, { __mode = "k" })
function T.kgFromText(raw)
if type(raw) ~= "string" or raw == "" then return nil end
local t = string.lower(stripTags(raw))
for i = 0, 9 do t = string.gsub(t, utf8.char(0x660 + i), tostring(i)) end
local n
for _, w in ipairs({ "كجم", "كغم", "كيلو", "kg" }) do
local a, b = string.find(t, w, 1, true)
if a then
local after = string.match(string.sub(t, b + 1), "^[%s:%-=]*(%d[%d%.,]*)")
local before = string.match(string.sub(t, 1, a - 1), "(%d[%d%.,]*)%s*$")
local pick = after or before
if pick then
n = tonumber((string.gsub(pick, ",", "")))
if n then break end
end
end
end
if n and n > 0 then return n end
return nil
end
function T.fmtKg(v)
if v >= 10 then return tostring(math.floor(v + 0.5)) end
return (string.gsub(string.format("%.1f", v), "%.0$", ""))
end
function T.dhabFacts(inst, root)
local now = os.clock()
local c = T.factsCache[inst]
if c and now - c.t < 3 then return c end
local arabic, kg
local function kgName(lk)
if string.find(lk, "ref", 1, true) or string.find(lk, "max", 1, true) or string.find(lk, "min", 1, true) or string.find(lk, "base", 1, true) then return false end
return lk == "kg" or string.find(lk, "kg", 1, true) ~= nil or string.find(lk, "weight", 1, true) ~= nil
or string.find(lk, "mass", 1, true) ~= nil or string.find(lk, "وزن", 1, true) ~= nil or string.find(lk, "كجم", 1, true) ~= nil
end
local function scan(o)
for k, v in pairs(o:GetAttributes()) do
local lk = string.lower(k)
if not kg and kgName(lk) then
if type(v) == "number" and v > 0 then kg = v
elseif type(v) == "string" then kg = T.kgFromText(v) or tonumber((string.gsub(v, ",", ""))) end
end
if lk == "arabic" and not arabic and type(v) == "string" and v ~= "" and #v <= 40 and hasArabic(v) then arabic = v end
end
if o:IsA("StringValue") and string.lower(o.Name) == "arabic" and not arabic then
local v = o.Value
if v ~= "" and #v <= 40 and hasArabic(v) then arabic = v end
elseif (o:IsA("NumberValue") or o:IsA("IntValue")) and kgName(string.lower(o.Name)) and not kg and o.Value > 0 then
kg = o.Value
elseif o:IsA("StringValue") and kgName(string.lower(o.Name)) and not kg then
kg = T.kgFromText(o.Value) or tonumber((string.gsub(o.Value, ",", "")))
elseif (o:IsA("TextLabel") or o:IsA("TextButton")) and not kg then
kg = T.kgFromText(o.Text)
end
end
scan(inst)
if root and root ~= inst then scan(root) end
do
local p = inst.Parent
for _ = 1, 3 do
if p and p ~= workspace and p ~= game then
for k, v in pairs(p:GetAttributes()) do
if not kg and kgName(string.lower(k)) and type(v) == "number" and v > 0 then kg = v end
end
p = p.Parent
end
end
end
local n = 0
for _, d in ipairs(inst:GetDescendants()) do
n = n + 1
if n > 300 then break end
scan(d)
if arabic and kg then break end
end
if not kg then
local function bill(t)
local rec = t and T.billText[t]
if rec then
for lb in pairs(rec) do
if lb.Parent and not kg then kg = T.kgFromText(lb.Text) end
end
end
end
bill(inst)
bill(root)
if inst:IsA("Model") then
bill(inst.PrimaryPart)
bill(inst:FindFirstChild("HumanoidRootPart"))
bill(inst:FindFirstChild("Head"))
end
local pc = 0
for _, d in ipairs(inst:GetDescendants()) do
if d:IsA("BasePart") then
pc += 1
if pc > 40 then break end
bill(d)
end
end
end
c = { t = now, arabic = arabic, kg = kg }
T.factsCache[inst] = c
return c
end
local function createMarker(radar, adornee)
local bw, bh = T.markerBox()
local bb = make("BillboardGui", {
Name = radar.key, Size = UDim2.fromOffset(bw, bh), StudsOffset = Vector3.new(0, 3, 0),
AlwaysOnTop = true, Adornee = adornee, MaxDistance = math.huge,
}, markerFolder)
local label = make("TextLabel", {
Name = "KeepColor", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
TextColor3 = Color3.new(1, 1, 1), TextSize = state.hudSize, Font = FONT, TextWrapped = false,
RichText = true, TextStrokeTransparency = 0.25, TextStrokeColor3 = Color3.new(0, 0, 0),
}, bb)
return { gui = bb, label = label }
end
T.ghosts = {}
function T.ghostStep(radar, entries, visible, origin, fwd, right, now, limit)
local G = T.ghosts
local n0 = #visible
for i = 1, n0 do
local e = visible[i]
if not e.ghost then
local g = G[e.inst]
if not g then g = {} G[e.inst] = g end
g.e, g.pos, g.last = e, e.root.Position, now
g.dead = T.isDead(e.inst)
end
end
for inst, g in pairs(G) do
local gone = not inst:IsDescendantOf(workspace)
if not gone then
if g.dead then G[inst] = nil end
else
local drop = g.dead or now - g.last > 60 or (g.pos - origin).Magnitude < 100
if not drop then
for i = 1, n0 do
local e = visible[i]
if not e.ghost and e.name == g.e.name and (e.root.Position - g.pos).Magnitude < 150 then drop = true break end
end
end
if drop then
if g.part then g.part:Destroy() end
G[inst] = nil
else
if not g.part then
local pt = Instance.new("Part")
pt.Anchored, pt.CanCollide, pt.CanQuery, pt.CanTouch = true, false, false, false
pt.Transparency, pt.Size, pt.Position = 1, Vector3.new(1, 1, 1), g.pos
pt.Parent = workspace
g.part = pt
local ge = table.clone(g.e)
ge.ghost, ge.inst, ge.root = true, pt, pt
g.ge = ge
end
local ge = g.ge
ge.distance = (g.pos - origin).Magnitude
if ge.distance <= limit and passFilters(radar, ge) then
ge.arrow = directionArrow(fwd, right, origin, g.pos)
visible[#visible + 1] = ge
end
end
end
end
end
function T.nextGhostPos()
local list = {}
for _, g in pairs(T.ghosts) do
if g.part then list[#list + 1] = g.pos end
end
if #list == 0 then return nil end
T.gi = (T.gi or 0) + 1
return list[(T.gi % #list) + 1]
end
function updateRadar(radar)
local myRoot = getRootPart()
if not myRoot then
radar.status.Text = radar.short .. ": بانتظار الشخصية"
radar.visible = {}
clearMarkers(radar)
return
end
if radar.hasRarity then T.infoBudget = 80 end
local entries, hint = radar.collect()
-- تدوير نقطة البداية كل دورة حتى لا يتجوّع أي كائن (الميزانية محدودة)
if radar.hasRarity and #entries > 1 then
local n = #entries
T.rr = ((T.rr or 0) + 17) % n
local re = table.create(n)
for k = 1, n do re[k] = entries[(k + T.rr - 1) % n + 1] end
entries = re
end
local fwd, right = cameraBasis()
local limit = state.range
if radar.hasRarity then limit = math.min(limit, T.DHAB_HIDE) end
if radar.fixedRange then limit = radar.fixedRange end
local origin = myRoot.Position
local now = os.clock()
local visible = {}
for _, e in ipairs(entries) do
local d = (e.root.Position - origin).Magnitude
-- هستيريسز: الهدف الظاهر حالياً يبقى حتى يتجاوز المدى بـ 40 م لمنع الوميض عند الحافة
local lim = (radar.markerMap[e.inst] and not radar.hasRarity) and (limit + 40) or limit
if d <= lim then
if radar.hasRarity then
T.updateMove(e, now)
-- الجامد غير الحي (جدار/طاولة/قفص) ما يستاهل فحص ثقيل
if T.lifeCached(e.inst, now) or T.isMoving(e, now) then
applyDhabInfo(e)
else
e.skip = true
end
if not e.skip then T.nameInfo[e.name] = { color = e.color } end
end
local showIt = true
if radar.hasRarity and (e.skip or (not e.evidence) or (not e.creature and not T.isMoving(e, now))) then showIt = false end
if showIt and radar.hasRarity and d < 30 then
local mv = myRoot.AssemblyLinearVelocity
if mv.Magnitude > 8 and (e.root.AssemblyLinearVelocity - mv).Magnitude < 12 then showIt = false end
end
if showIt and passFilters(radar, e) then
e.distance = d
e.arrow = directionArrow(fwd, right, origin, e.root.Position)
table.insert(visible, e)
end
end
end
if radar.hasRarity then T.ghostStep(radar, entries, visible, origin, fwd, right, now, limit) end
table.sort(visible, function(a, b) return a.distance < b.distance end)
radar.visible = visible
if #entries == 0 then
radar.status.Text = radar.short .. ": " .. (hint or "لا أهداف")
else
local n = visible[1]
if n then
radar.status.Text = ("%s: %d  •  الأقرب %d م %s"):format(radar.short, #visible, math.floor(n.distance + 0.5), n.arrow)
else
radar.status.Text = radar.short .. ": لا أهداف بالمدى"
end
end
local alive = {}
if radar.markers and state.espOn then
local bw, bh = T.markerBox()
for i, e in ipairs(visible) do
if i > CONFIG.MaxMarkers then break end
alive[e.inst] = true
local m = radar.markerMap[e.inst]
if not m or not m.gui.Parent then
m = createMarker(radar, e.root)
radar.markerMap[e.inst] = m
end
m.last = now
if m.gui.Adornee ~= e.root then m.gui.Adornee = e.root end
m.entry = e
local dist = math.floor(e.distance + 0.5)
local txt
if e.rarity then
local sz
do
local okK, facts = pcall(T.dhabFacts, e.inst, e.root)
local kg = okK and facts and facts.kg or nil
if kg then e.kgVal = kg end
if e.kgVal then sz = T.fmtKg(e.kgVal)
elseif e.hasSize and e.sizeText and e.sizeText ~= "?" then sz = esc(e.sizeText) end
end
if sz and e.big then sz = '<font color="#FF9628">' .. sz .. "</font>" end
local line2 = sz and ("حجم " .. sz .. " . " .. dist) or ("المسافة " .. dist)
local nmSrc = e.typeName or e.dispName
local nm = (nmSrc and hasArabic(nmSrc)) and esc(nmSrc) or nil
txt = (nm or e.rarityLabel) .. "\n" .. line2
else
txt = ("%s · %d م"):format(esc(e.name), dist)
end
if m.label.Text ~= txt and (not m.txtT or now - m.txtT > 0.08) then
m.label.Text = txt
m.txtT = now
end
m.label.TextColor3 = entryColor(e)
if m.label.TextSize ~= state.hudSize then
m.label.TextSize = state.hudSize
m.gui.Size = UDim2.fromOffset(bw, bh)
end
end
end
for inst, m in pairs(radar.markerMap) do
if not alive[inst] then
local ad = m.gui.Adornee
if not ad or not ad.Parent or not m.last or now - m.last > 2 or (m.entry and T.isDead(m.entry.inst)) then
m.gui:Destroy()
radar.markerMap[inst] = nil
end
end
end
end
end
local function applyHudSize()
local bw, bh = T.markerBox()
for _, radar in ipairs(radars) do
for _, m in pairs(radar.markerMap) do
m.label.TextSize = state.hudSize
m.gui.Size = UDim2.fromOffset(bw, bh)
end
end
end
local drawHud
do
local tracerLines = {}
local function getTracer(i)
local f = tracerLines[i]
if not f then
f = make("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, Visible = false, ZIndex = 2000,
BackgroundTransparency = 0,
}, tracerGui)
tracerLines[i] = f
end
return f
end
function drawHud()
local rc = Color3.fromHSV((os.clock() * 0.5) % 1, 0.8, 1)
for dot in pairs(T.rainbow) do
if dot.Parent then dot.BackgroundColor3 = rc else T.rainbow[dot] = nil end
end
for _, m in pairs(dhabRadar.markerMap) do
if m.entry and m.entry.rarity == "rainbow" then m.label.TextColor3 = rc end
end
end
local fovCircle = make("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0,
Visible = false, ZIndex = 3000,
}, tracerGui)
make("UICorner", { CornerRadius = UDim.new(0.5, 0) }, fovCircle)
addStroke(fovCircle, Color3.new(1, 1, 1), 1.5, 0.15)
-- مركز الضب الفعلي: حدود الأجزاء المرئية فقط (بدون أجزاء شفافة أو مجسّات ضخمة)، ويُحدَّث كل ثانية كإزاحة عن الجذر
local centerCache = setmetatable({}, { __mode = "k" })
local function entryCenter(e)
local root = e.root
if not e.inst:IsA("Model") then return root.Position end
local c = centerCache[e.inst]
local now = os.clock()
if (not c or now - c.t > 0.5) and (T.centerBudget or 0) > 0 then
T.centerBudget -= 1
local lo, hi
for _, d in ipairs(e.inst:GetDescendants()) do
if d:IsA("BasePart") and d.Transparency < 0.9 then
local sz = d.Size
if math.max(sz.X, sz.Y, sz.Z) < 60 then
local pos = d.Position
lo = lo and Vector3.new(math.min(lo.X, pos.X), math.min(lo.Y, pos.Y), math.min(lo.Z, pos.Z)) or pos
hi = hi and Vector3.new(math.max(hi.X, pos.X), math.max(hi.Y, pos.Y), math.max(hi.Z, pos.Z)) or pos
end
end
end
local off = Vector3.zero
if lo and hi then off = (lo + hi) / 2 - root.Position end
c = { t = now, off = off }
centerCache[e.inst] = c
end
if not c then return root.Position end
return root.Position + c.off
end
local function drawTracers()
local used = 0
T.centerBudget = 30
local cam = workspace.CurrentCamera
local vp = tracerGui.AbsoluteSize
if cam and vp.X <= 0 then vp = cam.ViewportSize end
local showCircle = state.aimOn and state.fovCircle
fovCircle.Visible = showCircle == true
if showCircle then
local r = state.aimCircle
fovCircle.Size = UDim2.fromOffset(r * 2, r * 2)
fovCircle.Position = UDim2.fromOffset(vp.X / 2, vp.Y / 2)
end
if cam and state.espOn and state.tracersOn and dhabRadar.enabled then
-- الحساب كله بإحداثيات الكاميرا ثم يُحوَّل لإحداثيات الواجهة بنسبة المقاسين فلا تنزاح الخطوط
local cv = cam.ViewportSize
local kx, ky = vp.X / cv.X, vp.Y / cv.Y
local center = cv / 2
local m = 2
local origin = Vector2.new(cv.X / 2, cv.Y)
local o = Vector2.new(origin.X * kx, origin.Y * ky)
for _, e in ipairs(dhabRadar.visible) do
if used >= CONFIG.MaxTracers then break end
if e.root.Parent then
local pt = cam:WorldToViewportPoint(entryCenter(e))
local p = Vector2.new(pt.X, pt.Y)
if pt.Z <= 0 then
local d = center - p
if d.Magnitude < 1 then d = Vector2.new(0, 1) end
p = center + d.Unit * 10000
end
local d = p - center
local sx = (math.abs(d.X) > 0) and ((center.X - m) / math.abs(d.X)) or math.huge
local sy = (math.abs(d.Y) > 0) and ((center.Y - m) / math.abs(d.Y)) or math.huge
p = center + d * math.min(sx, sy, 1)
p = Vector2.new(p.X * kx, p.Y * ky)
local diff = p - o
local len = diff.Magnitude
if len > 1 then
local mid = (o + p) / 2
used += 1
local f = getTracer(used)
f.BackgroundColor3 = entryColor(e)
f.Size = UDim2.fromOffset(len, 1)
f.Position = UDim2.fromOffset(mid.X, mid.Y)
f.Rotation = math.deg(math.atan2(diff.Y, diff.X))
f.Visible = true
end
end
end
end
for i = used + 1, #tracerLines do tracerLines[i].Visible = false end
end
pcall(function() RunService:UnbindFromRenderStep("RXZ_Tracers") end)
RunService:BindToRenderStep("RXZ_Tracers", Enum.RenderPriority.Camera.Value + 1, function() pcall(drawTracers) end)
track({ Disconnect = function() pcall(function() RunService:UnbindFromRenderStep("RXZ_Tracers") end) end })
end
-- تحميل المناطق البعيدة (StreamingEnabled): مسح دائري 16 اتجاه × 4 حلقات حتى نصف قطر المدى (2000)
-- كل طلب في مهمة منفصلة بمهلة ثانية حتى لا يتجمد الحلقة، وتقل الحمولة (طلب كل 0.2 ثانية)
task.spawn(function()
local dirs = {}
for i = 0, 23 do
local a = math.rad(i * 15)
dirs[#dirs + 1] = Vector3.new(math.cos(a), 0, math.sin(a))
end
local rings = { 0.2, 0.4, 0.6, 0.8, 1.0 }
local idx = 0
local streamBusy = 0
while gui.Parent do
local okS, streaming = pcall(function() return workspace.StreamingEnabled end)
if okS and streaming == true and state.farStream and dhabRadar.enabled then
local root = getRootPart()
local gp = root and T.nextGhostPos and T.nextGhostPos() or nil
if gp and streamBusy < 6 then
streamBusy += 1
task.spawn(function()
pcall(function() player:RequestStreamAroundAsync(gp, 1) end)
streamBusy -= 1
end)
end
if root and streamBusy < 8 then
idx += 1
local r = state.range * rings[(idx % #rings) + 1]
local d = dirs[(math.floor(idx / #rings) % #dirs) + 1]
local pos = root.Position + d * r
streamBusy += 1
task.spawn(function()
pcall(function() player:RequestStreamAroundAsync(pos, 1) end)
streamBusy -= 1
end)
end
end
task.wait(0.05)
end
end)
pcall(function() RunService:UnbindFromRenderStep("RXZ_Magic") end)
pcall(function() if typeof(_G) == "table" and typeof(_G.RXZ_Magic) == "table" then _G.RXZ_Magic.get = nil end end)
local aimTarget, aimAcc = nil, 0
local function myExclude()
local ex = {}
local char = getCharacter()
if char then ex[#ex + 1] = char end
local hum = getHumanoid()
local seat = hum and hum.SeatPart
if seat then
local m = seat:FindFirstAncestorOfClass("Model")
while m and m.Parent and m.Parent:IsA("Model") do m = m.Parent end
if m then ex[#ex + 1] = m end
end
return ex
end
-- فحص رؤية صارم: أي جدار/صخرة/شجرة/تضاريس بين الكاميرا والنقطة = غير ظاهر (بدون أي استثناء للمسافة)
local function canSeePoint(cam, pos, base)
local origin = cam.CFrame.Position
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
local ex = table.clone(base)
for _ = 1, 12 do
params.FilterDescendantsInstances = ex
local res = workspace:Raycast(origin, pos - origin, params)
if not res then return true end
local part = res.Instance
if part:IsA("Terrain") then return false end
local pm = part:FindFirstAncestorOfClass("Model")
local living = pm and (pm:FindFirstChildOfClass("Humanoid") or pm:FindFirstChildOfClass("AnimationController")) ~= nil
if living then
ex[#ex + 1] = pm
elseif part.Transparency >= 0.9 or (not part.CanCollide and part.Transparency >= 0.5) then
ex[#ex + 1] = part
else
return false
end
end
return false
end
T.velTrack = setmetatable({}, { __mode = "k" })
function T.targetVel(root)
local now = os.clock()
local t = T.velTrack[root]
local av = root.AssemblyLinearVelocity
if not t then
T.velTrack[root] = { pos = root.Position, time = now, vel = av }
return av
end
local dt = now - t.time
if dt >= 0.05 then
t.vel = t.vel:Lerp((root.Position - t.pos) / dt, 0.5)
t.pos, t.time = root.Position, now
end
if av.Magnitude > t.vel.Magnitude then return av end
return t.vel
end
T.headCache = setmetatable({}, { __mode = "k" })
function T.headPart(inst)
local c = T.headCache[inst]
if c ~= nil then
if c == false then return nil end
if c.Parent then return c end
end
local found = false
if inst:IsA("Model") then
for _, d in ipairs(inst:GetDescendants()) do
if d:IsA("BasePart") then
local n = string.lower(d.Name)
if string.find(n, "head", 1, true) or string.find(n, "skull", 1, true) then found = d break end
end
end
end
T.headCache[inst] = found
return found or nil
end
function T.bbox(e)
local ok, cf, size = pcall(function()
if e.inst:IsA("Model") then return e.inst:GetBoundingBox() end
return e.inst.CFrame, e.inst.Size
end)
if ok then return cf, size end
return nil, nil
end
-- نقطة الرأس: جزء اسمه Head/Skull إن وجد، وإلا تقدير طرف الجسم الأمامي
function T.headPoint(e, cf, size)
local hp = T.headPart(e.inst)
if hp then return hp.Position end
if cf and size then
local axis, half
if size.X >= size.Z then axis, half = cf.RightVector, size.X / 2 else axis, half = cf.LookVector, size.Z / 2 end
local v = T.targetVel(e.root)
local flat = Vector3.new(v.X, 0, v.Z)
local sign
if flat.Magnitude > 1 then
sign = (flat:Dot(axis) >= 0) and 1 or -1
else
sign = (e.root.CFrame.LookVector:Dot(axis) >= 0) and 1 or -1
end
return cf.Position + axis * sign * half * 0.85 + Vector3.new(0, size.Y * 0.1, 0)
end
return e.root.Position
end
local function aimPoints(e, raw)
local cf, size = T.bbox(e)
local head = T.headPoint(e, cf, size)
local center = cf and cf.Position or e.root.Position
local up = Vector3.new(0, size and size.Y or 2, 0)
local neck = head:Lerp(center, 0.4)
local b1, b2, b3 = center, center + up * 0.3, center - up * 0.2
local pts
if state.aimPart == "neck" then
pts = { neck, head, b1, b2, b3 }
elseif state.aimPart == "body" then
pts = { b1, b2, b3, neck, head }
else
pts = { head, neck, b1, b2, b3 }
end
if state.aimPredict then
local cam = workspace.CurrentCamera
if cam then
local dist = (e.root.Position - cam.CFrame.Position).Magnitude
local v = T.targetVel(e.root)
if v.Magnitude > 0.5 and v.Magnitude < 200 then
local lead = v * math.clamp(dist / 2500, 0, 0.3)
for i, p in ipairs(pts) do pts[i] = p + lead end
end
end
end
-- رفع التصويب فوق الرأس بشوي: تعويض نزول الرصاصة مع المسافة (لا يُطبّق على الرصاص السحري)
if not raw and state.aimLift > 0 then
local cam2 = workspace.CurrentCamera
if cam2 then
local dist2 = (e.root.Position - cam2.CFrame.Position).Magnitude
local up = Vector3.new(0, state.aimLift * (0.1 + dist2 * 0.0006), 0)
for i, p in ipairs(pts) do pts[i] = p + up end
end
end
return pts
end
local function visiblePoint(e, cam, base, center, radius)
local ex = table.clone(base)
ex[#ex + 1] = e.inst
local pts = aimPoints(e)
local function check(p)
local v = cam:WorldToViewportPoint(p)
if v.Z <= 0 then return nil end
local d = (Vector2.new(v.X, v.Y) - center).Magnitude
if d <= radius and canSeePoint(cam, p, ex) then return d end
return nil
end
if state.aimHead then
local d = check(pts[1])
if d then return pts[1], d end
end
local bestPt, bestD
for i = 1, #pts do
if not (state.aimHead and i == 1) then
local d = check(pts[i])
if d and (not bestD or d < bestD) then bestPt, bestD = pts[i], d end
end
end
return bestPt, bestD
end
local function findAimTarget()
local cam = workspace.CurrentCamera
local myRoot = getRootPart()
if not cam or not myRoot then return nil end
local entries = dhabRadar.collect()
local center = cam.ViewportSize / 2
local base = myExclude()
local best, bestD
for _, e in ipairs(entries) do
applyDhabInfo(e)
local allowed = not e.skip and not T.isDead(e.inst) and T.isMoving(e, os.clock()) and e.evidence and passFilters(dhabRadar, e)
if allowed and e.root.Parent then
local dist = (e.root.Position - myRoot.Position).Magnitude
if dist <= state.aimRange then
local pt, d = visiblePoint(e, cam, base, center, state.aimCircle)
if pt and (not bestD or d < bestD) then best, bestD = e, d end
end
end
end
return best
end
local function aimStep(dt)
if not state.aimOn then
aimTarget = nil
T.lastLocked = nil
return
end
aimAcc += dt
if aimAcc >= 0.06 then
aimAcc = 0
if not aimTarget then aimTarget = findAimTarget() end
end
local cam = workspace.CurrentCamera
local mr = getRootPart()
if cam and aimTarget and aimTarget.root.Parent and not T.isDead(aimTarget.inst)
and (not mr or (aimTarget.root.Position - mr.Position).Magnitude <= state.aimRange + 50) then
T.targetVel(aimTarget.root)
local pt = visiblePoint(aimTarget, cam, myExclude(), cam.ViewportSize / 2, state.aimCircle * 1.4)
if pt then
local goal = CFrame.lookAt(cam.CFrame.Position, pt)
if T.lastLocked ~= aimTarget then
T.lastLocked = aimTarget
cam.CFrame = goal
else
cam.CFrame = cam.CFrame:Lerp(goal, math.clamp(state.aimSmooth / 100, 0.02, 1))
end
else
aimTarget = nil
T.lastLocked = nil
end
else
aimTarget = nil
T.lastLocked = nil
end
end
RunService:BindToRenderStep(AIM_BIND, Enum.RenderPriority.Camera.Value + 1, function(dt)
pcall(aimStep, dt)
end)
-- ===== الرصاص السحري: أي طلقة تنطلق (حتى للسماء) تتحول للضب الأقرب لمنتصف الشاشة =====
T.mg = { t = 0, v = nil }
function T.magicTarget()
local now = os.clock()
if now - T.mg.t < 0.05 then return T.mg.v end
T.mg.t, T.mg.v = now, nil
local cam = workspace.CurrentCamera
local myRoot = getRootPart()
if not cam or not myRoot then return nil end
local look = cam.CFrame.LookVector
local best, bestDot
for _, e in ipairs(dhabRadar.collect()) do
applyDhabInfo(e)
local offE = e.root.Parent and (e.root.Position - cam.CFrame.Position) or nil
-- البعيد عن مدى الرادار ما نتتبع حركته، فما نشترط الحركة عليه (عشان الرصاص يوصل لأي ضب حي مهما بعد)
local farOut = offE ~= nil and offE.Magnitude > state.range
local allowed = not e.skip and not T.isDead(e.inst) and (farOut or T.isMoving(e, now)) and e.evidence and passFilters(dhabRadar, e)
if allowed and e.root.Parent then
local off = offE
local dist = off.Magnitude
if dist <= state.magicRange and dist > 1 then
local dot = look:Dot(off.Unit)
if aimTarget and aimTarget == e then dot = dot + 10 end
if not bestDot or dot > bestDot then best, bestDot = e, dot end
end
end
end
if best then
local pos = aimPoints(best, true)[1] or best.root.Position
T.mg.v = { inst = best.inst, root = best.root, pos = pos }
end
return T.mg.v
end
-- خط الطلقة المرئي (رصاصة ظاهرة من السلاح للهدف)
function T.magicTracer(toPos)
local now = os.clock()
if T.mgTr and now - T.mgTr < 0.04 then return end
T.mgTr = now
local char = player.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local tool = char and char:FindFirstChildOfClass("Tool")
local h = tool and (tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart", true))
local from = h and h.Position or (root and root.Position + Vector3.new(0, 1.5, 0))
if not from then return end
local len = (toPos - from).Magnitude
if len < 1 then return end
len = math.min(len, 3000)
local p = Instance.new("Part")
p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch = true, false, false, false
p.Material = Enum.Material.Neon
p.Color = Color3.fromRGB(255, 200, 60)
p.Size = Vector3.new(0.2, 0.2, len)
p.CFrame = CFrame.lookAt(from, toPos) * CFrame.new(0, 0, -len / 2)
p.Parent = workspace
game:GetService("Debris"):AddItem(p, 0.15)
end
function T.installMagic()
local MG = (typeof(_G) == "table") and _G or nil
if not MG then return false end
local M = MG.RXZ_Magic
if not M then M = {}; MG.RXZ_Magic = M end
M.get = function()
if not state.magicOn then return nil end
if os.clock() - (T.mgFire or 0) > 0.7 then return nil end
return T.magicTarget()
end
M.tracer = function(pos) end
-- نافذة الإطلاق: التحويل يشتغل فقط لحظة الإطلاق (عشان ما يتدخل بالكاميرا)
if not T.mgHB then
T.mgHB = true
T.mgFire = 0
local cur, conn, acc = nil, nil, 0
track(UserInputService.InputBegan:Connect(function(input, processed)
local t = input.UserInputType
if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.MouseButton2 or (t == Enum.UserInputType.Touch and processed) or input.KeyCode == Enum.KeyCode.ButtonR2 then
T.mgFire = os.clock()
end
end))
track(RunService.Heartbeat:Connect(function(dt)
if state.magicOn and (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR2)) then
T.mgFire = os.clock()
end
acc += dt
if acc < 0.25 then return end
acc = 0
local char = player.Character
local tool = char and char:FindFirstChildOfClass("Tool")
if tool == cur then return end
if conn then pcall(function() conn:Disconnect() end) conn = nil end
cur = tool
if tool then
conn = tool.Activated:Connect(function()
T.mgFire = os.clock()
end)
end
end))
end
if M.installed then
if state.magicMouse then pcall(T.installMagicMouse) end
return true
end
if typeof(hookmetamethod) ~= "function" or typeof(getnamecallmethod) ~= "function" then return false end
local isMine = (typeof(checkcaller) == "function") and checkcaller or function() return false end
local function wrap(f)
if typeof(newcclosure) == "function" then return newcclosure(f) end
return f
end
local setNC = (typeof(setnamecallmethod) == "function") and setnamecallmethod or nil
local canSkip = typeof(getcallingscript) == "function"
local minLen = canSkip and 15 or 40
local function skipCaller()
if not canSkip then return false end
local ok2, sc = pcall(getcallingscript)
if not ok2 or typeof(sc) ~= "Instance" then return false end
local n = sc:GetFullName()
return string.find(n, "PlayerModule", 1, true) ~= nil or string.find(n, "CoreGui", 1, true) ~= nil or string.find(n, "CoreScripts", 1, true) ~= nil
end
local ok = pcall(function()
local oldNC
oldNC = hookmetamethod(game, "__namecall", wrap(function(self, ...)
local method = getnamecallmethod()
if M.get and not M.busy and os.clock() - (T.mgFire or 0) < 0.7 and not isMine() then
local isRay = (self == workspace) and (method == "Raycast" or method == "FindPartOnRayWithWhitelist" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay")
local isCamRay = (method == "ViewportPointToRay" or method == "ScreenPointToRay") and self == workspace.CurrentCamera
if (isRay or isCamRay) and not skipCaller() then
M.busy = true
local override, camTgt
local args = { ... }
pcall(function()
local char = Players.LocalPlayer and Players.LocalPlayer.Character
local tool = char and char:FindFirstChildOfClass("Tool")
if not tool then return end
local hum0 = char:FindFirstChildOfClass("Humanoid")
if hum0 and hum0.SeatPart then return end
local tgt = M.get()
if not tgt then return end
if isCamRay then
camTgt = tgt
return
end
local origin, dir
if method == "Raycast" then
origin, dir = args[1], args[2]
elseif typeof(args[1]) == "Ray" then
origin, dir = args[1].Origin, args[1].Direction
end
if typeof(origin) ~= "Vector3" or typeof(dir) ~= "Vector3" or dir.Magnitude < minLen then return end
local cam = workspace.CurrentCamera
local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart", true)
local head = char:FindFirstChild("Head")
local near = (cam and (origin - cam.CFrame.Position).Magnitude < 25)
or (handle and (origin - handle.Position).Magnitude < 30)
or (head and (origin - head.Position).Magnitude < 25)
if not near then return end
if cam and dir.Unit:Dot(cam.CFrame.LookVector) < 0.35 then return end
-- نمدّ طول الشعاع ليوصل للضب مهما كان بعيد (قبل كان يفشل لو الضب أبعد من مدى السلاح)
local off = tgt.pos - origin
local newDir = off.Unit * math.max(dir.Magnitude, off.Magnitude + 60)
if method == "Raycast" then
local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Include
rp.FilterDescendantsInstances = { tgt.inst }
override = { true, origin, newDir, rp }
else
override = { false, Ray.new(origin, newDir), { tgt.inst } }
end
M.tracer(tgt.pos)
end)
M.busy = false
if override then
if setNC then setNC(method) end
if override[1] then return oldNC(self, override[2], override[3], override[4]) end
return workspace.FindPartOnRayWithWhitelist(workspace, override[2], override[3])
end
if camTgt then
if setNC then setNC(method) end
local r = oldNC(self, ...)
if typeof(r) == "Ray" then
return Ray.new(r.Origin, (camTgt.pos - r.Origin).Unit * r.Direction.Magnitude)
end
return r
end
end
if setNC then setNC(method) end
end
return oldNC(self, ...)
end))
end)
if ok then M.installed = true end
if ok and state.magicMouse then pcall(T.installMagicMouse) end
return ok
end
-- هوك الماوس (Mouse.Hit/Target): اختياري ومطفي افتراضياً لأنه أكثر شي يسبب فصل
function T.installMagicMouse()
local MG = (typeof(_G) == "table") and _G or nil
if not MG or not state.magicMouse then return false end
local M = MG.RXZ_Magic
if not M or not M.get then return false end
if M.idxDone then return true end
if typeof(hookmetamethod) ~= "function" then return false end
local isMine = (typeof(checkcaller) == "function") and checkcaller or function() return false end
local function wrap(f)
if typeof(newcclosure) == "function" then return newcclosure(f) end
return f
end
local ok = pcall(function()
local oldIdx
oldIdx = hookmetamethod(game, "__index", wrap(function(self, key)
if (key == "Hit" or key == "Target" or key == "UnitRay") and not M.inIdx and M.get
and os.clock() - (T.mgFire or 0) < 0.45 and not isMine() then
M.inIdx = true
local res
pcall(function()
if typeof(self) ~= "Instance" or not self:IsA("Mouse") then return end
local char = Players.LocalPlayer and Players.LocalPlayer.Character
local tool = char and char:FindFirstChildOfClass("Tool")
if not tool then return end
local hum0 = char:FindFirstChildOfClass("Humanoid")
if hum0 and hum0.SeatPart then return end
local tgt = M.get()
if not tgt then return end
if key == "Hit" then
res = CFrame.new(tgt.pos)
elseif key == "Target" then
res = tgt.root
else
local real = oldIdx(self, "UnitRay")
if typeof(real) == "Ray" then res = Ray.new(real.Origin, (tgt.pos - real.Origin).Unit) end
end
end)
M.inIdx = false
if res ~= nil then return res end
end
return oldIdx(self, key)
end))
end)
if ok then M.idxDone = true end
return ok
end
local carFlags, lastSeat, getCar, carStep, padsReset
do
local controlsModule = nil
local controlsTried = 0
local function getMoveVector()
if not controlsModule and os.clock() - controlsTried > 3 then
controlsTried = os.clock()
pcall(function()
local ps = player:FindFirstChild("PlayerScripts")
local pm = ps and ps:FindFirstChild("PlayerModule")
if pm then controlsModule = require(pm):GetControls() end
end)
end
if controlsModule then
local ok, v = pcall(function() return controlsModule:GetMoveVector() end)
if ok and typeof(v) == "Vector3" then return v end
end
local x, z = 0, 0
if UserInputService:IsKeyDown(Enum.KeyCode.D) then x += 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.A) then x -= 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.S) then z += 1 end
if UserInputService:IsKeyDown(Enum.KeyCode.W) then z -= 1 end
return Vector3.new(x, 0, z)
end
carFlags = { up = false, down = false, nitro = false, fwd = false, back = false, drive = false, brake = false, stableTap = false, jumpTap = false }
lastSeat = nil
function getCar()
local hum = getHumanoid()
local seat = hum and hum.SeatPart
if not seat then return nil, nil, hum end
local root = seat.AssemblyRootPart or seat
if not root or root.Anchored then return nil, nil, hum end
return seat, root, hum
end
local function padButton(text, flagKey, key, iconName)
local b = make("TextButton", {
Size = UDim2.fromOffset(60, 34), AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(state["pad" .. key .. "X"], state["pad" .. key .. "Y"]),
BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.1,
Text = text, TextColor3 = Color3.new(1, 1, 1), TextSize = 14, Font = FONT, AutoButtonColor = false,
ZIndex = 3501, Visible = false,
}, gui)
addCorner(b, 8)
if iconName then
local isz = (key == "Up" or key == "Down") and 30 or (key == "Nitro" and 38 or 24)
local ic = T.icon(iconName, b, isz, THEME.Text, THEME.Cyan)
ic.Name = "PadIcon"
ic.AnchorPoint = Vector2.new(0.5, 0.5)
ic.Position = UDim2.fromScale(0.5, text ~= "" and 0.34 or 0.5)
end
b.InputBegan:Connect(function(input)
if isPointer(input) and not state.padEdit then
carFlags[flagKey] = true
local c
c = input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
carFlags[flagKey] = false
c:Disconnect()
end
end)
end
end)
local startPos
makeDragger(b, function() startPos = b.Position end, function(d)
if state.padEdit and startPos then
local sz = gui.AbsoluteSize
if sz.X > 0 and sz.Y > 0 then
b.Position = UDim2.fromScale(math.clamp(startPos.X.Scale + d.X / sz.X, 0.04, 0.96),
math.clamp(startPos.Y.Scale + d.Y / sz.Y, 0.06, 0.94))
end
end
end, function()
if state.padEdit then
state["pad" .. key .. "X"] = b.Position.X.Scale
state["pad" .. key .. "Y"] = b.Position.Y.Scale
end
end)
T.regPad(key, b)
return b
end
local padUp = padButton("فوق", "up", "Up", "chev_up")
local padDown = padButton("تحت", "down", "Down", "chev_down")
local padNitro = padButton("نيترو", "nitro", "Nitro", "bolt")
local padFwd = padButton("أمام", "fwd", "Fwd", "arrow_up")
local padBack = padButton("خلف", "back", "Back", "arrow_down")
padFwd.TextSize, padBack.TextSize = 13, 13
local padDrive = padButton("امش", "drive", "Drive", "arrow_up")
padDrive.Size = UDim2.fromOffset(84, 124)
padDrive.TextSize = 18
padDrive.PadIcon.Size = UDim2.fromOffset(44, 44)
padDrive.PadIcon.Position = UDim2.fromScale(0.5, 0.4)
padDrive.BackgroundTransparency = 0.35
local padStable = padButton("ثبات", "stableTap", "Stable", "compass")
padStable.TextSize = 12
padStable.PadIcon.Size = UDim2.fromOffset(22, 22)
padStable.PadIcon.Position = UDim2.fromScale(0.5, 0.27)
local stablePrev = false
padStable.BackgroundTransparency = 0.25
local padJump = padButton("قفز", "jumpTap", "Jump", "chev_up2")
padJump.TextSize = 15
local jumpPrev = false
local padBrake = padButton("وقوف", "brake", "Brake", "stop")
padBrake.Size = UDim2.fromOffset(84, 70)
padBrake.TextSize = 16
padBrake.PadIcon.Size = UDim2.fromOffset(28, 28)
padBrake.BackgroundTransparency = 0.35
local dc = padDrive:FindFirstChildOfClass("UICorner")
if dc then dc.CornerRadius = UDim.new(0, 22) end
function padsReset()
for _, p in ipairs({ { padUp, "Up" }, { padDown, "Down" }, { padNitro, "Nitro" }, { padFwd, "Fwd" }, { padBack, "Back" }, { padDrive, "Drive" }, { padBrake, "Brake" }, { padStable, "Stable" }, { padJump, "Jump" } }) do
p[1].Position = UDim2.fromScale(state["pad" .. p[2] .. "X"], state["pad" .. p[2] .. "Y"])
end
end
function carStep(dt)
local seat, root, hum = getCar()
if hum and hum.SeatPart then lastSeat = hum.SeatPart end
local hideAll = T.menuOpen == true
local ed = state.padEdit and not hideAll
local inCar = seat ~= nil and not hideAll
padUp.Visible, padDown.Visible = ed or (inCar and state.flyOn), ed or (inCar and state.flyOn)
padNitro.Visible = ed or (inCar and state.nitroOn)
padFwd.Visible, padBack.Visible = ed or (inCar and state.flyOn), ed or (inCar and state.flyOn)
padDrive.Visible = ed or (inCar and state.walkOn and not state.flyOn)
padBrake.Visible = padDrive.Visible
padJump.Visible = not hideAll and (state.jumpBtn or state.padEdit)
if carFlags.jumpTap and not jumpPrev and not state.padEdit and T.carKick then T.carKick() end
jumpPrev = carFlags.jumpTap
padStable.Visible = ed or inCar
if carFlags.stableTap and not stablePrev and not state.padEdit then state.stableOn = not state.stableOn end
stablePrev = carFlags.stableTap
padStable.BackgroundColor3 = state.stableOn and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
padStable.TextColor3 = state.stableOn and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
local st = state.stableOn and "ثبات\nشغّال" or "ثبات\nمطفي"
if padStable.Text ~= st then padStable.Text = st end
if not seat then return end
if T.navBusy then return end
local cf = seat.CFrame
local fwd = cf.LookVector
local mass = root.AssemblyMass
local mv = getMoveVector()
if state.flyOn then
local cam = workspace.CurrentCamera
if cam then
local ccf = cam.CFrame
local dir = ccf.RightVector * mv.X + ccf.LookVector * (-mv.Z)
local up = 0
if carFlags.up or UserInputService:IsKeyDown(Enum.KeyCode.E) then up += 1 end
if carFlags.down or UserInputService:IsKeyDown(Enum.KeyCode.Q) then up -= 1 end
dir = dir + Vector3.new(0, up, 0) + fwd * ((carFlags.fwd and 1 or 0) - (carFlags.back and 1 or 0))
root.AssemblyLinearVelocity = dir * (math.min(state.flySpeed, 13) * 20)
root.AssemblyAngularVelocity = Vector3.zero
local flatS = Vector3.new(fwd.X, 0, fwd.Z)
local flatC = Vector3.new(ccf.LookVector.X, 0, ccf.LookVector.Z)
if flatS.Magnitude > 0.1 and flatC.Magnitude > 0.1 then
local ang = math.atan2(flatS:Cross(flatC).Y, flatS:Dot(flatC))
local rc = root.CFrame
local sc = cf
local relRot = (sc:Inverse() * rc).Rotation
local targetRot = CFrame.lookAt(Vector3.zero, flatS) * relRot
local nc = rc.Rotation:Lerp(targetRot, 0.35)
root.CFrame = CFrame.new(rc.Position) * CFrame.Angles(0, ang * 0.2, 0) * nc
end
end
return
end
if state.walkOn and carFlags.brake and not state.flyOn then
local cur = root.AssemblyLinearVelocity
root.AssemblyLinearVelocity = Vector3.new(cur.X * 0.2, cur.Y, cur.Z * 0.2)
local av0 = root.AssemblyAngularVelocity
root.AssemblyAngularVelocity = Vector3.new(av0.X * 0.5, av0.Y * 0.3, av0.Z * 0.5)
elseif state.walkOn and carFlags.drive then
local cam = workspace.CurrentCamera
local flat = Vector3.new(fwd.X, 0, fwd.Z)
if flat.Magnitude > 0.05 then
flat = flat.Unit
if cam then
local flatC = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
if flatC.Magnitude > 0.1 then
flatC = flatC.Unit
local ang = math.atan2(flat:Cross(flatC).Y, flat:Dot(flatC))
local rc = root.CFrame
root.CFrame = CFrame.new(rc.Position) * CFrame.Angles(0, ang * 0.25, 0) * (rc - rc.Position)
local nf = CFrame.Angles(0, ang * 0.25, 0):VectorToWorldSpace(flat)
flat = Vector3.new(nf.X, 0, nf.Z).Unit
end
end
local cur = root.AssemblyLinearVelocity
local sp = math.min(state.walkSpeed, 13) * 20
root.AssemblyLinearVelocity = Vector3.new(flat.X * sp, cur.Y, flat.Z * sp)
local av = root.AssemblyAngularVelocity
root.AssemblyAngularVelocity = Vector3.new(av.X, 0, av.Z)
end
end
if state.modOn then
local throttle = 0
if seat:IsA("VehicleSeat") then throttle = seat.ThrottleFloat end
if throttle == 0 then throttle = -mv.Z end
throttle = math.clamp(throttle, -1, 1)
local vel = root.AssemblyLinearVelocity
if throttle ~= 0 and vel:Dot(fwd) * throttle < state.maxKmh then
local accel = state.hp / 50000 * 90
if state.climbOn and fwd.Y > 0.12 then accel *= 1.6 end
local pos = root.AssemblyCenterOfMass
if state.push == "front" then pos += fwd * 3 elseif state.push == "rear" then pos -= fwd * 3 end
root:ApplyImpulseAtPosition(fwd * throttle * accel * mass * dt, pos)
end
if state.climbOn then
root:ApplyImpulse(Vector3.new(0, -1, 0) * mass * 35 * dt)
end
end
if state.nitroOn and (carFlags.nitro or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)) then
local vel = root.AssemblyLinearVelocity
if vel.Magnitude < state.nitroMax then
root.AssemblyLinearVelocity = vel + fwd * (state.nitroPower * 0.6) * dt
end
end
end
end
local function carKick()
local seat, root = getCar()
if not seat then
notify("اركب سيارة أولاً", "error")
return
end
T.kickUntil = os.clock() + 1.2
local v = root.AssemblyLinearVelocity
root.AssemblyLinearVelocity = Vector3.new(v.X, math.max(v.Y, 0) + state.carJump, v.Z)
root.AssemblyAngularVelocity = Vector3.zero
end
-- إصلاح: كان الربط T.carKick داخل الدالة بعد return المبكر فلا يُعيَّن إلا بعد أول استدعاء من القائمة
T.carKick = carKick
local function reenterCar()
local hum = getHumanoid()
local hrp = getRootPart()
local seat = (hum and hum.SeatPart) or lastSeat
if not hum or not hrp or not seat or not seat.Parent then
notify("ما في سيارة سابقة", "error")
return
end
if T.allowSeat then T.allowSeat(6) end
hum.Sit = false
task.wait(0.15)
hrp.CFrame = seat.CFrame * CFrame.new(0, 2, 0)
pcall(function() seat:Sit(hum) end)
end
local ghostOrig = {}
local function ghostRestore(all, keep)
for part in pairs(ghostOrig) do
if all or not (keep and keep[part]) then
if part.Parent then part.CanCollide = true end
ghostOrig[part] = nil
end
end
end
local function ghostStep()
if not state.ghostOn then
ghostRestore(true)
return
end
local seat, root = getCar()
if not seat then
ghostRestore(true)
return
end
local params = OverlapParams.new()
local ex = { getCharacter() }
local model = seat:FindFirstAncestorOfClass("Model")
if model then table.insert(ex, model) end
params.FilterDescendantsInstances = ex
params.FilterType = Enum.RaycastFilterType.Exclude
local keep = {}
local ry = root.Position.Y
for _, part in ipairs(workspace:GetPartBoundsInRadius(root.Position, 45, params)) do
if part.CanCollide or ghostOrig[part] then
local top = part.Position.Y + part.Size.Y / 2
local big = math.max(part.Size.X, part.Size.Y, part.Size.Z) > 150
local pm = part:FindFirstAncestorOfClass("Model")
local living = pm and pm:FindFirstChildOfClass("Humanoid") ~= nil
if (top > ry + 0.5 or ghostOrig[part]) and not big and not living then
ghostOrig[part] = true
part.CanCollide = false
keep[part] = true
end
end
end
ghostRestore(false, keep)
end
local applyNature
do
local NATURE = {
-- إنجليزي: يطابق بداية الكلمة (فلا تتأثر street بكلمة tree)، عربي: يطابق أي جزء من الاسم
treeEng = { "tree", "palm", "acacia", "ghaf", "sidr", "sidra", "talh", "samr", "arak", "athl", "tamarisk", "eucalyptus",
"bush", "shrub", "plant", "foliage", "leaf", "leaves", "trunk", "branch", "canopy", "vegetation", "flora", "pine", "oak" },
treeAr = { "شجر", "شجيرة", "نخل", "نخيل", "سدر", "غاف", "سمر", "طلح", "أراك", "اراك", "أثل", "اثل", "غضا", "عوسج", "نبات", "جذع", "أغصان", "اغصان" },
rockEng = { "rock", "stone", "boulder", "cliff", "pebble" },
rockAr = { "صخر", "حجر" },
treeTags = { "Tree", "Trees", "Palm", "Foliage", "Bush", "Plant" },
rockTags = { "Rock", "Rocks", "Stone", "Boulder" },
}
local natureOrig = setmetatable({}, { __mode = "k" })
local natureKind = setmetatable({}, { __mode = "k" })
local function nameHas(name, eng, arab)
local spaced = string.gsub(name, "(%l)(%u)", "%1 %2")
spaced = string.lower(spaced)
for tok in string.gmatch(spaced, "%a+") do
for _, kw in ipairs(eng) do
if string.sub(tok, 1, #kw) == kw then return true end
end
end
for _, w in ipairs(arab) do
if string.find(name, w, 1, true) then return true end
end
return false
end
local function hasAnyTag(inst, tags)
for _, t in ipairs(tags) do
if CollectionService:HasTag(inst, t) then return true end
end
return false
end
local function natureClassify(part)
local cached = natureKind[part]
if cached ~= nil then return cached end
local kind, inst, depth = false, part, 0
local size = part.Size
if math.max(size.X, size.Y, size.Z) > 400 then
natureKind[part] = false
return false
end
while inst and inst ~= workspace and depth < 12 do
if inst:IsA("Model") and inst:FindFirstChildOfClass("Humanoid") then
kind = false
break
end
if not kind then
local nm = inst.Name
if T.natureLearn.trees[nm] or hasAnyTag(inst, NATURE.treeTags) or nameHas(nm, NATURE.treeEng, NATURE.treeAr) then
kind = "trees"
elseif T.natureLearn.rocks[nm] or hasAnyTag(inst, NATURE.rockTags) or nameHas(nm, NATURE.rockEng, NATURE.rockAr) then
kind = "rocks"
end
end
inst = inst.Parent
depth += 1
end
natureKind[part] = kind
return kind
end
local function natureApply(part)
if not part:IsA("BasePart") or part:IsA("Terrain") then return end
local kind = natureClassify(part)
local want = (kind == "trees" and state.hideTrees) or (kind == "rocks" and state.hideRocks)
local o = natureOrig[part]
if want then
if not o then
natureOrig[part] = { collide = part.CanCollide }
end
part.LocalTransparencyModifier = 1
part.CanCollide = false
elseif o then
part.LocalTransparencyModifier = 0
part.CanCollide = o.collide
natureOrig[part] = nil
end
end
local natureBusy, natureAgain = false, false
function applyNature()
if natureBusy then
natureAgain = true
return
end
natureBusy = true
task.spawn(function()
repeat
natureAgain = false
pcall(function()
if state.hideTrees or state.hideRocks then
for i, inst in ipairs(workspace:GetDescendants()) do
natureApply(inst)
if i % 1500 == 0 then task.wait() end
end
end
for part in pairs(natureOrig) do natureApply(part) end
end)
until not natureAgain
natureBusy = false
end)
end
track(workspace.DescendantAdded:Connect(function(inst)
if state.hideTrees or state.hideRocks then
task.defer(function() pcall(natureApply, inst) end)
end
end))
function T.natureRecheck()
for k in pairs(natureKind) do natureKind[k] = nil end
applyNature()
end
-- تعليم: وجّه الكاميرا على الشجرة/الصخرة واضغط، فيحفظ اسمها ويخفي كل ما يحمل نفس الاسم
function T.natureLearnAim(kind)
local cam = workspace.CurrentCamera
if not cam then return end
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.FilterDescendantsInstances = myExclude()
local res = workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 400, params)
if not res then
notify("وجّه منتصف الشاشة على الشجرة ثم اضغط", "error")
return
end
local part = res.Instance
if part:IsA("Terrain") then
notify("اللي قدامك تضاريس مو شجرة", "error")
return
end
local GENERIC = { part = true, meshpart = true, model = true, folder = true, union = true, unionoperation = true,
mesh = true, handle = true, group = true, wedge = true, wedgepart = true, basepart = true, base = true,
baseplate = true, map = true, default = true, environment = true, world = true }
local picked, chain = nil, {}
local inst, d = part, 0
while inst and inst ~= workspace and d < 4 do
chain[#chain + 1] = inst.Name
if not picked and not GENERIC[string.lower(inst.Name)] and not string.match(inst.Name, "^%d+$") then picked = inst.Name end
inst = inst.Parent
d += 1
end
if not picked then
notify("اسمها عام (" .. table.concat(chain, " < ") .. ") ما قدرت أعلّمها", "error")
return
end
T.natureLearn[kind][picked] = true
T.natureRecheck()
notify("تم تعليم: " .. picked)
end
end
local function setRadar(radar, v)
radar.enabled = v
if v then updateRadar(radar) else clearRadar(radar) end
end
local function toggleSpeed(v)
state.speedOn = v
if not applyMovement() and v then notify("الشخصية غير متوفرة", "error") end
end
local function toggleJump(v)
state.jumpOn = v
if not applyMovement() and v then notify("الشخصية غير متوفرة", "error") end
end
local W = math.min(T.isPC and 630 or 530, view.X - 16)
local H = math.min(T.isPC and 420 or 350, view.Y - 16)
local SB = (W >= 520) and 150 or 118
local window = make("Frame", {
Name = "Window", Size = UDim2.fromOffset(W, H),
Position = UDim2.fromOffset(math.max((view.X - W) / 2, 0), math.max((view.Y - H) / 2, 0)),
BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1,
ClipsDescendants = true, Visible = false, Active = true,
}, gui)
addCorner(window, 16)
T.bgImg = make("ImageLabel", {
Name = "BgImage", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
Image = "rbxassetid://93162496534160", ScaleType = Enum.ScaleType.Crop,
ImageTransparency = state.bgTransparency, ZIndex = 0,
}, window)
addCorner(T.bgImg, 16)
addStroke(window, THEME.Line, 1.5, 0.2)
addGradient(window, THEME.Bg, THEME.BgMid, 90)
local uiScale = make("UIScale", { Scale = state.userScale }, window)
local header = make("Frame", {
Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, Active = true,
}, window)
make("TextLabel", {
Position = UDim2.fromOffset(14, 0), Size = UDim2.new(0.6, 0, 1, 0), BackgroundTransparency = 1,
Text = "RXZ | صيد الضبان", TextColor3 = THEME.Text, TextSize = 20, Font = FONT,
TextXAlignment = Enum.TextXAlignment.Left,
}, header)
local closeButton = make("TextButton", {
AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
Size = UDim2.fromOffset(44, 28), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0,
Text = "X", TextColor3 = Color3.new(1, 1, 1), TextSize = 16, Font = FONT, AutoButtonColor = false,
}, header)
addCorner(closeButton, 7)
local sidebar = make("Frame", {
Position = UDim2.fromOffset(8, 54), Size = UDim2.new(0, SB, 1, -62), BackgroundTransparency = 1,
}, window)
local searchWrap = make("Frame", {
Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = THEME.Row,
}, sidebar)
addCorner(searchWrap, 12)
addStroke(searchWrap, THEME.Line, 1, 0.4)
local searchBox = make("TextBox", {
Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -16, 1, 0), BackgroundTransparency = 1,
Text = "", PlaceholderText = "بحث", PlaceholderColor3 = Color3.fromRGB(170, 180, 205),
TextColor3 = THEME.Text, TextSize = 16, Font = FONT, ClearTextOnFocus = false,
TextXAlignment = Enum.TextXAlignment.Left,
}, searchWrap)
local navList = make("ScrollingFrame", {
Position = UDim2.fromOffset(0, 46), Size = UDim2.new(1, 0, 1, -46), BackgroundTransparency = 1,
BorderSizePixel = 0, ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y,
CanvasSize = UDim2.new(), ElasticBehavior = Enum.ElasticBehavior.Never, ScrollingEnabled = false,
}, sidebar)
make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, navList)
local content = make("Frame", {
Position = UDim2.new(0, SB + 16, 0, 54), Size = UDim2.new(1, -(SB + 24), 1, -62),
BackgroundColor3 = THEME.Panel, BackgroundTransparency = 0.45,
}, window)
addCorner(content, 14)
addStroke(content, THEME.Line, 1, 0.5)
local pages, navButtons, currentPage = {}, {}, nil
local searchables = {}
local buildPage = nil
local function showPage(name)
local changed = currentPage ~= name
currentPage = name
for pageName, page in pairs(pages) do
local on = (pageName == name)
if on and changed and state.effects ~= false then
page.Position = UDim2.fromOffset(4, 16)
page.Visible = true
TweenService:Create(page, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.fromOffset(4, 4) }):Play()
else
page.Visible = on
if on then page.Position = UDim2.fromOffset(4, 4) end
end
local b = navButtons[pageName]
TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = on and 0 or 1 }):Play()
end
end
local function newPage(name, icon)
local btn = make("TextButton", {
Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = THEME.RowSel, BackgroundTransparency = 1,
AutoButtonColor = false, Text = "", LayoutOrder = nextOrder(),
}, navList)
addCorner(btn, 12)
make("TextLabel", {
Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -16, 1, 0), BackgroundTransparency = 1,
Text = name, TextSize = 17, Font = FONT, TextColor3 = THEME.Text, TextXAlignment = Enum.TextXAlignment.Left,
}, btn)
navButtons[name] = btn
local col = make("ScrollingFrame", {
Size = UDim2.new(1, -8, 1, -8), Position = UDim2.fromOffset(4, 4), BackgroundTransparency = 1,
BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = THEME.Accent,
AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false,
ElasticBehavior = Enum.ElasticBehavior.Never,
}, content)
make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, col)
make("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 12),
PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 10) }, col)
pages[name] = col
btn.Activated:Connect(function() showPage(name) end)
buildPage = name
return col
end
local isOpen = false
function T.keepTop()
local MAX = 2147483647
for _, g in ipairs(playerGui:GetChildren()) do
if g:IsA("ScreenGui") and g ~= gui and g ~= tracerGui and g ~= toastGui and g ~= T.barGui and g.DisplayOrder >= MAX then
g.DisplayOrder = MAX - 1
end
end
if gui.DisplayOrder ~= MAX then gui.DisplayOrder = MAX end
end
local function setOpen(open)
if isOpen == open then return end
isOpen = open
T.menuOpen = open
if open then
pcall(T.keepTop)
window.Visible = true
if state.effects then
uiScale.Scale = state.userScale * 0.9
TweenService:Create(uiScale, EASE, { Scale = state.userScale }):Play()
else
uiScale.Scale = state.userScale
end
else
if state.effects then
local quick = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
TweenService:Create(uiScale, quick, { Scale = state.userScale * 0.92 }):Play()
task.delay(0.18, function()
if not isOpen then window.Visible = false end
end)
else
window.Visible = false
end
end
end
closeButton.Activated:Connect(function() setOpen(false) end)
local resizeHandle
local maxed = false
do
local dragOrigin
makeDragger(header, function() dragOrigin = window.Position end, function(d)
if maxed then return end
window.Position = UDim2.fromOffset(dragOrigin.X.Offset + d.X, dragOrigin.Y.Offset + d.Y)
clampFrame(window)
end)
resizeHandle = make("TextButton", {
AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -4, 1, -4), Size = UDim2.fromOffset(22, 22),
BackgroundColor3 = THEME.Row, BackgroundTransparency = 0.3, Text = "",
TextColor3 = THEME.Text, TextSize = 11, Font = FONT, AutoButtonColor = false, Active = true, ZIndex = 5,
}, window)
addCorner(resizeHandle, 8)
do
local ic = T.icon("grip", resizeHandle, 14, THEME.Text)
ic.AnchorPoint = Vector2.new(0.5, 0.5)
ic.Position = UDim2.fromScale(0.5, 0.5)
end
local resizeStart
makeDragger(resizeHandle, function() resizeStart = window.Size end, function(d)
if maxed then return end
local s = uiScale.Scale
window.Size = UDim2.fromOffset(
math.clamp(resizeStart.X.Offset + d.X / s, 380, 760),
math.clamp(resizeStart.Y.Offset + d.Y / s, 280, 640))
clampFrame(window)
end)
end
local refreshers = {}
local function refreshAll()
for _, r in ipairs(refreshers) do r() end
end
T.refreshAll = refreshAll
local function register(row, text, isTitle)
table.insert(searchables, { row = row, text = string.lower(text), page = buildPage, title = isTitle })
end
local function rowFrame(parent, height, className)
local row = make(className or "Frame", {
Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = THEME.Row, LayoutOrder = nextOrder(),
}, parent)
if className == "TextButton" then
row.AutoButtonColor = false
row.Text = ""
end
addCorner(row, 12)
addStroke(row, THEME.Line, 1, 0.55)
return row
end
local function section(parent, text)
local label = make("TextLabel", {
Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = text,
TextColor3 = THEME.Text, TextSize = 16, Font = FONT,
TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(),
}, parent)
make("UIPadding", { PaddingLeft = UDim.new(0, 4) }, label)
register(label, text, true)
return label
end
local function rowLabel(row, text, rightSpace)
return make("TextLabel", {
Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -(rightSpace + 20), 1, 0),
BackgroundTransparency = 1, Text = text, TextColor3 = THEME.Text, TextSize = 17, Font = FONT,
TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
}, row)
end
local function createToggle(parent, text, getter, onChange)
local row = rowFrame(parent, 50, "TextButton")
rowLabel(row, text, 70)
local rail = make("Frame", {
AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
Size = UDim2.fromOffset(52, 28), BackgroundColor3 = THEME.Off,
}, row)
addCorner(rail, 14)
local knob = make("Frame", {
Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(22, 22), BackgroundColor3 = Color3.new(1, 1, 1),
}, rail)
addCorner(knob, 11)
local lastOn
local function refresh()
local on = getter()
if on == lastOn then return end
lastOn = on
local info = TweenInfo.new(state.effects and 0.15 or 0)
TweenService:Create(knob, info, { Position = on and UDim2.fromOffset(27, 3) or UDim2.fromOffset(3, 3) }):Play()
TweenService:Create(rail, info, { BackgroundColor3 = on and THEME.On or THEME.Off }):Play()
end
row.Activated:Connect(function()
safe(text, function() onChange(not getter()) end)
refreshAll()
end)
table.insert(refreshers, refresh)
register(row, text)
refresh()
return row
end
local function createSlider(parent, text, getter, setter, minV, maxV, stepV, formatter)
local box = rowFrame(parent, 64)
rowLabel(box, text, 90).Size = UDim2.new(1, -110, 0, 30)
local valueLabel = make("TextLabel", {
AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 0), Size = UDim2.fromOffset(90, 30),
BackgroundTransparency = 1, TextColor3 = THEME.Text, TextSize = 16, Font = FONT,
TextXAlignment = Enum.TextXAlignment.Right,
}, box)
local trackFrame = make("Frame", {
Position = UDim2.new(0, 14, 1, -22), Size = UDim2.new(1, -28, 0, 8), BackgroundColor3 = THEME.Off,
}, box)
addCorner(trackFrame, 4)
local fill = make("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = THEME.Accent }, trackFrame)
addCorner(fill, 4)
local knob = make("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(20, 20),
BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 3,
}, trackFrame)
addCorner(knob, 10)
local hit = make("TextButton", {
AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(44, 44),
BackgroundTransparency = 1, Text = "", ZIndex = 4,
}, knob)
local function refresh()
local v = getter()
local ratio = math.clamp((v - minV) / (maxV - minV), 0, 1)
fill.Size = UDim2.fromScale(ratio, 1)
knob.Position = UDim2.fromScale(ratio, 0.5)
valueLabel.Text = formatter and formatter(v) or tostring(v)
end
local function setFromX(x)
local w = trackFrame.AbsoluteSize.X
if w <= 0 then return end
local ratio = math.clamp((x - trackFrame.AbsolutePosition.X) / w, 0, 1)
local v = minV + ratio * (maxV - minV)
v = math.clamp(math.floor(v / stepV + 0.5) * stepV, minV, maxV)
if v ~= getter() then safe(text, setter, v) end
refresh()
end
local dragging, scroller, grab = false, nil, 0
hit.InputBegan:Connect(function(input)
if isPointer(input) then
dragging = true
grab = (knob.AbsolutePosition.X + knob.AbsoluteSize.X / 2) - input.Position.X
scroller = box:FindFirstAncestorOfClass("ScrollingFrame")
if scroller then scroller.ScrollingEnabled = false end
local c
c = input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then
dragging = false
if scroller then scroller.ScrollingEnabled = true end
c:Disconnect()
end
end)
end
end)
track(UserInputService.InputChanged:Connect(function(input)
if dragging and isMove(input) then setFromX(input.Position.X + grab) end
end))
table.insert(refreshers, refresh)
register(box, text)
refresh()
end
-- أزرار + / - لقيمة رقمية (تُستخدم لحجم العلامات)
function T.createStepper(parent, text, getter, setter, minV, maxV, stepV)
local row = rowFrame(parent, 56)
rowLabel(row, text, 190)
local function mk(sym, xoff, delta)
local b = make("TextButton", {
AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, xoff, 0.5, 0), Size = UDim2.fromOffset(44, 38),
BackgroundColor3 = THEME.Accent, Text = sym, TextColor3 = THEME.Text, TextSize = 26, Font = FONT,
AutoButtonColor = false,
}, row)
addCorner(b, 10)
b.Activated:Connect(function()
safe(text, function() setter(math.clamp(getter() + delta, minV, maxV)) end)
refreshAll()
end)
return b
end
mk("+", -10, stepV)
local val = make("TextLabel", {
AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -58, 0.5, 0), Size = UDim2.fromOffset(48, 38),
BackgroundTransparency = 1, TextColor3 = THEME.Text, TextSize = 18, Font = FONT,
}, row)
mk("-", -110, -stepV)
table.insert(refreshers, function() val.Text = tostring(getter()) end)
register(row, text)
val.Text = tostring(getter())
return row
end
local function createChips(parent, text, values, getter, onPick, formatter)
local box = rowFrame(parent, 74)
rowLabel(box, text, 0).Size = UDim2.new(1, -28, 0, 30)
local holder = make("Frame", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 32), Size = UDim2.new(1, -24, 0, 34),
}, box)
make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6) }, holder)
local n = #values
local chips = {}
for _, v in ipairs(values) do
local chip = make("TextButton", {
Size = UDim2.new(1 / n, -(6 * (n - 1)) / n, 1, 0), BackgroundColor3 = THEME.Off,
Text = formatter and formatter(v) or tostring(v), TextColor3 = THEME.Text, TextSize = 16, Font = FONT,
AutoButtonColor = false,
}, holder)
addCorner(chip, 9)
chip.Activated:Connect(function()
safe(text, onPick, v)
refreshAll()
end)
chips[v] = chip
end
local function refresh()
for v, chip in pairs(chips) do
chip.BackgroundColor3 = (getter() == v) and THEME.Accent or THEME.Off
end
end
table.insert(refreshers, refresh)
register(box, text)
refresh()
end
local function createDropdown(parent, text, options, getter, setter)
local holder = make("Frame", {
Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
LayoutOrder = nextOrder(),
}, parent)
make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, holder)
local head = rowFrame(holder, 56)
head.LayoutOrder = 1
rowLabel(head, text, 190)
local btn = make("TextButton", {
AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(176, 38),
BackgroundColor3 = THEME.Panel, AutoButtonColor = false, Text = "",
}, head)
addCorner(btn, 10)
addStroke(btn, THEME.Line, 1, 0.3)
local dot = make("Frame", {
Position = UDim2.fromOffset(10, 12), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.new(1, 1, 1),
}, btn)
addCorner(dot, 7)
local valueLabel = make("TextLabel", {
Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -62, 1, 0), BackgroundTransparency = 1,
TextColor3 = THEME.Text, TextSize = 17, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
}, btn)
do
local ic = T.icon("updown", btn, 18, THEME.Text)
ic.AnchorPoint = Vector2.new(1, 0.5)
ic.Position = UDim2.new(1, -10, 0.5, 0)
end
local list = make("Frame", {
Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = THEME.Row,
Visible = false, LayoutOrder = 2,
}, holder)
addCorner(list, 12)
addStroke(list, THEME.Line, 1, 0.55)
make("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, list)
make("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }, list)
local optButtons = {}
for _, opt in ipairs(options) do
local ob = make("TextButton", {
Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = THEME.RowSel, BackgroundTransparency = 1,
AutoButtonColor = false, Text = "", LayoutOrder = nextOrder(),
}, list)
addCorner(ob, 9)
local od = make("Frame", {
Position = UDim2.fromOffset(10, 12), Size = UDim2.fromOffset(14, 14),
BackgroundColor3 = opt.color or Color3.new(1, 1, 1),
}, ob)
addCorner(od, 7)
if opt.noDot then od.Visible = false end
if opt.rainbow then T.rainbow[od] = true end
make("TextLabel", {
Position = UDim2.fromOffset(opt.noDot and 12 or 34, 0), Size = UDim2.new(1, -44, 1, 0), BackgroundTransparency = 1,
Text = opt.label, TextColor3 = THEME.Text, TextSize = 17, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left,
}, ob)
ob.Activated:Connect(function()
safe(text, setter, opt.key)
list.Visible = false
refreshAll()
end)
optButtons[opt.key] = ob
end
btn.Activated:Connect(function() list.Visible = not list.Visible end)
local function refresh()
local cur = getter()
for _, opt in ipairs(options) do
if opt.key == cur then
valueLabel.Text = opt.label
dot.BackgroundColor3 = opt.color or Color3.new(1, 1, 1)
dot.Visible = not opt.noDot
valueLabel.Position = UDim2.fromOffset(opt.noDot and 12 or 32, 0)
valueLabel.Size = UDim2.new(1, opt.noDot and -42 or -62, 1, 0)
T.rainbow[dot] = opt.rainbow and true or nil
end
optButtons[opt.key].BackgroundTransparency = (opt.key == cur) and 0 or 1
end
end
table.insert(refreshers, refresh)
register(holder, text)
refresh()
end
local function createMultiDropdown(parent, text, options, selected)
local holder = make("Frame", {
Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
LayoutOrder = nextOrder(),
}, parent)
make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, holder)
local head = rowFrame(holder, 56)
head.LayoutOrder = 1
rowLabel(head, text, 190)
local btn = make("TextButton", {
AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(176, 38),
BackgroundColor3 = THEME.Panel, AutoButtonColor = false, Text = "",
}, head)
addCorner(btn, 10)
addStroke(btn, THEME.Line, 1, 0.3)
local dot = make("Frame", {
Position = UDim2.fromOffset(10, 12), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.new(1, 1, 1),
}, btn)
addCorner(dot, 7)
local valueLabel = make("TextLabel", {
Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -62, 1, 0), BackgroundTransparency = 1,
TextColor3 = THEME.Text, TextSize = 17, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
}, btn)
do
local ic = T.icon("updown", btn, 18, THEME.Text)
ic.AnchorPoint = Vector2.new(1, 0.5)
ic.Position = UDim2.new(1, -10, 0.5, 0)
end
local list = make("Frame", {
Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = THEME.Row,
Visible = false, LayoutOrder = 2,
}, holder)
addCorner(list, 12)
addStroke(list, THEME.Line, 1, 0.55)
make("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, list)
make("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }, list)
local optButtons, checks = {}, {}
for _, opt in ipairs(options) do
local ob = make("TextButton", {
Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = THEME.RowSel, BackgroundTransparency = 1,
AutoButtonColor = false, Text = "", LayoutOrder = nextOrder(),
}, list)
addCorner(ob, 9)
local od = make("Frame", {
Position = UDim2.fromOffset(10, 12), Size = UDim2.fromOffset(14, 14),
BackgroundColor3 = opt.color or Color3.new(1, 1, 1),
}, ob)
addCorner(od, 7)
if opt.noDot then od.Visible = false end
if opt.rainbow then T.rainbow[od] = true end
make("TextLabel", {
Position = UDim2.fromOffset(opt.noDot and 12 or 34, 0), Size = UDim2.new(1, -74, 1, 0), BackgroundTransparency = 1,
Text = opt.label, TextColor3 = THEME.Text, TextSize = 17, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left,
}, ob)
checks[opt.key] = T.icon("check", ob, 20, THEME.On)
checks[opt.key].AnchorPoint = Vector2.new(1, 0.5)
checks[opt.key].Position = UDim2.new(1, -8, 0.5, 0)
checks[opt.key].Visible = false
ob.Activated:Connect(function()
if opt.key == "all" then
for k in pairs(selected) do selected[k] = nil end
else
selected[opt.key] = (not selected[opt.key]) or nil
end
refreshAll()
end)
optButtons[opt.key] = ob
end
btn.Activated:Connect(function() list.Visible = not list.Visible end)
local function refresh()
local names, firstOpt = {}, nil
for _, opt in ipairs(options) do
if opt.key ~= "all" and selected[opt.key] then
names[#names + 1] = opt.label
firstOpt = firstOpt or opt
end
end
local none = #names == 0
if none then
valueLabel.Text = "الكل"
dot.Visible = false
valueLabel.Position = UDim2.fromOffset(12, 0)
valueLabel.Size = UDim2.new(1, -42, 1, 0)
T.rainbow[dot] = nil
elseif #names == 1 then
valueLabel.Text = names[1]
dot.Visible = true
dot.BackgroundColor3 = firstOpt.color or Color3.new(1, 1, 1)
valueLabel.Position = UDim2.fromOffset(32, 0)
valueLabel.Size = UDim2.new(1, -62, 1, 0)
T.rainbow[dot] = firstOpt.rainbow and true or nil
else
valueLabel.Text = table.concat(names, "، ")
dot.Visible = false
valueLabel.Position = UDim2.fromOffset(12, 0)
valueLabel.Size = UDim2.new(1, -42, 1, 0)
T.rainbow[dot] = nil
end
for _, opt in ipairs(options) do
local on = (opt.key == "all") and none or (selected[opt.key] == true)
optButtons[opt.key].BackgroundTransparency = on and 0 or 1
checks[opt.key].Visible = on
end
end
table.insert(refreshers, refresh)
register(holder, text)
refresh()
end
local function createDynDropdown(parent, text, getOptions, getter, setter, describe, onDelete)
local holder = make("Frame", {
Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
LayoutOrder = nextOrder(),
}, parent)
make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, holder)
local head = rowFrame(holder, 56)
head.LayoutOrder = 1
rowLabel(head, text, 190)
local btn = make("TextButton", {
AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(176, 38),
BackgroundColor3 = THEME.Panel, AutoButtonColor = false, Text = "",
}, head)
addCorner(btn, 10)
addStroke(btn, THEME.Line, 1, 0.3)
local dot = make("Frame", {
Position = UDim2.fromOffset(10, 12), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.new(1, 1, 1),
}, btn)
addCorner(dot, 7)
local valueLabel = make("TextLabel", {
Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -62, 1, 0), BackgroundTransparency = 1,
TextColor3 = THEME.Text, TextSize = 17, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
}, btn)
do
local ic = T.icon("updown", btn, 18, THEME.Text)
ic.AnchorPoint = Vector2.new(1, 0.5)
ic.Position = UDim2.new(1, -10, 0.5, 0)
end
local list = make("Frame", {
Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = THEME.Row,
Visible = false, LayoutOrder = 2,
}, holder)
addCorner(list, 12)
addStroke(list, THEME.Line, 1, 0.55)
make("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, list)
make("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }, list)
local function rebuild()
for _, c in ipairs(list:GetChildren()) do
if c:IsA("TextButton") then c:Destroy() end
end
local opts = getOptions()
local cur = getter()
for i, opt in ipairs(opts) do
if i > 40 then break end
local ob = make("TextButton", {
Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = THEME.RowSel,
BackgroundTransparency = (opt.key == cur) and 0 or 1,
AutoButtonColor = false, Text = "", LayoutOrder = i,
}, list)
addCorner(ob, 9)
local od = make("Frame", {
Position = UDim2.fromOffset(10, 12), Size = UDim2.fromOffset(14, 14),
BackgroundColor3 = opt.color or Color3.new(1, 1, 1),
}, ob)
addCorner(od, 7)
if opt.rainbow then T.rainbow[od] = true end
make("TextLabel", {
Position = UDim2.fromOffset(34, 0), Size = UDim2.new(1, onDelete and -78 or -44, 1, 0), BackgroundTransparency = 1,
Text = opt.label, TextColor3 = THEME.Text, TextSize = 17, Font = FONT,
TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
}, ob)
ob.Activated:Connect(function()
safe(text, setter, opt.key)
list.Visible = false
refreshAll()
end)
if onDelete then
local xb = make("TextButton", {
AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.fromOffset(26, 26),
BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0, Text = "X", TextColor3 = Color3.new(1, 1, 1), TextSize = 14, Font = FONT, AutoButtonColor = false, ZIndex = 3,
}, ob)
addCorner(xb, 7)
xb.Activated:Connect(function()
safe(text, onDelete, opt.key)
local n2 = rebuild()
list.Visible = n2 > 0
refreshAll()
end)
end
end
return #opts
end
btn.Activated:Connect(function()
if list.Visible then
list.Visible = false
else
local n = 0
safe(text, function() n = rebuild() end)
list.Visible = n > 0
end
end)
local function refresh()
local label, color, rainbow = describe(getter())
valueLabel.Text = label
dot.Visible = color ~= nil
valueLabel.Position = UDim2.fromOffset(color and 32 or 12, 0)
valueLabel.Size = UDim2.new(1, color and -62 or -42, 1, 0)
if color then dot.BackgroundColor3 = color end
T.rainbow[dot] = rainbow and true or nil
end
table.insert(refreshers, refresh)
register(holder, text)
refresh()
end
local function createButton(parent, text, callback, danger)
local btn = rowFrame(parent, 46, "TextButton")
btn.BackgroundColor3 = danger and THEME.Danger or THEME.RowSel
-- نص يبدأ بـ {اسم_أيقونة} يرسم الأيقونة المطابقة على يسار الزر
local iconName, rest = string.match(text, "^{(%w+)}(.*)$")
if iconName then text = rest end
make("TextLabel", {
Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = text,
TextColor3 = THEME.Text, TextSize = 17, Font = FONT,
}, btn)
if iconName then
local ic = T.icon(iconName, btn, 24, THEME.Text, THEME.Cyan)
ic.AnchorPoint = Vector2.new(0, 0.5)
ic.Position = UDim2.new(0, 14, 0.5, 0)
end
btn.Activated:Connect(function() safe(text, callback) end)
register(btn, text)
return btn
end
local function createInfo(parent, text, searchable)
local row = rowFrame(parent, 0)
row.AutomaticSize = Enum.AutomaticSize.Y
row.Size = UDim2.new(1, 0, 0, 0)
make("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, row)
local label = make("TextLabel", {
Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
Text = text, TextWrapped = true, TextColor3 = THEME.Text, TextSize = 16, Font = FONT,
TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
}, row)
if searchable then register(row, text) end
return label, row
end
local function createTextField(parent, text, placeholder)
local row = rowFrame(parent, 56)
rowLabel(row, text, 170)
local box = make("TextBox", {
AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(156, 38),
BackgroundColor3 = THEME.Panel, Text = "", PlaceholderText = placeholder,
PlaceholderColor3 = Color3.fromRGB(170, 180, 205), TextColor3 = THEME.Text, TextSize = 16, Font = FONT,
ClearTextOnFocus = false,
}, row)
addCorner(box, 10)
addStroke(box, THEME.Line, 1, 0.3)
register(row, text)
return box
end
local function createInput(parent, text, placeholder, onSubmit)
local row = rowFrame(parent, 56)
rowLabel(row, text, 170)
local box = make("TextBox", {
AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(156, 38),
BackgroundColor3 = THEME.Panel, Text = "", PlaceholderText = placeholder,
PlaceholderColor3 = Color3.fromRGB(170, 180, 205), TextColor3 = THEME.Text, TextSize = 16, Font = FONT,
ClearTextOnFocus = false,
}, row)
addCorner(box, 10)
addStroke(box, THEME.Line, 1, 0.3)
box.FocusLost:Connect(function()
local t = box.Text
if t ~= "" then
safe(text, onSubmit, t)
box.Text = ""
end
end)
register(row, text)
return row
end
do
local radarPage = newPage("الرادار", "radar")
section(radarPage, "الكشف (ESP)")
createToggle(radarPage, "تشغيل الكشف (ESP)", function() return state.espOn end, function(v)
state.espOn = v
if not v then
for _, radar in ipairs(radars) do clearMarkers(radar) end
end
end)
createToggle(radarPage, "رادار الضبان", function() return dhabRadar.enabled end, function(v) setRadar(dhabRadar, v) end)
createToggle(radarPage, "كشف اللاعبين", function() return playersRadar.enabled end, function(v) setRadar(playersRadar, v) end)
createToggle(radarPage, "كشف السيارات", function() return carsRadar.enabled end, function(v) setRadar(carsRadar, v) end)
createToggle(radarPage, "كشف تاجر الخلا", function() return traderRadar.enabled end, function(v) setRadar(traderRadar, v) end)
createToggle(radarPage, "كشف شيخ النفود", function() return T.sheikhRadar.enabled end, function(v) setRadar(T.sheikhRadar, v) end)
createToggle(radarPage, "تنبيه رسبنة شيخ النفود", function() return T.sk.alert end, function(v) T.sk.alert = v end)
createToggle(radarPage, "الخطوط (Tracers)", function() return state.tracersOn end, function(v) state.tracersOn = v end)
local RARITY_OPTIONS = { { key = "all", label = "الكل", noDot = true } }
for _, key in ipairs(RARITY_ORDER) do
table.insert(RARITY_OPTIONS, {
key = key, label = RARITIES[key].label, color = RARITIES[key].color, rainbow = (key == "rainbow"),
})
end
section(radarPage, "الكشف حسب الندرة")
createToggle(radarPage, "تشغيل الكشف حسب الندرة", function() return dhabRadar.rarityFilter end,
function(v) dhabRadar.rarityFilter = v end)
createMultiDropdown(radarPage, "الندرة", RARITY_OPTIONS, dhabRadar.rarities)
section(radarPage, "المدى البعيد")
createToggle(radarPage, "تحميل المناطق البعيدة (يقوّي المدى)", function() return state.farStream end,
function(v) state.farStream = v end)
do
local lbl = createInfo(radarPage, "", false)
table.insert(refreshers, function()
local okS, streaming = pcall(function() return workspace.StreamingEnabled end)
if okS and streaming then
local okR, rad = pcall(function() return workspace.StreamingTargetRadius end)
lbl.Text = "اللعبة تحمّل الخريطة تدريجياً" .. ((okR and typeof(rad) == "number") and (" (نصف القطر " .. math.floor(rad) .. ")") or "") .. ". الضبان خارجه ما تنحمّل عندك، والخيار فوق يحاول يحمّلها."
else
lbl.Text = "الخريطة محمّلة كاملة، أي ضب داخل المدى يظهر."
end
end)
end
section(radarPage, "العرض")
createToggle(radarPage, "علامات فوق الأهداف", function() return dhabRadar.markers end, function(v)
for _, radar in ipairs(radars) do
radar.markers = v
if not v then clearMarkers(radar) end
end
end)
T.createStepper(radarPage, "حجم العلامات + / -", function() return state.hudSize end,
function(v) state.hudSize = v; applyHudSize() end, CONFIG.MarkerMin, CONFIG.MarkerMax, 1)
createSlider(radarPage, "حجم الخط", function() return state.hudSize end,
function(v) state.hudSize = v; applyHudSize() end, CONFIG.MarkerMin, CONFIG.MarkerMax, 1, function(v) return tostring(v) end)
createSlider(radarPage, "مدى الرادار", function() return state.range end,
function(v) state.range = v end, 100, 2000, 50, function(v) return v .. " Studs" end)
for _, radar in ipairs(radars) do
radar.status = { Text = "" }
end
end
do
local speedPage = newPage("اللاعب", "bolt")
section(speedPage, "السرعة")
createToggle(speedPage, "تشغيل السرعة", function() return state.speedOn end, function(v)
state.speedOn = v
applyMovement()
end)
createSlider(speedPage, "سرعة اللاعب", function() return state.speed end,
function(v) state.speed = v; applyMovement() end, 16, CONFIG.SpeedMax, 2,
function(v) return v <= 16 and "عادي" or tostring(v) end)
do
local note = createInfo(speedPage, "السرعه الموصى بها 32 ما يعلق", false)
note.Name = "KeepColor"
note.TextColor3 = Color3.fromRGB(255, 70, 70)
note.TextSize = 13
end
section(speedPage, "القفز")
createToggle(speedPage, "تشغيل القفز", function() return state.jumpOn end, function(v)
state.jumpOn = v
applyMovement()
end)
createSlider(speedPage, "قوة القفز", function() return state.jump end,
function(v) state.jump = v; applyMovement() end, 50, CONFIG.JumpMax, 5,
function(v) return v <= 50 and "عادي" or tostring(v) end)
do
local note = createInfo(speedPage, "القوة الموصى بها 70 او 65 مايعلق", false)
note.Name = "KeepColor"
note.TextColor3 = Color3.fromRGB(255, 70, 70)
note.TextSize = 13
end
section(speedPage, "ميزات اللاعب")
createToggle(speedPage, "اختراق الجدران", function() return state.noclip end, function(v) state.noclip = v end)
track(RunService.Stepped:Connect(function()
if not state.noclip then return end
local char = getCharacter()
if not char then return end
for _, d in ipairs(char:GetDescendants()) do
if d:IsA("BasePart") and d.CanCollide then d.CanCollide = false end
end
end))
end
do
local carPage = newPage("السيارة", "car")
section(carPage, "تيربو")
createToggle(carPage, "تيربو (Shift أو زر التيربو)", function() return state.nitroOn end, function(v) state.nitroOn = v end)
createSlider(carPage, "قوة التيربو", function() return state.nitroPower end,
function(v) state.nitroPower = v end, 100, 5000, 50, function(v) return v .. "%" end)
do
local note = createInfo(carPage, "قوة التيربو الموصى بها: 1000", false)
note.Name = "KeepColor"
note.TextColor3 = Color3.fromRGB(255, 70, 70)
note.TextSize = 13
end
createSlider(carPage, "أقصى سرعة للتيربو", function() return state.nitroMax end,
function(v) state.nitroMax = v end, 50, 700, 10, function(v) return v .. " سرعة" end)
do
local note = createInfo(carPage, "أقصى سرعة للتيربو الموصى بها: 250 (ما يعلق)", false)
note.Name = "KeepColor"
note.TextColor3 = Color3.fromRGB(255, 70, 70)
note.TextSize = 13
end
section(carPage, "الركوب")
createToggle(carPage, "منع الركوب التلقائي (السيارة ما تركبك لما تقرب منها)", function() return state.noAutoSit end,
function(v)
state.noAutoSit = v
local h = getHumanoid()
T.okSeat = h and h.SeatPart or nil
end)
section(carPage, "طيران السيارة (VFly)")
createToggle(carPage, "تشغيل طيران السيارة (VFly)", function() return state.flyOn end, function(v)
state.flyOn = v
if not v then carFlags.up, carFlags.down = false, false end
end)
createSlider(carPage, "سرعة الطيران (1-13)", function() return state.flySpeed end,
function(v) state.flySpeed = v end, 1, 13, 1, function(v) return v .. "x" end)
section(carPage, "قفزة السيارة")
createSlider(carPage, "قوة القفزة", function() return state.carJump end,
function(v) state.carJump = v end, 50, 300, 10)
createButton(carPage, "قفزة عمودية", function() carKick() end)
createToggle(carPage, "زر القفز على الشاشة", function() return state.jumpBtn end,
function(v) state.jumpBtn = v end)
section(carPage, "المساعدات")
createToggle(carPage, "تقوية المساعدات (ثبات بدون نقز)", function() return state.suspOn end,
function(v) state.suspOn = v end)
createSlider(carPage, "قوة المساعدات", function() return state.suspPower end,
function(v) state.suspPower = v end, 0, 300, 10, function(v) return v .. "%" end)
createToggle(carPage, "ثبات الاتجاه (ما تحوص ولا تلف مع السرعة)", function() return state.stableOn end,
function(v) state.stableOn = v end)
section(carPage, "أزرار السيارة")
createToggle(carPage, "تحريك الأزرار (اسحب أي زر لمكانه)", function() return state.padEdit end,
function(v) state.padEdit = v end)
section(carPage, "مشي بدون بنزين")
createToggle(carPage, "مشي بدون بنزين (زر للأمام فقط)", function() return state.walkOn end,
function(v) state.walkOn = v end)
createSlider(carPage, "سرعة المشي", function() return state.walkSpeed end,
function(v) state.walkSpeed = v end, 1, 13, 1, function(v) return v .. "x" end)
section(carPage, "تعديل السيارة")
createToggle(carPage, "جعل العوائق غير قابلة للمس", function() return state.ghostOn end, function(v)
state.ghostOn = v
if not v then ghostRestore(true) end
end)
createButton(carPage, "إعادة الدخول للسيارة", reenterCar)
do
local C = {
orig = setmetatable({}, { __mode = "k" }),
wo = setmetatable({}, { __mode = "k" }),
so = setmetatable({}, { __mode = "k" }),
springs = {}, modeCar = nil, liftMode = nil, base = nil,
body = nil, wheels = nil, scanT = -100, car = nil, light = nil, dirty = false, acc = 0, quick = nil,
GREEN = Color3.fromRGB(60, 255, 90),
WHEEL_WORDS = { "wheel", "tire", "tyre", "كفر", "عجل", "تاير", "جنط" },
SKIP_WORDS = { "light", "lamp", "glass", "window", "windshield", "نور", "ضوء", "مصباح", "زجاج", "شباك" },
MATS = { Plastic = Enum.Material.Plastic, SmoothPlastic = Enum.Material.SmoothPlastic,
Metal = Enum.Material.Metal, Foil = Enum.Material.Foil, Neon = Enum.Material.Neon },
MAT_LABEL = { orig = "أصلية", Plastic = "عادية", SmoothPlastic = "ناعمة", Metal = "معدن", Foil = "فويل", Neon = "نيون" },
QUICK = {
{ "أحمر", 230, 30, 30 }, { "أزرق", 30, 90, 240 }, { "أخضر", 30, 200, 80 },
{ "أسود", 15, 15, 15 }, { "أبيض", 245, 245, 245 }, { "ذهبي", 255, 190, 30 },
},
FXKEYS = { "carColorOn", "carR", "carG", "carB", "carRainbow", "carBlink", "carAnimSpeed", "carShine",
"carShinePulse", "carShinePower", "carMat", "carTrans", "carGlow", "carGlowPower", "carWheelColor",
"wheelOn", "wheelW", "wheelS", "liftOn", "liftLvl", "viewMode" },
VIEW = { orig = setmetatable({}, { __mode = "k" }), on = false, acc = 0, pos = nil },
VIEW_T = 0.65,
hoverParams = RaycastParams.new(),
}
C.hoverParams.FilterType = Enum.RaycastFilterType.Exclude
T.CarFX = C
state.viewMode = false
state.liftLvl = math.clamp(math.floor(state.liftLvl), 0, 5)

function C.topModel(seat)
local m = seat:FindFirstAncestorOfClass("Model")
while m and m.Parent and m.Parent:IsA("Model") do m = m.Parent end
return m
end

function C.info(p)
local o = C.orig[p]
if not o then
local inc = p.Transparency < 0.5 and p.Material ~= Enum.Material.Glass
and p.Material ~= Enum.Material.Neon and p.Material ~= Enum.Material.ForceField
and not matches(p.Name, C.SKIP_WORDS)
o = { inc = inc, c = p.Color, m = p.Material, r = p.Reflectance, t = p.Transparency }
C.orig[p] = o
end
return o
end

function C.setProp(p, o, prop, on, val, orig)
if on then
if p[prop] ~= val then p[prop] = val end
o["x" .. prop] = true
elseif o["x" .. prop] then
p[prop] = orig
o["x" .. prop] = nil
end
end

function C.scan(car)
local body, wheels, cyl, springs = {}, {}, {}, {}
for _, d in ipairs(car:GetDescendants()) do
if d:IsA("BasePart") then
local s = d.Size
local mx = math.max(s.X, s.Y, s.Z)
local par = d.Parent
local isW = C.wo[d] ~= nil or ((matches(d.Name, C.WHEEL_WORDS) or (par and par ~= car and matches(par.Name, C.WHEEL_WORDS))) and mx < 30)
if isW then
wheels[#wheels + 1] = d
else
if d:IsA("Part") and d.Shape == Enum.PartType.Cylinder and mx < 12 then cyl[#cyl + 1] = d end
body[#body + 1] = d
end
elseif d:IsA("SpringConstraint") then
springs[#springs + 1] = d
end
end
if #wheels == 0 and #cyl > 0 then
local set = {}
for _, w in ipairs(cyl) do set[w] = true end
local nb = {}
for _, b in ipairs(body) do if not set[b] then nb[#nb + 1] = b end end
wheels, body = cyl, nb
end
C.body, C.wheels, C.scanT, C.springs = body, wheels, os.clock(), springs
end

function C.setSpring(d, o, l)
if d.MaxLength < o.max + l then
pcall(function() d.MaxLength = o.max + l end)
pcall(function() d.FreeLength = o.free + l end)
pcall(function() d.MinLength = o.min + l end)
else
pcall(function() d.MinLength = o.min + l end)
pcall(function() d.FreeLength = o.free + l end)
pcall(function() d.MaxLength = o.max + l end)
end
end

function C.restoreAll()
for d, o in pairs(C.so) do
if o.on then
if d.Parent then C.setSpring(d, o, 0) end
o.on, o.l = nil, nil
end
end
for p, o in pairs(C.orig) do
if p.Parent then
if o.xColor then p.Color = o.c end
if o.xMaterial then p.Material = o.m end
if o.xReflectance then p.Reflectance = o.r end
if o.xTransparency then p.Transparency = o.t end
end
o.xColor, o.xMaterial, o.xReflectance, o.xTransparency = nil, nil, nil, nil
end
for w, o in pairs(C.wo) do
if o.on then
if w.Parent then w.Size = o.size end
o.on = nil
end
end
if C.light then C.light:Destroy() C.light = nil end
end

function C.step()
local any = state.carColorOn or state.carRainbow or state.carBlink or state.carMat ~= "orig"
or state.carShine or state.carShinePulse or state.carTrans > 0 or state.carGlow
or state.wheelOn or state.carWheelColor or state.liftOn
if not any then
if C.dirty then C.dirty = false C.restoreAll() end
return
end
C.dirty = true
local seat, root = getCar()
if not seat then return end
local car = C.topModel(seat)
if not car then return end
local now = os.clock()
if C.car ~= car or not C.body or now - C.scanT > 3 then
C.car = car
C.scan(car)
end
local colorize = state.carColorOn or state.carRainbow or state.carBlink
local col
if state.carRainbow then
col = Color3.fromHSV((now * state.carAnimSpeed * 0.1) % 1, 0.9, 1)
else
col = Color3.fromRGB(state.carR, state.carG, state.carB)
if state.carBlink and math.floor(now * state.carAnimSpeed * 1.5) % 2 == 1 then
col = Color3.new(1 - col.R, 1 - col.G, 1 - col.B)
end
end
local mat = C.MATS[state.carMat]
local refl = state.carShinePower / 100
if state.carShinePulse then refl = refl * (0.5 + 0.5 * math.sin(now * 4)) end
local shineOn = state.carShine or state.carShinePulse
local trans = state.carTrans / 100
for _, p in ipairs(C.body) do
if p.Parent then
local o = C.info(p)
if o.inc then
C.setProp(p, o, "Color", colorize, col, o.c)
C.setProp(p, o, "Material", mat ~= nil, mat, o.m)
C.setProp(p, o, "Reflectance", shineOn, refl, o.r)
C.setProp(p, o, "Transparency", trans > 0, trans, o.t)
end
end
end
-- الكفرات: العرض على محور الدوران، والحجم يُطبَّق على القطرين بنفس النسبة فيبقى الكفر دائري
local wheelTint = colorize and state.carWheelColor
local ws, ss = state.wheelW / 100, state.wheelS / 100
for _, w in ipairs(C.wheels) do
if w.Parent then
local o = C.info(w)
C.setProp(w, o, "Color", wheelTint, col, o.c)
local wo = C.wo[w]
if not wo then
local s = w.Size
local axis, mn = "X", s.X
if s.Y < mn then axis, mn = "Y", s.Y end
if s.Z < mn then axis, mn = "Z", s.Z end
wo = { size = s, axis = axis }
C.wo[w] = wo
end
if state.wheelOn then
local s = wo.size
local n
if wo.axis == "X" then n = Vector3.new(s.X * ws, s.Y * ss, s.Z * ss)
elseif wo.axis == "Y" then n = Vector3.new(s.X * ss, s.Y * ws, s.Z * ss)
else n = Vector3.new(s.X * ss, s.Y * ss, s.Z * ws) end
if (w.Size - n).Magnitude > 0.01 then w.Size = n end
wo.on = true
elseif wo.on then
w.Size = wo.size
wo.on = nil
end
end
end
-- رفع السيارة
local lift = state.liftOn and math.clamp(state.liftLvl, 0, 5) * 4 or 0
C.liftMode = (#C.springs > 0) and "spring" or "hover"
if state.liftOn and C.modeCar ~= car then
C.modeCar = car
notify(C.liftMode == "spring" and "رفع السيارة: عن طريق المساعدات" or "رفع السيارة: بالتحليق (لو ما تحركت استخدم تيربو أو مشي بدون بنزين)")
end
for _, d in ipairs(C.springs) do
if d.Parent then
local o = C.so[d]
if not o then
o = { free = d.FreeLength, min = d.MinLength, max = d.MaxLength }
C.so[d] = o
end
if lift > 0 then
if o.l ~= lift then
C.setSpring(d, o, lift)
o.l, o.on = lift, true
end
elseif o.on then
C.setSpring(d, o, 0)
o.l, o.on = nil, nil
end
end
end
if state.carGlow and root then
if not C.light or C.light.Parent ~= root then
if C.light then C.light:Destroy() end
local l = Instance.new("PointLight")
l.Name, l.Shadows, l.Parent = "RXZGlow", false, root
C.light = l
end
C.light.Color = col
C.light.Brightness = state.carGlowPower
C.light.Range = math.min(12 + state.carGlowPower * 4, 60)
elseif C.light then
C.light:Destroy()
C.light = nil
end
end

track(RunService.Heartbeat:Connect(function(dt)
C.acc += dt
local fast = state.carRainbow or state.carBlink or state.carShinePulse or state.carGlow
if C.acc < (fast and 0.04 or 0.25) then return end
C.acc = 0
safe("ألوان السيارة", C.step)
end))

-- رفع السيارة: المساعدات ترفع، وهذا يكمّل الارتفاع الناقص حتى يوصل المستوى المطلوب
track(RunService.Heartbeat:Connect(function()
if not state.liftOn or state.liftLvl <= 0 or state.flyOn or T.navBusy then
C.base = nil
return
end
local seat, root = getCar()
if not seat then
C.base = nil
return
end
C.hoverParams.FilterDescendantsInstances = { C.topModel(seat) or seat, getCharacter() }
local hit = workspace:Raycast(root.Position, Vector3.new(0, -3000, 0), C.hoverParams)
if not hit then return end
local d = hit.Distance
if not C.base then C.base = d end
local target = C.base + math.min(state.liftLvl, 5) * 4
local lo = (C.liftMode == "hover") and -120 or 0
local vy = math.clamp((target - d) * 6, lo, 120)
local v = root.AssemblyLinearVelocity
if (vy > 0 and v.Y < vy) or vy < 0 then
root.AssemblyLinearVelocity = Vector3.new(v.X, vy, v.Z)
end
end))

-- وضع التعديل: القائمة تصغر وتنزاح للزاوية وتصير شفافة عشان تشوف السيارة
function C.viewApply()
local V = C.VIEW
if not V.on then
V.on = true
V.pos = window.Position
window.Position = UDim2.fromOffset(4, 4)
task.defer(function() pcall(clampFrame, window) end)
end
T.bgImg.ImageTransparency = 0.92
local target = state.userScale * 0.55
if uiScale.Scale ~= target then uiScale.Scale = target end
for _, d in ipairs(window:GetDescendants()) do
if (d:IsA("Frame") or d:IsA("TextButton") or d:IsA("ScrollingFrame") or d:IsA("TextBox"))
and d.BackgroundTransparency < C.VIEW_T and d.AbsoluteSize.Y >= 30 and not d:IsDescendantOf(sidebar) then
if V.orig[d] == nil then V.orig[d] = d.BackgroundTransparency end
d.BackgroundTransparency = C.VIEW_T
end
end
end

function C.viewRestore()
local V = C.VIEW
if not V.on then return end
V.on = false
T.bgImg.ImageTransparency = state.bgTransparency
uiScale.Scale = state.userScale
for d, t in pairs(V.orig) do
if d.Parent and math.abs(d.BackgroundTransparency - C.VIEW_T) < 0.001 then d.BackgroundTransparency = t end
V.orig[d] = nil
end
if V.pos then
window.Position = V.pos
V.pos = nil
task.defer(function() pcall(clampFrame, window) end)
end
end

track(RunService.Heartbeat:Connect(function(dt)
local V = C.VIEW
V.acc += dt
if V.acc < 0.25 then return end
V.acc = 0
if state.viewMode and isOpen then
safe("وضع التعديل", C.viewApply)
elseif not state.viewMode and V.on then
safe("وضع التعديل", C.viewRestore)
end
end))

-- إطار أخضر على كل ميزة جديدة
function C.green(parent)
local last, lo
for _, c in ipairs(parent:GetChildren()) do
if c:IsA("GuiObject") and (not lo or c.LayoutOrder > lo) then last, lo = c, c.LayoutOrder end
end
if not last then return end
local st = last:FindFirstChildOfClass("UIStroke") or addStroke(last, C.GREEN, 2, 0)
st.Color, st.Thickness, st.Transparency = C.GREEN, 2, 0
end
function C.quickPick(v)
local q = C.QUICK[v]
state.carR, state.carG, state.carB = q[2], q[3], q[4]
state.carColorOn, state.carRainbow = true, false
C.quick = v
end
function C.quickLabel(v) return C.QUICK[v][1] end
function C.quickGet() return C.quick end
function C.matLabel(v) return C.MAT_LABEL[v] end
function C.matGet() return state.carMat end
function C.matPick(v) state.carMat = v end
local function add(fn, ...)
fn(carPage, ...)
C.green(carPage)
end

section(carPage, "وضع التعديل (جديد)")
add(createToggle, "وضع التعديل: قائمة صغيرة وشفافة بالزاوية عشان أشوف السيارة", function() return state.viewMode end, function(v) state.viewMode = v end)

section(carPage, "ألوان ولمعان السيارة (جديد)")
add(createToggle, "تغيير لون السيارة", function() return state.carColorOn end, function(v) state.carColorOn = v end)
add(createSlider, "اللون: أحمر", function() return state.carR end, function(v) state.carR = v; C.quick = nil end, 0, 255, 5)
add(createSlider, "اللون: أخضر", function() return state.carG end, function(v) state.carG = v; C.quick = nil end, 0, 255, 5)
add(createSlider, "اللون: أزرق", function() return state.carB end, function(v) state.carB = v; C.quick = nil end, 0, 255, 5)
add(createChips, "ألوان جاهزة", { 1, 2, 3 }, C.quickGet, C.quickPick, C.quickLabel)
add(createChips, "ألوان جاهزة ", { 4, 5, 6 }, C.quickGet, C.quickPick, C.quickLabel)
add(createToggle, "تلوين متحرك (قوس قزح)", function() return state.carRainbow end, function(v) state.carRainbow = v end)
add(createToggle, "وميض الألوان (شرطة)", function() return state.carBlink end, function(v) state.carBlink = v end)
add(createSlider, "سرعة التلوين والوميض", function() return state.carAnimSpeed end, function(v) state.carAnimSpeed = v end, 1, 20, 1)
add(createToggle, "لمعان السيارة", function() return state.carShine end, function(v) state.carShine = v end)
add(createToggle, "لمعان نابض (يلمع ويخفت)", function() return state.carShinePulse end, function(v) state.carShinePulse = v end)
add(createSlider, "قوة اللمعان", function() return state.carShinePower end, function(v) state.carShinePower = v end, 0, 100, 5, function(v) return v .. "%" end)
add(createChips, "خامة السيارة", { "orig", "SmoothPlastic", "Metal" }, C.matGet, C.matPick, C.matLabel)
add(createChips, "خامة السيارة ", { "Foil", "Neon", "Plastic" }, C.matGet, C.matPick, C.matLabel)
add(createSlider, "شفافية الهيكل", function() return state.carTrans end, function(v) state.carTrans = v end, 0, 80, 5, function(v) return v .. "%" end)
add(createToggle, "إضاءة تحت السيارة (بلون السيارة)", function() return state.carGlow end, function(v) state.carGlow = v end)
add(createSlider, "قوة الإضاءة", function() return state.carGlowPower end, function(v) state.carGlowPower = v end, 1, 10, 1)
add(createToggle, "تلوين الكفرات مع السيارة", function() return state.carWheelColor end, function(v) state.carWheelColor = v end)

section(carPage, "رفع السيارة (جديد)")
add(createToggle, "رفع السيارة", function() return state.liftOn end, function(v) state.liftOn = v end)
add(createSlider, "مستوى الرفع (0 - 5)", function() return state.liftLvl end, function(v)
state.liftLvl = v
state.liftOn = v > 0
end, 0, 5, 1, function(v) return v == 0 and "مطفي" or ("مستوى " .. v) end)

section(carPage, "حجم الكفرات (جديد)")
add(createToggle, "تغيير حجم الكفرات", function() return state.wheelOn end, function(v) state.wheelOn = v end)
add(createSlider, "عرض الكفر", function() return state.wheelW end, function(v) state.wheelW = v end, 60, 250, 5, function(v) return v .. "%" end)
add(createSlider, "سمك الكفر (حجم الدائرة)", function() return state.wheelS end, function(v) state.wheelS = v end, 70, 200, 5, function(v) return v .. "%" end)
add(createButton, "إرجاع السيارة والكفرات للأصل", function()
for _, k in ipairs(C.FXKEYS) do state[k] = DEFAULTS[k] end
C.quick = nil
refreshAll()
notify("تم إرجاع شكل السيارة")
end, true)
end
end
do
local tpPage = newPage("التنقل", "navigate")
local sitOn
local holdToken = 0
local function topObjOf(inst)
local m = inst:FindFirstAncestorOfClass("Model")
local obj = m
while obj and obj.Parent and obj.Parent:IsA("Model") do obj = obj.Parent end
return obj or inst
end
-- القلص/الكرفان: كل موديل مربوط بالسيارة (لحام أو قيد أو حبل) ننقله معها بنفس الوضع النسبي
function T.attachedFor(obj, pv)
local found, seen = {}, { [obj] = true }
local queue, qi = { obj }, 1
local function consider(other, from)
if not (other and other:IsA("BasePart")) or other == from or other:IsDescendantOf(from) then return end
if other.Anchored then return end
local top = topObjOf(other)
if seen[top] or top == workspace then return end
if top:IsA("Model") then
if Players:GetPlayerFromCharacter(top) then return end
local okz, sz = pcall(function() return top:GetExtentsSize() end)
if okz and math.max(sz.X, sz.Y, sz.Z) > 400 then return end
end
seen[top] = true
found[#found + 1] = top
queue[#queue + 1] = top
end
local function fromJoint(j, part, cur)
if j:IsA("JointInstance") or j:IsA("WeldConstraint") then
consider(j.Part0 == part and j.Part1 or j.Part0, cur)
elseif j:IsA("Constraint") then
local a0, a1 = j.Attachment0, j.Attachment1
local p0, p1 = a0 and a0.Parent, a1 and a1.Parent
consider(p0 == part and p1 or p0, cur)
end
end
while qi <= #queue and #found < 40 do
local cur = queue[qi]
qi += 1
local list = cur:IsA("BasePart") and { cur } or cur:GetDescendants()
for _, part in ipairs(list) do
if part:IsA("BasePart") then
local okj, joints = pcall(function() return part:GetJoints() end)
if okj then
for _, j in ipairs(joints) do fromJoint(j, part, cur) end
end
end
end
end
if #found == 0 then
-- احتياط: بعض الألعاب تربط القلص بقيد خارج موديل السيارة، نفحص القيود في الخريطة
for _, d in ipairs(workspace:GetDescendants()) do
if d:IsA("Constraint") or d:IsA("WeldConstraint") then
local pa, pb
if d:IsA("WeldConstraint") then
pa, pb = d.Part0, d.Part1
else
pa, pb = d.Attachment0 and d.Attachment0.Parent, d.Attachment1 and d.Attachment1.Parent
end
if pa and pb and pa:IsA("BasePart") and pb:IsA("BasePart") then
if pa:IsDescendantOf(obj) and not pb:IsDescendantOf(obj) then
consider(pb, obj)
elseif pb:IsDescendantOf(obj) and not pa:IsDescendantOf(obj) then
consider(pa, obj)
end
end
end
end
end
local out = {}
for _, inst in ipairs(found) do
local okp, ipv = pcall(function() return inst:GetPivot() end)
if okp then out[#out + 1] = { inst = inst, rel = pv:ToObjectSpace(ipv) } end
end
return out
end
function T.moveExtras(list, cf)
for _, ex in ipairs(list or {}) do
if ex.inst.Parent then
pcall(function()
ex.inst:PivotTo(cf * ex.rel)
local p = ex.inst:IsA("BasePart") and ex.inst or (ex.inst.PrimaryPart or ex.inst:FindFirstChildWhichIsA("BasePart", true))
if p then
p.AssemblyLinearVelocity = Vector3.zero
p.AssemblyAngularVelocity = Vector3.zero
end
end)
end
end
end
local function holdCar(obj, goal, rot, dur, extras)
holdToken += 1
local my = holdToken
task.spawn(function()
local t0 = os.clock()
while holdToken == my and os.clock() - t0 < dur do
local s2, r2 = getCar()
if not s2 then break end
local cf = CFrame.new(goal) * rot
if (obj:GetPivot().Position - goal).Magnitude > 4 then
pcall(function() obj:PivotTo(cf) end)
end
r2.AssemblyLinearVelocity = Vector3.zero
r2.AssemblyAngularVelocity = Vector3.zero
if extras and #extras > 0 then
for _, ex in ipairs(extras) do
if ex.inst.Parent then
local okp, ipv = pcall(function() return ex.inst:GetPivot() end)
if okp and (ipv.Position - (cf * ex.rel).Position).Magnitude > 4 then
T.moveExtras({ ex }, cf)
end
end
end
end
RunService.Heartbeat:Wait()
end
end)
end
-- تحميل المنطقة حول موقع بعيد (للخرائط اللي تحمّل تدريجياً) قبل الانتقال له
local function loadAround(pos, timeout)
local okS, streaming = pcall(function() return workspace.StreamingEnabled end)
if okS and streaming == true then
pcall(function() player:RequestStreamAroundAsync(pos, timeout or 4) end)
end
end
local function teleportTo(pos)
local seat, root = getCar()
local target = pos + Vector3.new(0, 6, 0)
local from = root and root.Position
if not from then
local hrp0 = getRootPart()
from = hrp0 and hrp0.Position
end
local far = from ~= nil and (from - pos).Magnitude > 1200
if far then
loadAround(pos, 4)
seat, root = getCar()
end
if seat then
local model = seat:FindFirstAncestorOfClass("Model")
local obj = model
while obj and obj.Parent and obj.Parent:IsA("Model") do obj = obj.Parent end
obj = obj or root
local pv = obj:GetPivot()
local rot = pv - pv.Position
local attached = T.attachedFor(obj, pv)
local cf = CFrame.new(target) * rot
obj:PivotTo(cf)
T.moveExtras(attached, cf)
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
holdCar(obj, target, rot, (far and 4 or 2) + (#attached > 0 and 1.5 or 0), attached)
return true
end
local hrp = getRootPart()
if hrp then
hrp.CFrame = CFrame.new(target)
hrp.AssemblyLinearVelocity = Vector3.zero
return true
end
return false
end
local function instPos(inst)
if inst:IsA("Model") then return inst:GetPivot().Position end
if inst:IsA("BasePart") then return inst.Position end
return nil
end
local function nearestOf(list, words, pred)
local myRoot = getRootPart()
if not myRoot then return nil end
local best, bd
for _, inst in ipairs(list) do
if inst.Parent and (not words or matches(inst.Name, words)) and (not pred or pred(inst)) then
local pos = instPos(inst)
if pos then
local d = (pos - myRoot.Position).Magnitude
if not bd or d < bd then best, bd = pos, d end
end
end
end
return best
end
-- موقعي الحالي (سيارتي إذا راكب، وإلا شخصيتي) بدون الإزاحة الإضافية حق الانتقال
local function currentSpot()
local seat, root = getCar()
if seat then
local model = seat:FindFirstAncestorOfClass("Model")
local obj = model
while obj and obj.Parent and obj.Parent:IsA("Model") do obj = obj.Parent end
obj = obj or root
return obj:GetPivot().Position - Vector3.new(0, 6, 0)
end
local hrp = getRootPart()
if hrp then return hrp.Position - Vector3.new(0, 6, 0) end
return nil
end
-- البحث عن مكان بعيد: يجرب القائمة الحالية، ثم يمسح الخريطة حولك بطلبات تحميل بعيدة حتى يلقاه
local locating = false
local function locate(key, getFn, scanObj, words, label, pred)
local pos = nearestOf(getFn(), words, pred)
if pos then
if key then T.places[key] = pos end
return pos
end
if key and T.places[key] then return T.places[key] end
if locating then
notify("البحث شغّال الآن، انتظر", "error")
return nil
end
locating = true
local result
pcall(function()
scanObj.t = -100
for _ = 1, 5 do
task.wait(0.4)
result = nearestOf(getFn(), words, pred)
if result then return end
end
local okS, streaming = pcall(function() return workspace.StreamingEnabled end)
if not (okS and streaming == true) then return end
notify("جاري البحث عن " .. label .. " في الأماكن البعيدة، انتظر قليلاً...")
local hrp = getRootPart()
local origin = hrp and hrp.Position or Vector3.zero
for ri, r in ipairs({ 1500, 3000, 4500, 6500, 9000, 12000 }) do
for i = 0, 11 do
local a = math.rad(i * 30 + ri * 7)
local p = origin + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
task.spawn(function()
pcall(function() player:RequestStreamAroundAsync(p, 2) end)
end)
end
task.wait(1.8)
scanObj.t = -100
for _ = 1, 4 do
task.wait(0.5)
result = nearestOf(getFn(), words, pred)
if result then return end
end
end
end)
locating = false
if result and key then T.places[key] = result end
return result
end
local function ownedByMe(inst)
if string.find(string.lower(inst.Name), string.lower(player.Name), 1, true) then return true end
for _, v in pairs(inst:GetAttributes()) do
if v == player.Name or v == player.DisplayName or v == player.UserId then return true end
end
for _, ch in ipairs(inst:GetChildren()) do
if ch:IsA("ObjectValue") and ch.Value == player then return true end
if ch:IsA("StringValue") and (ch.Value == player.Name or ch.Value == player.DisplayName) then return true end
if (ch:IsA("IntValue") or ch:IsA("NumberValue")) and ch.Value == player.UserId then return true end
end
return false
end
local function ownerOf(model)
for k, v in pairs(model:GetAttributes()) do
if matches(k, { "owner", "player", "مالك", "صاحب" }) then
if type(v) == "string" and v ~= "" then return v end
if type(v) == "number" then
local plr = Players:GetPlayerByUserId(v)
if plr then return plr.DisplayName end
end
end
end
for _, ch in ipairs(model:GetChildren()) do
if ch:IsA("ValueBase") and matches(ch.Name, { "owner", "player", "مالك", "صاحب" }) then
if ch:IsA("StringValue") and ch.Value ~= "" then return ch.Value end
if ch:IsA("ObjectValue") and ch.Value then return ch.Value.Name end
end
end
local nm = string.lower(model.Name)
local par = model.Parent and string.lower(model.Parent.Name) or ""
for _, plr in ipairs(Players:GetPlayers()) do
local pn = string.lower(plr.Name)
if string.find(nm, pn, 1, true) or par == pn then return plr.DisplayName end
end
return nil
end
section(tpPage, "سيارات اللاعبين")
-- أسماء السيارات بالعربي: الاسم الداخلي (مثل DH_رقم_LX6002__46) يتحول لاسم لاعب + اسم سيارة عربي.
-- القائمة الأولى: سيارات معروفة (الأخصّ فوق). لإضافة سيارة: { "جزء من الاسم بحروف صغيرة وبدون _ أو مسافات", "الاسم العربي" }
T.CAR_NAMES = {
{ "supersafari", "نيسان باترول سوبر سفاري" }, { "patrol", "نيسان باترول" }, { "safari", "نيسان سفاري" },
{ "armada", "نيسان أرمادا" }, { "altima", "نيسان ألتيما" }, { "maxima", "نيسان ماكسيما" }, { "sunny", "نيسان صني" },
{ "sierra", "جمس سييرا" }, { "seirra", "جمس سييرا" }, { "yukon", "جمس يوكن" }, { "terrain", "جمس تيرين" }, { "gmc", "جمس" },
{ "lx600", "لكزس إل إكس 600" }, { "lx570", "لكزس إل إكس 570" }, { "gx460", "لكزس جي إكس 460" }, { "es350", "لكزس إي إس 350" },
{ "bronco", "فورد برونكو" }, { "bronca", "فورد برونكو" }, { "f150", "فورد إف 150" }, { "f250", "فورد إف 250" },
{ "raptor", "فورد رابتر" }, { "explorer", "فورد إكسبلورر" }, { "expedition", "فورد إكسبيديشن" }, { "mustang", "فورد موستنق" },
{ "ranger", "فورد رينجر" }, { "navigator", "لينكولن نافيجيتور" },
{ "landcruiser", "تويوتا لاندكروزر" }, { "gxr", "لاندكروزر جي إكس آر" }, { "vxr", "لاندكروزر في إكس آر" },
{ "prado", "تويوتا برادو" }, { "fortuner", "تويوتا فورتشنر" }, { "sequoia", "تويوتا سيكويا" }, { "tundra", "تويوتا تندرا" },
{ "hilux", "تويوتا هايلوكس" }, { "tacoma", "تويوتا تاكوما" }, { "camry", "تويوتا كامري" }, { "corolla", "تويوتا كورولا" },
{ "yaris", "تويوتا يارس" }, { "avalon", "تويوتا أفالون" }, { "rav4", "تويوتا راف فور" }, { "supra", "تويوتا سوبرا" },
{ "tahoe", "شيفروليه تاهو" }, { "suburban", "شيفروليه سوبربان" }, { "silverado", "شيفروليه سلفرادو" },
{ "camaro", "شيفروليه كمارو" }, { "corvette", "شيفروليه كورفيت" }, { "malibu", "شيفروليه ماليبو" }, { "colorado", "شيفروليه كولورادو" },
{ "escalade", "كاديلاك إسكاليد" }, { "cadillac", "كاديلاك" },
{ "g63", "مرسيدس جي 63" }, { "gclass", "مرسيدس جي كلاس" }, { "gwagon", "مرسيدس جي كلاس" }, { "maybach", "مرسيدس مايباخ" },
{ "mercedes", "مرسيدس" }, { "bmw", "بي إم دبليو" }, { "audi", "أودي" },
{ "grandcherokee", "جيب جراند شيروكي" }, { "cherokee", "جيب شيروكي" }, { "wrangler", "جيب رانجلر" }, { "gladiator", "جيب جلادييتور" },
{ "charger", "دودج تشارجر" }, { "challenger", "دودج تشالنجر" }, { "durango", "دودج دورانجو" },
{ "rangerover", "رينج روفر" }, { "defender", "لاند روفر ديفندر" }, { "discovery", "لاند روفر ديسكفري" },
{ "pajero", "ميتسوبيشي باجيرو" }, { "montero", "ميتسوبيشي مونتيرو" }, { "jimny", "سوزوكي جمني" },
{ "hummer", "همر" }, { "cybertruck", "تسلا سايبر ترك" }, { "tesla", "تسلا" }, { "urus", "لامبورجيني أوروس" },
{ "porsche", "بورش" }, { "cayenne", "بورش كايين" }, { "bentley", "بنتلي" }, { "rolls", "رولز رويس" },
{ "hyundai", "هيونداي" }, { "kia", "كيا" }, { "honda", "هوندا" }, { "mazda", "مازدا" },
{ "ram", "دودج رام" }, { "lx", "لكزس إل إكس" },
}
-- كلمات للتحويل لما ما تطابق السيارة أي اسم فوق (تُحوَّل كلمة كلمة، وغير المعروف يُكتب بحروف عربية)
T.CAR_WORDS = {
toyota = "تويوتا", nissan = "نيسان", ford = "فورد", chevrolet = "شيفروليه", chevy = "شيفروليه", dodge = "دودج",
jeep = "جيب", lexus = "لكزس", mercedes = "مرسيدس", benz = "بنز", hyundai = "هيونداي", kia = "كيا", honda = "هوندا",
mazda = "مازدا", mitsubishi = "ميتسوبيشي", suzuki = "سوزوكي", land = "لاند", rover = "روفر", range = "رينج",
cruiser = "كروزر", super = "سوبر", sport = "سبورت", sports = "سبورت", pickup = "بيك أب", truck = "شاحنة",
suv = "إس يو في", van = "فان", classic = "كلاسيك", limited = "ليميتد", edition = "إديشن", black = "أسود",
white = "أبيض", red = "أحمر", blue = "أزرق", gold = "ذهبي", silver = "فضي", old = "قديم", new = "جديد",
car = "سيارة", desert = "صحراء", offroad = "أوف رود", turbo = "تيربو",
}
T.LETTER_NAMES = {
a = "إيه", b = "بي", c = "سي", d = "دي", e = "إي", f = "إف", g = "جي", h = "إتش", i = "آي", j = "جيه",
k = "كي", l = "إل", m = "إم", n = "إن", o = "أو", p = "بي", q = "كيو", r = "آر", s = "إس", t = "تي",
u = "يو", v = "في", w = "دبليو", x = "إكس", y = "واي", z = "زد",
}
T.DIGRAPHS = {
sh = "ش", ch = "تش", kh = "خ", th = "ث", ph = "ف", ck = "ك", ee = "ي", oo = "و", ou = "و", ai = "ي", ea = "ي",
ss = "س", ll = "ل", rr = "ر", tt = "ت", nn = "ن", mm = "م", pp = "ب", dd = "د", ff = "ف", gg = "ج",
}
T.LETTERS = {
a = "ا", b = "ب", c = "ك", d = "د", e = "ي", f = "ف", g = "ج", h = "ه", i = "ي", j = "ج", k = "ك", l = "ل", m = "م",
n = "ن", o = "و", p = "ب", q = "ق", r = "ر", s = "س", t = "ت", u = "و", v = "ف", w = "و", x = "كس", y = "ي", z = "ز",
}
-- تحويل كلمة إنجليزية لحروف عربية (آخر حل إذا الكلمة غير معروفة)
function T.translit(w)
local out, last = {}, ""
local i = 1
while i <= #w do
local piece
local two = string.sub(w, i, i + 1)
if T.DIGRAPHS[two] then
piece = T.DIGRAPHS[two]
i += 2
else
local ch = string.sub(w, i, i)
piece = T.LETTERS[ch] or ""
if ch == "c" then
local nx = string.sub(w, i + 1, i + 1)
if nx == "e" or nx == "i" or nx == "y" then piece = "س" end
end
i += 1
end
local isVowel = (piece == "ا" or piece == "ي" or piece == "و")
if not (isVowel and (last == "ا" or last == "ي" or last == "و")) and piece ~= "" then
out[#out + 1] = piece
last = piece
end
end
return table.concat(out)
end
function T.arabize(rest)
local spaced = string.gsub(rest, "(%l)(%u)", "%1 %2")
spaced = string.gsub(spaced, "(%a)(%d)", "%1 %2")
spaced = string.gsub(spaced, "(%d)(%a)", "%1 %2")
local words = {}
for tok in string.gmatch(spaced, "[%w]+") do
local low = string.lower(tok)
if string.match(tok, "^%d+$") then
words[#words + 1] = tok
elseif T.CAR_WORDS[low] then
words[#words + 1] = T.CAR_WORDS[low]
elseif #tok <= 4 and tok == string.upper(tok) then
local sp = {}
for ch in string.gmatch(low, "%a") do sp[#sp + 1] = T.LETTER_NAMES[ch] or "" end
words[#words + 1] = table.concat(sp, " ")
else
words[#words + 1] = T.translit(low)
end
end
return table.concat(words, " ")
end
function T.carInfo(inst)
local m, uid, rest = inst, nil, nil
for _ = 1, 6 do
if not m or m == workspace then break end
uid, rest = string.match(m.Name, "^DH_(%d+)_(.+)$")
if uid then break end
m = m.Parent
end
if not uid then rest = inst.Name end
rest = string.gsub(rest, "__%d+$", "")
local key = string.gsub(string.lower(rest), "[%s_%-]", "")
local title
for _, p in ipairs(T.CAR_NAMES) do
if string.find(key, p[1], 1, true) then title = p[2] break end
end
title = title or T.arabize(rest)
local owner
if uid then
local plr = Players:GetPlayerByUserId(tonumber(uid))
if plr then owner = plr.DisplayName end
end
return owner, title
end
local function carOptions()
local myRoot = getRootPart()
local arr = {}
for _, e in ipairs(collectCars()) do
local d = myRoot and (e.root.Position - myRoot.Position).Magnitude or 0
local owner, title = T.carInfo(e.inst)
owner = owner or ownerOf(e.inst)
local label = (owner and (owner .. " · ") or "") .. title
T.carLabels[e.inst] = label
arr[#arr + 1] = { key = e.inst, label = label, color = Color3.fromRGB(90, 220, 255), d = d }
end
table.sort(arr, function(a, b) return a.d < b.d end)
return arr
end
createDynDropdown(tpPage, "سيارات اللاعبين", carOptions,
function() return T.car end,
function(k) T.car = k end,
function(k)
if k and k.Parent then
return T.carLabels[k] or k.Name, Color3.fromRGB(90, 220, 255)
end
if #carGet() == 0 then return "ما فيه سيارات" end
return "اختر سيارة"
end)
local seatGet, seatScan = makeScanner(function(inst) return inst:IsA("Seat") end)
function sitOn(seat)
local hum, hrp = getHumanoid(), getRootPart()
if not hum or not hrp or not seat then return false end
if T.allowSeat then T.allowSeat(6) end
hum.Sit = false
pcall(function() seat.Disabled = false end)
for _ = 1, 50 do
if hum.SeatPart == seat then return true end
if not seat.Parent then return false end
hrp.CFrame = seat.CFrame * CFrame.new(0, 1, 0)
hrp.AssemblyLinearVelocity = Vector3.zero
pcall(function() seat:Sit(hum) end)
task.wait(0.06)
end
return hum.SeatPart == seat
end
-- مقعد السواق: VehicleSeat أولاً، ثم أي كرسي اسمه يدل على السواق، ثم الأمامي الأيسر (ما نختار راكب أبداً)
T.DRIVER_WORDS = { "driver", "drive", "pilot", "سواق", "سائق", "قائد", "قياده", "قيادة" }
T.PASSENGER_WORDS = { "passenger", "pass", "rear", "back", "rider", "راكب", "ركاب", "خلف" }
function T.pickDriverSeat(model)
if model:IsA("Seat") or model:IsA("VehicleSeat") then return model end
local seats = {}
for _, d in ipairs(model:GetDescendants()) do
if d:IsA("VehicleSeat") or d:IsA("Seat") then seats[#seats + 1] = d end
end
if #seats == 0 then return nil end
local okp, pv = pcall(function() return model:GetPivot() end)
local center = okp and pv.Position or seats[1].Position
local ref = seats[1]
for _, st in ipairs(seats) do
if st:IsA("VehicleSeat") then ref = st break end
end
local fwd, rgt = ref.CFrame.LookVector, ref.CFrame.RightVector
local best, bestScore
for i, st in ipairs(seats) do
local score = 0
if st:IsA("VehicleSeat") then score += 1000 end
local nm = st.Name .. " " .. (st.Parent and st.Parent.Name or "")
if matches(nm, T.DRIVER_WORDS) then score += 400 end
if matches(nm, T.PASSENGER_WORDS) then score -= 400 end
local off = st.Position - center
score += off:Dot(fwd) * 2 - off:Dot(rgt) * 0.5 - i * 0.01
if not bestScore or score > bestScore then best, bestScore = st, score end
end
return best
end
local function rideCar(model)
if not model or not model.Parent then
notify("اختر سيارة أولاً", "error")
return false
end
if not getHumanoid() or not getRootPart() then
notify("الشخصية غير متوفرة", "error")
return false
end
local seat = T.pickDriverSeat(model)
if not seat then
notify("ما لقيت مقعد السواق في السيارة", "error")
return false
end
if seat.Occupant ~= nil then
notify("مقعد السواق مشغول", "error")
return false
end
if sitOn(seat) then
notify("تم الجلوس في مقعد السواق")
return true
end
notify("ما انقبل الجلوس في مقعد السواق (السيارة مقفلة من اللعبة غالبًا)", "error")
return false
end
local function sitNear(pos, maxD)
local seat
for attempt = 1, 10 do
local best, bd
for _, st in ipairs(seatGet()) do
if st.Parent and st.Occupant == nil and not st.Disabled then
local m = st:FindFirstAncestorOfClass("Model")
if not (m and m:FindFirstChildWhichIsA("VehicleSeat", true)) then
local d = (st.Position - pos).Magnitude
if d < (maxD or 200) and (not bd or d < bd) then best, bd = st, d end
end
end
end
seat = best
if seat then break end
seatScan.t = -100
task.wait(0.5)
end
if not seat then
notify("ما لقيت كرسي قريب", "error")
return
end
if sitOn(seat) then notify("جلست على الكرسي") else notify("ما انقبل الجلوس", "error") end
end
createButton(tpPage, "قيادة السيارة المحددة (مقعد السواق)", function() rideCar(T.car) end)
section(tpPage, "الأماكن")
createButton(tpPage, "{village}التنقل إلى القرية", function()
local pos = locate("village", villageGet, villageScan, CONFIG.VillageWords, "الديرة")
if not pos then
notify("ما لقيت الديرة في الخريطة", "error")
return
end
teleportTo(pos)
notify("تم الانتقال: الديرة")
task.spawn(function()
task.wait(0.8)
sitNear(pos)
end)
end)
function T.tagLast(parent, text)
local last, lo
for _, c in ipairs(parent:GetChildren()) do
if c:IsA("GuiObject") and (not lo or c.LayoutOrder > lo) then last, lo = c, c.LayoutOrder end
end
if not last then return end
for _, c in ipairs(last:GetChildren()) do
if c:IsA("TextLabel") and c.Name ~= "TagSmall" then c.Position = UDim2.fromOffset(0, -7) end
end
make("TextLabel", {
Name = "TagSmall", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -3),
Size = UDim2.new(1, -20, 0, 13), BackgroundTransparency = 1, Text = text,
TextSize = 11, Font = FONT, TextColor3 = THEME.Text, TextTransparency = 0.25,
}, last)
end
T.tagLast(tpPage, "نقل لاعب فقط")
createButton(tpPage, "{cart}التنقل إلى شيخ النفود", function()
if T.sk.busy then
notify("جاري البحث عن شيخ النفود، انتظر", "error")
return
end
T.sk.busy = true
local okRun, errRun = pcall(function()
local function fresh()
T.sheikhScan.t = -100
T.sheikhGet()
local t0 = os.clock()
task.wait(0.15)
while T.sheikhScan.busy and os.clock() - t0 < 10 do task.wait(0.1) end
return T.collectSheikh()
end
local function nearestPos(list)
local hrp = getRootPart()
local best, bd
for _, e in ipairs(list) do
local d = hrp and (e.root.Position - hrp.Position).Magnitude or 0
if not bd or d < bd then best, bd = e.root.Position, d end
end
return best
end
local list = T.collectSheikh()
if #list == 0 then
notify("جاري البحث عن شيخ النفود...")
if T.places.sheikh then loadAround(T.places.sheikh, 5) end
list = fresh()
end
if #list == 0 and not T.places.sheikh then
local found = locate("sheikh", function()
local r = {}
for _, e in ipairs(T.collectSheikh()) do r[#r + 1] = e.inst end
return r
end, T.sheikhScan, nil, "شيخ النفود")
list = T.collectSheikh()
if #list == 0 and found then
T.places.sheikh = found
teleportTo(found)
notify("تم الانتقال: شيخ النفود")
task.spawn(function()
task.wait(0.8)
sitNear(found, 80)
end)
return
end
end
local tgt = nearestPos(list)
if not tgt then
T.sk.waiting = true
notify("شيخ النفود ما رسبن حالياً — بنبلغك أول ما يرسبن", "force", 3)
return
end
T.places.sheikh = tgt
teleportTo(tgt)
notify("تم الانتقال: شيخ النفود")
task.spawn(function()
task.wait(0.8)
sitNear(tgt, 80)
end)
end)
T.sk.busy = false
if not okRun then
warn("[RXZ] sheikh: " .. tostring(errRun))
notify("تعذّر التنقل لشيخ النفود", "error")
end
end)
section(tpPage, "الأماكن المحفوظة")
local nameField = createTextField(tpPage, "اسم المكان", "اكتب اسم المكان")
createDynDropdown(tpPage, "الأماكن المحفوظة",
function()
local o = {}
for i, sp in ipairs(teleportSpots) do
o[#o + 1] = { key = i, label = sp.name .. " | " .. i }
end
return o
end,
function() return T.spot end,
function(k) T.spot = k T.navSrc = "saved" end,
function(k)
local sp = teleportSpots[k]
if sp then return sp.name .. " | " .. k end
return "لا أماكن محفوظة"
end,
function(k)
local sp = teleportSpots[k]
if not sp then return end
table.remove(teleportSpots, k)
if T.spot > k then
T.spot -= 1
end
T.spot = math.clamp(T.spot, 1, math.max(#teleportSpots, 1))
notify("تم حذف: " .. sp.name)
end)
createButton(tpPage, "حفظ مكاني", function()
local hrp = getRootPart()
if not hrp then
notify("الشخصية غير متوفرة", "error")
return
end
local name = string.gsub(nameField.Text, "^%s+", "")
name = string.gsub(name, "%s+$", "")
if name == "" then name = "مكان " .. (#teleportSpots + 1) end
local pos = hrp.Position
table.insert(teleportSpots, { name = name, x = pos.X, y = pos.Y, z = pos.Z })
T.spot = #teleportSpots
T.navSrc = "saved"
nameField.Text = ""
notify("تم حفظ: " .. name)
end)
local glideToken = 0
local function glideTo(pos, label)
local seat, root = getCar()
if not seat then return false end
glideToken += 1
local my = glideToken
local model = seat:FindFirstAncestorOfClass("Model")
local obj = model
while obj and obj.Parent and obj.Parent:IsA("Model") do obj = obj.Parent end
obj = obj or root
local pivot = obj:GetPivot()
local start = pivot.Position
local goal = pos + Vector3.new(0, 4, 0)
local dist = (goal - start).Magnitude
if dist < 8 then return teleportTo(pos) end
local dur = math.max(dist / math.max(state.glideSpeed, 50), 0.6)
local arc = math.clamp(dist * 0.04, 6, 50)
local rot = pivot - pivot.Position
local attached = T.attachedFor(obj, pivot)
task.spawn(function()
local t0 = os.clock()
while glideToken == my do
local s2, r2 = getCar()
if not s2 then break end
local a = math.clamp((os.clock() - t0) / dur, 0, 1)
local e = a * a * (3 - 2 * a)
local p = start:Lerp(goal, e) + Vector3.new(0, math.sin(math.pi * a) * arc, 0)
obj:PivotTo(CFrame.new(p) * rot)
T.moveExtras(attached, CFrame.new(p) * rot)
r2.AssemblyLinearVelocity = Vector3.zero
r2.AssemblyAngularVelocity = Vector3.zero
if a >= 1 then
notify("وصلت: " .. label)
break
end
RunService.Heartbeat:Wait()
end
end)
return true
end
-- ===== الانتقال السلس تحت الأرض (للسيارة وللاعب) =====
-- ينزل تحت الأرض، يمشي بسرعة ثابتة تحت التضاريس (بدون اصطدام)، ثم يطلع بهدوء بنفس نقطة المكان المحفوظ بالضبط
local NAV_DEPTH = 90
local navToken = 0
local function groundAt(px, pz, fromY, ignore)
local prm = RaycastParams.new()
prm.FilterType = Enum.RaycastFilterType.Exclude
prm.FilterDescendantsInstances = ignore
pcall(function() prm.RespectCanCollide = true end)
local hit = workspace:Raycast(Vector3.new(px, fromY, pz), Vector3.new(0, -5000, 0), prm)
return hit and hit.Position.Y or nil
end
-- يلقى سطح الأرض الحقيقي: يفضّل التيرين، ويقبل أرضية/طريق قريب منه، ويتجاهل الأسقف والأشجار العالية والأجزاء الشفافة
local function findSurface(px, pz, fromY, ignore)
local prm = RaycastParams.new()
prm.FilterType = Enum.RaycastFilterType.Exclude
prm.FilterDescendantsInstances = ignore
pcall(function() prm.RespectCanCollide = true end)
local hits, terrainY = {}, nil
local y = fromY
for _ = 1, 14 do
local hit = workspace:Raycast(Vector3.new(px, y, pz), Vector3.new(0, -5000, 0), prm)
if not hit then break end
local inst = hit.Instance
if inst:IsA("Terrain") then
terrainY = hit.Position.Y
break
elseif not (inst:IsA("BasePart") and inst.Transparency > 0.9) then
hits[#hits + 1] = hit.Position.Y
end
y = hit.Position.Y - 0.2
end
local base = terrainY or hits[1]
if not base then return nil end
local best = base
for _, hy in ipairs(hits) do
if hy <= base + 6 and hy > best then best = hy end
end
return best
end
local function smoothTravel(dest, label, unknownY, air, fast, lift, hunt)
if T.navBusy then
notify("التنقل السلس شغّال الآن", "error")
return false
end
local seat, root = getCar()
local char = getCharacter()
local hum = getHumanoid()
local hrp = getRootPart()
if not char or not hrp then
notify("الشخصية غير متوفرة", "error")
return false
end
local footMode = (seat == nil)
local obj
if footMode then
obj = char
else
obj = seat:FindFirstAncestorOfClass("Model")
while obj and obj.Parent and obj.Parent:IsA("Model") do obj = obj.Parent end
obj = obj or root
end
T.navBusy = true
navToken += 1
local my = navToken
holdToken += 1
glideToken += 1
local origCollide, origAnch = {}, {}
local oldPS = hum and hum.PlatformStand or false
local arrivedFlag = false
task.spawn(function()
local function cleanup()
-- 1) نرجّع التصادم وهي لسا مثبتة
for p, c in pairs(origCollide) do
if p.Parent then p.CanCollide = c end
end
-- 2) نفك التثبيت ونصفّر السرعات
for p, a in pairs(origAnch) do
if p.Parent then
p.Anchored = a
p.AssemblyLinearVelocity = Vector3.zero
p.AssemblyAngularVelocity = Vector3.zero
end
end
if footMode and hum and hum.Parent then hum.PlatformStand = oldPS end
T.navBusy = false
end
local ok, err = pcall(function()
local ignore = { obj, char }
local pv = obj:GetPivot()
local start = pv.Position
local rot = pv - pv.Position
local attached = {} -- التنقل العادي/الفارم لا يسحب الكرفان (ميزة الكرفان صارت مستقلة)
for _, ex in ipairs(attached) do ignore[#ignore + 1] = ex.inst end
local hiY = math.max(start.Y, dest.Y) + 1500
local floorY = workspace.FallenPartsDestroyHeight + 80
local g0 = groundAt(start.X, start.Z, start.Y + 5, ignore) or (start.Y - 3)
local clearance = math.clamp(start.Y - g0, 1.5, lift and 4 or 12)
-- عمق ثابت: أخفض أرض على المسار - العمق
local lowest = math.min(g0, dest.Y - 3)
local highest = math.max(g0, dest.Y)
do
local dx, dz = dest.X - start.X, dest.Z - start.Z
local len = math.sqrt(dx * dx + dz * dz)
local n = math.clamp(math.ceil(len / 120), 1, 80)
for i = 0, n do
local a = i / n
local g = groundAt(start.X + dx * a, start.Z + dz * a, hiY, ignore)
if g and g < lowest then lowest = g end
if g and g > highest then highest = g end
end
end
local cruiseY = math.max(lowest - NAV_DEPTH, floorY)
if air then cruiseY = (air <= 8) and (g0 + air) or (highest + air) end
local okS, streamVal = pcall(function() return workspace.StreamingEnabled end)
local streaming = okS and streamVal == true
local reqBusy = 0
local function req(p, t)
if not streaming or reqBusy >= 3 then return end
reqBusy += 1
task.spawn(function()
pcall(function() player:RequestStreamAroundAsync(p, t) end)
reqBusy -= 1
end)
end
local function setPivot(p)
pcall(function()
local cf = CFrame.new(p) * rot
obj:PivotTo(cf)
for _, ex in ipairs(attached) do ex.inst:PivotTo(cf * ex.rel) end
end)
end
-- تثبيت كل الأجزاء + إلغاء التصادم: السيارة تتحرك كجسم واحد بدون فيزياء
local function lockParts(inst)
local list = inst:GetDescendants()
list[#list + 1] = inst
for _, d in ipairs(list) do
if d:IsA("BasePart") and origAnch[d] == nil then
origAnch[d] = d.Anchored
origCollide[d] = d.CanCollide
d.CanCollide = false
d.Anchored = true
end
end
end
req(dest, 6)
lockParts(obj)
for _, ex in ipairs(attached) do lockParts(ex.inst) end
if obj ~= char then lockParts(char) end
if footMode and hum then hum.PlatformStand = true end
local pos = start
-- 1) نزول هادي لعمق الرحلة
local t1 = os.clock()
while navToken == my and obj.Parent and pos.Y > cruiseY + 0.4 and os.clock() - t1 < 8 do
local dt = RunService.Heartbeat:Wait()
local rate = math.clamp((pos.Y - cruiseY) * 3, 8, 60)
pos = Vector3.new(pos.X, math.max(pos.Y - rate * dt, cruiseY), pos.Z)
setPivot(pos)
end
if air then
local t1b = os.clock()
while navToken == my and obj.Parent and pos.Y < cruiseY - 0.4 and os.clock() - t1b < 6 do
local dtb = RunService.Heartbeat:Wait()
local rateb = math.clamp((cruiseY - pos.Y) * 3, 8, 120)
pos = Vector3.new(pos.X, math.min(pos.Y + rateb * dtb, cruiseY), pos.Z)
setPivot(pos)
end
end
-- 2) مشي أفقي مستقيم بنفس الارتفاع
local t2, lastReq = os.clock(), 0
while navToken == my and obj.Parent do
local dt = RunService.Heartbeat:Wait()
local h = Vector3.new(dest.X - pos.X, 0, dest.Z - pos.Z)
local rem = h.Magnitude
if rem < 1.5 then break end
local vmax = math.clamp(state.navSpeed, 20, 3000)
local ramp = fast and 0.35 or 1.2
local el = os.clock() - t2
local v = math.min(vmax * math.min(1, 0.08 + el / ramp), math.max(rem / ramp, 6))
local step = math.min(v * dt, rem)
local dirv = h.Unit
local nx, nz = pos.X + dirv.X * step, pos.Z + dirv.Z * step
local g = groundAt(nx, nz, hiY, ignore)
if air then
if g then
if air <= 8 then cruiseY = g + air
elseif g + air > cruiseY then cruiseY = g + air end
end
elseif g and g - NAV_DEPTH < cruiseY then
cruiseY = math.max(g - NAV_DEPTH, floorY)
end
local vr = (air and air <= 8) and 200 or 60
local ny = pos.Y + math.clamp(cruiseY - pos.Y, -vr * dt, vr * dt)
pos = Vector3.new(nx, ny, nz)
setPivot(pos)
if os.clock() - lastReq > 0.4 then
lastReq = os.clock()
req(rem < 2500 and dest or (pos + dirv * math.max(300, vmax * 0.5)), 1)
end
end
if not obj.Parent then return end
-- 3) طلوع عمودي بالضبط عند نقطة الوجهة
local arrived = (navToken == my)
local ax, az, ref, fallbackG = pos.X, pos.Z, hiY, g0
if arrived then
ax, az, ref, fallbackG = dest.X, dest.Z, dest.Y + 8, (unknownY and g0 or dest.Y - 3)
pos = Vector3.new(dest.X, pos.Y, dest.Z)
setPivot(pos)
end
local gy
if unknownY then
-- ارتفاع المكان مجهول: نطلع ببطء ونلقى الأرض الحقيقية، وما نفك التثبيت إلا لما تثبت
local capY = g0 + clearance + 0.3
local lastG, stable = nil, 0
local t3 = os.clock()
while os.clock() - t3 < 20 and navToken == my and obj.Parent do
local dt = RunService.Heartbeat:Wait()
local g = findSurface(ax, az, hiY, ignore)
if g then
if lastG and math.abs(g - lastG) < 0.6 then stable += 1 else stable = 1 end
lastG = g
else
stable = 0
end
if stable >= 4 then gy = g break end
req(Vector3.new(ax, pos.Y, az), 2)
pos = Vector3.new(pos.X, math.min(pos.Y + 45 * dt, math.max(capY, pos.Y)), pos.Z)
setPivot(pos)
end
gy = gy or lastG or (arrived and (dest.Y - 3)) or g0
else
local t3 = os.clock()
while os.clock() - t3 < 3 do
gy = groundAt(ax, az, ref, ignore)
if gy then break end
req(Vector3.new(ax, ref, az), 2)
setPivot(pos)
RunService.Heartbeat:Wait()
end
gy = gy or groundAt(ax, az, hiY, ignore) or fallbackG
end
local topY = gy + clearance + 0.3 + (lift or 0)
local t4 = os.clock()
while pos.Y < topY - 0.05 and os.clock() - t4 < 10 do
local dt = RunService.Heartbeat:Wait()
local rate = math.clamp((topY - pos.Y) * 2.5, 5, 70)
pos = Vector3.new(pos.X, math.min(pos.Y + rate * dt, topY), pos.Z)
setPivot(pos)
end
pos = Vector3.new(pos.X, topY, pos.Z)
setPivot(pos)
-- ما نفك التثبيت إلا لما الأرض تحتنا محمّلة فعلاً (عشان ما نغرز ولا نطيح)
local t5 = os.clock()
while navToken == my and obj.Parent and os.clock() - t5 < 8 do
local gh = groundAt(pos.X, pos.Z, pos.Y + 2, ignore)
if gh then
local want = gh + clearance + 0.3 + (lift or 0)
if math.abs(pos.Y - want) < 0.4 then break end
local dt5 = RunService.Heartbeat:Wait()
pos = Vector3.new(pos.X, pos.Y + math.clamp(want - pos.Y, -60 * dt5, 60 * dt5), pos.Z)
setPivot(pos)
else
req(Vector3.new(pos.X, pos.Y, pos.Z), 2)
RunService.Heartbeat:Wait()
setPivot(pos)
end
end
arrivedFlag = arrived
if arrived then
T.pinObj, T.pinGoal, T.pinRot, T.pinLast = obj, pos, rot, nil
T.pinExtras = attached
if hunt then
T.pinUntil, T.pinSettle, T.pinSnaps = os.clock() + 4, os.clock() + 1, 0
else
T.pinUntil, T.pinSettle, T.pinSnaps = os.clock() + 20, os.clock() + 2.5, 0
end
T.pinMinY, T.pinFalls, T.pinHunt = gy, 0, hunt == true
end
end)
cleanup()
if not ok then
warn("[RXZ] smoothTravel: " .. tostring(err))
notify("تعذّر التنقل السلس", "error")
elseif arrivedFlag then
notify("وصلت: " .. tostring(label))
else
notify("تم إيقاف التنقل")
end
end)
return true
end
T.smoothTravel = smoothTravel
function T.stopNav() navToken += 1 end

-- ===== نقل الكرفان (مستقل تماماً عن التنقل العادي، سرعة ثابتة 600 حتى ما يتقلب) =====
local CARAVAN_SPEED = 600
local caravanToken = 0
function T.caravanStop() caravanToken += 1 end
function T.caravanTravel(dest, label)
if T.caravanBusy then
notify("نقل الكرفان شغّال الآن", "error")
return false
end
local seat, root = getCar()
if not seat then
notify("اركب السيارة أولاً عشان تسحب الكرفان", "error")
return false
end
local char = getCharacter()
local hum = getHumanoid()
if not char then
notify("الشخصية غير متوفرة", "error")
return false
end
local obj = seat:FindFirstAncestorOfClass("Model")
while obj and obj.Parent and obj.Parent:IsA("Model") do obj = obj.Parent end
obj = obj or root
local pv0 = obj:GetPivot()
local attached = T.attachedFor(obj, pv0)
if #attached == 0 then
notify("ما فيه كرفان/قلص مربوط بالسيارة", "error")
return false
end
T.caravanBusy = true
caravanToken += 1
local my = caravanToken
local origCollide, origAnch = {}, {}
local arrivedFlag = false
task.spawn(function()
local function cleanup()
for p, c in pairs(origCollide) do
if p.Parent then p.CanCollide = c end
end
for p, a in pairs(origAnch) do
if p.Parent then
p.Anchored = a
p.AssemblyLinearVelocity = Vector3.zero
p.AssemblyAngularVelocity = Vector3.zero
end
end
T.caravanBusy = false
end
local ok, err = pcall(function()
local ignore = { obj, char }
for _, ex in ipairs(attached) do ignore[#ignore + 1] = ex.inst end
local pv = obj:GetPivot()
local start = pv.Position
local rot = pv - pv.Position
local hiY = math.max(start.Y, dest.Y) + 1500
local floorY = workspace.FallenPartsDestroyHeight + 80
local g0 = groundAt(start.X, start.Z, start.Y + 5, ignore) or (start.Y - 3)
local clearance = math.clamp(start.Y - g0, 1.5, 12)
local lowest = math.min(g0, dest.Y - 3)
do
local dx, dz = dest.X - start.X, dest.Z - start.Z
local len = math.sqrt(dx * dx + dz * dz)
local n = math.clamp(math.ceil(len / 120), 1, 80)
for i = 0, n do
local a = i / n
local g = groundAt(start.X + dx * a, start.Z + dz * a, hiY, ignore)
if g and g < lowest then lowest = g end
end
end
local cruiseY = math.max(lowest - NAV_DEPTH, floorY)
local okS, streamVal = pcall(function() return workspace.StreamingEnabled end)
local streaming = okS and streamVal == true
local reqBusy = 0
local function req(p, t)
if not streaming or reqBusy >= 3 then return end
reqBusy += 1
task.spawn(function()
pcall(function() player:RequestStreamAroundAsync(p, t) end)
reqBusy -= 1
end)
end
local function setPivot(p)
pcall(function()
local cf = CFrame.new(p) * rot
obj:PivotTo(cf)
for _, ex in ipairs(attached) do ex.inst:PivotTo(cf * ex.rel) end
end)
end
local function lockParts(inst)
local list = inst:GetDescendants()
list[#list + 1] = inst
for _, d in ipairs(list) do
if d:IsA("BasePart") and origAnch[d] == nil then
origAnch[d] = d.Anchored
origCollide[d] = d.CanCollide
d.CanCollide = false
d.Anchored = true
end
end
end
req(dest, 6)
lockParts(obj)
for _, ex in ipairs(attached) do lockParts(ex.inst) end
local pos = start
-- نزول هادي لعمق ثابت تحت الأرض
local t1 = os.clock()
while caravanToken == my and obj.Parent and pos.Y > cruiseY + 0.4 and os.clock() - t1 < 8 do
local dt = RunService.Heartbeat:Wait()
local rate = math.clamp((pos.Y - cruiseY) * 3, 8, 60)
pos = Vector3.new(pos.X, math.max(pos.Y - rate * dt, cruiseY), pos.Z)
setPivot(pos)
end
-- مشي أفقي بسرعة ثابتة 600 (ما تتسارع ولا تتباطأ حتى ما ينقلب الكرفان)
local lastReq = os.clock()
while caravanToken == my and obj.Parent do
local dt = RunService.Heartbeat:Wait()
local h = Vector3.new(dest.X - pos.X, 0, dest.Z - pos.Z)
local rem = h.Magnitude
if rem < 1.5 then break end
local step = math.min(CARAVAN_SPEED * dt, rem)
local dirv = h.Unit
local nx, nz = pos.X + dirv.X * step, pos.Z + dirv.Z * step
local g = groundAt(nx, nz, hiY, ignore)
if g and g - NAV_DEPTH < cruiseY then
cruiseY = math.max(g - NAV_DEPTH, floorY)
end
local ny = pos.Y + math.clamp(cruiseY - pos.Y, -60 * dt, 60 * dt)
pos = Vector3.new(nx, ny, nz)
setPivot(pos)
if os.clock() - lastReq > 0.4 then
lastReq = os.clock()
req(rem < 2500 and dest or (pos + dirv * 300), 1)
end
end
if not obj.Parent then return end
local arrived = (caravanToken == my)
local ax, az, ref, fallbackG = pos.X, pos.Z, hiY, g0
if arrived then
ax, az, ref, fallbackG = dest.X, dest.Z, dest.Y + 8, dest.Y - 3
pos = Vector3.new(dest.X, pos.Y, dest.Z)
setPivot(pos)
end
local gy
local t3 = os.clock()
while os.clock() - t3 < 3 do
gy = groundAt(ax, az, ref, ignore)
if gy then break end
req(Vector3.new(ax, ref, az), 2)
setPivot(pos)
RunService.Heartbeat:Wait()
end
gy = gy or groundAt(ax, az, hiY, ignore) or fallbackG
local topY = gy + clearance + 0.3
local t4 = os.clock()
while pos.Y < topY - 0.05 and os.clock() - t4 < 10 do
local dt = RunService.Heartbeat:Wait()
local rate = math.clamp((topY - pos.Y) * 2.5, 5, 70)
pos = Vector3.new(pos.X, math.min(pos.Y + rate * dt, topY), pos.Z)
setPivot(pos)
end
pos = Vector3.new(pos.X, topY, pos.Z)
setPivot(pos)
local t5 = os.clock()
while caravanToken == my and obj.Parent and os.clock() - t5 < 8 do
local gh = groundAt(pos.X, pos.Z, pos.Y + 2, ignore)
if gh then
local want = gh + clearance + 0.3
if math.abs(pos.Y - want) < 0.4 then break end
local dt5 = RunService.Heartbeat:Wait()
pos = Vector3.new(pos.X, pos.Y + math.clamp(want - pos.Y, -60 * dt5, 60 * dt5), pos.Z)
setPivot(pos)
else
req(Vector3.new(pos.X, pos.Y, pos.Z), 2)
RunService.Heartbeat:Wait()
setPivot(pos)
end
end
arrivedFlag = arrived
if arrived then
T.pinObj, T.pinGoal, T.pinRot, T.pinLast = obj, pos, rot, nil
T.pinExtras = attached
T.pinUntil, T.pinSettle, T.pinSnaps = os.clock() + 20, os.clock() + 6, 0
T.pinMinY, T.pinFalls, T.pinHunt = gy, 0, false
end
end)
cleanup()
if not ok then
warn("[RXZ] caravanTravel: " .. tostring(err))
notify("تعذّر نقل الكرفان", "error")
elseif arrivedFlag then
notify("وصل الكرفان: " .. tostring(label))
else
notify("تم إيقاف نقل الكرفان")
end
end)
return true
end
T.HUNT_SKIP = { "water", "food", "bread", "drink", "ماء", "مياه", "خبز", "طعام", "تمر", "قربة", "عصير", "حليب" }
function T.huntPick()
local myRoot = getRootPart()
if not myRoot then return nil end
local best, bd
for _, e in ipairs(dhabRadar.collect()) do
applyDhabInfo(e)
if not e.skip and e.root.Parent and not T.isDead(e.inst) and e.evidence and passFilters(dhabRadar, e) then
local d = (e.root.Position - myRoot.Position).Magnitude
if not bd or d < bd then best, bd = e, d end
end
end
return best, bd
end
function T.huntFinish()
T.huntRun = false
pcall(function() RunService:UnbindFromRenderStep("RXZ_Hunt") end)
end
function T.huntKill()
T.huntToken = (T.huntToken or 0) + 1
if T.huntRun and T.navBusy then T.stopNav() end
T.huntFinish()
end
function T.huntCancel()
if not T.huntRun then
notify("ما فيه صيد شغّال", "error")
return
end
T.huntKill()
notify("تم إيقاف الصيد")
end
-- يوصل للضب: ينزل من السيارة، يمسك سلاح، ويطلق عليه لين يموت (أو يبعد فنقرّب منه)
function T.huntEngage(e, my)
local hum = getHumanoid()
if not hum then return true end
if hum.SeatPart then
hum.Sit = false
pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
local t0 = os.clock()
while hum.SeatPart and os.clock() - t0 < 2 and T.huntToken == my do
hum.Sit = false
task.wait(0.1)
end
end
if not state.huntShoot then return true end
local ch = getCharacter()
local tool = ch and ch:FindFirstChildOfClass("Tool")
if not tool then
local bp = player:FindFirstChildOfClass("Backpack")
if bp then
for _, c in ipairs(bp:GetChildren()) do
if c:IsA("Tool") and not matches(c.Name, T.HUNT_SKIP) then
tool = c
break
end
end
end
if tool then
hum:EquipTool(tool)
task.wait(0.3)
end
end
if not tool then
notify("ما لقيت سلاح بحقيبتك", "error")
return true
end
pcall(function() RunService:UnbindFromRenderStep("RXZ_Hunt") end)
RunService:BindToRenderStep("RXZ_Hunt", Enum.RenderPriority.Camera.Value + 2, function()
if T.huntToken ~= my or not e.root.Parent then return end
local cam = workspace.CurrentCamera
if not cam then return end
local okp, pts = pcall(aimPoints, e)
if okp and pts and pts[1] then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, pts[1]) end
end)
while T.huntToken == my and e.root.Parent and not T.isDead(e.inst) do
local myRoot = getRootPart()
if not myRoot then break end
if (e.root.Position - myRoot.Position).Magnitude > 220 then break end
local ch2 = getCharacter()
local cur = ch2 and ch2:FindFirstChildOfClass("Tool")
if cur then
T.mgFire = os.clock()
pcall(function() cur:Activate() end)
end
task.wait(0.12)
end
pcall(function() RunService:UnbindFromRenderStep("RXZ_Hunt") end)
return false
end
function T.huntRoutine(e, my)
local t0 = os.clock()
local trips = 0
notify("بدأ الصيد: انتقال للضب...")
while T.huntToken == my and e.root.Parent and e.inst.Parent and not T.isDead(e.inst) and os.clock() - t0 < 180 do
local myRoot = getRootPart()
if not myRoot then return end
local tp = e.root.Position
if (tp - myRoot.Position).Magnitude > 90 then
trips += 1
if trips > 6 then
notify("الضب يهرب منك، أعد المحاولة", "error")
return
end
local away = Vector3.new(myRoot.Position.X - tp.X, 0, myRoot.Position.Z - tp.Z)
away = away.Magnitude > 1 and away.Unit or Vector3.new(1, 0, 0)
if not T.smoothTravel(tp + away * 8, "الضب", true, nil, nil, nil, true) then return end
repeat task.wait(0.1) until not T.navBusy or T.huntToken ~= my
else
if T.huntEngage(e, my) then return end
end
end
if T.huntToken == my and T.isDead(e.inst) then notify("مات الضب") end
end
function T.huntStart()
if T.huntRun then
T.huntCancel()
return
end
if T.navBusy then
notify("التنقل السلس شغّال الآن", "error")
return
end
local e = T.huntPick()
if not e then
notify("ما فيه ضب محمّل قريب منك", "error")
return
end
T.huntRun = true
T.huntToken = (T.huntToken or 0) + 1
local my = T.huntToken
task.spawn(function()
local ok, err = pcall(T.huntRoutine, e, my)
if not ok then
warn("[RXZ] hunt: " .. tostring(err))
notify("تعذّر الصيد", "error")
end
if T.huntToken == my then T.huntFinish() end
end)
end
-- ===== الفارم: انتقال لأقرب ضب =====
T.farmGoToken = 0
function T.farmGoStop()
T.farmGoToken = (T.farmGoToken or 0) + 1
if T.navBusy then T.stopNav() end
T.farmGoBusy = false
end
function T.farmGo()
if T.farmGoBusy then
T.farmGoStop()
notify("تم إيقاف الانتقال")
return
end
if state.farmOn then
notify("أوقف الفارم التلقائي أولاً", "error")
return
end
if T.navBusy then
notify("التنقل السلس شغّال الآن", "error")
return
end
if not getCar() then
notify("لازم تركب السيارة أولاً", "error")
return
end
local e = T.huntPick()
if not e then
notify("ما فيه ضب محمّل قريب منك", "error")
return
end
local hum0, hrp0 = getHumanoid(), getRootPart()
if not hum0 or not hrp0 then
notify("الشخصية غير متوفرة", "error")
return
end
T.farmGoBusy = true
T.farmGoToken = (T.farmGoToken or 0) + 1
local my = T.farmGoToken
task.spawn(function()
local ok, err = pcall(function()
local tp = e.root.Position
local mp = hrp0.Position
local away = Vector3.new(mp.X - tp.X, 0, mp.Z - tp.Z)
away = away.Magnitude > 1 and away.Unit or Vector3.new(1, 0, 0)
local seat = getCar()
notify(seat and "انتقال بالسيارة لأقرب ضب..." or "انتقال لأقرب ضب...")
-- نفس التنقل السلس المثبّت (السيارة تنزل على الأرض عند الوصول)، وارتفاع الوجهة معروف من الضب نفسه
if not T.hopTravel(Vector3.new(tp.X + away.X * 7, tp.Y, tp.Z + away.Z * 7), "الضب", 2, true, function() return T.farmGoToken == my end) then return end
if T.farmGoToken ~= my then return end
if not seat then return end
-- ينزلك من السيارة ويجري وراه فقط
local h = getHumanoid()
if h and h.SeatPart then
task.wait(0.05)
h.Sit = false
pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
local t0 = os.clock()
while h.SeatPart and os.clock() - t0 < 2 and T.farmGoToken == my do
h.Sit = false
task.wait(0.1)
end
end
notify("الركض خلف الضب — أطلق بنفسك وبيوقف عن الملاحقة")
local userFired = false
local conn = game:GetService("UserInputService").InputBegan:Connect(function(inp, processed)
local t = inp.UserInputType
if t == Enum.UserInputType.MouseButton1 or (t == Enum.UserInputType.Touch and processed) then
userFired = true
end
end)
local t1 = os.clock()
while T.farmGoToken == my and os.clock() - t1 < 60 and not userFired do
local h2, r2 = getHumanoid(), getRootPart()
if not h2 or not r2 or not e.root.Parent or T.isDead(e.inst) then break end
if (e.root.Position - r2.Position).Magnitude < 6 then break end
h2:MoveTo(e.root.Position)
task.wait(0.15)
end
pcall(function() conn:Disconnect() end)
if userFired then
local h3, r3 = getHumanoid(), getRootPart()
if h3 and r3 then h3:MoveTo(r3.Position) end
end
end)
if not ok then
warn("[RXZ] farmGo: " .. tostring(err))
notify("تعذّر الانتقال للضب", "error")
end
if T.farmGoToken == my then T.farmGoBusy = false end
end)
end
createButton(tpPage, "{navigate}انتقال", function()
local sp = teleportSpots[T.spot]
if not sp then
notify("اختر مكان محفوظ أولاً", "error")
return
end
if smoothTravel(Vector3.new(sp.x, sp.y, sp.z), sp.name) then
notify("بدأ التنقل السلس إلى: " .. sp.name)
end
end)
createButton(tpPage, "{stop}إيقاف الانتقال", function()
if not T.navBusy then
notify("ما فيه تنقل شغّال", "error")
return
end
navToken += 1
end, true)
section(tpPage, "التنقل بالكرفان أو القلص")
createButton(tpPage, "{cart}التنقل بالكرفان أو القلص", function()
local sp = teleportSpots[T.spot]
if not sp then
notify("اختر مكان محفوظ أولاً", "error")
return
end
if T.caravanTravel(Vector3.new(sp.x, sp.y, sp.z), sp.name) then
notify("بدأ التنقل بالكرفان/القلص إلى: " .. sp.name)
end
end)
createButton(tpPage, "{stop}إيقاف التنقل بالكرفان أو القلص", function()
if not T.caravanBusy then
notify("ما فيه نقل كرفان شغّال", "error")
return
end
T.caravanStop()
end, true)
do
local note = createInfo(tpPage, "( اقصى سرعه 600 لـ تجنب المشاكل )", false)
note.Name = "KeepColor"
note.TextColor3 = Color3.fromRGB(255, 70, 70)
note.TextSize = 13
end
section(tpPage, "مواقع مختارة")
T.presetSpots = {
{ name = "القرية", x = -864, y = 19, z = 478 },
{ name = "نقرة الفيروز", x = -28438, y = 300, z = -5014 },
{ name = "حزم الياقوت", x = 9807, y = 300, z = -27007 },
{ name = "قارة التبر", x = 9996, y = 58, z = 27249 },
{ name = "ديار العماليق", x = -23601, y = 54, z = -11433 },
{ name = "وادي النقوش", x = 19835, y = 51, z = 11448 },
{ name = "بوابة ابو النفود", x = 30154, y = 300, z = -20304 },
{ name = "خان العقيلات", x = -2059, y = 300, z = -6105 },
{ name = "اختراق بوابة ابو النفود", x = 30130, y = -10, z = -37773 },
}
T.presetSel = 1
createDynDropdown(tpPage, "مواقع مختارة",
function()
local o = {}
for i, sp in ipairs(T.presetSpots) do
o[#o + 1] = { key = i, label = sp.name }
end
return o
end,
function() return T.presetSel end,
function(k) T.presetSel = k T.navSrc = "preset" end,
function(k)
local sp = T.presetSpots[k]
return sp and sp.name or "اختر موقع"
end)
createButton(tpPage, "{navigate}انتقال للموقع المختار", function()
local sp = T.presetSpots[T.presetSel]
if not sp then
notify("اختر موقع أولاً", "error")
return
end
T.navSrc = "preset"
if smoothTravel(Vector3.new(sp.x, sp.y, sp.z), sp.name, true) then
notify("بدأ التنقل السلس إلى: " .. sp.name)
end
end)
createSlider(tpPage, "سرعة الوصول", function() return state.navSpeed end,
function(v) state.navSpeed = v end, 20, 3000, 10, function(v) return v .. " م/ث" end)
do
local lbl = createInfo(tpPage, "", false)
table.insert(refreshers, function()
local sp = (T.navSrc == "preset") and T.presetSpots[T.presetSel] or teleportSpots[T.spot]
local hr = getRootPart()
if sp and hr then
local d = Vector3.new(sp.x - hr.Position.X, 0, sp.z - hr.Position.Z).Magnitude
local sec = d / math.max(state.navSpeed, 20) + 4
lbl.Text = string.format("المسافة للمكان المحدد: %d م  •  الوقت التقريبي: %d ثانية", math.floor(d + 0.5), math.floor(sec + 0.5))
else
lbl.Text = "اختر مكان محفوظ لعرض المسافة والوقت التقريبي"
end
end)
end
section(tpPage, "احداثيات العالم")
do
local coordLbl = createInfo(tpPage, "", false)
table.insert(refreshers, function()
local hr = getRootPart()
if hr then
local p = hr.Position
coordLbl.Text = string.format("X = %d  ·  Y = %d  ·  Z = %d", math.floor(p.X + 0.5), math.floor(p.Y + 0.5), math.floor(p.Z + 0.5))
else
coordLbl.Text = "الشخصية غير متوفرة"
end
end)
end
track(RunService.Heartbeat:Connect(function()
local obj = T.pinObj
if not obj or T.navBusy then return end
local now = os.clock()
if now > (T.pinUntil or 0) or not obj.Parent then
T.pinObj, T.pinLast, T.pinExtras = nil, nil, nil
return
end
local okp, pv = pcall(function() return obj:GetPivot() end)
if not okp then return end
local cur = pv.Position
local last = T.pinLast
T.pinLast = cur
local _, carRoot = getCar()
local rt = carRoot or getRootPart()
if T.pinMinY and cur.Y < T.pinMinY - 12 and (T.pinFalls or 0) < 6 then
-- وقعت من الأرض: نرجّعك فوقها ونثبّتك
T.pinFalls = (T.pinFalls or 0) + 1
pcall(function() obj:PivotTo(CFrame.new(T.pinGoal) * T.pinRot) end)
T.moveExtras(T.pinExtras, CFrame.new(T.pinGoal) * T.pinRot)
if rt then
rt.AssemblyLinearVelocity = Vector3.zero
rt.AssemblyAngularVelocity = Vector3.zero
end
T.pinLast = T.pinGoal
T.pinUntil = now + 4
T.pinSettle = now + 2.5
return
end
if (not T.pinHunt) and last and (cur - last).Magnitude > 40 and (T.pinSnaps or 0) < 12 then
-- الخادم رجّعك لمكانك القديم: نعيدك لمكان الوصول ونثبّته (نتجاهل هذا أثناء الصيد/الفارم عشان ما يعلّق عليك وأنت تتحرك على الضب)
T.pinSnaps = (T.pinSnaps or 0) + 1
pcall(function() obj:PivotTo(CFrame.new(T.pinGoal) * T.pinRot) end)
T.moveExtras(T.pinExtras, CFrame.new(T.pinGoal) * T.pinRot)
if rt then
rt.AssemblyLinearVelocity = Vector3.zero
rt.AssemblyAngularVelocity = Vector3.zero
end
T.pinLast = T.pinGoal
T.pinUntil = now + 10
T.pinSettle = now + 2.5
return
end
-- أول ثواني بعد الوصول: نهدّي السيارة وهي تنزل حتى ما ترتج وتنفك
if rt and now < (T.pinSettle or 0) then
local v = rt.AssemblyLinearVelocity
rt.AssemblyAngularVelocity = Vector3.zero
if v.Y < -12 then rt.AssemblyLinearVelocity = Vector3.new(v.X * 0.5, -12, v.Z * 0.5) end
end
-- القلص: لو انفصل عن السيارة (بعد حدّ معيّن) نرجّعه مكانه المربوط
if T.pinExtras and #T.pinExtras > 0 then
for _, ex in ipairs(T.pinExtras) do
if ex.inst.Parent then
local okp, ipv = pcall(function() return ex.inst:GetPivot() end)
local want = pv * ex.rel
-- القلص/الكرفان: لو ابتعد أو انقلب نرجّعه مكانه المربوط ونثبّته
local settling = now < (T.pinSettle or 0)
local posTol = settling and 0.6 or 3
local upTol = settling and 0.97 or 0.85
if okp and ((ipv.Position - want.Position).Magnitude > posTol or ipv.UpVector:Dot(want.UpVector) < upTol) then
T.moveExtras({ ex }, pv)
elseif settling then
local ep = ex.inst:IsA("BasePart") and ex.inst or (ex.inst.PrimaryPart or ex.inst:FindFirstChildWhichIsA("BasePart", true))
if ep then
ep.AssemblyAngularVelocity = Vector3.zero
local ev = ep.AssemblyLinearVelocity
if ev.Y < -12 then ep.AssemblyLinearVelocity = Vector3.new(ev.X * 0.5, -12, ev.Z * 0.5) end
end
end
end
end
end
end))
end
do
local farmPage = newPage("الفارم", "clef")
function T.farmRestore()
local cl = T.farmCollide
if cl then
for part, c in pairs(cl) do
if part.Parent then part.CanCollide = c end
end
end
T.farmCollide = nil
T.farmLastPos = nil
local hum = getHumanoid()
if hum and T.farmAR ~= nil then hum.AutoRotate = T.farmAR end
T.farmAR = nil
if T.farmHover then pcall(function() T.farmHover:Destroy() end) T.farmHover = nil end
local r = T.farmRoot
if T.farmBV then pcall(function() T.farmBV:Destroy() end) T.farmBV = nil end
if T.farmBG then pcall(function() T.farmBG:Destroy() end) T.farmBG = nil end
if r and r.Parent then r.AssemblyLinearVelocity = Vector3.zero r.AssemblyAngularVelocity = Vector3.zero end
T.farmRoot = nil
end
function T.farmCleanup()
T.farmTarget = nil
pcall(function() RunService:UnbindFromRenderStep("RXZ_Farm") end)
if T.farmSavedMagic ~= nil then
state.magicOn = T.farmSavedMagic
state.magicRange = T.farmSavedRange or state.magicRange
T.farmSavedMagic, T.farmSavedRange = nil, nil
end
pcall(function() if T.farmRestore then T.farmRestore() end end)
-- الكلك الوهمي يحوّل اللعبة لنمط الكمبيوتر: نرجّعها لنمط الجوال بلمسة وهمية
pcall(function()
local uis = game:GetService("UserInputService")
if not uis.TouchEnabled then return end
local vim = game:GetService("VirtualInputManager")
local cam = workspace.CurrentCamera
local vp = cam and cam.ViewportSize or Vector2.new(800, 400)
local x, y = vp.X * 0.5, vp.Y * 0.1
task.spawn(function()
pcall(function() vim:SendTouchEvent(9, 0, x, y) end)
task.wait(0.05)
pcall(function() vim:SendTouchEvent(9, 2, x, y) end)
end)
end)
end
function T.farmStop()
T.farmToken = (T.farmToken or 0) + 1
local was = state.farmOn
state.farmOn = false
if was and T.navBusy then T.stopNav() end
T.farmCleanup()
if was then notify("تم إيقاف الفارم") end
end

-- ===== الإطلاق التلقائي (يقلّد ضغطة زر الإطلاق عندك) =====
function T.shootShown(o)
if not o or not o.Parent or not o:IsDescendantOf(playerGui) then return false end
if o.AbsoluteSize.X < 4 or o.AbsoluteSize.Y < 4 then return false end
local cur = o
while cur and cur ~= playerGui do
if cur:IsA("GuiObject") and not cur.Visible then return false end
if cur:IsA("ScreenGui") and not cur.Enabled then return false end
cur = cur.Parent
end
return true
end
function T.findFireBtn()
local c = T.shootObj
if c and T.shootShown(c) then return c end
if os.clock() - (T.shootSearchT or 0) < 0.5 then return nil end
T.shootSearchT = os.clock()
local best, bestScore
for _, d in ipairs(playerGui:GetDescendants()) do
if d:IsA("GuiObject") and string.lower(d.Name) == "shoot" and not d:IsDescendantOf(gui) then
local o = d
if not d:IsA("GuiButton") then
o = d:FindFirstChildWhichIsA("GuiButton", true) or d
end
if T.shootShown(o) then
local score = (o:IsA("GuiButton") and 2 or 0) + (d:IsA("GuiButton") and 1 or 0)
if not best or score > bestScore then best, bestScore = o, score end
end
end
end
T.shootObj = best
return best
end
function T.fireOnce()
local ch = getCharacter()
local tool = ch and ch:FindFirstChildOfClass("Tool")
if tool then pcall(function() tool:Activate() end) end
-- الإطلاق = كلك ماوس يسار، والماوس الوهمي يتحرك لمنتصف الشاشة (وين تصوّب الكاميرا على الضب)
local okv, vim = pcall(function() return game:GetService("VirtualInputManager") end)
if okv and vim then
local cam = workspace.CurrentCamera
local vp = cam and cam.ViewportSize or Vector2.new(800, 400)
local x, y = vp.X / 2, vp.Y / 2
pcall(function() vim:SendMouseMoveEvent(x, y, game) end)
pcall(function() vim:SendMouseButtonEvent(x, y, 0, true, game, 1) end)
task.wait(0.03)
pcall(function() vim:SendMouseButtonEvent(x, y, 0, false, game, 1) end)
end
if typeof(mouse1press) == "function" and typeof(mouse1release) == "function" then
pcall(mouse1press)
task.wait(0.02)
pcall(mouse1release)
elseif not okv and typeof(mouse1click) == "function" then
pcall(mouse1click)
end
end
function T.fireShot()
if T.fireBusy then return end
T.fireBusy = true
task.spawn(function()
pcall(T.fireOnce)
T.fireBusy = false
end)
end
-- تعلّم زر الإطلاق: تضغط زر الإطلاق في لعبتك مرة وحدة وهو يحفظ مكانه
function T.learnFire()
if T.learning then return end
T.learning = true
notify("اضغط زر الإطلاق في لعبتك الحين (أغلق القائمة)", "force", 5)
local conn
local function finish()
T.learning = false
if conn then conn:Disconnect() conn = nil end
end
conn = UserInputService.InputBegan:Connect(function(input)
if not T.learning then return end
local t = input.UserInputType
if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then return end
local pos = input.Position
local insY = game:GetService("GuiService"):GetGuiInset().Y
local found
for _, off in ipairs({ 0, insY }) do
local okq, objs = pcall(function() return playerGui:GetGuiObjectsAtPosition(pos.X, pos.Y - off) end)
if okq then
for _, o in ipairs(objs) do
if o:IsDescendantOf(gui) then return end
if not found and o:IsA("GuiButton") then found = o end
end
end
end
local cam = workspace.CurrentCamera
local vp = cam and cam.ViewportSize or Vector2.new(800, 400)
state.fireX = math.clamp(pos.X / vp.X, 0.001, 1)
state.fireY = math.clamp(pos.Y / vp.Y, 0.001, 1)
if found then
local names, o = {}, found
while o and o ~= playerGui do
table.insert(names, 1, o.Name)
o = o.Parent
end
state.fireBtnPath = table.concat(names, "/")
notify("تم حفظ زر الإطلاق: " .. found.Name, "force", 3)
else
state.fireBtnPath = ""
notify("تم حفظ مكان الضغط كزر إطلاق", "force", 3)
end
finish()
end)
task.delay(20, function()
if T.learning then
finish()
notify("انتهى وقت تحديد زر الإطلاق", "error")
end
end)
end

-- حلقة الفارم: ينتقل لأقرب ضب (التنقل السلس المثبّت)، يطلق عليه لين يموت، ثم ينتقل للي بعده
T.FARM_LIFT = 8
function T.hopTravel(dest, label, air, fast, alive, lift)
local HOP = 1500
for _ = 1, 30 do
if not alive() then return false end
local r = getRootPart()
if not r then return false end
local cur = r.Position
local flat = Vector3.new(dest.X - cur.X, 0, dest.Z - cur.Z)
local target, last = dest, true
if flat.Magnitude > HOP * 1.3 then
local p = cur + flat.Unit * HOP
target, last = Vector3.new(p.X, dest.Y, p.Z), false
end
if not T.smoothTravel(target, last and label or "مرحلة", not last, air, fast, lift, true) then return false end
repeat task.wait(0.1) until not T.navBusy or not alive()
if not alive() then return false end
task.wait(last and 0.6 or 0.4)
local r2 = getRootPart()
if not r2 then return false end
local dd = Vector3.new(target.X - r2.Position.X, 0, target.Z - r2.Position.Z).Magnitude
if dd <= 80 and last then return true end
-- لو الخادم سحبك للخلف نعيد نفس المرحلة من مكانك الحالي
end
return false
end
function T.farmAimPt(e)
local okp, pts = pcall(aimPoints, e, true)
if not okp or not pts then return nil end
local p0 = pts[(state.aimPart == "body") and 1 or 3] or pts[1]
if not p0 then return nil end
-- تعويض حركة الضب خلال تأخر الشبكة (بينغ + لحظة الإطلاق)
local okv, v = pcall(T.targetVel, e.root)
if okv and typeof(v) == "Vector3" and v.Magnitude > 1 and v.Magnitude < 200 then
local okg, ping = pcall(function() return player:GetNetworkPing() end)
local lat = math.clamp((okg and ping or 0.05) + 0.06, 0.03, 0.35)
p0 = p0 + v * lat
end
return p0
end
function T.farmLoop(my)
local function live() return T.farmToken == my and state.farmOn end
local function getTool()
local ch = getCharacter()
local tool = ch and ch:FindFirstChildOfClass("Tool")
if tool then return tool end
local hum = getHumanoid()
local bp = player:FindFirstChildOfClass("Backpack")
if bp and hum then
for _, c in ipairs(bp:GetChildren()) do
if c:IsA("Tool") and not matches(c.Name, T.HUNT_SKIP) then
hum:EquipTool(c)
task.wait(0.25)
local ch2 = getCharacter()
return (ch2 and ch2:FindFirstChildOfClass("Tool")) or c
end
end
end
return nil
end
local hum0 = getHumanoid()
if hum0 and hum0.SeatPart then
hum0.Sit = false
pcall(function() hum0:ChangeState(Enum.HumanoidStateType.Jumping) end)
local t0 = os.clock()
while hum0.SeatPart and os.clock() - t0 < 2 and live() do
hum0.Sit = false
task.wait(0.1)
end
end
if not getTool() then
notify("ما لقيت سلاح بحقيبتك", "error")
return
end
do
local hAR = getHumanoid()
if hAR and T.farmAR == nil then
T.farmAR = hAR.AutoRotate
hAR.AutoRotate = false
end
end
pcall(function() setOpen(false) end)
if T.farmSavedMagic == nil then
T.farmSavedMagic, T.farmSavedRange = state.magicOn, state.magicRange
end
state.magicRange = 3000
if not state.magicOn then
if T.installMagic() then
state.magicOn = true
else
notify("مشغّلك ما يدعم الرصاص السحري، الطلقة ممكن ما توصل للضب", "force")
end
end
pcall(function() RunService:UnbindFromRenderStep("RXZ_Farm") end)
RunService:BindToRenderStep("RXZ_Farm", Enum.RenderPriority.Camera.Value + 2, function(dt)
local e = T.farmTarget
if not e or not e.root.Parent then return end
local cam = workspace.CurrentCamera
if not cam then return end
-- تصويب دقيق على الضب
do
local rh = getRootPart()
if rh and T.navBusy then
if T.farmHover then pcall(function() T.farmHover:Destroy() end) T.farmHover = nil end
elseif rh and not rh.Anchored then
local hv = T.farmHover
if not hv or hv.Parent ~= rh then
if hv then pcall(function() hv:Destroy() end) end
hv = Instance.new("BodyPosition")
hv.MaxForce = Vector3.new(0, 1e7, 0)
hv.P, hv.D = 3e4, 2e3
hv.Parent = rh
T.farmHover = hv
end
local hrp2 = RaycastParams.new()
hrp2.FilterType = Enum.RaycastFilterType.Exclude
hrp2.FilterDescendantsInstances = { getCharacter() or rh, e.inst }
local hit = workspace:Raycast(rh.Position + Vector3.new(0, 3, 0), Vector3.new(0, -80, 0), hrp2)
if hit then
local hm = getHumanoid()
local standY = (hm and hm.HipHeight or 2) + rh.Size.Y / 2
hv.MaxForce = Vector3.new(0, 1e7, 0)
hv.Position = Vector3.new(0, hit.Position.Y + standY + T.FARM_LIFT, 0)
-- دعم مباشر بالسرعة العمودية عشان ما ينزل للأرض
local vy = math.clamp((hit.Position.Y + standY + T.FARM_LIFT - rh.Position.Y) * 10, -60, 60)
local vv = rh.AssemblyLinearVelocity
rh.AssemblyLinearVelocity = Vector3.new(vv.X, vy, vv.Z)
else
hv.MaxForce = Vector3.zero
end
end
end
do
local rf = getRootPart()
if rf and not T.navBusy and not rf.Anchored then
local tpf = e.root.Position
local dv = Vector3.new(tpf.X - rf.Position.X, 0, tpf.Z - rf.Position.Z)
if dv.Magnitude > 0.5 then
rf.CFrame = CFrame.lookAt(rf.Position, rf.Position + dv.Unit)
end
end
end
local ap = T.farmAimPt(e)
if ap then
local goalCF = CFrame.lookAt(cam.CFrame.Position, ap)
local a = 1 - math.exp(-60 * math.clamp(dt or 0.016, 0.001, 0.1))
cam.CFrame = cam.CFrame:Lerp(goalCF, a)
end
end)
notify("بدأ الفارم التلقائي")
local idle, lastFire = 0, 0
while live() do
local hum, hrp = getHumanoid(), getRootPart()
if not hum or not hrp or hum.Health <= 0 then
T.farmTarget = nil
task.wait(0.5)
else
local e = T.huntPick()
if not e then
T.farmTarget = nil
idle = idle + 1
if idle % 10 == 1 then notify("الفارم: ما فيه ضب محمّل — أنتظر...") end
task.wait(0.5)
else
idle = 0
do
local r0 = getRootPart()
local tp0 = e.root.Position
local away = r0 and Vector3.new(r0.Position.X - tp0.X, 0, r0.Position.Z - tp0.Z) or Vector3.zero
T.farmSide = away.Magnitude > 1 and away.Unit or Vector3.new(1, 0, 0)
end
T.farmArrived = false
T.farmSnaps = 0
T.farmTarget = e
local t0 = os.clock()
while live() and e.root.Parent and e.inst.Parent and not T.isDead(e.inst) and os.clock() - t0 < 60 do
local r = getRootPart()
if not r then break end
local tp = e.root.Position
local d = (tp - r.Position).Magnitude
if T.navBusy then
task.wait(0.1)
elseif d > 60 then
-- يطير بارتفاع وسط (فوق الأرض) وينزل جنب الضب، وبعدها يطلق من مكانه الفعلي (نفس الطريقة اللي يقبلها السيرفر)
local away = Vector3.new(r.Position.X - tp.X, 0, r.Position.Z - tp.Z)
away = away.Magnitude > 1 and away.Unit or Vector3.new(1, 0, 0)
if not T.hopTravel(Vector3.new(tp.X + away.X * 10, tp.Y, tp.Z + away.Z * 10), "الضب", 10, true, live, T.FARM_LIFT) then break end
else
if T.farmNotified ~= e then
T.farmNotified = e
notify("وصلت للضب — بدأ الإطلاق")
end
local aimed = true
do
local cam2 = workspace.CurrentCamera
local ap2 = T.farmAimPt(e)
if cam2 and ap2 then
local dv = ap2 - cam2.CFrame.Position
if dv.Magnitude > 1 then aimed = dv.Unit:Dot(cam2.CFrame.LookVector) > 0.998 end
end
end
do
local hc = getHumanoid()
if hc then
-- نحافظ على مسافة بسيطة (حوالي 12 خطوة) من الضب: نقرب إذا بعد، ونتراجع إذا لصقنا فيه
local rv = Vector3.new(r.Position.X - tp.X, 0, r.Position.Z - tp.Z)
local ln = rv.Magnitude
local dir = ln > 0.5 and rv.Unit or (T.farmSide or Vector3.new(1, 0, 0))
if ln > 16 or ln < 7 then
hc:MoveTo(Vector3.new(tp.X + dir.X * 12, r.Position.Y, tp.Z + dir.Z * 12))
else
hc:MoveTo(r.Position)
end
end
end
if aimed and os.clock() - lastFire > 0.1 then
lastFire = os.clock()
getTool()
T.mgFire = os.clock()
T.fireShot()
end
task.wait(0.03)
end
end
T.farmTarget = nil
task.wait(0.1)
end
end
end
end
function T.farmStart()
if state.farmOn then return end
local hum, hrp = getHumanoid(), getRootPart()
if not hum or not hrp then
notify("الشخصية غير متوفرة", "error")
return
end
if T.navBusy then
notify("التنقل السلس شغّال الآن", "error")
return
end
if T.huntRun then T.huntKill() end
T.farmGoToken = (T.farmGoToken or 0) + 1
T.farmGoBusy = false
state.farmOn = true
T.farmToken = (T.farmToken or 0) + 1
local my = T.farmToken
task.spawn(function()
local ok, err = pcall(T.farmLoop, my)
if not ok then
warn("[RXZ] farm: " .. tostring(err))
notify("تعذّر الفارم", "error")
end
if T.farmToken == my then
state.farmOn = false
T.farmCleanup()
end
refreshAll()
end)
end

section(farmPage, "الانتقال إلى الضب بالسيارة")
createButton(farmPage, "{navigate}الانتقال إلى الضب بالسيارة", function() T.farmGo() end)
createButton(farmPage, "{stop}إيقاف الانتقال", function()
T.farmGoStop()
notify("تم إيقاف الانتقال")
end, true)

section(farmPage, "تلفيل اللاعب")
createToggle(farmPage, "تلفيل اللاعب", function() return state.farmOn end, function(v)
if v then T.farmStart() else T.farmStop() end
end)
createSlider(farmPage, "سرعة الطيران", function() return state.farmSpeed end,
function(v) state.farmSpeed = v end, 50, 600, 10, function(v) return v .. " م/ث" end)
do
local warnLbl = createInfo(farmPage, "تلفيل الاعب تحت الصيانة الا الان ليس متكمل  وتوجد بعض المشاكل ينصح لا يستخدم حتى حل المشكله", false)
warnLbl.RichText = true
warnLbl.Text = '<font color="#FF3232">تلفيل الاعب تحت الصيانة الا الان ليس متكمل  وتوجد بعض المشاكل ينصح لا يستخدم حتى حل المشكله</font>'
warnLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
end

section(farmPage, "أزرار الشاشة")
createToggle(farmPage, "زر الفارم على الشاشة", function() return state.farmBtn end, function(v) state.farmBtn = v end)
createToggle(farmPage, "زر الانتقال على الشاشة", function() return state.goBtn end, function(v) state.goBtn = v end)
end
do
local aimPage = newPage("الايمبوت", "target")
section(aimPage, "الايمبوت")
createToggle(aimPage, "تشغيل الايمبوت", function() return state.aimOn end, function(v)
state.aimOn = v
aimTarget = nil
end)
createToggle(aimPage, "إظهار دائرة الايمبوت", function() return state.fovCircle end,
function(v) state.fovCircle = v end)
createDropdown(aimPage, "نقطة التصويب", {
{ key = "head", label = "الرأس (هيد شوت)", noDot = true },
{ key = "neck", label = "الرقبة", noDot = true },
{ key = "body", label = "الجسم", noDot = true },
}, function() return state.aimPart end, function(k)
state.aimPart = k
aimTarget = nil
end)
createSlider(aimPage, "حجم دائرة الايمبوت", function() return state.aimCircle end,
function(v) state.aimCircle = v end, 20, 1000, 10, function(v) return v .. " px" end)
createSlider(aimPage, "مدى الاستهداف", function() return state.aimRange end,
function(v) state.aimRange = v end, 50, 5000, 50, function(v) return v .. " Studs" end)
createSlider(aimPage, "سرعة التتبع", function() return state.aimSmooth end,
function(v) state.aimSmooth = v end, 5, 100, 5, function(v) return v .. "%" end)
createSlider(aimPage, "رفع التصويب فوق الرأس", function() return state.aimLift end,
function(v) state.aimLift = v end, 0, 10, 1, function(v) return v == 0 and "مطفي" or tostring(v) end)
createToggle(aimPage, "زر الايمبوت على الشاشة", function() return state.aimBtn end,
function(v) state.aimBtn = v end)
section(aimPage, "الرصاص السحري")
createToggle(aimPage, "رصاص سحري (الطلقة توصل للضب)", function() return state.magicOn end, function(v)
state.magicOn = v
if v and not T.installMagic() then
state.magicOn = false
notify("المشغّل ما يدعم الرصاص السحري (يحتاج hookmetamethod)", "force")
end
end)
createSlider(aimPage, "مدى الرصاص السحري", function() return state.magicRange end,
function(v) state.magicRange = v end, 100, 3000, 100, function(v) return v .. " م" end)
end
do
local extrasPage = newPage("الإضافات", "widgets")
local function applyScaleAll()
if isOpen then uiScale.Scale = state.userScale end
clampFrame(window)
end
local function applyBackground()
T.bgImg.ImageTransparency = state.bgTransparency
end
section(extrasPage, "الرؤية والإضاءة")
createToggle(extrasPage, "إزالة الضباب", function() return state.fogOn end,
function(v) state.fogOn = v; applyVision() end)
createToggle(extrasPage, "تحسين الإضاءة", function() return state.visOn end,
function(v) state.visOn = v; applyVision() end)
createSlider(extrasPage, "السطوع", function() return state.brightness end,
function(v) state.brightness = v; applyVision() end, 0, 5, 0.25, function(v) return string.format("%.2f", v) end)
createSlider(extrasPage, "الإضاءة المحيطة", function() return state.ambientBoost end,
function(v) state.ambientBoost = v; applyVision() end, 0, 100, 5, function(v) return v .. "%" end)
createToggle(extrasPage, "إزالة التغبيش", function() return state.clearBlur end,
function(v) state.clearBlur = v; applyVision() end)
section(extrasPage, "إزالة العوائق")
createToggle(extrasPage, "إزالة الأشجار", function() return state.hideTrees end,
function(v) state.hideTrees = v; applyNature() end)
createToggle(extrasPage, "إزالة الصخور", function() return state.hideRocks end,
function(v) state.hideRocks = v; applyNature() end)
createButton(extrasPage, "تعليم الصخرة اللي قدامي", function() T.natureLearnAim("rocks") end)
createButton(extrasPage, "مسح الأسماء المعلّمة", function()
T.natureLearn = { trees = {}, rocks = {} }
T.natureRecheck()
notify("تم مسح الأسماء المعلّمة")
end, true)
section(extrasPage, "الواجهة")
createToggle(extrasPage, "المؤثرات", function() return state.effects end, function(v) state.effects = v end)
createToggle(extrasPage, "الإشعارات", function() return state.notifications end, function(v) state.notifications = v end)
createSlider(extrasPage, "حجم الواجهة", function() return state.userScale end,
function(v) state.userScale = v; applyScaleAll() end, 0.7, 1.3, 0.05,
function(v) return string.format("%d%%", math.floor(v * 100 + 0.5)) end)
createSlider(extrasPage, "شفافية الخلفية", function() return state.bgTransparency end,
function(v) state.bgTransparency = v; applyBackground() end, 0, 0.6, 0.05,
function(v) return string.format("%d%%", math.floor(v * 100 + 0.5)) end)
section(extrasPage, "الأزرار")
createToggle(extrasPage, "تعديل الأزرار (فعّل لتحريكها، أطفئ لتثبيتها)", function() return state.padEdit end,
function(v) state.padEdit = v end)
createButton(extrasPage, "إعادة أماكن الأزرار للافتراضي", function()
for k, v in pairs(DEFAULTS) do
if string.match(k, "^pad%u%a*[XY]$") or string.match(k, "^padScale") or string.match(k, "^padAlpha") then state[k] = v end
end
pcall(padsReset)
pcall(T.padApplyAll)
notify("تمت إعادة أماكن الأزرار")
end)
local function resetSettings()
for k, v in pairs(DEFAULTS) do state[k] = v end
for _, radar in ipairs(radars) do
clearRadar(radar)
resetRadarState(radar)
end
aimTarget = nil
ghostRestore(true)
carFlags.up, carFlags.down, carFlags.nitro, carFlags.fwd, carFlags.back, carFlags.drive, carFlags.brake = false, false, false, false, false, false, false
scanState.t = -100
applyMovement(); applyVision(); applyNature(); applyScaleAll(); applyBackground(); applyHudSize(); pcall(padsReset)
setRadar(dhabRadar, true)
refreshAll()
notify("تمت إعادة الضبط")
end
createButton(extrasPage, "إعادة ضبط كل الإعدادات", resetSettings, true)
end
local refreshStatus
do
local infoPage = newPage("معلومات", "info")
local statusLabel, featuresLabel
section(infoPage, "الإصدار")
createInfo(infoPage, "RXZ  v" .. VERSION, true)
section(infoPage, "الحالة")
statusLabel = createInfo(infoPage, "", false)
section(infoPage, "الدعم")
featuresLabel = createInfo(infoPage, "", false)
createButton(infoPage, "تحديث الحالة", function() refreshStatus() end)
refreshStatus = function()
local hum = getHumanoid()
local dhab = #CollectionService:GetTagged(CONFIG.DhabTag) + #scanState.list
statusLabel.Text = table.concat({
"الشخصية: " .. (getCharacter() and "متوفرة" or "غير متوفرة"),
"الضبان: " .. dhab .. "  |  اللاعبون: " .. math.max(#Players:GetPlayers() - 1, 0),
"السيارة: " .. ((hum and hum.SeatPart) and "راكب" or "غير راكب"),
}, "\n")
featuresLabel.Text = table.concat({
"السرعة والقفز: " .. (hum and "مدعومة" or "بانتظار الشخصية"),
"رادار الضبان: " .. (dhab > 0 and "جاهز" or "بدون بيانات"),
}, "\n")
end
end
do
local origSpring = setmetatable({}, { __mode = "k" })
local origPhys = setmetatable({}, { __mode = "k" })
local lastCar, lastSig = nil, ""
local upLocal = setmetatable({}, { __mode = "k" })
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
local function restoreCar()
for c, o in pairs(origSpring) do
if c.Parent then pcall(function() c.Stiffness = o.s; c.Damping = o.d end) end
origSpring[c] = nil
end
for p, o in pairs(origPhys) do
if p.Parent then pcall(function() p.CustomPhysicalProperties = o.v end) end
origPhys[p] = nil
end
end
local function applyCar(car, root)
if not state.suspOn then return end
for _, d in ipairs(car:GetDescendants()) do
if d:IsA("SpringConstraint") then
if not origSpring[d] then origSpring[d] = { s = d.Stiffness, d = d.Damping } end
local o = origSpring[d]
local pw = state.suspPower / 100
d.Stiffness = o.s * (1 + 1.5 * pw)
d.Damping = math.max(o.d * (1 + 3 * pw), o.s * 0.15 * pw)
end
end
end
local function carTop(seat)
local m = seat:FindFirstAncestorOfClass("Model")
while m and m.Parent and m.Parent:IsA("Model") do m = m.Parent end
return m
end
track(RunService.Heartbeat:Connect(function(dt)
if T.navBusy then return end
if not (state.suspOn or state.flipOn) then
if lastCar then restoreCar(); lastCar = nil; lastSig = "" end
return
end
local seat, root = getCar()
if not seat then return end
local car = carTop(seat)
local sig = tostring(state.suspOn) .. tostring(state.flipOn) .. tostring(state.suspPower)
if car and (car ~= lastCar or sig ~= lastSig) then
restoreCar()
lastCar, lastSig = car, sig
safe("المساعدات", applyCar, car, root)
rayParams.FilterDescendantsInstances = { car, getCharacter() }
end
if state.flyOn then return end
local cf = seat.CFrame
local av = root.AssemblyAngularVelocity
local kicking = os.clock() <= (T.kickUntil or 0)
if state.flipOn and not kicking then
local hit = workspace:Raycast(root.Position, Vector3.new(0, -20, 0), rayParams)
local grounded = hit and hit.Distance < 6
if car and not upLocal[car] and grounded then
upLocal[car] = cf:VectorToObjectSpace(Vector3.yAxis)
end
local ul = car and upLocal[car]
if ul then
local normal = Vector3.yAxis
if hit then normal = (hit.Normal * 0.5 + Vector3.yAxis * 0.5).Unit end
local u = cf:VectorToWorldSpace(ul)
local dotv = math.clamp(u:Dot(normal), -1, 1)
local tilt = math.acos(dotv)
if tilt > 0.25 then
local axis = u:Cross(normal)
if axis.Magnitude < 0.2 then axis = cf.LookVector end
local strength = math.min((tilt - 0.25) * 8, 10)
root.AssemblyAngularVelocity = av + axis.Unit * strength * math.min(1, dt * 30)
end
end
if (not hit) or hit.Distance > 5 then
root:ApplyImpulse(Vector3.new(0, -1, 0) * root.AssemblyMass * 45 * dt)
end
elseif state.suspOn and not kicking then
local lav = cf:VectorToObjectSpace(av)
local k = math.clamp(1 - dt * 10 * (state.suspPower / 100), 0, 1)
local steer = 0
if seat:IsA("VehicleSeat") then steer = math.abs(seat.SteerFloat) end
local hum = getHumanoid()
if hum then steer = math.max(steer, math.abs(hum.MoveDirection:Dot(cf.RightVector))) end
local ky = steer > 0.1 and 1 or math.clamp(1 - dt * 12, 0, 1)
root.AssemblyAngularVelocity = cf:VectorToWorldSpace(Vector3.new(lav.X * k, lav.Y * ky, lav.Z * k))
end
if not kicking and not (state.nitroOn and carFlags.nitro) then
local cap = state.flipOn and 8 or 14
local v = root.AssemblyLinearVelocity
if v.Y > cap then
root.AssemblyLinearVelocity = Vector3.new(v.X, cap, v.Z)
end
end
end))
end
do
local lockYaw = nil
track(RunService.Heartbeat:Connect(function(dt)
if not state.stableOn or state.flyOn or carFlags.drive or T.navBusy then
lockYaw = nil
return
end
local seat, root = getCar()
if not seat then lockYaw = nil return end
local cf = seat.CFrame
local f = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
if f.Magnitude < 0.1 then return end
f = f.Unit
local steer = 0
if seat:IsA("VehicleSeat") then steer = math.abs(seat.SteerFloat) end
local hum = getHumanoid()
if hum then steer = math.max(steer, math.abs(hum.MoveDirection:Dot(cf.RightVector))) end
local speed = root.AssemblyLinearVelocity.Magnitude
if steer > 0.15 or speed < 4 then
lockYaw = f
return
end
if not lockYaw then lockYaw = f return end
local ang = math.atan2(f:Cross(lockYaw).Y, f:Dot(lockYaw))
local av = root.AssemblyAngularVelocity
root.AssemblyAngularVelocity = Vector3.new(av.X, math.clamp(ang * 8, -3, 3), av.Z)
end))
end
do
local aimButton = make("TextButton", {
Size = UDim2.fromOffset(60, 34), AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(state.padAimX, state.padAimY),
BackgroundColor3 = Color3.new(0, 0, 0), AutoButtonColor = false, Active = true,
Text = "ايم", TextSize = 14, Font = FONT, TextColor3 = THEME.Text, ZIndex = 3900, Visible = false,
}, gui)
addCorner(aimButton, 8)
T.regPad("Aim", aimButton)
local startPos
local aimDragging = false
makeDragger(aimButton, function()
startPos = aimButton.Position
aimDragging = state.padEdit
end, function(d)
if state.padEdit and startPos then
local sz = gui.AbsoluteSize
if sz.X > 0 and sz.Y > 0 then
aimButton.Position = UDim2.fromScale(math.clamp(startPos.X.Scale + d.X / sz.X, 0.04, 0.96),
math.clamp(startPos.Y.Scale + d.Y / sz.Y, 0.06, 0.94))
end
end
end, function(moved)
if state.padEdit then
state.padAimX = aimButton.Position.X.Scale
state.padAimY = aimButton.Position.Y.Scale
else
if not moved then
state.aimOn = not state.aimOn
aimTarget = nil
end
end
aimDragging = false
end)
track(RunService.Heartbeat:Connect(function()
aimButton.Visible = (state.aimBtn or state.padEdit) and not T.menuOpen
if not aimDragging then
aimButton.Position = UDim2.fromScale(state.padAimX, state.padAimY)
end
if state.aimBtn or state.padEdit then
aimButton.BackgroundColor3 = state.aimOn and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
aimButton.TextColor3 = state.aimOn and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
local t = state.aimOn and "ايم\nشغّال" or "ايم\nمطفي"
if aimButton.Text ~= t then aimButton.Text = t end
end
end))
end
do
T.hb = make("TextButton", {
Size = UDim2.fromOffset(60, 34), AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(state.padFarmX, state.padFarmY),
BackgroundColor3 = Color3.new(0, 0, 0), AutoButtonColor = false, Active = true,
Text = "فارم", TextSize = 14, Font = FONT, TextColor3 = THEME.Text, ZIndex = 3900, Visible = false,
}, gui)
addCorner(T.hb, 8)
T.regPad("Farm", T.hb)
T.hbDrag = false
local startPos
makeDragger(T.hb, function()
startPos = T.hb.Position
T.hbDrag = state.padEdit
end, function(d)
if state.padEdit and startPos then
local sz = gui.AbsoluteSize
if sz.X > 0 and sz.Y > 0 then
T.hb.Position = UDim2.fromScale(math.clamp(startPos.X.Scale + d.X / sz.X, 0.04, 0.96),
math.clamp(startPos.Y.Scale + d.Y / sz.Y, 0.06, 0.94))
end
end
end, function(moved)
if state.padEdit then
state.padFarmX = T.hb.Position.X.Scale
state.padFarmY = T.hb.Position.Y.Scale
elseif not moved then
if state.farmOn then T.farmStop() else T.farmStart() end
refreshAll()
end
T.hbDrag = false
end)
track(RunService.Heartbeat:Connect(function()
T.hb.Visible = (state.farmBtn or state.padEdit) and not T.menuOpen
if not T.hbDrag then T.hb.Position = UDim2.fromScale(state.padFarmX, state.padFarmY) end
if T.hb.Visible then
T.hb.BackgroundColor3 = state.farmOn and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
T.hb.TextColor3 = state.farmOn and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
local t = state.farmOn and "فارم\nشغّال" or "فارم\nمطفي"
if T.hb.Text ~= t then T.hb.Text = t end
end
end))
end
do
T.gb = make("TextButton", {
Size = UDim2.fromOffset(60, 34), AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.fromScale(state.padGoX, state.padGoY),
BackgroundColor3 = Color3.new(0, 0, 0), AutoButtonColor = false, Active = true,
Text = "انتقال", TextSize = 14, Font = FONT, TextColor3 = THEME.Text, ZIndex = 3900, Visible = false,
}, gui)
addCorner(T.gb, 8)
T.regPad("Go", T.gb)
T.gbDrag = false
local startPos
makeDragger(T.gb, function()
startPos = T.gb.Position
T.gbDrag = state.padEdit
end, function(d)
if state.padEdit and startPos then
local sz = gui.AbsoluteSize
if sz.X > 0 and sz.Y > 0 then
T.gb.Position = UDim2.fromScale(math.clamp(startPos.X.Scale + d.X / sz.X, 0.04, 0.96),
math.clamp(startPos.Y.Scale + d.Y / sz.Y, 0.06, 0.94))
end
end
end, function(moved)
if state.padEdit then
state.padGoX = T.gb.Position.X.Scale
state.padGoY = T.gb.Position.Y.Scale
elseif not moved then
T.farmGo()
end
T.gbDrag = false
end)
track(RunService.Heartbeat:Connect(function()
T.gb.Visible = (state.goBtn or state.padEdit) and not T.menuOpen
if not T.gbDrag then T.gb.Position = UDim2.fromScale(state.padGoX, state.padGoY) end
if T.gb.Visible then
T.gb.BackgroundColor3 = T.farmGoBusy and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
T.gb.TextColor3 = T.farmGoBusy and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
local t = T.farmGoBusy and "انتقال\nجاري" or "انتقال\nللضب"
if T.gb.Text ~= t then T.gb.Text = t end
end
end))
end
-- ===== البوصلات: الديرة وشيخ النفود (صغيرة بأعلى الشاشة، جنب بعض بدون تداخل) =====
do
T.vcRow = make("Frame", {
Name = "Compasses", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(state.padCompassX, state.padCompassY),
Size = UDim2.fromOffset(240, 64), BackgroundTransparency = 1, ZIndex = 3600,
}, gui)
make("UIListLayout", {
FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
VerticalAlignment = Enum.VerticalAlignment.Top, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
}, T.vcRow)
local function newCompass(order, accent, name)
local c = {}
c.frame = make("Frame", {
Name = name, Size = UDim2.fromOffset(60, 64), BackgroundTransparency = 1, Visible = false,
LayoutOrder = order, ZIndex = 3600,
}, T.vcRow)
local disc = make("Frame", {
AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), Size = UDim2.fromOffset(42, 42),
BackgroundColor3 = THEME.Bg, BackgroundTransparency = 0.2, ZIndex = 3600,
}, c.frame)
addCorner(disc, 21)
addStroke(disc, accent, 1.5, 0.15)
c.arrow = T.icon("navigate", disc, 28, THEME.Text, accent)
c.arrow.AnchorPoint = Vector2.new(0.5, 0.5)
c.arrow.Position = UDim2.fromScale(0.5, 0.5)
for _, d in ipairs(c.arrow:GetDescendants()) do
if d:IsA("GuiObject") then d.ZIndex = 3602 end
end
c.label = make("TextLabel", {
Position = UDim2.fromOffset(0, 45), Size = UDim2.fromOffset(60, 17), BackgroundColor3 = THEME.Bg, BackgroundTransparency = 0.2,
Text = name, TextColor3 = THEME.Text, TextSize = 11, Font = FONT, ZIndex = 3600,
}, c.frame)
addCorner(c.label, 6)
c.acc, c.pos = 0, nil
return c
end
-- يحدّث بوصلة: radar مفعّل، getPos يرجع أقرب موقع (أو nil)، saved موقع محفوظ احتياطي
local function stepCompass(c, dt, enabled, getPos, saved, title, hideIfMissing)
local myRoot = getRootPart()
local edit = state.padEdit and not T.menuOpen
local show = (enabled or edit) and not T.menuOpen
if show then
c.acc += dt
if c.acc >= 0.5 or c.first == nil then
c.acc, c.first = 0, true
local found = myRoot and getPos(myRoot.Position) or nil
c.found = found ~= nil
c.pos = found or (saved and saved()) or nil
end
if hideIfMissing and not c.found and not edit then show = false end
end
if c.frame.Visible ~= show then c.frame.Visible = show end
if not show then
c.first = nil
return
end
local cam = workspace.CurrentCamera
if not myRoot or not cam or not c.pos then
c.arrow.Visible = false
c.label.Text = title
return
end
c.arrow.Visible = true
local look = cam.CFrame.LookVector
local fwd = Vector3.new(look.X, 0, look.Z)
if fwd.Magnitude < 1e-3 then return end
fwd = fwd.Unit
local d = Vector3.new(c.pos.X - myRoot.Position.X, 0, c.pos.Z - myRoot.Position.Z)
if d.Magnitude > 1 then
c.arrow.Rotation = math.deg(math.atan2(d:Dot(fwd:Cross(Vector3.yAxis)), d:Dot(fwd)))
end
c.label.Text = title .. " " .. math.floor(d.Magnitude + 0.5)
end
local function nearestPos(getList)
return function(from)
local okc, list = pcall(getList)
if not okc or not list then return nil end
local best, bd
for _, e in ipairs(list) do
if e.root and e.root.Parent then
local dd = (e.root.Position - from).Magnitude
if not bd or dd < bd then best, bd = e.root.Position, dd end
end
end
return best
end
end
T.vcVillage = newCompass(1, THEME.Cyan, "الديرة")
T.vcSheikh = newCompass(2, Color3.fromRGB(255, 200, 60), "الشيخ")
T.regPad("Compass", T.vcRow)
local nearVillage = nearestPos(collectVillage)
local nearSheikh = nearestPos(T.collectSheikh)
-- تحريك مكان البوصلات من «تعديل الأزرار»
local cStart
T.vcDrag = false
T.vcRow.Active = false
makeDragger(T.vcRow, function()
cStart = T.vcRow.Position
T.vcDrag = state.padEdit
end, function(d)
if state.padEdit and cStart then
local sz = gui.AbsoluteSize
if sz.X > 0 and sz.Y > 0 then
T.vcRow.Position = UDim2.fromScale(math.clamp(cStart.X.Scale + d.X / sz.X, 0.08, 0.92),
math.clamp(cStart.Y.Scale + d.Y / sz.Y, 0, 0.88))
end
end
end, function()
if state.padEdit then
state.padCompassX = T.vcRow.Position.X.Scale
state.padCompassY = T.vcRow.Position.Y.Scale
end
T.vcDrag = false
end)
track(RunService.RenderStepped:Connect(function(dt)
T.vcRow.Active = state.padEdit and not T.menuOpen
if not T.vcDrag then T.vcRow.Position = UDim2.fromScale(state.padCompassX, state.padCompassY) end
stepCompass(T.vcVillage, dt, true, function(from)
local p = nearVillage(from)
if p then T.places.villageC = p end
return p
end, function() return T.places.villageC end, "الديرة", false)
-- الشيخ: يظهر في البوصلة فقط إذا طلع (موجود فعلاً بالخريطة)
stepCompass(T.vcSheikh, dt, T.sheikhRadar.enabled, function(from)
local p = nearSheikh(from)
if p then T.places.sheikh = p end
return p
end, nil, "الشيخ", true)
end))
end
local function runSearch()
local q = string.lower(searchBox.Text)
local pageHas, firstPage = {}, nil
for _, s in ipairs(searchables) do
if s.title then
s.row.Visible = (q == "")
else
local show = (q == "") or string.find(s.text, q, 1, true) ~= nil
s.row.Visible = show
if show and q ~= "" then
pageHas[s.page] = true
firstPage = firstPage or s.page
end
end
end
if q ~= "" and not pageHas[currentPage] and firstPage then showPage(firstPage) end
end
track(searchBox:GetPropertyChangedSignal("Text"):Connect(runSearch))
do
local floatButton = make("TextButton", {
Size = UDim2.fromOffset(70, 26), Position = UDim2.fromOffset(math.max((view.X - 70) / 2, 0), 22),
BackgroundColor3 = Color3.new(0, 0, 0), AutoButtonColor = false, Active = true,
Text = "RXZ", TextColor3 = Color3.new(1, 1, 1), TextSize = 14, Font = Enum.Font.GothamBlack, ZIndex = 4000,
}, gui)
addCorner(floatButton, 7)
local floatScale = make("UIScale", { Scale = 1 }, floatButton)
local floatStart
makeDragger(floatButton, function()
floatStart = floatButton.Position
TweenService:Create(floatScale, TweenInfo.new(0.1), { Scale = 0.92 }):Play()
end, function(d, moved)
if moved then
floatButton.Position = UDim2.fromOffset(floatStart.X.Offset + d.X, floatStart.Y.Offset + d.Y)
clampFrame(floatButton)
end
end, function(moved)
TweenService:Create(floatScale, TweenInfo.new(0.15), { Scale = 1 }):Play()
if not moved then setOpen(not isOpen) end
end)
end
-- ===== اختصارات الكمبيوتر =====
do
track(UserInputService.InputBegan:Connect(function(input, gp)
if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
if UserInputService:GetFocusedTextBox() then return end
local k = input.KeyCode
if k == Enum.KeyCode.Insert or k == Enum.KeyCode.RightControl then
setOpen(not isOpen)
return
end
if gp or isOpen then return end
if k == Enum.KeyCode.Z then
state.aimOn = not state.aimOn
notify(state.aimOn and "الايم شغّال" or "الايم مطفي")
elseif k == Enum.KeyCode.X then
if state.farmOn then T.farmStop() else T.farmStart() end
refreshAll()
elseif k == Enum.KeyCode.C then
T.farmGo()
end
end))
if T.isPC then
notify("اضغط Insert أو Ctrl الأيمن لإظهار/إخفاء القائمة  •  Z ايم  •  X فارم  •  C انتقال", nil, 7)
end
end
local function collectSettings()
local st = {}
for k, v in pairs(state) do
local t = typeof(v)
if t == "number" or t == "boolean" or t == "string" then st[k] = v end
end
local rd = {}
for _, r in ipairs(radars) do
rd[r.key] = {
enabled = r.enabled, markers = r.markers, rarityFilter = r.rarityFilter, rarityPick = r.rarityPick, rarities = (function() local l = {} for k in pairs(r.rarities or {}) do l[#l + 1] = k end return l end)(),
pickOn = r.pickOn, pickName = r.pickName,
}
end
local ig = {}
for k in pairs(T.ignore) do ig[#ig + 1] = k end
return { ver = "5.6", natureLearn = T.natureLearnPack(), places = T.placesPack(), seenUpdate = T.seenUpdate, state = st, radars = rd, patterns = CONFIG.NamePatterns.dhab, spots = teleportSpots, learned = T.learned, rbn = T.rbn, ignore = ig }
end
local lastSaved = ""
local function saveSettings(force)
if not canFile then return end
local ok, json = pcall(function() return HttpService:JSONEncode(collectSettings()) end)
if ok and (force or json ~= lastSaved) then
lastSaved = json
pcall(writefile, SETTINGS_FILE, json)
end
end
T.saveNow = function() saveSettings(true) end
-- ===== منع الركوب التلقائي في السيارة (بدون ما يطيّرك) =====
T.allowSeatUntil, T.okSeat = 0, nil
function T.allowSeat(sec) T.allowSeatUntil = math.max(T.allowSeatUntil, os.clock() + (sec or 6)) end
do
-- أي نية ركوب مقصودة (زر E/F/Enter، تفعيل ProximityPrompt، ضغطة على زر بالواجهة) تفتح نافذة سماح قصيرة
track(UserInputService.InputBegan:Connect(function(input, gp)
local t = input.UserInputType
if t == Enum.UserInputType.Keyboard then
local k = input.KeyCode
if k == Enum.KeyCode.E or k == Enum.KeyCode.F or k == Enum.KeyCode.G or k == Enum.KeyCode.Return then T.allowSeat(3) end
end
end))
pcall(function()
local pps = game:GetService("ProximityPromptService")
track(pps.PromptTriggered:Connect(function() T.allowSeat(4) end))
track(pps.PromptButtonHoldBegan:Connect(function() T.allowSeat(5) end))
end)
local gHum, lastKick = nil, 0
track(RunService.Heartbeat:Connect(function()
local hum = getHumanoid()
if not hum then return end
if hum ~= gHum then
gHum = hum
T.okSeat = hum.SeatPart
end
local seat = hum.SeatPart
if not seat then
T.okSeat = nil
return
end
local block = state.noAutoSit and os.clock() >= T.allowSeatUntil
if not block then
T.okSeat = seat
return
end
if seat == T.okSeat then return end
-- ركوب غير مقصود: ننزل مرة وحدة بهدوء. لو السيارة تتحرك بسرعة ما نلمسها (عشان ما تتطاير)
local now = os.clock()
if now - lastKick < 1.5 then return end
local asm = seat.AssemblyRootPart or seat
local sp = asm.AssemblyLinearVelocity.Magnitude
if sp > 8 then
T.okSeat = seat
return
end
lastKick = now
hum.Sit = false
task.delay(0.2, function()
if hum.Parent and hum.SeatPart == seat and state.noAutoSit and os.clock() >= T.allowSeatUntil then
hum.Jump = true
end
end)
end))
end
local accRadar, accStatus, accHud, accGhost, accSave = 0, 0, 0, 0, 0
track(RunService.Heartbeat:Connect(function(dt)
accSave += dt
if accSave >= 3 then
accSave = 0
saveSettings(false)
end
accRadar += dt
accStatus += dt
accHud += dt
accGhost += dt
if state.speedOn or state.jumpOn or originals.speedTouched or originals.jumpTouched then
pcall(applyMovement)
end
safe("السيارة", carStep, dt)
-- إعادة تهيئة العلامات عند الدخول/الخروج من السيارة أو إعادة ظهور الشخصية
-- حتى لا تبقى علامات قديمة معلّقة وتعاد الفحوصات من الصفر
do
local hum0 = getHumanoid()
local seatNow = hum0 and hum0.SeatPart or nil
local charNow = getCharacter()
if seatNow ~= T.lastSeatSeen or charNow ~= T.lastCharSeen then
T.lastSeatSeen, T.lastCharSeen = seatNow, charNow
for _, radar in ipairs(radars) do clearMarkers(radar) end
scanState.dirty = true
accRadar = 1
end
end
if accGhost >= 0.3 then
accGhost = 0
safe("العوائق", ghostStep)
end
if accRadar >= (T.radarGap or CONFIG.RadarInterval) then
accRadar = 0
local rt0 = os.clock()
for _, radar in ipairs(radars) do
if radar.enabled then safe(radar.title, updateRadar, radar) end
end
-- فاصل تكيّفي: إذا صار التحديث ثقيلاً (قرية/زحمة) يوسّع الفاصل تلقائياً فلا يحصل تقطيع
T.radarGap = math.clamp((os.clock() - rt0) * 5, 0.02, 0.12)
end
if accHud >= 0.05 then
accHud = 0
safe("قائمة الرادار", drawHud)
end
if accStatus >= 0.5 then
accStatus = 0
if isOpen and currentPage == "معلومات" then safe("الحالة", refreshStatus) end
if isOpen then safe("القوائم", refreshAll) safe("أعلى القائمة", T.keepTop) end
end
end))
local cleaned = false
local function cleanup()
if cleaned then return end
cleaned = true
pcall(function() if T.Nav then T.Nav.stop() end end)
pcall(function() if T.huntKill then T.huntKill() end end)
pcall(function() T.farmToken = (T.farmToken or 0) + 1 T.farmGoToken = (T.farmGoToken or 0) + 1 if T.farmCleanup then T.farmCleanup() end end)
pcall(function() if T.CarFX then T.CarFX.restoreAll() T.CarFX.viewRestore() end end)
pcall(saveSettings, true)
pcall(function() local h = getHumanoid() if h then h:SetStateEnabled(Enum.HumanoidStateType.Seated, true) end end)
pcall(function() if T.skGhost then T.skGhost:Destroy() end end)
pcall(function() if T.barGui then T.barGui:Destroy() end end)
pcall(function() tracerGui:Destroy() end)
pcall(function() toastGui:Destroy() end)
pcall(function() for _, g in pairs(T.ghosts) do if g.part then g.part:Destroy() end end end)
pcall(function() RunService:UnbindFromRenderStep(AIM_BIND) end)
state.magicOn = false
for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
state.speedOn, state.jumpOn, state.aimOn, state.farmOn, state.autoKill = false, false, false, false, false
state.fogOn, state.visOn, state.clearBlur = false, false, false
state.flyOn, state.nitroOn, state.modOn, state.ghostOn = false, false, false, false
state.noclip, state.pFly, state.infJump = false, false, false
pcall(applyMovement)
state.hideTrees, state.hideRocks = false, false
pcall(applyVision)
pcall(applyNature)
pcall(ghostRestore, true)
end
gui.Destroying:Connect(cleanup)
pcall(function()
if script then
script.Destroying:Connect(function() gui:Destroy() end)
end
end)
local WHITE = Color3.new(1, 1, 1)
local function whiten(inst)
if (inst:IsA("TextLabel") or inst:IsA("TextButton")) and inst.Name ~= "KeepColor" then
inst.TextColor3 = WHITE
inst:GetPropertyChangedSignal("TextColor3"):Connect(function()
if inst.TextColor3 ~= WHITE then
inst.TextColor3 = WHITE
end
end)
end
end
for _, d in ipairs(gui:GetDescendants()) do whiten(d) end
track(gui.DescendantAdded:Connect(whiten))
pcall(function() showPage("الرادار") setOpen(true) end)
do
local sr = typeof(savedData.radars) == "table" and savedData.radars or nil
for _, radar in ipairs(radars) do
local r = sr and sr[radar.key]
if typeof(r) == "table" then
if typeof(r.markers) == "boolean" then radar.markers = r.markers end
if typeof(r.rarityFilter) == "boolean" then radar.rarityFilter = r.rarityFilter end
if typeof(r.rarityPick) == "string" and (r.rarityPick == "all" or RARITIES[r.rarityPick]) then radar.rarityPick = r.rarityPick end
if typeof(r.rarities) == "table" then
for _, k in ipairs(r.rarities) do
if typeof(k) == "string" and RARITIES[k] then radar.rarities[k] = true end
end
end
if radar.rarityPick ~= "all" and next(radar.rarities) == nil then radar.rarities[radar.rarityPick] = true end
if r.enabled == true then setRadar(radar, true) end
elseif radar == dhabRadar and not sr then
setRadar(radar, true)
end
end
end
setRadar(dhabRadar, true)
dhabRadar.markers = true
safe("تطبيق الإعدادات", function()
applyVision(); applyNature(); applyHudSize()
end)
if state.magicOn then
local okm, instm = pcall(function() return T.installMagic() end)
if not (okm and instm) then
state.magicOn = false
notify("المشغّل ما يدعم الرصاص السحري", "force")
end
end
villageGet(); traderGet(); carGet(); getDhabMatches(); T.startSheikhWatch()
refreshAll()
T.navOrder = { "الرادار", "اللاعب", "الايمبوت", "السيارة", "التنقل", "الفارم", "الإضافات", "معلومات" }
function T.fitNav()
for i, nm in ipairs(T.navOrder) do
local b = navButtons[nm]
if b then b.LayoutOrder = i end
end
local n = 0
for _ in pairs(navButtons) do n = n + 1 end
if n == 0 then return end
local wh = window.Size.Y.Offset
if wh < 150 then return end
local avail = wh - 62 - 46
local h = math.clamp(math.floor((avail - (n - 1) * 4) / n), 26, 44)
for _, b in pairs(navButtons) do b.Size = UDim2.new(1, 0, 0, h) end
navList.ScrollingEnabled = (n * h + (n - 1) * 4) > avail + 1
if not navList.ScrollingEnabled then navList.CanvasPosition = Vector2.zero end
end
track(window:GetPropertyChangedSignal("Size"):Connect(T.fitNav))
T.fitNav()
showPage("الرادار")
refreshStatus()
setOpen(true)
end
local ok, err = pcall(main)
if not ok then
warn("[RXZ] " .. tostring(err))
pcall(function()
local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local g = Instance.new("ScreenGui")
g.Name = "RXZ_Error"; g.ResetOnSpawn = false; g.DisplayOrder = 1000; g.Parent = pg
local l = Instance.new("TextLabel")
l.Size = UDim2.new(0.9, 0, 0, 120); l.Position = UDim2.new(0.05, 0, 0, 10)
l.BackgroundColor3 = Color3.fromRGB(120, 20, 20); l.TextColor3 = Color3.new(1, 1, 1)
l.TextWrapped = true; l.TextSize = 16; l.Text = "RXZ خطأ: " .. tostring(err); l.Parent = g
end)
end

