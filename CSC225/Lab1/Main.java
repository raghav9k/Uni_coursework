import java.util.*;
import java.io.*;
public class Main
{
   public static void main(String args[])
   {
       int value;

       LinkedList sortedList;

       Scanner in = new Scanner(System.in);

       sortedList= LinkedList.readList(in);
       System.out.println("The original list:");
       sortedList.printList();

       value=5;
       sortedList.insertList(value);
       System.out.println("After inserting " + value + ":");
       sortedList.printList();

       value=1;
       sortedList.insertList(value);
       System.out.println("After inserting " + value + ":");
       sortedList.printList();

       value=42;
       sortedList.insertList(value);
       System.out.println("After inserting " + value + ":");
       sortedList.printList();

       LinkedList emptyList= new LinkedList();
       System.out.println("Try inserting into an empty list:");
       emptyList.insertList(7);
       emptyList.printList();
   }
}
