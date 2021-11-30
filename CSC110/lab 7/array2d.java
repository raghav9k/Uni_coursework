/* Name: Raghav Khurana
   Student id:	V00875126*/

public class array2d{
	public static void main(String[]args){
		char array[][]={{'a','b','c'},{'d','e','f'},{'g','h','i'}};
			System.out.println("Our 2D array is given below: \n");
			printArray(array);
	//		swapRow(array,1,2);
			swapColumn(array, 1, 2);
			printArray(array);
	}
	
	public static void printArray(char[][]array){
		for(int i=0; i < array.length; i++){
			for(int j = 0; j < array[i].length;j++){
				System.out.print(array[i][j]+" ");
			}
				System.out.println();
		}
	}
	
	public static void swapRow(char array[][],int row1,int row2){
		char temparray[]=array[row1];
		array[row1]=array[row2];
		 array[row2]=temparray;
	}
	public static void swapColumn(char array[][],int col1,int col2){
		int i = 2;
		while(i>-1){
		char temp=array[i][col1];
		array[i][col1]=array[i][col2];
		array[i][col2]= temp;
		i--;
		}
	}
}