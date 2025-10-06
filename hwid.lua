-- 获取 Roblox 提供的唯一设备 ID（安全合法）
local AnalyticsService = game:GetService("RbxAnalyticsService")
local HttpService = game:GetService("HttpService")

-- 获取本地 HWID
local hwid = AnalyticsService:GetClientId()
print("[系统] 当前设备 HWID:", hwid)

-- GitHub 授权列表地址
local authUrl = "https://raw.githubusercontent.com/TongScriptX/Saturn/refs/heads/main/auth.json"

-- 拉取授权列表
local success, response = pcall(function()
    return game:HttpGet(authUrl)
end)

if not success then
    warn("[授权系统] 无法连接到授权服务器，请检查网络或URL")
    return
end

-- 解析 JSON 授权文件
local data
local success2, err = pcall(function()
    data = HttpService:JSONDecode(response)
end)

if not success2 then
    warn("[授权系统] 授权文件格式错误:", err)
    return
end

-- 检查当前 HWID 是否在授权列表中
local authorized = false
for _, v in ipairs(data) do
    if v == hwid then
        authorized = true
        break
    end
end

if authorized then
    print("[授权系统] ✅ 已授权设备，欢迎使用！")
    -- 在此处放置你的主脚本逻辑
else
    warn("[授权系统] ❌ 未授权设备，拒绝运行！")
end