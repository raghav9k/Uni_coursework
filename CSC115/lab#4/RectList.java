public class RectList implements List{
	private RectNode first;
	private int count;
	private RectNode last;
	
		public RectList()
		{
			first = null;
			last = first;
			count =0;
		}
		public boolean isEmpty(){
			return count==0;
		}
		public int size(){
			return count;
		}
		public void append(Rectangle r){
			if(count==0){
				RectNode temp=new RectNode(r,null);
				last=temp;
				this.count++;
			}else{
			RectNode temp = new RectNode(r);
			last.next=temp;
			last=temp;
			this.count++;}
		}
		public void prepend(Rectangle r){
			if(count==0){
				RectNode temp =new RectNode(r,null);
				first=temp;
				last=first;
				count++;
			}else{
				RectNode temp =new RectNode(r,first);
				first = temp;
				this.count++;
			}
		}
		public int getIndex(Rectangle r){
			int index =-1;
			if (first==null){
				return index;
			}else{
				for(RectNode temp = first;temp != null;temp = temp.next){
					index++;
					if(temp.item.equals(r)){
						return index;
					}
				}return -1;
			}
		}
		public Rectangle findAtIndex(int index){
			if((index > count)||(first==null)){
				return null;
			}else{
			int counter=0;
			RectNode temp = first;
			while(counter<index){
				temp = temp.next;
				counter++;
			}return temp.item;
				}
		}
		public void remove(Rectangle r){
				int position = getIndex(r);
				if(position==-1){
					return;
				}
				if(position == 0){
					first=first.next;
				}else{
					RectNode current = first;
					RectNode previous = first;
					while(current!=null){
						if(current.item.equals(r)){
							previous.next=current.next;
							current=current.next;
						}else{
							previous=current;
							current=current.next;
						}
					}
					}
				count--;}
		public void insertAtPos(Rectangle r, int pos){
			if(pos==0){
				 
			}
		}
		public String toString(){
			StringBuilder sb= new StringBuilder(count*10);
			sb.append("List Size: "+count);
			for(RectNode temp=first;temp != null;temp=temp.next){
				sb.append("\n\t"+temp.item);
			}
			return sb.toString();
		}
	public static void main (String[]args){
		RectList rList = new RectList();
		System.out.println("An empty list:");
		System.out.println(rList);
		Rectangle r1 = new Rectangle(33,4);
		rList.prepend(r1);
		rList.prepend(new Rectangle());
		rList.prepend(new Rectangle(14,5));
		System.out.println("A list of 3 rectangles:");
		System.out.println(rList);
		rList.append(new Rectangle(10,15));
		rList.append(new Rectangle(102,115));
		System.out.println(rList);
		System.out.println(rList.getIndex(r1));
		System.out.println(rList.findAtIndex(2));
		rList.remove(r1);
		System.out.println(rList);
	}	
}