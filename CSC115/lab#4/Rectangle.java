/**
 A Rectangle is a closed geometric shape that has 4 sides, 2 vertical and 2 horizontal.
 * The vertical sides have the same length and the horizontal sides have the same length.
 */
public class Rectangle {
	private int width;
	private int height;
	/**
	 * Creates a Rectangle object, with lines that are oriented along the horizontal and vertical.
	 * @param width The width of the rectangle (length of the horizontal sides).
	 * @param height The height of the rectangle (length of the vertical sides).
	 */
	public Rectangle(int width, int height) {
		this.width = width;
		this.height = height;
	}
	
	/**
	 * Creates a default Rectangle object with width = height = 0.
	 */
	public Rectangle() {
		// You can use the same code to initialize in the previous constructor, but the following gets the same result,
		// by calling the other constructor directly.
		this(0,0); 
	}
	/**
	 * Returns a string representation of this object.
	 * @return The string.
	 */
	public String toString() {
		StringBuffer sb = new StringBuffer(50); // a  rough (over)-estimate of the number of characters.
		sb.append("Rectangle: width = ");
		sb.append(width);
		sb.append(", height = ");
		sb.append(height);
		return sb.toString(); 
	}

	/**
	 * Determines if this Rectangle is equivalent to another.
	 * Equivalent rectangles have the same width and height.
	 * @param other The other rectangle to compare to this one.
	 * @return true if they are equivalent, false otherwise.
	 */
	public boolean equals(Rectangle other) {
		return width==other.width && height==other.height;
	}
	/**
	 * Used as a unit tester.
	 * @param args Not used.
	 */
	public static void main(String[] args) {
		Rectangle r1 = new Rectangle(4,3);
		Rectangle r2 = new Rectangle(65,3);
		Rectangle r3 = new Rectangle();
		System.out.println(r1);
		System.out.println(r2);
		System.out.println(r3);
	}
}
