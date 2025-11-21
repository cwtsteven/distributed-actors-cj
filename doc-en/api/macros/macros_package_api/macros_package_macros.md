# Macros

## @Actor macro

```cangjie
public macro Actor(input: Tokens): Tokens

public macro Actor(options: Tokens, input: Tokens): Tokens
```

Function: Transform a class into an actor.

> **Description:**
>
> The usage of the `@Actor` macro has the following limitations:
>
> - It can only be applied to classes.
> - The class being annotated cannot be `abstract`, `open`, or `sealed`.

Violating these limitations will result in a compilation error during macro expansion.

Options: The `@Actor` macro accepts a list of options in the form `opt1: value1, opt2: value2`. For example:

```cangjie
@Actor[option1: value1, option2: value2]
```

Currently, the only available option is `enableReceiverPriority: value` — this specifies whether to enable priority between receiver functions. The value provided must be a boolean literal, either `true` or `false`. If this option is not specified, it defaults to `false`.

Each option can only appear once; otherwise, an error will be thrown during macro expansion.

## @ActorInterface macro

```cangjie
public macro ActorInterface(input: Tokens): Tokens

public macro ActorInterface(options: Tokens, input: Tokens): Tokens
```

Function: Transform an interface into an actor interface that can be used for both local and distributed actor communication.

> **Description:**
>
> The usage of the `@ActorInterface` macro has the following limitations:
>
> - It can only be applied to interfaces.
> - The interface cannot have type parameters.
> - All `@Receiver` marked functions must be abstract.
> - All `@Receiver` marked functions cannot have type parameters.
> - No two `@Receiver` marked functions can have the same identifier.

Violating these limitations will result in a compilation error during macro expansion.

Options: The `@ActorInterface` macro accepts a list of options in the form `opt1: value1, opt2: value2`. For example:

```cangjie
@ActorInterface[option1: value1, option2: value2]
```

Available options:

- `distributed: value` - Specifies whether this is a distributed actor interface. Must be a boolean literal (`true` or `false`). Defaults to `false`.
- `description: value` - A human-readable description of the actor interface. Must be a string literal.
- `customInfo: value` - Custom metadata in JSON format. Must be a valid JSON string.

Each option can only appear once; otherwise, an error will be thrown during macro expansion.

## @Receiver macro

```cangjie
public macro Receiver(input: Tokens): Tokens

public macro Receiver(options: Tokens, input: Tokens): Tokens
```

Function: Transform a member function into a receiver function that can be called by other actors.

> **Description:**
>
> The usage of the `@Receiver` macro has the following limitations:
>
> - It can only be used inside an `@Actor` or `@ActorInterface` macro;
> - The annotated method must not be `static`;
> - The annotated method must have an explicitly declared return type;
> - The annotated method cannot override an interface method, i.e., it cannot be marked as `override`;
> - If the annotated method does not explicitly use the `override` modifier but actually overrides an interface method, a compilation error will occur after macro expansion;
> - The annotated method cannot be `open`;
> - The annotated method cannot have a parameter named `tell` or `config`.

Violating these restrictions will result in a compilation error during macro expansion.

Options: The `@Receiver` macro accepts a list of options in the form of `opt1: value1, opt2: value2`. For example,

```cangjie
@Receiver[option1: value1, option2: value2]
```

Available options:

- `priority: value` - Specifies the default priority level for the receiving function. The provided value must be an integer literal between 1 and 10; otherwise, an error will be thrown during macro expansion. This option is only available when the outer `@Actor` macro has the `enableReceiverPriority: true` option.
- `mode: value` - Specifies whether the annotated function should be modified with 'Ask' or 'Tell' behaviour. The supplied value to the `mode` option must be one of the following:
    - `AskOnly`: only generates a receiver function that can be called in `Ask` mode, which returns an `ActorFuture` which allows the caller to obtain the return value of the function and/or wait for the function call to finish.
    - `TellOnly`: only generates a receiver function that can be called in `Tell` mode, which returns `Unit` and gives no way for the caller to obtain the return value or synchronize with the actor thread.
    - `AskAndTell`: generates both receiver functions. If the `Tell` receiver function is generated, it will have the same identifier as the `Ask` receiver function, but will expect an additional parameter named `tell`, for which the [`Tell.True`](../../actors_package_api/actors_package_enums.md#enum-tell) value must be supplied.
- `description: value` - A human-readable description of the receiver function. Must be a string literal.
- `customInfo: value` - Custom metadata for the receiver function in JSON format. Must be a valid JSON string.

Each option can only appear once, otherwise, an error will be thrown during macro expansion.
