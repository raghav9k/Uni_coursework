import java.util.*;
public class lab4{
	//public static void str(){
		//String s1 = ("hey hi");
		//nt i = 80/ s1.length();
			//for ( int a = 1; a <= i; a++){
			//	System.out.println(s1);
			//}

	public static void main(String[]args){
		Random rd=new Random();
		
		Scanner input = new Scanner(System.in);
		System.out.println("What number will you like to choose between 1 and 10?");
		int a = input.nextInt();
		int b = rd.nextInt(10)+1;
		System.out.println("The randomn number is " +b);
		if (a == b ){
			System.out.println("You guessed it right!");
		}
		if ( a > b){
			System.out.println("Your number is too high");
		}
		if ( a < b){
			System.out.println("Your number is lower!");
		}
		
	}
	
}
