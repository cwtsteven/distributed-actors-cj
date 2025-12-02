package actors.distributed

import std.collection.*
import std.collection.concurrent.*

import serialization.serialization.*

private type SpawnFunc = (Array<SpawnArgument>) -> Option<Distributable>
private type ConcreteSpawnFunc<T> = (Array<SpawnArgument>) -> Option<T>

private var spawnTable = ConcurrentHashMap<String, SpawnFunc>()

public interface ActorCluster {
    static func spawnActor<T>(name: String, args: Array<SpawnArgument>): Option<T> where T <: Distributable & Proxyable<T> & Spawnable<T>

    static func registerSpawnable<T>(typeName: String, spawnableFunc: ConcreteSpawnFunc<T>): Bool where T <: Distributable & Proxyable<T> & Spawnable<T> {
        spawnTable.put(typeName, { args => match (spawnableFunc(args)) { case Some(t) => Some(t) case None => None } })
        true
    }

    static func getSpawnable(typeName: String): Option<(Array<SpawnArgument>) -> Option<Distributable>> {
        spawnTable.get(typeName)
    }
}

public interface Spawnable<T> where T <: Distributable {
    static func typeName(): String
    static func spawnWith(args: Array<SpawnArgument>): Option<T>
}

public struct SpawnArgument <: Serializable<SpawnArgument> & TypeSerializable {
    private static let serializeTable = ConcurrentHashMap<String, SerializableFuncs>()

    public let typeName: String
    public let value: Any

    private init(typeName: String, value: Any) {
        this.typeName = typeName
        this.value = value
    }

    public static func create<T>(typeName: String, value: T): SpawnArgument where T <: Serializable<T> & TypeSerializable {
        let serializeFunc = { t: Any => (t as Serializable<T>).getOrThrow().serialize() }
        let deserializeFunc: (DataModel) -> Any = { dm: DataModel => T.deserialize(dm) }
        let typeModel = T.typeModel()
        serializeTable.put(typeName, SerializableFuncs(serializeFunc, deserializeFunc, typeModel))
        SpawnArgument(typeName, value)
    }

    public func serialize(): DataModel {
        let serializeFunc = serializeTable.get(typeName).getOrThrow().serializeFunc
        DataModelStruct(ArrayList([
            Field("typeName", DataModelString(typeName)),
            Field("value", serializeFunc(value))
        ]))
    }

    public static func deserialize(dataModel: DataModel): SpawnArgument {
        let structValue = (dataModel as DataModelStruct).getOrThrow()
        let typeName = (structValue.get("typeName") as DataModelString).getOrThrow().getValue()
        let deserializeFunc = serializeTable.get(typeName).getOrThrow().deserializeFunc
        let value = deserializeFunc(structValue.get("value"))
        SpawnArgument(typeName, value)
    }

    public static func typeModel(): TypeModel {
        TypeModel.StructType([
            FieldModel(name: "typeName", description: "Type Name", typeModel: TypeModel.StringType),
            FieldModel(name: "value", description: "Value", typeModel: TypeModel.IntType)
        ])
    }
}

struct SerializableFuncs {
    SerializableFuncs(
        let serializeFunc: (Any) -> DataModel,
        let deserializeFunc: (DataModel) -> Any,
        let typeModel: TypeModel
    ) {}
}