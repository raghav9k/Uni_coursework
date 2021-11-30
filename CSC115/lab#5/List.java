/**
 * List.java
 * An enhanced basic list interface for CSC115, 
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

/**********************   The following specifications have been added since Lab03 *******/

	/**
	 * Returns the index position in the list of the
	 * the given rectangle.
	 * Index positions are ranged from 0 ... size()-1.
	 * @param r the rectangle we are looking for.
	 * 	Note that we are looking for an <i>equivalent</i>
	 * 	rectangle in the list, not the necessarily the actual object.
	 * @return The index position in the list (0 ... size()-1) if the 
	 * 	rectangle is in the list, -1 if it is not in the list.
	 */
	public int getIndex(Rectangle r);

	/**
	 * Returns a reference to the rectangle object at index at the given index 
	 * postion.
	 * @param index the valid index position between 0 and size()-1 inclusive.
	 * 	Note that input error-checking is not done.
	 *	It is the user's responsibility to provide a valid
	 *	index.
	 * @return A reference to the rectangle at the given position.
	 */
	public Rectangle findAtIndex(int index);

	/**
	 * Removes the rectangle in the list.
	 * If the rectangle cannot be found, then nothing happens.
	 * @param r the rectangle equivalence to look for.
	 */
	public void remove(Rectangle r);

	/**
	 * Adds a rectangle into the list, so that it resides at
	 * the index position.
	 * Note that index positions range from 0 ... size()-1.
	 * @param r the Rectangle to insert.
	 * @param pos the valid index position of the newly inserted rectangle.
	 * 	Note that size() is a valid index position, resulting in the
	 * 	the new rectangle is the last item in the list.
	 */
	public void insertAtPos(Rectangle r, int pos);
}

	


