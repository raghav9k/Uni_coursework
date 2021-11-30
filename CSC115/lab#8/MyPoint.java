import java.awt.Point;

/**
 * MyPoint.java
 * @author B. Bultena.
 * @version 1.0
 * Written exclusively for UVic CSC115 201701, Lab 8.
 * Students are welcome to use and modify this code, provided they do 
 * not claim this as their own code.
 */

/**
 * MyPoint class is a class created specifically for CSC115
 * students to illustrate the following:
 * <ul>
 * <li> extension of an existing class.
 * <li> inheritance of the data fields: (<i>x</i>,<i>y</i>)
 * <li> the use of <code>super</code> to call the super constructor.
 * <li> overloading of the <code>toString</code> method.
 * <li> some basic graph formulae.
 * </ul>
 * The MyPoint class extends the java.awt.Point class by 
 * adding a couple extra methods.
*/
public class MyPoint extends Point {

	// Note that we do not need data fields, since
	// we inherit the x and y from the Point class.

	/**
	 * Creates a point with x and y coordinates.
	 * @param xCoord The x coordinate.
	 * @param yCoord The y coordinate.
	 */

	public MyPoint(int xCoord, int yCoord) {
		super(xCoord,yCoord);
	}
	/**
	 * Creates a point with coordinates (0,0).
	 */
	public MyPoint() {
		super();
	}

	// STUDENT WORK:
	// Complete this method as specified in the MyPoint.html file.
	public MyPoint midPoint(MyPoint other) {
		int m_x=(int)Math.round((0.0+x+other.x)/2);
		int m_y = (int)Math.round((0.0+y+other.y)/2);
		return new MyPoint(m_x,m_y);
	}

	/**
	 * Determines the slope of this point in relation to another point.
	 * @param other the second point, <i>this</i> being the first point.
	 * @return the slope
	 * @throws VerticalSlopeException if the points are on the same vertical line.
	 */
	public double slope(MyPoint other) {
		/* There is a much easier way to check for dx != 0, but
		 * this is a nice example of re-throwing an exception.
		 */
		try {
			int check=(other.y-y)/(other.x-x);
		} catch (ArithmeticException ae) {
			if (ae.getMessage().contains("/ by zero")) {
				throw new VerticalSlopeException();
			} else {
				// we don't recognize the exception: must be something else
				throw ae;
			}
		}	
		return 1.0*(other.y-y)/(other.x-x);
	}

	// STUDENT WORK:
	// Complete this method as specified in the MyPoint.html file.
	public double distance(MyPoint other) {
		double distance = Math.sqrt(((other.x-x)*(other.x-x))+((other.y-y)*(other.y-y)));
		return distance;
}

	/**
	 * Provides the details of this point as "(<i>x</i>,<i>y</i>)" where 
	 * <i>x</i> and <i>y</i> are
	 * integer values.
	 * @return the string.
	 */
	public String toString() {
		return "("+x+","+y+")";
	}

	/**
	 * Used for unit testing only.
	 * @param args Not used.
	 */
	public static void main(String[] args) {
		System.out.println("Testing the MyPoint class:");
		// check vertical slope:
		MyPoint a = new MyPoint(1,1);
		MyPoint b = new MyPoint(1,4);
		System.out.println("Point a = "+a);
		System.out.println("Point b = "+b);
		try {
			double m = a.slope(b);
		} catch(VerticalSlopeException vse) {
			System.out.println("Caught the vertical slope");
		}
		a.x = 0;
		System.out.println("Changed Point a to "+a);
		System.out.println("Slope = "+a.slope(b));
		System.out.println("MidPoint = "+a.midPoint(b));
		System.out.println("Distance between a and b is "+a.distance(b));
	}
}

