package actors.distributed

import std.collection.*
import std.collection.concurrent.*

import serialization.serialization.*

/*
* An interface for types that can be spawned in a cluster
*/
public interface Spawnable<T> where T <: Distributable {
    /*
    * Gets the type name of the spawnable type, each type should have a unique type name
    * @return the type name
    */
    static func typeName(): String
    /*
    * Spawns a new instance of the type
    * @param args - the arguments to spawn the type with
    * @return the spawned instance
    * @throws IllegalArgumentException - if the arguments are invalid
    */
    static func spawnWith(args: Array<SpawnArgument>): Option<T>
}

private type SpawnFunc = (Array<SpawnArgument>) -> Option<Distributable>
private type ConcreteSpawnFunc<T> = (Array<SpawnArgument>) -> Option<T>

private let spawnTable = ConcurrentHashMap<String, SpawnFunc>()
private let serializeTable = ConcurrentHashMap<String, SerializingFuncs>()

/*
* An interface for creating cluster of actors
*/
public interface ActorCluster {
    /*
    * Spawns a new instance of the type
    * @param name - the name of the actor
    * @param args - the arguments to spawn the type with
    * @return the spawned instance
    * @throws RemoteException - if the connection to the cluster fails
    * @throws IllegalArgumentException - if the arguments are invalid
    */
    static func spawnActor<T>(name: String, args: Array<SpawnArgument>): Option<T> where T <: Distributable & Proxyable<T> & Spawnable<T>

    /*
    * Gets an existing instance of the type
    * @param name - the name of the actor
    * @return the existing instance
    */
    static func getActor<T>(name: String): Option<T> where T <: Distributable & Proxyable<T> & Spawnable<T>

    /*
    * Kills an existing instance of the type
    * @param name - the name of the actor
    * @return true if the actor was killed, false if the actor was not found
    */
    static func killActor(name: String): Bool

    /*
    * Registers a spawning function for a given actor type name
    * @param typeName - the name of the actor type
    * @param spawnableFunc - the spawning function
    * @return true if the spawning function was registered, false if it was already registered
    */
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

    /*
    * Registers a spawning argument type with a given type name
    * @param typeName - the name of the type
    * @return true if the spawning argument is registered, false if it was already registered
    */
    static func registerSpawnArgument<T>(typeName: String): Bool where T <: Serializable<T> & TypeSerializable {
        let serializeFunc = { t: Any => (t as Serializable<T>).getOrThrow().serialize() }
        let deserializeFunc: (DataModel) -> Any = { dm: DataModel => T.deserialize(dm) }
        let typeModel = T.typeModel()
        let res = serializeTable.putIfAbsent(typeName, SerializingFuncs(serializeFunc, deserializeFunc, typeModel))
        match (res) {
            case Some(_) => false
            case None => true
        }
    }

    /*
    * Gets a spawning function for a given type name
    * @param typeName - the name of the type
    * @return the spawning function
    */
    static func getSpawnable(typeName: String): Option<(Array<SpawnArgument>) -> Option<Distributable>> {
        spawnTable.get(typeName)
    }
}

/*
* Serializing functions for a type
*/
struct SerializingFuncs {
    /*
    * Initializes the SerializingFuncs
    * @param serializeFunc - the function to serialize the type
    * @param deserializeFunc - the function to deserialize the type
    * @param typeModel - the type model of the type
    */
    SerializingFuncs(
        let serializeFunc: (Any) -> DataModel,
        let deserializeFunc: (DataModel) -> Any,
        let typeModel: TypeModel
    ) {}
}

/*
* An argument for spawning a distributed actor in a cluster
*/
public struct SpawnArgument <: Serializable<SpawnArgument> & TypeSerializable {

    /*
    * The type name of the argument
    */
    public let typeName: String

    /*
    * The value of the argument
    */
    public let value: Any

    /*
    * Initializes the SpawnArgument
    * @param typeName - the type name of the argument
    * @param value - the value of the argument
    */
    private init(typeName: String, value: Any) {
        this.typeName = typeName
        this.value = value
    }

    /*
    * Creates a new SpawnArgument
    * @param typeName - the type name of the argument
    * @param value - the value of the argument
    * @return the new SpawnArgument
    */
    public static func create<T>(typeName: String, value: T): SpawnArgument where T <: Serializable<T> & TypeSerializable {
        SpawnArgument(typeName, value)
    }

    /*
    * Serializes the SpawnArgument into a DataModel
    * @return the serialized SpawnArgument
    * @throws SerializingFunctionsNotFoundException - if the serializing functions are not registered
    */
    public func serialize(): DataModel {
        let funcs = match(serializeTable.get(typeName)) {
            case Some(funcs) => funcs
            case None => throw SerializingFunctionsNotFoundException("Serializable functions not found for type name ${typeName}.")
        }
        DataModelStruct(ArrayList([
            Field("typeName", DataModelString(typeName)),
            Field("value", funcs.serializeFunc(value))
        ]))
    }

    /*
    * Deserializes a DataModel into a SpawnArgument
    * @param dataModel - the DataModel to deserialize
    * @return the deserialized SpawnArgument
    * @throws DeserializationException - if the deserialization fails
    * @throws SerializingFunctionsNotFoundException - if the serializing functions are not registered
    */
    public static func deserialize(dataModel: DataModel): SpawnArgument {
        let structValue = match (dataModel) {
            case dm: DataModelStruct => dm
            case _ => throw DeserializationException("Expected DataModelStruct for SpawnArgument deserialization.")
        }
        let typeName = match (structValue.get("typeName")) {
            case nameField: DataModelString => nameField.getValue()
            case _ => throw DeserializationException("Expected DataModelString for SpawnArgument deserialization.")
        }
        let funcs = match(serializeTable.get(typeName)) {
            case Some(funcs) => funcs
            case None => throw SerializingFunctionsNotFoundException("Serializable functions not found for type name ${typeName}.")
        }
        let value = match(structValue.get("value")) {
            case valueField: DataModel => funcs.deserializeFunc(valueField)
            case _ => throw DeserializationException("Expected DataModel for SpawnArgument deserialization.")
        }
        SpawnArgument(typeName, value)
    }

    /*
    * Gets the type model of the SpawnArgument
    * @return the type model of the SpawnArgument
    */
    public static func typeModel(): TypeModel {
        TypeModel.StructType([
            FieldModel(name: "typeName", description: "Type Name", typeModel: TypeModel.StringType),
            FieldModel(name: "value", description: "Value", typeModel: TypeModel.UnitType)
        ])
    }
}