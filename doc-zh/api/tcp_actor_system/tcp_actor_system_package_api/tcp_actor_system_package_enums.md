# 枚举

## enum Payload

```Cangjie
enum Payload <: Equatable<Payload> & ToString {
    Ok
    | ErrorCode(TCPActorSystemError)
    | Find(String)
    | FindAll
    | FindResponse(Array<ActorInfo>)
    | Ask(String, String, Array<DataModel>, ReceiverConfig, UInt64)
    | Tell(String, String, Array<DataModel>, ReceiverConfig)
    | Fulfill(UInt64, DataModel)
}
```

功能：TCP 主机与客户端之间的消息协议，定义了两者可交换的所有消息类型。

### 取值

- `Ok` — 操作成功
- `ErrorCode(TCPActorSystemError)` — 携带错误码的错误
- `Find(String)` — 按名称查找 Actor 的请求
- `FindAll` — 查询全部注册 Actor 的请求
- `FindResponse(Array<ActorInfo>)` — 返回 Actor 信息的响应
- `Ask(String, String, Array<DataModel>, ReceiverConfig, UInt64)` — Ask 请求，包含 Actor 名、Receiver 名、参数、配置与 Future ID
- `Tell(String, String, Array<DataModel>, ReceiverConfig)` — Tell 请求，包含 Actor 名、Receiver 名、参数与配置
- `Fulfill(UInt64, DataModel)` — 使用 Future ID 与结果数据完成 Future

### operator ==()

```cangjie
public operator func ==(other: Payload): Bool
```

功能：比较两个 `Payload` 是否相等。

参数：

- `other: Payload` — 另一个待比较的值。

返回值：

- `Bool` — 相等返回 `true`，否则 `false`。

### operator !=()

```cangjie
public operator func !=(other: Payload): Bool
```

功能：比较两个 `Payload` 是否不相等。

参数：

- `other: Payload` — 另一个待比较的值。

返回值：

- `Bool` — 不相等返回 `true`，否则 `false`。

### func toString()

```cangjie
public func toString(): String
```

功能：将 `Payload` 转为字符串。

返回值：

- `String` — `Payload` 的字符串表示。

## enum TCPActorSystemError

```Cangjie
enum TCPActorSystemError <: ToString & Equatable<TCPActorSystemError> {
    | UnknownError
    | ActorNotFound
    | ReceiverNotFound
}
```

功能：TCPActorSystem 的错误码，表示可能出现的错误情况。

### 取值

- `UnknownError` — 未知或意外错误
- `ActorNotFound` — 未找到请求的 Actor
- `ReceiverNotFound` — 未找到请求的 Receiver 函数

### func toString()

```cangjie
public override func toString(): String
```

功能：将错误码转为字符串。

返回值：

- `String` — `TCPActorSystemError`的字符串表示。

### operator ==()

```cangjie
public override operator func ==(other: TCPActorSystemError): Bool
```

功能：比较两个错误码是否相等。

参数：

- `other: TCPActorSystemError` — 另一个待比较的值。

返回值：

- `Bool` — 相等返回 `true`，否则 `false`。

### operator !=()

```cangjie
public override operator func !=(other: TCPActorSystemError): Bool
```

功能：比较两个错误码是否不相等。

参数：

- `other: TCPActorSystemError` — 另一个待比较的值。

返回值：

- `Bool` — 不相等返回 `true`，否则 `false`。
