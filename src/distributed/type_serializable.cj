package actors.distributed

import std.collection.*

public interface TypeSerializable {
    static func typeModel(): TypeModel
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