# 异常

## class ActorClusterException

```cangjie
public class ActorClusterException <: ActorSystemException
```

功能：当分布式 actor 集群发生错误时抛出，例如集群管理或协调失败。

## class ActorNotFoundException

```cangjie
public class ActorNotFoundException <: ActorSystemException {
  public init(name: String)
}
```

功能：当找不到指定名称的 actor 时抛出。

### init(String)

```cangjie
public init(name: String)
```

功能：创建包含找不到的 Actor 名称信息的 `ActorNotFoundException`。

参数：

- `name: String` - 找不到的 actor 的名称。

## class ActorSystemException

```cangjie
public class ActorSystemException <: Exception
```

功能：actor 系统相关错误的通用异常。

## class DeserializationException

```cangjie
public class DeserializationException <: ActorSystemException {
  public init(message: String)
}
```

功能：当反序列化操作失败时抛出。

### init(String)

```cangjie
public init(message: String)
```

功能：创建带自定义错误信息的 `DeserializationException`。

参数：

- `message: String` - 描述反序列化错误的自定义错误信息。

## class ReceiverNotFoundException

```cangjie
public class ReceiverNotFoundException <: ActorSystemException {
  public init(name: String, receiverName: String)
}
```

功能：当在指定的 actor 接口中找不到 receiver 函数时抛出。

### init(String, String)

```cangjie
public init(name: String, receiverName: String)
```

功能：创建包含接口名与找不到的 receiver 名称信息的 `ReceiverNotFoundException`。

参数：

- `name: String` - actor 接口名称。
- `receiverName: String` - 找不到的 receiver 函数名称。

## class RemoteException

```cangjie
public class RemoteException <: ActorSystemException
```

功能：分布式 actor 通信过程中远程连接失败时抛出。

## class RemoteReceiverException

```cangjie
public class RemoteReceiverException <: ActorSystemException & Serializable<RemoteReceiverException> {
  public override func serialize(): DataModel
  public static func deserialize(dm: DataModel): RemoteReceiverException
}
```

功能：包装远程 receiver 执行中抛出的不可序列化异常或错误；该异常可序列化以便网络传输。

实现接口：
- `Serializable`

### func serialize()

```cangjie
public override func serialize(): DataModel
```

功能：将 `RemoteReceiverException` 序列化以进行网络传输。

返回值：

- `DataModel` - 异常的序列化表示。

### func deserialize()

```cangjie
public static func deserialize(dm: DataModel): RemoteReceiverException
```

功能：从 `DataModel` 反序列化得到 `RemoteReceiverException`。

参数：

- `dm: DataModel` - 异常的序列化数据。

返回值：

- `RemoteReceiverException` - 反序列化得到的异常实例。

异常：

- `DeserializationException` - 如果异常无法反序列化则抛出。

## class SerializationException

```cangjie
public class SerializationException <: ActorSystemException
```

功能：当序列化操作失败时抛出。

## class SerializingFunctionsNotFoundException

```cangjie
public class SerializingFunctionsNotFoundException <: ActorClusterException
```

功能：当找不到序列化函数时抛出。
