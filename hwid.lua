-- 精简版：从 GitHub 拉取授权列表并验证 HWID
local AnalyticsService = game:GetService("RbxAnalyticsService")
local HttpService = game:GetService("HttpService")

local hwid = AnalyticsService:GetClientId()
print("[系统] 当前设备 HWID:", hwid)

local authUrl = "https://raw.githubusercontent.com/TongScriptX/Saturn/main/auth.json"

local ok, resp = pcall(function() return game:HttpGet(authUrl) end)
if not ok then
    warn("[授权系统] 无法请求授权列表:", authUrl)
    return
end

-- 简单排除 HTML 响应
if resp:find("^%s*<") then
    warn("[授权系统] 返回非 JSON 内容，请确认使用 raw.githubusercontent.com 的 raw 链接")
    return
end

-- 去除可能的 UTF-8 BOM
if resp:sub(1,3) == "\239\187\191" then
    resp = resp:sub(4)
end

local data
local decode_ok, decode_err = pcall(function() data = HttpService:JSONDecode(resp) end)
if not decode_ok or type(data) ~= "table" then
    warn("[授权系统] 授权文件解析失败:", tostring(decode_err or "解析后非数组"))
    return
end

for _, v in ipairs(data) do
    if tostring(v) == tostring(hwid) then
        print("[授权系统] 已授权设备，欢迎使用！")
        return
    end
end

warn("[授权系统] 未授权设备，拒绝运行！")
