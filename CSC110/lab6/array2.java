public class array3{
	
	public static void printArray(int a1[]){
		
		for(int i = 0; i < a1.length; i++){
			if (i>0){
				System.out.print(",");
			}
			System.out.print(a1[i]);
		}
		
	}
	
	public static void swapElement(){
		int temp = a[4];
		a[4] = a[1];
		a[1] = temp;
	}
	
	public static void main(String args[]){
		
		int a[]= {23, 56, 345, 258, 35, 147};
		
		printArray(a);
			
		}
	}
