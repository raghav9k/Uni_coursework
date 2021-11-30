public class Numbers{
	private int[] numbers;
	private int size;
	private int count=0;
	public Numbers(int size){
		this.numbers= new int[size];
		this.size=size;
		this.count =0;
	}
	public void add(int num){
		if(this.count < this.size){
			this.numbers[count]=num;
			this.count++;
		}
		else if(this.count==this.size){
			doubleArray();
			this.numbers[count]=num;
			this.count++;
		}
	}
	public void remove(int num){
		for(int i=0; i < this.count; i++){
			if(this.numbers[i]==num){
				this.numbers[i]=this.numbers[count-1];
				numbers[count-1]=0;
				this.count--;
			break;}
			}
			
		}
	public String toString(){
		String s1 = "";
		if(count ==0){
			s1 = "{}";
		}
		else{
		s1=s1 + "{ "+this.numbers[0];
		for(int i =1; i<this.count; i++){
			s1 = s1 +","+ this.numbers[i];
		}
		s1=s1+" }";
		}
		return s1;
	}	
		
	private void doubleArray(){
		int[] tempnum= new int[2*this.size];
		for(int i=0; i <this.count; i++){
			tempnum[i]=this.numbers[i];
		}
		this.numbers = tempnum;
		this.size=2*this.size;
	}
	public static void main(String[]args){
		Numbers num = new Numbers(3);
		num.add(5);
		System.out.println(num);
		num.add(3);
		System.out.println(num);
		num.add(4);
		System.out.println(num);
		num.add(44);
		System.out.println(num);
		num.add(15);
		System.out.println(num);
		num.remove(4);
		System.out.println(num);
		num.add(54);
		System.out.println(num);
		num.remove(22);
		System.out.println(num);
	}
}