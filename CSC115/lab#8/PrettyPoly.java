/**
 * PrettyPoly.java
 * @author B.Bultena
 * @version 1.0
 * Written exclusively for UVic CSC115 201701 Lab 8.
 * Students are welcome to use and modify this code, provided
 * they do not claim it as their own.
 */
import java .awt.*;
import javax.swing.*;
import java.util.ArrayList;

/**
 * Class PrettyPoly is a panel that contains a drawing of 
 * a MyPolygon object that has repeated smaller versions of itself
 * in the drawing.
 */
public class PrettyPoly extends JPanel {

	private static final long serialVersionUID = 16L;

	private static final int DEFAULT_SIZE = 400;
	private static final int minDistance = 5;
	private ArrayList<MyPolygon> polys;


	/**
	 * Creates the panel and draws the pretty polygon picture.
	 * @param canvasSize The required dimensions of the panel to accommodate
	 *		the points of the polygon.
	 * @param p The initial polygon that will be the largest polygon.
 	 */
	public PrettyPoly(Dimension canvasSize,MyPolygon p) {
		super();
		this.setPreferredSize(canvasSize);
		polys = new ArrayList<MyPolygon>(10);
		makeAllPolys(p);
		repaint();
	}

	/**
	 * Draws the pretty polygon picture on a canvas of 400 X 400 pixels.
	 * @param p The initial polygon that will be the largest polygon.
	 */
	public PrettyPoly(MyPolygon p) {
		this(new Dimension(DEFAULT_SIZE,DEFAULT_SIZE),p);
	}

	/**
	 * Makes sure the pretty polygon is drawn whenever
	 * the window is adjusted.
	 */
	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		paintPolys(g);
	}

	/**
	 * Sets up the window and puts this frame into it.
	 * This method must be called directly after a PrettyPoly
	 * has been instantiated.
 	 * For example after the line:
	 *	<pre>
	 * PrettyPoly pp = new PrettyPoly(poly);
	 * pp.showFrame();
	 * </pre>
	 */ 
	public void showFrame() {
		JFrame frame = new JFrame("Pretty Poly");
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.setContentPane(this);
		frame.pack();
		frame.setVisible(true);
	}

	/*
 	 * A private method that calls each polygon's
	 * drawMe method.
	 * @param g The graphics object for this panel.
 	 */
	private void paintPolys(Graphics g) {
		for (MyPolygon p : polys) {
			p.drawMe(g);
		}
	}

	/*
 	 * A private method that generates all the polygons
	 * and stores them in the polys list.
	 * This method makes use of recursion to do so.
	 * @param The current polygon that generates all the smaller polygons.
	 */
	// STUDENT WORK:
	// This is the recursive method
	private void makeAllPolys(MyPolygon p) {
		if((p.get(0).distance(p.get(1)))> minDistance){
			polys.add(p);
			MyPolygon next = p.rotateAndShrink();
			makeAllPolys(next);
		}else{return;}
	}

	/**
	 * A place to test the drawing.
	 * Generally one PrettyPoly object is created at a time,
	 * but several windows can be created as well.
	 * @param args Not used for this class.
	 */
	public static void main(String[] args) {

		MyPoint[] pts = new MyPoint[4];
		// create a square that fits in the default size panel
		pts[0] = new MyPoint();
		pts[1] = new MyPoint(400,0);
		pts[2] = new MyPoint(400,400);
		pts[3] = new MyPoint(0,400);
/*
// This will draw a square.
		MyPolygon poly = new MyPolygon(pts);
		PrettyPoly pp = new PrettyPoly(poly);
		pp.showFrame();
*/
		MyPoint[] octPts = new MyPoint[8];
		octPts[0] = new MyPoint();
		octPts[1] = pts[0].midPoint(pts[1]);
		octPts[2] = new MyPoint(400,0);
		octPts[3] = pts[1].midPoint(pts[2]);
		octPts[4] = new MyPoint(400,400);
		octPts[5] = pts[2].midPoint(pts[3]);
		octPts[6] = new MyPoint(0,400);
		octPts[7] = pts[3].midPoint(pts[0]);
		MyPolygon oct = new MyPolygon(octPts);
		PrettyPoly pp2 = new PrettyPoly(oct);
		pp2.showFrame();

	}
}
