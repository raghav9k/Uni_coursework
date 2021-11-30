/**
 * QueueEmptyException is thrown whenever an item is requested
 * from an empty queue.
 */
public class QueueEmptyException extends RuntimeException {
	/**
	 * Creates a new Exception.
 	 */
	public QueueEmptyException() {
		super();
	}
	/**
	 * Creates a new Exception.
	 * @param msg A specific message for the user.
	 */
	public QueueEmptyException(String msg) {
		super(msg);
	}
}
