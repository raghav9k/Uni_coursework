#include <stdio.h>

	/* pack_point(x,y)
   Given two 8-bit values x and y, return a single 16-bit value
   which represents the point (x,y).
	*/
	unsigned short int pack_point(unsigned char x, unsigned char y){
		unsigned short int result = x<<8|y;
		return result;
	}

	/* print_packed_point(P)
   Given a 16-bit value P representing an (x,y) point in the plane
   (in the format produced by pack_point), print the x and y coordinates
   in the format "Point: (x,y)" (for example "Point: (6,10)").
	*/
	void print_packed_point(unsigned short int P){
	unsigned char x, y;
	/* Put some code here to determine the values of x and y */
	y = P&255;
	x = P >> 8;
	printf("Point (%u, %u)\n", x, y);
	}


	/* Do not modify main() */
	int main(){

	unsigned short int P1, P2, P3;

	P1 = pack_point(6, 10);
	P2 = pack_point(17, 230);
	P3 = pack_point(225, 111);

	printf("Packed points: P1 = 0x%04x, P2 = 0x%04x, P3 = 0x%04x\n", P1, P2, P3);

	printf("Printing unpacked points\n");
	printf("P1 = ");
	print_packed_point(P1);
	printf("P2 = ");
	print_packed_point(P2);
	printf("P3 = ");
	print_packed_point(P3);

	return 0;
}