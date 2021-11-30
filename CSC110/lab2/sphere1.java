class sphere1
{
public static double sphere(double a)
{
  double r = (4 / 3) * Math.PI * Math.pow(a , 3);
  return r;
}
public static void main (String[]args)
{
	System.out.println(sphere(3));
	System.out.println(sphere(45));
}
}