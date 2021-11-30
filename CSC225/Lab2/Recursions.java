/* Recursions.java
   CSC 225 - Spring 2017
   
   Template for a set of recursive functions on linked lists of integers.

   A. Webster & B. Bird - 05/19/2015
   M. Simpson           - 01/16/2017
   Rahnuma Islam Nishat and Michael Simpson - 01/13/2018
*/

import java.util.Scanner;
import java.util.Vector;
import java.util.Arrays;
import java.io.File;


public class Recursions{
        
        /* Sum(head)
           Return the sum of all elements in the linked list starting at the
           provided node.
        */
        public int Sum(ListNode head){
            int sum = 0;
			ListNode pointer = head;
			if(pointer == null){return sum;}
			sum = pointer.value + Sum(pointer.next);
			
            return sum;
        }
        /* FindMax(head)
           Return the maximum of all elements in the linked list starting at the
           provided node.
        */
        public int FindMax(ListNode head){
			if (head == null){
				return -1;
			}
			return Math.max(head.value, FindMax(head.next));
        }

        /* JoinLists(h1, h2)
           Given two linked lists of integers, create a list consisting of the 
           first list followed by the second list.
        */
        public ListNode JoinLists(ListNode h1, ListNode h2){
            /* Your code here */
            return null;
        }
        
        /* ValuePlusIndex(index, head)
           Given a starting index and the first node of a linked list, create a
           new list containing each node's value plus its index.
           
           For example, with the list [3, 3, 3] and the starting index 0,
           the result should be [3, 4, 5].

           With the list [3, 4, 5] and the starting index 0, the result should
           be [3, 5, 7].
           
           With the list [3, 4, 5] and the starting index 1, the result should
           be [4, 6, 8].
        */
        public ListNode ValuePlusIndex(int index, ListNode head){
            /* Your code here */
            return null;
        }
        
        /* ExtractEvenNodes(head)
           Given a linked list of integers (starting at the provided node),
           construct a new list containing the even numbers in the input
           list.
           
           For example, if the input list is [3, 4, 6, 7, 8, 9, 11], the
           result should be [4, 6, 8].
        */
        public ListNode ExtractEven(ListNode head){
            if (head == null) return null;
			if(head.value%2 == 0){
				return new ListNode(head.value, ExtractEven(head.next));
				
			} else{
				return ExtractEven(head.next);
			return null;
        }
        
        
        
        
        /* ListNode class */
        /* Do not change, add or remove any aspect of the class definition below.
           
           The members of the class should be accessed directly (e.g. node.next, 
           node.value), since no get/set methods exist.
        */
        public class ListNode{
                int value;
                ListNode next;
                public ListNode(int value){
                        this.value = value;
                        this.next = null;
                }
                public ListNode(int value, ListNode next){
                        this.value = value;
                        this.next = next;
                }
        }
        
        
        
        
        
        
        
        
        
        /* Testing code */
        
        /* listLength(node)
           Compute the length of the list starting at the provided node.
        */
        public int listLength(ListNode node){
                if (node == null)
                        return 0;
                return 1 + listLength(node.next);
        }
        
        /* printList(node)
           Print all list elements starting at the provided node.
        */
        public void printList(ListNode node){
                if (node == null)
                        System.out.println();
                else{
                        System.out.print(node.value + " ");
                        printList(node.next);
                }
        }
        
        /* readInput(inputScanner)
           Read integer values from the provided scanner into a linked list.
           Each recursive call reads one value, and recursion ends when the user
           enters a negative value or the input file ends.
        */
        public ListNode readInput(Scanner inputScanner){
                //If no input is left, return an empty list (i.e. null)
                if (!inputScanner.hasNextInt())
                        return null;
                int v = inputScanner.nextInt();
                //If the user entered a negative value, return an empty list.
                if (v < 0)
                        return null;
                //If the user entered a valid input value, create a list node for it.
                ListNode node = new ListNode(v);
                //Scan for more values recursively, and set the returned list of values
                //to follow the node we just created.
                node.next = readInput(inputScanner);
                //Return the created list.
                return node;
        }

        /* main()
           Contains code to test the functions above.
        */
        public static void main(String[] args){
                Scanner s;
                
                Recursions m = new Recursions();
                
                if (args.length > 0){
                        try{
                                s = new Scanner(new File(args[0]));
                        } catch(java.io.FileNotFoundException e){
                                System.out.printf("Unable to open %s\n",args[0]);
                                return;
                        }
                        System.out.printf("Reading input values from %s.\n", args[0]);
                }else{
                        s = new Scanner(System.in);
                        System.out.printf("Enter a list of non-negative integers. Enter a negative value to end the list.\n");
                }
            
                ListNode inputListHead = m.readInput(s);
                
                int inputLength = m.listLength(inputListHead);
                System.out.printf("Read %d values.\n",inputLength);
                
                System.out.println("The original list: ");
                m.printList(inputListHead);
                
                System.out.println("The sum of all elements in the list: " + m.Sum(inputListHead));
				System.out.println("the max number in the list: " + m.FindMax(inputListHead));
                
                System.out.printf("Enter a second list of non-negative integers. Enter a negative value to end the list.\n");
                ListNode secondInputListHead = m.readInput(s);
                ListNode joinedListHead = m.JoinLists(inputListHead, secondInputListHead);
                System.out.println("Joined");
                m.printList(joinedListHead);
                ListNode EvenListHead = m.ExtractEven(inputListHead);
                System.out.println("The even elements of the input list:");
                m.printList(EvenListHead);
                ListNode ValueIndexHead = m.ValuePlusIndex(0, inputListHead);
                System.out.println("Value of each node added to its place in the list:");
                m.printList(ValueIndexHead);
                System.out.println("The original list again (it should not have changed): ");
                m.printList(inputListHead);
                
        }
}
