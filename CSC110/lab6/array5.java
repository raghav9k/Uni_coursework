public class array5{
	public static void main(String[]args){
		int a[]={-1, 3, -4, 5, 1, -6, 2, 1};
		int leftsum = 0;
		int rightsum = 0;
		for(int i = 1; i < a.length - 1; i++){
			for(int left=0; left < i; left++){
				leftsum += a[left];
			}
			for(int right = i+1;right<a.length;right++ ){
				rightsum+= a[right];
			}
			if (rightsum == leftsum){
				System.out.println(i);
			}
			leftsum =0;
			rightsum = 0;
		}
		
	}
}