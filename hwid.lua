-- 获取 Roblox 提供的唯一设备 ID（安全合法）
local AnalyticsService = game:GetService("RbxAnalyticsService")
local HttpService = game:GetService("HttpService")

-- 获取本地 HWID
local hwid = AnalyticsService:GetClientId()
print("[系统] 当前设备 HWID:", hwid)

-- 请确认为 raw.githubusercontent.com 的正确 raw 链接（注意不要带 refs/heads）
local authUrl = "https://raw.githubusercontent.com/TongScriptX/Saturn/main/auth.json"

-- 拉取授权列表
local ok, response = pcall(function()
    return game:HttpGet(authUrl)
end)

if not ok then
    warn("[授权系统] 无法连接到授权服务器，请检查网络或 URL:", authUrl)
    return
end

-- 输出调试信息（首 500 字节，供排查用）
local preview = tostring(response):sub(1, 500)
print("[授权系统] 拉取到内容长度:", #response)
print("[授权系统] 内容预览（前500字符）:\n---START---\n" .. preview .. "\n---END---")

-- 检查是否为 HTML（常见错误：使用了 github 页面地址而非 raw）
if tostring(response):find("<!DOCTYPE html") or tostring(response):find("<html") then
    warn("[授权系统] 返回内容似乎是 HTML 页面，请确认你使用的是 raw.githubusercontent.com 的 raw 链接，而不是 github 页面 URL。当前 URL:", authUrl)
    return
end

-- 去除可能的 BOM（UTF-8 BOM）
if response:sub(1,3) == "\239\187\191" then
    response = response:sub(4)
end

-- 尝试解析 JSON
local data
local decode_ok, decode_err = pcall(function()
    data = HttpService:JSONDecode(response)
end)

if not decode_ok then
    warn("[授权系统] 授权文件解析失败（JSONDecode 错误）:", tostring(decode_err))
    -- 为方便调试，打印完整响应的前 2000 字符（如果很长请注意）
    print("[授权系统] 响应前2000字符（供调试）:\n" .. tostring(response):sub(1, 2000))
    return
end

-- data 解析后应为数组（table）
if type(data) ~= "table" then
    warn("[授权系统] 授权文件内容解析后不是数组，请检查 JSON 格式，应为 string 数组")
    return
end

-- 检查当前 HWID 是否在授权列表中
local authorized = false
for _, v in ipairs(data) do
    if tostring(v) == tostring(hwid) then
        authorized = true
        break
    end
end

if authorized then
    print("[授权系统] 已授权设备，欢迎使用！")
    -- 在此处放置你的主脚本逻辑
else
    warn("[授权系统] 未授权设备，拒绝运行！")
end
