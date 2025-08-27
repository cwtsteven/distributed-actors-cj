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

## @Receiver macro

```cangjie
public macro Receiver(input: Tokens): Tokens

public macro Receiver(options: Tokens, input: Tokens): Tokens
```

Function: Transform a member function into a receiver function

> **Description:**
>
> The usage of the `@Receiver` macro has the following limitations:
>
> - It can only be used inside an `@Actor` macro;
> - The annotated method must not be `static`;
> - The annotated method must have an explicitly declared return type;
> - The annotated method cannot override an interface method, i.e., it cannot be marked as `override`;
> - If the annotated method does not explicitly use the `override` modifier but actually overrides an interface method, a compilation error will occur after macro expansion;
> - The annotated method cannot be `open`;
> - When used inside an `@Actor` macro with `enableReceiverPriority` set to `true`, the annotated method cannot have a parameter named `priority`.
> - The annotated method cannot have a parameter named `tell`.

Violating these restrictions will result in a compilation error during macro expansion.

Options: The `Receiver` macro accepts a list of options in the form of `opt1: value1, opt2: value2`. For example,

```cangjie
@Receiver[option1: value1, option2: value2]
```

Currently, the only available options are:
- `priority: value` - specifies the default priority level for the receiving function. The provided value must be an integer literal between 1 and 10; otherwise, an error will be thrown during macro expansion. This option is only available when the outer [@Actor](./macros_package_macros.md#actor-macro) macro has the `enableReceiverPriority: true` option.
- `mode: value` - Specifies whether the annotated function should be modified with
'Ask' or 'Tell' behaviour. A function modified with `Ask` behaviour returns an `ActorFuture` 
which allows the caller to obtain the return value of the function and/or wait for the function 
call to finish.
A function modified with `Tell` behaviour returns `Unit` and gives no way for the caller to 
obtain the return value or synchronize with the actor thread.
If the `Tell` receiver function is generated, it will have the same
identifier as the `Ask` receiver function, but will expect an additional
parameter named `tell`, for which the
[`Tell.True`](../../actors_package_api/actors_package_enums.md#enum-tell) 
value must be supplied.
The supplied value to the `mode` option must be one of the following:
    - `AskOnly`: only generates a receiver function that can be called in `Ask` mode.
    - `TellOnly`: only generates a receiver function that can be called in `Tell` mode.
    - `AskAndTell`: generates both receiver functions.

Each option can only appear once, otherwise, an error will be thrown during macro expansion.
