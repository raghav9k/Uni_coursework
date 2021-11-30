/* Name: Raghav Khurana
	id:	V00875126
	FileName: ObjStack.java
	Date: 20th feb 2017
*/
public class ObjStack{
	private Node top;
	
	public ObjStack(){ //Contructor method
		top = null;
	}
	public boolean isEmpty(){ //Checks if the stack is empty
			return top==null;
	}
	public Object peek(){ //Returns the last object in the stack
		if(top==null) throw new StackEmptyException();
		return top.item;
	}
	public Object pop(){ //returns and removes the last object in the stack
		if(top==null) throw new StackEmptyException();
		Object temp = top.item;
		top = top.next;
		return temp;
	}
	public void push(Object item){ //adds an object to the top of the stack
		top = new Node(item, top);
	}
	public static void main(String[]args){ //internal tester
		ObjStack stack = new ObjStack();
			if(stack.isEmpty()){System.out.println("The stack is empty.");}
			try{
				stack.peek();
				System.out.println("My peek exception is not working.");
			}
			catch(StackEmptyException ex){
				System.out.println("my exception is working for peek.");
			}
			try{
				stack.pop();
				System.out.println("My pop exception is not working.");
			}catch(StackEmptyException ex){
				System.out.println("my exception is working for pop.");
			}
			for(int i =-10; i<=10; i++){
				stack.push(i);
			}
			System.out.println(stack.peek());
			stack.pop();
			System.out.println(stack.peek());
			String s1 = new String("A string Object Type");
			stack.push(s1);
			System.out.print(stack.peek());
	}
	
}	