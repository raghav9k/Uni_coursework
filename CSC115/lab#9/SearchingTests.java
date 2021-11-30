import java.util.Collections;
import java.util.ArrayList;
import java.util.Random;
//The class searchingTests tries linear and binary search and returns the number of comparisons done for us to compare
public class SearchingTests {

	private static final String border = "*****************************************";
	ArrayList<Integer> list;
	//primeList method gernerates the list and randomly generates a value between 0 and number of elements
	 void primeList(int numElements) {
		Random r = new Random();
		list = new ArrayList<Integer>(numElements);
		for (int i=0; i<numElements; i++) {
			list.add(r.nextInt(numElements));
		}
		Collections.sort(list);
	}

	// Search for the target.
	// return the number of comparisons done.
	int linearSearch(Integer target) {
		int counter = 0;				//Keeps track of the number of comparison done.
		for(int i =0; i < list.size();i++){		//transverses through the array
			counter++;					//Increments counter on every search
			if(list.get(i).equals(target)){
				break;					//ends the if loop when condition is fulfilled
			}
		}
		return counter;					//returns the number of comparisons
	}

	// Search for the target
	// return the number of comparisons done.
	int binarySearch(Integer target) {
		int searches = binarySearchPriv(0,list.size(),target);  //uses recursion to update search variable 
		return searches;				//returns the number of comparisons
	}
	
	private int binarySearchPriv(int start, int end, Integer target){	//private binary search method to help implement recursion
		if(end-start==0){
			return 0;				//when our start and end are the same then there are no more searches
		}
		if(end-start==1){			//when we are down to last 2 indexes then we need only 1 more search
			return 1;
		}
		int mid = (start + end)/2;
		if(target.compareTo(list.get(mid))==0){		//when our given element equals element at middle index
			return 1;
		}
		else if(target.compareTo(list.get(mid))<0){		//when our target element is less than the middle element
			return 1 + binarySearchPriv(start,mid-1,target);	//implements recursion
		}else{											//when our target element is greater than the middle element
			return 1 + binarySearchPriv(mid+1,end,target);		//implements recurrsion
		}
	}

	// sample test.
	public static void main(String[] args) {
		int numElements = 100;
		int numTests = 10;
		SearchingTests test = new SearchingTests();
		test.primeList(numElements);
		Random rand = new Random();
		long linearSearchTotal = 0;
		long binarySearchTotal = 0;
		int target;
		for (int i=0; i<numTests; i++) {
			target = rand.nextInt(numElements);
			linearSearchTotal += test.linearSearch(target);
			binarySearchTotal += test.binarySearch(target);
		}
		System.out.println(border);
		System.out.println("Average number of comparisions for list of size "+numElements+":");
		System.out.printf("%-10s%-10s%-10s\n","Tests","Linear","Binary");
		System.out.printf("%-10s%-10s%-10s\n",numTests,linearSearchTotal/numTests,binarySearchTotal/numTests);
	}
} 
