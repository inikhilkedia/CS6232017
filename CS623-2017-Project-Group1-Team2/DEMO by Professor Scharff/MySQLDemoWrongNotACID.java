import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * @author cscharff
 * Sample of JDBC for MySQL
 * Note that this code is wrong as ACID in not implemented 
 */

public class MySQLDemoWrongNotACID {

	/**
	 * @param args
	 * @throws ClassNotFoundException
	 * @throws SQLException
	 * @throws ClassNotFoundException
	 */
	public static void main(String args[]) throws SQLException,
			ClassNotFoundException {

		// Load the MySQL driver
		Class.forName("com.mysql.jdbc.Driver");

		// Connect to the database
		Connection conn = DriverManager
				.getConnection("jdbc:mysql://localhost:3306/test");

		Statement stmt = conn.createStatement();
		
		// create table student2007(Id integer, Name varchar(10));
		// I did not put any primary key such that this code can be executed several times
		
		stmt.executeUpdate("insert into student2017 values (1,'Smith')");

		stmt.executeUpdate("insert into student2017 values (2,'John')");
		
		ResultSet rs = stmt.executeQuery("select * from  student2017");
		
		while (rs.next()) {
			System.out.println("ID: " + rs.getInt("ID") + " NAME: "
					+ rs.getString("NAME"));
		}
	}
}