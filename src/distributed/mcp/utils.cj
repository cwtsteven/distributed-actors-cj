package actors.distributed.mcp

import std.collection.*

extend<T> Array<T> {
    func map<K>(f: (T) -> K): Array<K> {
        Array<K>(size, { i => f(this[i]) })
    }
}

extend<T> ArrayList<T> {
    func map<K>(f: (T) -> K): ArrayList<K> {
        ArrayList<K>(size, { i => f(this[i]) })
    }
}