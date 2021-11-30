public class array4{
	
	public static void printArray(int a1[]){
		
		for(int i = 0; i < a1.length; i++){
			if (i>0){
				System.out.print(",");
			}
			System.out.print(a1[i]);
		}
		
	}
	
	public static void swapElement(int a2[], int i, int j){
		int temp = a2[i];
		a2[i] = a2[j];
		a2[j] = temp;
	}
	private static int smallest(int a3[]){
		int myno = a3[0];
		for(int i = 1; i<a3.length;i++){
			if(myno>a3[i]){
				
				myno = a3[i];
			}
		}
			return myno;
	}
	
	public static void main(String args[]){
		
		int a[]= {23, 56, 345, 258, 35, 147};
		int small = smallest(a);
		
		System.out.println(small);
			
		}
	}
