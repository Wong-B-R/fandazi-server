# 第 1 周接口（前后端按这份实现）

统一返回：

```json
{ "code": 0, "message": "ok", "data": {} }
```

- `code === 0` 成功
- `code === 401` 未登录或 token 失效
- 其它失败一般是 `400`，`message` 给前端展示

除登录、发验证码、探活外，请求头都要带：

```
Authorization: Bearer <token>
```

---

## 已有（组长）

### GET `/api/hello`

不需要登录。用来确认后端活着。

`data` 示例：`"fandazi backend is running"`

---

## 组员4 · 用户与认证

### POST `/api/auth/wx-login`

不需要登录。

请求：

```json
{ "code": "wx.login拿到的code" }
```

成功 `data`：

```json
{
  "token": "jwt字符串",
  "needProfile": true
}
```

- `needProfile`：昵称/学院/年级是否还没填完
- 验收：授权后进首页；拒绝授权则前端不调用本接口，停在登录页

### POST `/api/auth/campus/send-code`

需要登录。

```json
{ "email": "学号@szu.edu.cn" }
```

- 只允许深大校园邮箱
- 把 6 位验证码写入 `email_code` 表，10 分钟有效
- 第 1 周若还没接邮件服务：验证码打在后端控制台，接口仍返回成功

### POST `/api/auth/campus/verify`

需要登录。

```json
{ "email": "学号@szu.edu.cn", "code": "123456" }
```

- 验证码正确：`user.verified = 1`，写入 `campus_email`
- 验收：头像旁可显示「已认证」；未认证只能浏览饭局（第 2 周再卡权限，本周先把字段写下）

### GET `/api/me`

需要登录。返回当前用户。

```json
{
  "id": 1,
  "nickname": "小王",
  "avatar": "",
  "college": "计算机与软件学院",
  "grade": "2024",
  "verified": true,
  "creditScore": 100,
  "tastes": ["爱吃辣", "清淡"]
}
```

### PUT `/api/me`

需要登录。首次完善资料。

```json
{
  "nickname": "小王",
  "college": "计算机与软件学院",
  "grade": "2024"
}
```

三项都必填。

### GET `/api/me/tastes`

需要登录。返回字符串数组，例如 `["爱吃辣","清淡"]`

### PUT `/api/me/tastes`

需要登录。

```json
{ "tastes": ["爱吃辣", "清淡", "素食"] }
```

- 至少 1 个、最多 5 个
- 允许值：`爱吃辣` `清淡` `素食` `清真` `重口` `少油`
- 验收：显示在个人主页（饭局卡片第 2 周再带上）

---

## 组员5 · 食堂数据与转盘

### GET `/api/canteens`

需要登录。转盘「排除食堂」用。

`data`：

```json
[
  { "id": 1, "name": "荔园食堂" },
  { "id": 2, "name": "风华食堂" }
]
```

### POST `/api/spin`

需要登录。

```json
{ "excludeCanteenIds": [1] }
```

`excludeCanteenIds` 可空数组。

成功 `data`：

```json
{
  "canteen": "风华食堂",
  "windowName": "风华面档",
  "dish": "牛肉汤面",
  "remainTimes": 4
}
```

验收：

1. 3 秒内前端出结果（动画在前端，接口立刻返回即可）
2. 可排除不想去的食堂
3. 同一用户每天最多 5 次，第 6 次：`code=400, message=别挑了，就它吧`

---

## 组员1 / 2 / 3 对照

| 前端页面 | 调用 |
|---|---|
| 登录 | `POST /api/auth/wx-login` |
| 个人中心 | `GET/PUT /api/me`，`GET/PUT /api/me/tastes`，校园认证两个接口 |
| 转盘 | `GET /api/canteens`，`POST /api/spin` |
| 饭局（本周） | 继续用 `GET /api/hello` 练手，不接新接口 |

改接口必须先改这份文档，再改代码。
