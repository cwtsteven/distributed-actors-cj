package actors.tcp_actor_system

import std.collection.*

class ByteArrayStream {
    private let data = ArrayList<Byte>()
    private var readPos: Int64 = 0

    prop length: Int64 {
        get() {
            data.size
        }
    }

    func write(bytes: Array<Byte>): Unit {
        for (b in bytes) {
            data.add(b)
        }
    }

    func read(bytes: Array<Byte>): Unit {
        if (readPos + bytes.size > data.size) {
            throw IllegalArgumentException("Not enough bytes in stream.")
        }

        for (i in 0..bytes.size) {
            bytes[i] = data[readPos + i]
        }
        readPos += bytes.size
    }
}
