# 宏

## @Actor 宏

```cangjie
public macro Actor(input: Tokens): Tokens

public macro Actor(options: Tokens, input: Tokens): Tokens
```

功能：将类转换为 actor。

> **说明：**
>
> 使用 `@Actor` 宏有以下限制：
>
> - 只能用于类；
> - 被注解的类不能为 `abstract`、`open` 或 `sealed`；
>
> 违反上述限制将在宏展开阶段触发编译错误。
>
选项：`@Actor` 接受形如 `opt1: value1, opt2: value2` 的选项列表，例如：

```cangjie
@Actor[option1: value1, option2: value2]
```

目前可用的选项仅为 `enableReceiverPriority: value` —— 指定是否启用 receiver 之间的优先级。取值必须为布尔字面量 `true` 或 `false`，默认 `false`。每个选项最多出现一次，否则宏展开时报错。

## @ActorInterface 宏

```cangjie
public macro ActorInterface(input: Tokens): Tokens

public macro ActorInterface(options: Tokens, input: Tokens): Tokens
```

功能：将接口转换为可用于本地与分布式通信的 actor 接口。

> **说明：**
>
> 使用 `@ActorInterface` 宏有以下限制：
>
> - 只能用于接口；
> - 接口不能包含类型参数；
> - 所有使用 `@Receiver` 标注的函数必须为抽象函数；
> - 所有使用 `@Receiver` 标注的函数不能有类型参数；
> - 不能存在两个具有相同标识符的 `@Receiver` 函数；
>
> 违反上述限制将在宏展开阶段触发编译错误。
>
选项：`@ActorInterface` 接受形如 `opt1: value1, opt2: value2` 的选项列表，例如：

```cangjie
@ActorInterface[option1: value1, option2: value2]
```

可用选项：

- `distributed: value` — 是否为分布式 actor 接口。必须为布尔字面量（`true` 或 `false`），默认 `false`；
- `description: value` — 接口的人类可读描述。必须为字符串字面量；
- `customInfo: value` — JSON 格式的自定义元数据。必须为合法 JSON 字符串；

每个选项最多出现一次，否则宏展开时报错。

## @Receiver 宏

```cangjie
public macro Receiver(input: Tokens): Tokens

public macro Receiver(options: Tokens, input: Tokens): Tokens
```

功能：将成员函数转换为可被其他 actor 调用的 receiver 函数。

> **说明：**
>
> 使用 `@Receiver` 宏有以下限制：
>
> - 只能在 `@Actor` 或 `@ActorInterface` 内部使用；
> - 被注解方法不得为 `static`；
> - 被注解方法必须显式声明返回类型；
> - 被注解方法不得重写接口方法（不能标注 `override`）；
> - 若未显式标注 `override` 但实际重写了接口方法，宏展开后将产生编译错误；
> - 被注解方法不能为 `open`；
> - 被注解方法的参数名中不得包含 `tell` 或 `config`；
>
> 违反上述限制将在宏展开阶段触发编译错误。
>
选项：`@Receiver` 接受形如 `opt1: value1, opt2: value2` 的选项列表，例如：

```cangjie
@Receiver[option1: value1, option2: value2]
```

可用选项：

- `priority: value` — 指定 receiver 的默认优先级，仅当外层宏启用 `enableReceiverPriority: true` 时有效，包括 `@Actor[...]` 和 `@ActorInterface[distributed: true, ...]` 两种情况。取值需为 1 到 10 的整数字面量，否则宏展开时报错；
- `mode: value` — 指定函数的 Ask/Tell 行为：
  - `AskOnly`：仅生成 Ask 模式的 receiver（返回 `ActorFuture`，可等待/获取返回值）；
  - `TellOnly`：仅生成 Tell 模式的 receiver（返回 `Unit`，不可等待/获取返回值）；
  - `AskAndTell`：同时生成两种 receiver。若生成 Tell 版 receiver，其标识与 Ask 版相同，但会额外期望名为 `tell` 的参数，其值必须为 [`Tell.True`](../../actors_package_api/actors_package_enums.md#enum-tell)；
- `description: value` — receiver 的人类可读描述。字符串字面量；
- `customInfo: value` — receiver 的 JSON 格式自定义元数据。必须为合法 JSON 字符串；

每个选项最多出现一次，否则宏展开时报错。
