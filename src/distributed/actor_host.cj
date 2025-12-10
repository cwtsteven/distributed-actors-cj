package actors.distributed

/*
* Interface for actor hosts
*/
public interface ActorHost {
    /*
    * Exports an actor
    * @param name - the name of the actor
    * @param a - the actor to export
    * @return true if the actor was successfully exported, false otherwise
    * @throws ActorSystemException - for any system-specific errors
    */
    func export(name: String, a: Distributable): Bool

    /*
    * Un-exports an actor
    * @param name - the name of the actor
    * @return true if the actor was successfully un-exported, false otherwise
    * @throws ActorSystemException - for any system-specific errors
    */
    func unexport(name: String): Bool
}