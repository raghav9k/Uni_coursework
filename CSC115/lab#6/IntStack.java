public class IntStack{
	private static final int size = 10;
	private int[] stack;
/* Name: Raghav Khurana
	id:	V00875126
	FileName: ObjStack.java
	Date: 20th feb 2017
*/	
	private int count;
		
		public IntStack(){ //Initializes a new intstack
			stack = new int [size];
			count = 0;
		}
		public boolean isEmpty(){ //checks if the stack is empty
			return count==0;
		}
		public int peek(){ //returns the top element in the stack
			if (count == 0) throw new StackEmptyException();
			return stack[count-1];
		}
		public int pop(){ //returns and removes the last element
			if(count==0) throw new StackEmptyException();
			return stack[--count];
		}
		public void push( int item){ //adds an element to the top of stack
			if(count==stack.length){
				enlargeArray();
			}
			stack[count] = item;
			count++;
		}
		private void enlargeArray(){ //doubles the size of array
		int[] temp = new int[count*2];
		for(int i =0; i <count; i++){
				temp[i]=stack[i];
			}
			stack = temp;
		}
		public static void main(String[]args){ //internal tester
			IntStack stack = new IntStack();
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
		}
}