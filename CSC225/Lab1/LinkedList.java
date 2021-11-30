import java.util.*;
import java.io.*;
public class LinkedList
{
   static boolean debug= false;

   int n;
   ListNode start;
   ListNode rear;

   public LinkedList()
   {
       n= 0;
       start= null;
       rear= null;
   }
// Assumes the list is already sorted and inserts a new
// cell into the list with the data value.
// This code is buggy. What are the bugs and
// how can the code be fixed?

   public void insertList(int value)
   {
       
		ListNode current;
		current=start;
	  if(n>0){
		  if((n>=1)||(start.data > value)){
			   start = new ListNode(value,current);
		   }
		   else if((n>=1)||(rear.data < value)){
			   current = rear;
			  rear = new ListNode(value,null);
			  current.next = rear;
		   }
		   while (current.next.data < value)
       {
           current= current.next;
       }
       current.next= new ListNode(value, current.next);
	  }
		   if(n==0){
			   start=rear=new ListNode(value, null);
		   }
	   n++;
   }
   public static LinkedList readList(Scanner in)
   {
       LinkedList newList; 
       int num_item;
       int value;
       int i;

       newList= new LinkedList();

       num_item= readInteger(in);
       if (num_item <= 0) return(null);

       for (i=0; i < num_item; i++)
       {
           value= readInteger(in);
           if (i==0)
           {
              newList.start= new ListNode(value, null);
              newList.rear= newList.start;
              newList.n=1;
           }
           else
           {
              newList.rear.next= new ListNode(value, null);
              newList.rear= newList.rear.next;
              newList.n++;
           }
           if (debug)
           {
              System.out.println("After reading in " + (i+1) + " items: ");
              newList.printList();
           }
       }
       return(newList);
   }
// Tries to read in a non-negative integer from the input stream.
// If it succeeds, the integer read in is returned. 
// Otherwise the method returns -1.
   public static int readInteger(Scanner in)
   {
       int n;

       try{
           n= in.nextInt();
           if (n >=0) return(n);
           else return(-1);
       }
       catch(Exception e)
       {
//        We are assuming legal integer input values are >= zero.
          return(-1);
       }
   }

   public void printList()
   {
       ListNode current;

       int count=0;

       System.out.println("The list has " + n + " items: ");

       current= start;
       while (current != null)
       {
           count++;
           
           System.out.print(current.data + " ");
           current= current.next;
       }
       System.out.println();
   }
}
