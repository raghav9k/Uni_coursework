/**
 * The RectNode class is a non-public class specifically
 * created to be used as the container in a singly-linked list that holds
 * Rectangle objects.
 * It's use is strictly limited to the RefList class, contained in the
 * same directory that stores this source code
 */

/**
 * RectNode is a Node that contains a Rectangle object and information
 * about the Node that follows this Node in a list.
 * It is only accessible to the RectList class which is stored as part of
 * the same package, and is therefore not public
 */
class RectNode {

	/* 
	 * The following fields are declared as package-protected (the default).
	 * The only user is the RectList class, which enjoys direct access
	 * to the fields (as opposed to having a set and a get method for 
	 * each of them.
	 */
	Rectangle item; 
	RectNode next; 

	
	/**
 	 * Constructs a node that contains an item and points to the next node.
	 * @param r The item.
	 * @param next The next node in the list that contains this node.
	 */
	RectNode(Rectangle r, RectNode next) {
		item = r;
		this.next = next;
	}

	/**
	 * Constructs a node that contains an item and is either the last node in a list,
	 * or is not yet a member of a list.
	 */
	RectNode(Rectangle r) {
		this(r,null);
	}

	/**
	 * Constructs a default node: no item and no reference to the next node.
	 */
	RectNode() {
		this(null,null);
	}

}
