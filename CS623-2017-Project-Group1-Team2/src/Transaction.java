import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class Transaction {

	public static void main(String args[]) throws SQLException, IOException, ClassNotFoundException {
		
		// Load the PostgreSQL driver
		Class.forName("org.postgresql.Driver");
		
		// Connect to the database
		Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres?user=postgres&password=cs6232017");
		
		// For atomicity
		conn.setAutoCommit(false);		
		
		// For isolation 
		conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE); 
		
		Statement stmt = null;
		
		try {
			// create statement object
			stmt = conn.createStatement();
			
			//Before Delete
			System.out.println("BEFORE ! \n");
			
			ResultSet productbefore = stmt.executeQuery("SELECT * FROM cs623projectschema.product;");
			System.out.println("\t Product \t");
			
			while(productbefore.next()) {
				//Retrieve by column name
				//Product
				String prodid = productbefore.getString("prodid");
				String pname = productbefore.getString("pname");
				double price = productbefore.getDouble("price");
				// Display values
				System.out.print("Prodid: "+ prodid +"\t");
				System.out.print("Pname: "+ pname +"\t");
				System.out.print("Price: "+ price +"\t");
				System.out.println();	
			}
			System.out.println("\n");
			productbefore.close();
			
			ResultSet depotbefore = stmt.executeQuery("SELECT * FROM cs623projectschema.depot;");
			System.out.println("\t Depot \t");
			
				while(depotbefore.next()) {
					//Retrieve by column name
					//Depot
					String depid = depotbefore.getString("depid");
					String addr = depotbefore.getString("addr");
					int volume = depotbefore.getInt("volume");
					// Display values
					System.out.print("Depid: "+ depid +"\t");
					System.out.print("Addr: "+ addr +"\t");
					System.out.print("Volume: "+ volume +"\t");
					System.out.println();
				}
				System.out.println("\n");
				depotbefore.close();
		} catch (SQLException e) {
			System.out.println("catch Exception");
			e.printStackTrace();
			// For atomicity
			conn.rollback();
			stmt.close();
			conn.close();
			return;
		} // main
		conn.commit();
		stmt.close();
		conn.close();
	}
}
