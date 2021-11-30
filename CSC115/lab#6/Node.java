class Node {
	Object item;
	Node next;

	Node(Object item, Node next) {
		this.item = item;
		this.next = next;
	}

	Node(Object item) {
		this(item,null);
	}

	Node () {
		this(null);
	}
}
