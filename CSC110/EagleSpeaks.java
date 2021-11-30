import java.util.*;
public class EagleSpeaks{
    public static void printEagle() {
        System.out.println("\t        /");
        System.out.println("\\ \t      /*/");
        System.out.println(" \\\\\\\' ,      / //");
        System.out.println("  \\\\\\//    _/ //\'");
        System.out.println("   \\_-//\' /  //<\'   ");
        System.out.println("    \\*///  <//\'");
        System.out.println("    /  >>  *\\\\\\`");
        System.out.println("   /,)-^>>  _\\`");
        System.out.println("   (/   \\\\ / \\\\\\");
        System.out.println("        //  //\\\\\\");
        System.out.println("  /   ((");
        System.out.println(" /      ");
        
    }
    
    public static void speak() {
        Scanner console = new Scanner(System.in);
        String words = console.nextLine();
        printEagle();
        int x = words.length();
        System.out.print("*");
        //int i = x;
        for (int i = x;i <= x; i+=4 ){
            System.out.print("-");
        }
        System.out.println("*");
        System.out.print("|         ");
        System.out.print(words);
        System.out.println("          |");
        System.out.print("*");
        for (int i = x;i <= x; i+=4 ){
            System.out.print("-");
        }
        System.out.println("*");
    }
    public static void main(String[]args){
        speak();
    }
}