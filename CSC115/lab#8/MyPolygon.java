/**
 * MyPolygon.java
 * @author B.Bultena
 * @version 1.0
 * Written exclusively for Uvic CSC115 201701, Lab 8.
 * Students are welcome to use and modify this code, provided they do
 * not claim it as their own.
 */
import java.awt.Polygon;
import java.awt.Graphics;
import java.util.ArrayList;


/**
 * MyPolygon is a Polygon with a couple extra features.
 * It consists of a list of MyPoint objects, lines are between consecutive points,
 * with a final line between the last point and the first, to close off the polygon.
 * A MyPolygon object must have at least three MyPoints and 
 * must not have all its points on the same line. 
 * It can be a simple polygon or a complex polygon.
 */
public class MyPolygon extends Polygon {

	ArrayList<MyPoint> points;
	// also uses the data fields from the Polygon class.
	/**
	 * Creates a new MyPolygon object that is determined by the array of points.
	 * The points remain in the exact order as the incoming array.
	 * @param points a full array of points.
	 * @throws RuntimeException if the polygon has fewer than three points,
	 *			or if all the points are collinear (all on the same line).
	 */
	public MyPolygon(MyPoint[] points) {
		super();
		if (points.length < 3) {
			throw new IllegalArgumentException("A polygon must have at least 3 points");
		}
		this.points = new ArrayList<MyPoint>(points.length);
		// fill up the MyPoint list and the underlying Polygon arrays.
		for (int i=0; i<points.length; i++) {
			this.points.add(points[i]);
			super.addPoint(points[i].x,points[i].y);
		}
		if (isCollinear()) {
			throw new IllegalArgumentException("The points in the polygon must not be collinear");
		}
	}

	/*
	 * Checks to make sure that all points in the list are not collinear.
	 * Assertion: There are at least three points in the polygon
	 * @return true if all points are collinear, false if they are not.
	 */
	private boolean isCollinear() {
		MyPoint a = points.get(0);
		boolean yes = true;
		try {	
			// grab an initial slope
			double m = a.slope(points.get(1));
			for (int i=2; i<npoints; i++) {
				if (a.slope(points.get(i)) != m) {
					yes = false;
					break;
				}
			}
		} catch (VerticalSlopeException vse) {
			// If all the x values are the same, not a polygon
			int x = a.x;
			for (int i=2; i<npoints; i++) {
				if (points.get(i).x != x) {
					yes = false;
					break;
				}
			}
		// in both cases we have to return the decided value.
		} finally {
			return yes;
		}
	}

	/** 
	 * Accesses the point at the given index position.
	 * @param index the valid position from 0 ... npoints-1.
	 * @return the point at that position.
	 */
	public MyPoint get(int index) {
		return points.get(index);
	}

	/**
	 * Updates a point at a given index position.
	 * @param index the valid position 0 ... npoints-1.
	 * @param p the new version of the point at that position.
	 */
	public void set(int index,MyPoint p) {
		points.set(index,p);
		// updating the super class' version:
		xpoints[index] = p.x;
		ypoints[index] = p.y;
	}

	/**
	 * Adds point to the end of the list of points in the polygon.
	 * @param p the point to add.
	 */
	public void addPoint(MyPoint p) {
		points.add(p);
		super.addPoint(p.x,p.y);
	}

	/**
	 * Adds a point with the given coordinates to the end
	 * of the list of points in the polygon.
	 * @param x The x value of a point.
	 * @param y The y value of a point
	 */
	public void addPoint(int x, int y) {
		addPoint(new MyPoint(x,y));
	}

	/**
	 * Inserts a point into the position of the list, where
	 * the list positions are numbered 0 ... npoints-1.
	 * All other points beyond this position move into a position that is
	 * one greater than their previous position.
	 * @param index The index position number.
	 * @param p The point to insert into the given position.
	 */
	public void insertAt(int index, MyPoint p) {
		points.add(index,p);
		// the super class does not allow this so it has be emptied and reset.
		super.reset();
		for (MyPoint point:  points) {
			super.addPoint(p.x,p.y);
		}
	}

	/**
	 * Draws the polygon on a panel.
	 * This method is generally called by the panel object.
	 * @param g The graphics object that is set to draw on the calling panel.
	 */
	public void drawMe(Graphics g) {
		g.drawPolygon(this);
	}

	// STUDENT WORK:
	// Complete this method as specified in the MyPolygon.html file.
	public MyPolygon rotateAndShrink() {
		MyPoint[] midpoints = new MyPoint[npoints];
		midpoints[0] = points.get(0).midPoint(points.get(npoints - 1));
		for(int i = 1; i < npoints; i++){
			midpoints[i] = points.get(i).midPoint(points.get(i-1));
		}
		return new MyPolygon(midpoints);
	}

	/**
	 * Returns a string representation of the polygon as a list of points.
	 * @return The string.
 	 */
	public String toString() {
		StringBuilder sb = new StringBuilder(npoints*10);
		sb.append("Polygon: "+points.get(0));
		for (int i=1; i<npoints; i++) {
			sb.append(","+points.get(i));
		}
		return sb.toString();
	}

	/**
	 * Used  as a unit tester.
	 * @param args not used for this class.
	 */
	public static void main(String[] args) {
		// start by checking for bad input
		MyPoint[] pts = new MyPoint[2];
		pts[0] = new MyPoint(0,0);
		pts[1] = new MyPoint(1,1);
		try {
			MyPolygon twoPts = new MyPolygon(pts);
		} catch (RuntimeException e) {
			System.out.println("Caught an expected exception with msg : "+e.getMessage());
		}
		pts = new MyPoint[3];
		pts[0] = new MyPoint(0,0);
		pts[1] = new MyPoint(1,1);
		pts[2] = new MyPoint(2,2);
		try {
			MyPolygon colin = new MyPolygon(pts);
		} catch (RuntimeException e) {
			System.out.println("Caught an expected exception with msg : "+e.getMessage());
		}
		pts = new MyPoint[3];
		pts[0] = new MyPoint(1,0);
		pts[1] = new MyPoint(1,1);
		pts[2] = new MyPoint(1,2);
		try {
			MyPolygon colin = new MyPolygon(pts);
		} catch (RuntimeException e) {
			System.out.println("Caught an expected exception with msg : "+e.getMessage());
		}
		// good input: 
		pts = new MyPoint[4];
		pts[0] = new MyPoint(0,0);
		pts[1] = new MyPoint(0,100);
		pts[2] = new MyPoint(1,1);
		pts[3] = new MyPoint(100,0);
		MyPolygon square = null;
		square = new MyPolygon(pts);
		System.out.println("bad square is "+square);
		square.set(2,new MyPoint(100,100));
		System.out.println("good square is "+square);
		MyPolygon littleSquare = square.rotateAndShrink();
		System.out.println("LittleSquare:"+littleSquare);
		square.insertAt(2,new MyPoint(3,3));
		System.out.println("pentagon from square is "+square);
	}
		
		
}
		
		
