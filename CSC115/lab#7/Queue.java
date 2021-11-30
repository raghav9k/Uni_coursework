/* Name: Raghav Khurana
	id:	V00875126
	FileName: Queue.java
*/
public class Queue<E>{
	private Node<E> head;
	private Node<E> tail;
	
	public Queue(){ //Contructor method
		head = null;
		tail=head;
	}
	public boolean isEmpty(){ //Checks if the queue is empty
			return head==null;
	}
	public E peek(){ //Returns the last element in the queue
		if(head==null) throw new QueueEmptyException();
		return head.item;
	}
	public E dequeue(){ //returns and removes the last element in the queue
		if(head==null) throw new QueueEmptyException();
		E temp = head.item;
		head = head.next;
		return temp;
	}
	public void enqueue(E item){ //adds an element to the head of the queue
		if(head==null){
			Node<E> temp = new Node<E>(item, null);
			head = temp;
			tail=temp;
			return;
		}
		Node<E> temp = new Node<E>(item, null);
		tail.next = temp;
		tail = temp;
	}
	public static void main(String[]args){ //internal tester
		Queue<String> queue = new Queue<String>();
			if(queue.isEmpty()){System.out.println("The queue is empty.");}
			try{
				queue.peek();
				System.out.println("My peek exception is not working.");
			}
			catch(QueueEmptyException ex){
				System.out.println("my exception is working for peek.");
			}
			try{
				queue.dequeue();
				System.out.println("My dequeue exception is not working.");
			}catch(QueueEmptyException ex){
				System.out.println("my exception is working for dequeue.");
			}
			System.out.println("Enqueing into queue");
			queue.enqueue("CSC 100");
			queue.enqueue("CSC 115");
			queue.enqueue("Math 101");
			queue.enqueue("MAth 122");

			System.out.println(queue.peek());
			System.out.println(queue.dequeue());
			System.out.println(queue.peek());
			String s1 = new String("A string E Type");
			queue.enqueue(s1);
			System.out.print(queue.peek());
	}
	
}	