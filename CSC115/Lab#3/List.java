/**d
 * List.java
 * A partially completed basic list interface for CSC115, 
 * The ADT is taken from the textbook for the 201701 version of this course.
 */


/**
 * ADT List is maintained as a linear data structure that contains Rectangle objects.
 * The list is either empty or contains a first item and a last item, which are the same if the list contains only one
 * item.
 */
public interface List {

	/**
	 * @return True if there are no elements in the list, false if there are.
	 */
	public boolean isEmpty();

	/**
	 * @return The number of elements in the list.
	 */
	public int size();

	/**
	 * Add an element to the end of the list, so it becomes the last item.
	 * After this method is completed, the previous last item is now the second to last.
	 * @param r The rectangle to insert.
	 */
	public void append(Rectangle r);

	/**
	 * Add an element to the front of the list, so it becomes the first item.
	 * After this method is completed, the previous first item is now the second.
	 * @param r The rectangle to insert.
	 */
	public void prepend(Rectangle r);

	/**
	 * Returns the string that lists the Rectangles that are in the list.
	 * The format of the string is as follows:
	 * <pre>List: size = [number of items]
	 * \t[firstItem]
	 * \t[more items if they exist in list]
	 * \t[lastItem]
	 * </pre>
	 * For instance, if the list is empty, the result is
	 * <pre>
	 * List: size = 0
	 * </pre>
	 * If the list contains three rectangles, depending on the actual items, the result looks something like:
	 * <pre>
	 * List: size = 3
	 * 	Rectangle: width = 2, height = 4
	 * 	Rectnagle: width = 0, height = 0
	 * 	Rectangle: width = 5, height = 14
	 * </pre>
	 */
	public String toString();
}

	


