/* Derivative.java
   CSC 225 - Spring 2017
   
   Template for the TreeDerivative problem.
   
   The expression tree implemented in the code below can print
   and evaluate polynomials in a single variable x. Each type of node
   (add, subtract, multiply, divide, exponent) has an unimplemented 
   ComputeDerivative() function, which should convert the subtree
   rooted at a given node to an expression tree corresponding to its
   derivative.

   B. Bird - 05/31/2015
   M. Simpson - 02/25/2016
*/

import java.util.Scanner;
import java.util.Vector;
import java.util.Arrays;
import java.util.LinkedList;
import java.io.File;

public class Derivative{
	
	
	/* *************************** TreeNode Class ************************** */
	/* The TreeNode class provides the basic foundation for a parse tree
	   representing a polynomial like f(x) = x^3 + x^2 + 2*x + 1000
	   The individual operators are implemented by subclasses of TreeNode */
	/* ********************************************************************* */
	public static abstract class TreeNode{
	
		public TreeNode leftChild, rightChild;
	
		/* Evaluate the function described by this expression tree at the
		   provided value of x */
		public abstract double Evaluate(double x);
		
		/* Return an expression tree representing the derivative of the subtree
		   rooted at the current node */
		public abstract TreeNode ComputeDerivative();
		
	}
	
	
	
	/* **************************** Node Classes *************************** */
	/* The classes below provide functionality for nodes containing constant
	   values, the 'x' variable and five arithmetic operators (+,-,*,/,^). */
	/* ********************************************************************* */
	
	
	
	/* TreeNodeConstant: A node representing a constant (like 0 or 6) */
	public static class TreeNodeConstant extends TreeNode{
		int constantValue;
		public TreeNodeConstant(int value){
			constantValue = value;
		}
		public double Evaluate(double x){
			return constantValue;
		}
		public TreeNode ComputeDerivative(){
			//Derivative of a constant is 0
			return new TreeNodeConstant(0);
		}
		public String toString(){
			return String.format("%d",constantValue);
		}
	}
	
	
	
	/* TreeNodeX: A node representing the unknown variable x */
	public static class TreeNodeX extends TreeNode{
		public TreeNodeX(){
		}
		public double Evaluate(double x){
			return x;
		}
		public TreeNode ComputeDerivative(){
			//The derivative of the variable x is 1
			return new TreeNodeConstant(1);
		}
		public String toString(){
			return "x";
		}
	}
	
	/* TreeNodeAdd and TreeNodeSubtract: Nodes representing the + and - operators*/
	public static class TreeNodeAdd extends TreeNode{
		public TreeNodeAdd(TreeNode left, TreeNode right){
			leftChild = left;
			rightChild = right;
		}
		public double Evaluate(double x){
			return leftChild.Evaluate(x) + rightChild.Evaluate(x);
		}
		public TreeNode ComputeDerivative(){
			//Derivative of f(x) + g(x) = f'(x) + g'(x)
			TreeNode d_left = leftChild.ComputeDerivative();
			TreeNode d_right = rightChild.ComputeDerivative();
			return new TreeNodeAdd(d_left,d_right);
			
			
			//throw new Error("Derivative of f(x) + g(x) not supported");
		}
		public String toString(){
			return String.format("%s + %s",leftChild.toString(), rightChild.toString());
		}
	}
	
	public static class TreeNodeSubtract extends TreeNode{
		public TreeNodeSubtract(TreeNode left, TreeNode right){
			leftChild = left;
			rightChild = right;
		}
		public double Evaluate(double x){
			return leftChild.Evaluate(x) - rightChild.Evaluate(x);
		}
		public TreeNode ComputeDerivative(){
			//Derivative of f(x) - g(x) = f'(x) - g'(x)
			TreeNode d_left = leftChild.ComputeDerivative();
			TreeNode d_right = rightChild.ComputeDerivative();
			return new TreeNodeSubtract(d_left,d_right);
			//throw new Error("Derivative of f(x) - g(x) not supported");
		}
		public String toString(){
			return String.format("%s - %s",leftChild.toString(), rightChild.toString());
		}
	}
	
	/* TreeNodeMultiply and TreeNodeDivide: Nodes representing the * and / operators*/
	public static class TreeNodeMultiply extends TreeNode{
		public TreeNodeMultiply(TreeNode left, TreeNode right){
			leftChild = left;
			rightChild = right;
		}
		public double Evaluate(double x){
			return leftChild.Evaluate(x) * rightChild.Evaluate(x);
		}
		public TreeNode ComputeDerivative(){
			//Derivative of f(x)g(x) = f'(x)g(x) + f(x)g'(x)
			TreeNode d_left = leftChild.ComputeDerivative();
			TreeNode d_right = rightChild.ComputeDerivative();
			return new TreeNodeAdd((new TreeNodeMultiply(d_left,rightChild)),new TreeNodeMultiply(leftChild,d_right));
			//throw new Error("Derivative of f(x) * g(x) not supported");
		}
		public String toString(){
			//The complicated stuff is to try to minimize brackets.
			String leftString = leftChild.toString();
			String rightString = rightChild.toString();
			if (leftChild instanceof TreeNodeAdd || leftChild instanceof TreeNodeSubtract || leftChild instanceof TreeNodeDivide)
				leftString = "("+leftString+")";
			if (rightChild instanceof TreeNodeAdd || rightChild instanceof TreeNodeSubtract || rightChild instanceof TreeNodeDivide)
				rightString = "("+rightString+")";
			return String.format("%s*%s",leftString, rightString);
		}
	}
	
