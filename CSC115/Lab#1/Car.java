/*	Name:		Raghav Khurana
*	Student id:	V00875126
*	CSC115:		Lab #1
*/
public class Car{		
	private int horsepower=0;
	private int torque=0;
	public Car(){
		this.horsepower=0;
		this.torque=0;
		}
	public Car(int horsepower, int torque){
		this.horsepower=horsepower;
		this.torque=torque;
	}	
	public String toString(){
		String s1= new String();
		s1=("The car produces " + this.horsepower + "horsepower & "+this.torque+"Nm of torque.");  
		return s1;
	}
	public static void main (String[] args){
		Car car1 = new Car(230,480);
		Car car2 = new Car(450,600);
		Car car3 = new Car(600,800);
		System.out.println(car1);
		System.out.println(car2);
		System.out.println(car3);
	}
	
}