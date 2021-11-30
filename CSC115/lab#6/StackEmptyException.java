/**
 * StackEmptyException.java
 * Created as a lab exercise for UVic CSC115 201702
 * @author B. Bultena
 * @version 1.0
 */

/**
 * StackEmptyException is thrown whenever an item is requested
 * from an empty stack.
 */
public class StackEmptyException extends RuntimeException {
	/**
	 * Creates a new Exception.
 	 */
	public StackEmptyException() {
		super();
	}
	/**
	 * Creates a new Exception.
	 * @param msg A specific message for the user.
	 */
	public StackEmptyException(String msg) {
		super(msg);
	}
}