	public static class TreeNodeDivide extends TreeNode{
		public TreeNodeDivide(TreeNode left, TreeNode right){
			leftChild = left;
			rightChild = right;
		}
		public double Evaluate(double x){
			return leftChild.Evaluate(x) / rightChild.Evaluate(x);
		}
		public TreeNode ComputeDerivative(){
			//Derivative of f(x)/g(x) = (f'(x)g(x) - f(x)g'(x))/g(x)^2
			TreeNode d_left = leftChild.ComputeDerivative();
			TreeNode d_right = rightChild.ComputeDerivative();
			return new TreeNodeDivide(new TreeNodeSubtract(new TreeNodeMultiply(d_left,rightChild),new TreeNodeMultiply(leftChild,d_right)),new TreeNodeMultiply(rightChild,rightChild));
			//throw new Error("Derivative of f(x)/g(x) not supported");
		}
		public String toString(){
			String leftString = leftChild.toString();
			String rightString = rightChild.toString();
			if (leftChild instanceof TreeNodeAdd || leftChild instanceof TreeNodeSubtract || leftChild instanceof TreeNodeDivide)
				leftString = "("+leftString+")";
			if (rightChild instanceof TreeNodeAdd || rightChild instanceof TreeNodeSubtract || rightChild instanceof TreeNodeMultiply || rightChild instanceof TreeNodeDivide)
				rightString = "("+rightString+")";
			return String.format("%s/%s",leftString, rightString);
		}
	}
	
