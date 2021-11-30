/**
 * An arithmetic exception that allows for DivideByZero when determining
 * the slope of two points whose coordinate are integers.
 */
public class VerticalSlopeException extends ArithmeticException {
		/**
	  	 * Creates an exception with a message.
	 	 * @param msg The message.
		 */
		public VerticalSlopeException(String msg) {
			super(msg);
		}

		/**
		 * Creates an exception.
	 	 */
		public VerticalSlopeException() {
			super();
		}
}
