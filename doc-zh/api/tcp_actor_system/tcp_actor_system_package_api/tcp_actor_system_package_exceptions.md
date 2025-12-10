# 异常

## class TCPActorSystemDeserializationException

```cangjie
public class TCPActorSystemDeserializationException <: ActorSystemException {
  TCPActorSystemDeserializationException(message: String)
}
```

功能：TCP Actor 系统中反序列化操作失败时抛出的异常。

### init(String)

```cangjie
TCPActorSystemDeserializationException(message: String)
```

功能：创建带自定义错误信息的反序列化异常。

参数：

- `message: String` - 反序列化错误的描述信息。

## class TCPActorSystemInternalException

```cangjie
public class TCPActorSystemInternalException <: ActorSystemException {
  TCPActorSystemInternalException(message: String)
}
```

功能：TCP Actor 系统中发生内部错误时抛出的异常。

### init(String)

```cangjie
TCPActorSystemInternalException(message: String)
```

功能：创建带自定义错误信息的内部错误异常。

参数：

- `message: String` - 内部错误的描述信息。

## class TCPActorSystemRemoteException

```cangjie
public class TCPActorSystemRemoteException <: RemoteException {
  TCPActorSystemRemoteException(message: String)
  TCPActorSystemRemoteException()
}
```

功能：TCP Actor 系统中远程连接失败时抛出的异常。

### init(String)

```cangjie
TCPActorSystemRemoteException(message: String)
```

功能：创建带自定义错误信息的远程连接异常。

参数：

- `message: String` - 远程连接错误的描述信息。

### init()

```cangjie
TCPActorSystemRemoteException()
```

功能：创建带默认错误信息的远程连接异常。

## class TCPActorSystemRequestTimeoutException

```cangjie
public class TCPActorSystemRequestTimeoutException <: RemoteException {
  TCPActorSystemRequestTimeoutException(message: String)
  TCPActorSystemRequestTimeoutException()
}
```

功能：TCP Actor 系统中请求超时时抛出的异常。

### init(String)

```cangjie
TCPActorSystemRequestTimeoutException(message: String)
```

功能：创建带自定义错误信息的请求超时异常。

参数：

- `message: String` - 超时错误的描述信息。

### init()

```cangjie
TCPActorSystemRequestTimeoutException()
```

功能：创建带默认错误信息的请求超时异常，表示请求已超时。

## class TCPActorSystemSerializationException

```cangjie
public class TCPActorSystemSerializationException <: ActorSystemException {
  TCPActorSystemSerializationException(message: String)
}
```

功能：TCP Actor 系统中序列化操作失败时抛出的异常。

### init(String)

```cangjie
TCPActorSystemSerializationException(message: String)
```

功能：创建带自定义错误信息的序列化异常。

参数：

- `message: String` - 序列化错误的描述信息。

