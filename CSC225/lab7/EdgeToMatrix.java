import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;

public class EdgeToMatrix{
	public static int[][] getMatrix(Scanner s){
		// TO DO: Write your code here
		int size = s.nextInt();
		int[][] matrix = new int[size][size];
		for( int i = 0; i < s.nextInt(); i++){
			matrix[s.nextInt()][s.nextInt()] = s.nextInt();
			i++;
			}
		return matrix;
	}	
	
	public static void main(String[] args) throws FileNotFoundException{
		Scanner s;
		if(args.length>0){
			s=new Scanner(new File(args[0]));
		}
		else{
			s = new Scanner(System.in);
		}
		int[][] matrix = getMatrix(s);
		printMatrix(matrix);
		if(args.length>1){
			System.out.println(checkMatrix(matrix,args[1])? "correct": "not correct");
		}
		s.close();
	}
	
	public static boolean checkMatrix(int[][] matrix, String outputFile) throws FileNotFoundException{
		Scanner s = new Scanner(new File(outputFile));
		//TO DO: Write your code here
		
		s.close();
		return false;
	}
	
	public static void printMatrix(int[][] matrix){
		for(int i=0;i<matrix.length;i++){
			for(int j=0;j<matrix.length;j++){
				System.out.print(matrix[i][j]+" ");
			}
			System.out.println();
		}
	}
}