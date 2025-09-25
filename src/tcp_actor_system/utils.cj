package actors.tcp_actor_system

extend<T> Array<T> {
    /*
    * Fills the array with the same value
    * @param x - the value to fill the array with
    */
    func fill(x: T) {
        for (i in 0..size) {
            this[i] = x
        }
    }
}