/* Name: Raghav Khurana
	id:	V00875126
	FileName: Objqueue.java
	Date: 20th feb 2017
*/
public class Queue{
	private Node head;
	private Node tail;
	
	public Queue(){ //Contructor method
		head = null;
		tail=head;
	}
	public boolean isEmpty(){ //Checks if the queue is empty
			return head==null;
	}
	public Object peek(){ //Returns the last object in the queue
		if(head==null) throw new QueueEmptyException();
		return head.item;
	}
	public Object dequeue(){ //returns and removes the last object in the queue
		if(head==null) throw new QueueEmptyException();
		Object temp = head.item;
		head = head.next;
		return temp;
	}
	public void enqueue(Object item){ //adds an object to the head of the queue
		temp = new Node(item, null);
		tail.next = temp;
		tail = temp;
	}
	public static void main(String[]args){ //internal tester
		ObjQueue queue = new ObjQueue();
			if(queue.isEmpty()){System.out.println("The queue is empty.");}
			try{
				queue.peek();
				System.out.println("My peek exception is not working.");
			}
			catch(QueueEmptyException ex){
				System.out.println("my exception is working for peek.");
			}
			try{
				queue.pop();
				System.out.println("My pop exception is not working.");
			}catch(QueueEmptyException ex){
				System.out.println("my exception is working for pop.");
			}
			for(int i =-10; i<=10; i++){
				queue.push(i);
			}
			System.out.println(queue.peek());
			queue.pop();
			System.out.println(queue.peek());
			String s1 = new String("A string Object Type");
			queue.push(s1);
			System.out.print(queue.peek());
	}
	
}	