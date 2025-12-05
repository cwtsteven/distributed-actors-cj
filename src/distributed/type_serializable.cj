package actors.distributed

import std.collection.*

/*
* An interface for types that can be represneted as a TypeModel
*/
public interface TypeSerializable {
    /*
    * Returns the type model of the type
    * @return the type model
    */
    static func typeModel(): TypeModel
}

extend Rune <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.IntType
    }
}

extend UInt8 <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.IntType
    }
}

extend UInt16 <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.IntType
    }
}

extend UInt32 <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.IntType
    }
}

extend UInt64 <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.IntType
    }
}

extend Int8 <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.IntType
    }
}

extend Int16 <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.IntType
    }
}

extend Int32 <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.IntType
    }
}

extend Int64 <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.IntType
    }
}

extend Float16 <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.FloatType
    }
}

extend Float32 <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.FloatType
    }
}

extend Float64 <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.FloatType
    }
}

extend Bool <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.BoolType
    }
}

extend Unit <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.UnitType
    }
}

extend String <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.StringType
    }
}

extend<T> Array<T> <: TypeSerializable where T <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.ListType(T.typeModel())
    }
}

extend<T> Option<T> <: TypeSerializable where T <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.ListType(T.typeModel())
    }
}

extend<T> ArrayList<T> <: TypeSerializable where T <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.ListType(T.typeModel())
    }
}

extend<T> HashSet<T> <: TypeSerializable where T <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.ListType(T.typeModel())
    }
}

extend<K, V> HashMap<K, V> <: TypeSerializable where K <: TypeSerializable & Equatable<K> & Hashable, V <: TypeSerializable {
    public static func typeModel(): TypeModel {
        TypeModel.StructType([
            FieldModel(name: "key", description: "Key", typeModel: K.typeModel()),
            FieldModel(name: "value", description: "Value", typeModel: V.typeModel())
        ])
    }
}