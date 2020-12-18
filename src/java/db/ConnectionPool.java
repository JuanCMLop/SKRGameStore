/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package db;

/**
 *
 * @author JuanCML
 */
import java.sql.*;
import javax.sql.DataSource;

public class ConnectionPool {

    private static ConnectionPool pool = null;
    private static DataSource dataSource = null;

    public static Connection getConnection() {
        Connection cn = null;
        try {
            Class.forName("com.mysql.jdbc.Driver");
            cn = DriverManager.getConnection("jdbc:mysql://localhost/gamestore","root","");
            System.out.println("Conexion satisfactoria");
        } catch (Exception e) {
            System.out.println("Error en la conexion");
        }
        return cn;

    }

//    private ConnectionPool() {
//        try {
//            InitialContext ic = new InitialContext();
//            dataSource = (DataSource) ic.lookup("java:/comp/env/jdbc/gamestore");
//        } catch (NamingException e) {
//            System.out.println(e);
//        }
//    }
    public static synchronized ConnectionPool getInstance() {
        if (pool == null) {
            pool = new ConnectionPool();
        }
        return pool;
    }

//    public Connection getConnection() {
//        try {
//            return dataSource.getConnection();
//        } catch (SQLException e) {
//            System.out.println(e);
//            return null;
//        }
//    }

    public void freeConnection(Connection c) {
        try {
            c.close();
        } catch (SQLException e) {
            System.out.println(e);
        }
    }
    
    public static void main(String[] args) {
        ConnectionPool.getConnection();
    }
}