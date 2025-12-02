package actors.distributed

import std.collection.*
import std.collection.concurrent.*

import serialization.serialization.*

public interface Spawnable<T> where T <: Distributable {
    static func typeName(): String
    static func spawnWith(args: Array<SpawnArgument>): Option<T>
}

private type SpawnFunc = (Array<SpawnArgument>) -> Option<Distributable>
private type ConcreteSpawnFunc<T> = (Array<SpawnArgument>) -> Option<T>

private let spawnTable = ConcurrentHashMap<String, SpawnFunc>()
private let serializeTable = ConcurrentHashMap<String, SerializableFuncs>()

public interface ActorCluster {
    static func spawnActor<T>(name: String, args: Array<SpawnArgument>): Option<T> where T <: Distributable & Proxyable<T> & Spawnable<T>
    static func getActor<T>(name: String): Option<T> where T <: Distributable & Proxyable<T> & Spawnable<T>
    static func killActor(name: String): Bool

    static func registerSpawnable<T>(typeName: String, spawnableFunc: ConcreteSpawnFunc<T>): Bool where T <: Distributable & Proxyable<T> & Spawnable<T> {
        let res = spawnTable.putIfAbsent(typeName,
            { args =>
                let opt = spawnableFunc(args)
                match (opt) {
                    case Some(t) => Some(t)
                    case None => None
                }
            }
        )
        match (res) {
            case Some(_) => false
            case None => true
        }
    }

    static func registerSpawnArgument<T>(typeName: String): Bool where T <: Serializable<T> & TypeSerializable {
        let serializeFunc = { t: Any => (t as Serializable<T>).getOrThrow().serialize() }
        let deserializeFunc: (DataModel) -> Any = { dm: DataModel => T.deserialize(dm) }
        let typeModel = T.typeModel()
        let res = serializeTable.putIfAbsent(typeName, SerializableFuncs(serializeFunc, deserializeFunc, typeModel))
        match (res) {
            case Some(_) => false
            case None => true
        }
    }

    static func getSpawnable(typeName: String): Option<(Array<SpawnArgument>) -> Option<Distributable>> {
        spawnTable.get(typeName)
    }
}

struct SerializableFuncs {
    SerializableFuncs(
        let serializeFunc: (Any) -> DataModel,
        let deserializeFunc: (DataModel) -> Any,
        let typeModel: TypeModel
    ) {}
}

public struct SpawnArgument <: Serializable<SpawnArgument> & TypeSerializable {

    public let typeName: String
    public let value: Any

    private init(typeName: String, value: Any) {
        this.typeName = typeName
        this.value = value
    }

    public static func create<T>(typeName: String, value: T): SpawnArgument where T <: Serializable<T> & TypeSerializable {
        SpawnArgument(typeName, value)
    }

    public func serialize(): DataModel {
        let funcs = match(serializeTable.get(typeName)) {
            case Some(funcs) => funcs
            case None => throw ActorSystemException("Serializable functions not found for type name ${typeName}.")
        }
        DataModelStruct(ArrayList([
            Field("typeName", DataModelString(typeName)),
            Field("value", funcs.serializeFunc(value))
        ]))
    }

    public static func deserialize(dataModel: DataModel): SpawnArgument {
        let structValue = match (dataModel) {
            case dm: DataModelStruct => dm
            case _ => throw DataModelException("Expected DataModelStruct for SpawnArgument deserialization.")
        }
        let typeName = match (structValue.get("typeName")) {
            case nameField: DataModelString => nameField.getValue()
            case _ => throw DataModelException("Expected DataModelString for SpawnArgument deserialization.")
        }
        let funcs = match(serializeTable.get(typeName)) {
            case Some(funcs) => funcs
            case None => throw ActorSystemException("Serializable functions not found for type name ${typeName}.")
        }
        let value = match(structValue.get("value")) {
            case valueField: DataModel => funcs.deserializeFunc(valueField)
            case _ => throw DataModelException("Expected DataModel for SpawnArgument deserialization.")
        }
        SpawnArgument(typeName, value)
    }

    public static func typeModel(): TypeModel {
        TypeModel.StructType([
            FieldModel(name: "typeName", description: "Type Name", typeModel: TypeModel.StringType),
            FieldModel(name: "value", description: "Value", typeModel: TypeModel.UnitType)
        ])
    }
}