	/* TreeNodeConstantPower: A node representing a function raised to a constant power */
	/* (This code does not support raising a function of x to a non-constant 
	    power because doing so would require adding support for logarithms) */
	public static class TreeNodeConstantPower extends TreeNode{
		int constantPower;
		public TreeNodeConstantPower(TreeNode baseFunction, int power){
			leftChild = baseFunction;
			rightChild = null;
			constantPower = power;
		}
		public double Evaluate(double x){
			double leftResult = leftChild.Evaluate(x);
			double result = 1;
			for (int i = 0; i < constantPower; i++){
				result *= leftResult;
			}
			return result;
		}
		public TreeNode ComputeDerivative(){
			//Derivative of f(x)^n = n*f'(x)*f(x)^(n-1)
			if (constantPower == 1){
				return leftChild.ComputeDerivative();
			} else if (constantPower == 2){
				return new TreeNodeMultiply(
						new TreeNodeMultiply( new TreeNodeConstant(constantPower), leftChild.ComputeDerivative()),
						leftChild
						);
			}else{
				return new TreeNodeMultiply(
						new TreeNodeMultiply( new TreeNodeConstant(constantPower), leftChild.ComputeDerivative()),
						new TreeNodeConstantPower(leftChild,constantPower-1)
						);
			}
		}
		public String toString(){
			String leftString = leftChild.toString();
			return String.format("(%s)^%d",leftString, constantPower);
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	/* ************************* Parsing Functions ************************* */
	/* The functions below convert a string (like 'x^2 + x + 2*x + 1') into
	   a parse tree. This type of parser is called a 'recursive descent parser'
	   since it recursively breaks up the input string with operator
	   precedence rules. Courses like CSC 435 (Compiler Construction) cover
	   parsing techniques in greater detail. */
	/* ********************************************************************* */
	
	
	
	public static class ParseException extends Exception{
		
		public String message;
		public ParseException(String fmt, Object... args){
			message = String.format(fmt,args);
		}
	}
	
	
	public static boolean isWhitespace(char c){
		return Character.isSpaceChar(c);
	}
	public static int parseConstant(LinkedList<Character> L) throws ParseException {
		while(!L.isEmpty() && isWhitespace(L.getFirst()))
			L.removeFirst();
		if (L.isEmpty() || !Character.isDigit(L.getFirst()))
			throw new ParseException("Missing numerical constant");
		int val = 0;
		while (!L.isEmpty() && Character.isDigit(L.getFirst())){
			val = val*10 + Integer.parseInt(L.removeFirst().toString());
		}
		return val;
	}
	public static TreeNode parseLiteral(LinkedList<Character> L) throws ParseException {
		while(!L.isEmpty() && isWhitespace(L.getFirst()))
			L.removeFirst();
		if (L.isEmpty()){
			throw new ParseException("Missing operand");
		}
		if (L.getFirst() == '('){
			L.removeFirst();
			TreeNode t = parseAdd(L);
			if (L.isEmpty() || L.getFirst() != ')')
				throw new ParseException("Unbalanced parentheses");
			L.removeFirst();
			return t;
		}
		if (!Character.isDigit(L.getFirst())){
			//If the next character isn't a digit, it must be the value 'x'
			if (L.getFirst() != 'x'){
				throw new ParseException("Invalid character %c (expected 'x' or a number)",L.getFirst());
			}
			L.removeFirst();
			return new TreeNodeX();
		}
		int val = parseConstant(L);
		return new TreeNodeConstant(val);
	}
	public static TreeNode parsePow(LinkedList<Character> L) throws ParseException {
		TreeNode t = parseLiteral(L);
		while(!L.isEmpty() && isWhitespace(L.getFirst()))
			L.removeFirst();
		if (L.isEmpty())
			return t;
		char c = L.getFirst();
		if (c == '+' || c == '-' || c == '*' || c == '/' || c == ')')
			return t;
		L.removeFirst();
		if (c == '^')
			return new TreeNodeConstantPower(t,parseConstant(L));
		else 
			throw new ParseException("Invalid character %c (expected ^)",c);
	}
	public static TreeNode parseMul(LinkedList<Character> L) throws ParseException {
		TreeNode t = parsePow(L);
		while(!L.isEmpty() && isWhitespace(L.getFirst()))
			L.removeFirst();
		if (L.isEmpty())
			return t;
		char c = L.getFirst();
		if (c == '+' || c == '-' || c == ')')
			return t;
		L.removeFirst();
		
		if (c == '*')
			return new TreeNodeMultiply(t,parseMul(L));
		else if (c == '/')
			return new TreeNodeDivide(t,parseMul(L));
		else 
			throw new ParseException("Invalid character %c (expected * or /)",c);
	}
	public static TreeNode parseAdd(LinkedList<Character> L) throws ParseException {
		TreeNode t = parseMul(L);
		while(!L.isEmpty() && isWhitespace(L.getFirst()))
			L.removeFirst();
		if (L.isEmpty())
			return t;
		char c = L.getFirst();
		if (c == ')')
			return t;
		L.removeFirst();
		if (c == '+')
			return new TreeNodeAdd(t,parseAdd(L));
		else if (c == '-')
			return new TreeNodeSubtract(t,parseAdd(L));
		else 
			throw new ParseException("Invalid character %c (expected + or -)",c);
			
		
	}
	
	public static TreeNode parseString(String s){
		LinkedList<Character> L = new LinkedList<Character>();
		for(int i = 0; i < s.length(); i++)
			L.add(s.charAt(i));
		try{
			return parseAdd(L);
		}catch(ParseException e){
			int location = s.length() - L.size();
			System.out.printf("Parsing error:\n");
			System.out.printf("\t%s\n",s);
			System.out.printf("\t");
			for(int i = 0; i < location; i++)
				System.out.printf(" ");
			System.out.printf("^\n");
			System.out.printf("Error message: %s\n",e.message);
			return null;
		}
	}
	
	
	

	
	/* ******************************* main ******************************** */
	/* Code to test the functions above */
	/* ********************************************************************* */
	public static void main(String[] args){
		Scanner s;
		s = new Scanner(System.in);

		System.out.printf("Enter a function of x:\nf(x) = ");
		String formula = s.nextLine().trim();
		System.out.printf("\n");
		System.out.printf("Enter an x value:\nx = ");
		double x_value = s.nextDouble();
		System.out.printf("\n");
		System.out.printf("Original Formula: \"%s\"\n",formula);
		System.out.printf("Value of x: %.2f\n\n",x_value);
		
		long startTime = System.currentTimeMillis();
		
		TreeNode formulaTree = parseString(formula);
		if (formulaTree == null){
			System.out.printf("Exiting due to parsing error...\n");
			return;
		}
		
		System.out.printf("Parsed formula:\n\tf(x) = %s\n",formulaTree.toString());
		System.out.printf("\tf(%g) = %g\n\n",x_value, formulaTree.Evaluate(x_value));
		TreeNode derivativeTree = formulaTree.ComputeDerivative();
		
		System.out.printf("Derivative formula:\n\tf'(x) = %s\n",derivativeTree.toString());
		System.out.printf("\tf'(%g) = %g\n\n",x_value, derivativeTree.Evaluate(x_value));
		
		
		long endTime = System.currentTimeMillis();
		
		double totalTimeSeconds = (endTime-startTime)/1000.0;
		
		System.out.printf("Total Time (seconds): %.4f\n",totalTimeSeconds);
	}
}

