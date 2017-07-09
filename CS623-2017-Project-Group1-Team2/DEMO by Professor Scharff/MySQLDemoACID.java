import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * @author cscharff Sample of JDBC for MySQL ACID is implemented
 */

public class MySQLDemoACID {

	public static void main(String args[]) throws SQLException, IOException, ClassNotFoundException {

		// Load the MySQL driver
		Class.forName("com.mysql.jdbc.Driver");

		// Connect to the database
		Connection conn = DriverManager
				.getConnection("jdbc:mysql://localhost:3306/test");

		// For atomicity
		conn.setAutoCommit(false);
		
		// For isolation 
		conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE); 
		
		Statement stmt1 = null;
		try {
			// create statement object
			stmt1 = conn.createStatement();
			// Maybe a table student1 exists, maybe not
			// create table student1(Id integer, Name varchar(10), primary key(Id))
			// Either the 2 following inserts are executed, or none of them are. This is atomicity.
			stmt1.executeUpdate("insert into student1 values (1, 'stud1')");
			stmt1.executeUpdate("insert into student1 values (2, 'stud2')");
		} catch (SQLException e) {
			System.out.println("catch Exception");
			// For atomicity
			conn.rollback();
			stmt1.close();
			conn.close();
			return;
		} // main
		conn.commit();
		stmt1.close();
		conn.close();
	}
}
