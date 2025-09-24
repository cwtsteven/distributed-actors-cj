/**
 * Created on 16/09/2025
 */

package actors.tcp_actor_system

extend<T> Array<T> {
    func fill(x: T) {
        for (i in 0..size) {
            this[i] = x
        }
    }
}