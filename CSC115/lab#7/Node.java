class Node<E> {
	E item;
	Node<E> next;

	Node(E item, Node<E> next) {
		this.item = item;
		this.next = next;
	}

	Node(E item) {
		this(item,null);
	}

	Node () {
		this(null);
	}
}
