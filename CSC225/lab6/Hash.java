/* 
   CSC 225 - Spring 2018

   M. Simpson & B. Bird - 07/04/2015
   Rahnuma Islam Nishat - Feb 27, 2018
*/

import java.util.Scanner;
import java.util.Vector;
import java.util.Arrays;
import java.io.File;
import java.lang.Math;

public class Hash{


	/* **************** METHODS **************** */
	
	//The size of the hash table. 
	//Do not change this value.
	public static final int TableSize = 225225;
	
	//The TableStorage object T represents the array used for the table.
	//To retrieve the element at index i, use the method T.getElement(i).
	//To set the element at index i to a value s, use the method T.setElement(i,s).
	//You must use only the object below to access the table values.
	TableStorage T = new TableStorage(TableSize);
	
	/* hash(s)
	   Return the hash code for the provided string.
	   The returned value must be in the range [0,TableSize-1]
	*/
	public int hash(String s){
		//TO DO: Write your code to compute the hashvalue of s
		int hash = 0;
		for(char ch: s.toCharArray()){
			hash = hash*31 + ch;
			hash = hash % TableSize;
		}
		
		return hash;
	}
	
	/* insert(s)
	   Insert the value s into the hash table and return the index at 
	   which it was stored.
	*/
	public int insert(String s){
	
		//Get the hash value of the string and start the search at that index.
		int i = hash(s);
		if(T.getElement(i)==null){T.setElement(i,s);
		return i;}
		//To DO: Use linear/quadratic probing to find an empty slot.
		int j = i;
			//int a =0;
		while(T.getElement(j)!=null){
			//a++;
			j ++;
			if(j==TableSize-1)j = 0;
			}
			T.setElement(j,s);
		return j;
	}
	
	/* find(s)
	   Search for the string s in the hash table. If s is found, return
	   the index at which it was found. If s is not found, return -1.
	*/
	public int find(String s){
	
		//Get the hash value of the string and start the search at that index.
		int i = hash(s);
		
		//To Do: Use linear/quadratic probing to find the string.
		if(T.getElement(i)==s)return i;
		else{
			int j = i;
			//int a =0;
		while((T.getElement(j)!=null)&&(T.getElement(j).equals(s)==false)){
			
			//a++;
			j++;
			if(j>TableSize-1)j = 0;
			}
			if(T.getElement(j)==null)return -1;
			return j;
		}
		
	}	
	
	/* **************************************************** */
	



	/* **************** TableStorage Class **************** */
	/* The hash table methods use this class to store
	   and retrieve table values. 
	*/
	public static class TableStorage{
		
		public TableStorage(int tableSize){
			table = new String[tableSize];
			resetProbeCount();
		}
		private String[] table;
		private long probeCount,lastProbed;
		public void resetProbeCount() { probeCount = 0; lastProbed = -1; }
		public long getProbeCount() { return probeCount; }
		
		public void setElement(int index, String value){
			table[index] = value;
		}
		public String getElement(int index){
			if (index != lastProbed)
				probeCount++;
			lastProbed = index;
			return table[index];
		}
	}
	/* **************************************************** */
	
	/* main()
	   Contains code to test the hash table methods. 
	*/
	public static void main(String[] args){
		Scanner s;
		boolean interactiveMode = false;
		if (args.length > 0){
			try{
				s = new Scanner(new File(args[0]));
			} catch(java.io.FileNotFoundException e){
				System.out.printf("Unable to open %s\n",args[0]);
				return;
			}
			System.out.printf("Reading input values from %s.\n",args[0]);
		}else{
			interactiveMode = true;
			s = new Scanner(System.in);
		}
		s.useDelimiter("\n");
		if (interactiveMode){
			System.out.printf("Enter a list of strings to store in the hash table, one per line.\n");
			System.out.printf("To end the list, enter '###'.\n");
		}else{
			System.out.printf("Reading table values from %s.\n",args[0]);
		}
		
		Vector<String> tableValues = new Vector<String>();
		Vector<String> searchValues = new Vector<String>();		
		String nextWord;
		
		while(s.hasNext() && !(nextWord = s.next().trim()).equals("###"))
			tableValues.add(nextWord);
		System.out.printf("Read %d strings.\n",tableValues.size());
		
		if (interactiveMode){
			System.out.printf("Enter a list of strings to search for in the hash table, one per line.\n");
			System.out.printf("To end the list, enter '###'.\n");
		}else{
			System.out.printf("Reading search values from %s.\n",args[0]);
		}	
		
		while(s.hasNext() && !(nextWord = s.next().trim()).equals("###"))
			searchValues.add(nextWord);
		System.out.printf("Read %d strings.\n",searchValues.size());
		
		Hash H = new Hash();
		long startTime, endTime;
		double totalTimeSeconds;
		long totalProbes = 0;
		long maxProbes = 0;
		
		totalProbes = 0;
		maxProbes = 0;
		startTime = System.currentTimeMillis();

		for(int i = 0; i < tableValues.size(); i++){
			H.T.resetProbeCount();
			String tableElement = tableValues.get(i);
			long index = H.insert(tableElement);
			long probeCount = H.T.getProbeCount();
			String insertedElement = (index >= 0)? H.T.getElement((int)index): null;
			if (insertedElement != null && !insertedElement.equals(tableElement))
				System.out.printf("Inserting \"%s\": Returned value does not match value inserted.\n",tableElement);
			if (probeCount > maxProbes)
				maxProbes = probeCount;
			totalProbes += probeCount;
		}
		endTime = System.currentTimeMillis();
		totalTimeSeconds = (endTime-startTime)/1000.0;
		
		System.out.printf("Inserted %d elements.\n Total Time (seconds): %.2f\n Total Probes: %d\n Max. Probes: %d\n",tableValues.size(),totalTimeSeconds, totalProbes, maxProbes);
		
		totalProbes = 0;
		maxProbes = 0;
		int foundCount = 0;
		int notFoundCount = 0;
		startTime = System.currentTimeMillis();

		for(int i = 0; i < searchValues.size(); i++){
			H.T.resetProbeCount();
			String searchElement = searchValues.get(i);
			long index = H.find(searchElement);
			long probeCount = H.T.getProbeCount();
			String foundElement = (index >= 0)? H.T.getElement((int)index): null;
			if (foundElement == null)
				notFoundCount++;
			else
				foundCount++;
			if (foundElement != null && !foundElement.equals(searchElement))
				System.out.printf("Search for \"%s\": Returned value does not match search string.\n",searchElement);
			if (probeCount > maxProbes)
				maxProbes = probeCount;
			totalProbes += probeCount;
		}
		endTime = System.currentTimeMillis();
		totalTimeSeconds = (endTime-startTime)/1000.0;
		
		System.out.printf("Searched for %d items (%d found, %d not found).\n Total Time (seconds): %.2f\n Total Probes: %d\n Max. Probes: %d\n",
							searchValues.size(),foundCount,notFoundCount,totalTimeSeconds, totalProbes, maxProbes);
	}
}

