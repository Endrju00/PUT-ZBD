/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package lab_jdbc;

import java.sql.*;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
/**
 *
 * @author student
 */
public class Lab_JDBC {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        Connection conn = null;
        String connectionString =
                "jdbc:oracle:thin:@//admlab2.cs.put.poznan.pl:1521/" +
                        "dblab02_students.cs.put.poznan.pl";
        Properties connectionProps = new Properties();
        connectionProps.put("user", "inf145358");
        connectionProps.put("password", "inf145358");

        try {
            conn = DriverManager.getConnection(connectionString,connectionProps);
            System.out.println("Połączono z bazą danych");
        } catch(SQLException ex) {
            Logger.getLogger(Lab_JDBC.class.getName()).log(Level.SEVERE, "Nie udało się połączyć z bazą danych", ex);
            System.exit(-1);
        }

//        zatrudnienieInfo(conn);
            sprawdzAsystentow(conn);
        try {
            conn.close();
        } catch (SQLException ex) {
            Logger.getLogger(Lab_JDBC.class.getName()).log(Level.SEVERE, null, ex);
        }
        System.out.println("Odłączono się od bazy danych");
    }

    // Zadanie 1
    private static void zatrudnienieInfo(Connection conn){
        try (Statement stmt1 = conn.createStatement();
             ResultSet rs= stmt1.executeQuery(
                     "select COUNT(nazwisko)" + "from pracownicy");

             Statement stmt2 = conn.createStatement();
             ResultSet nazwiska_zespoly = stmt2.executeQuery(
                     "select nazwisko, nazwa from pracownicy p "
                             + "left join zespoly z on p.id_zesp = z.id_zesp");
        ) {
            while(rs.next()) {
                System.out.println("Zatrudniono " + rs.getInt(1) + " pracownikow, w tym:");
            }

            while(nazwiska_zespoly.next()) {
                System.out.println(nazwiska_zespoly.getString(1) + " w zespole " + nazwiska_zespoly.getString(2) + ",");
            }
        } catch(SQLException ex) {
            System.out.println("Błąd wykonania polecenia: "+ ex.getMessage());
        }
    }

    // Zadanie 3
    private static void sprawdzAsystentow(Connection conn) {
        try(Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
                ResultSet.CONCUR_READ_ONLY);
            ResultSet rs = stmt.executeQuery(
                    "select nazwisko, placa_pod+COALESCE(placa_dod, 0) as placa" +
                            " from pracownicy where etat = 'ASYSTENT'" +
                            "order by placa desc"
            );
        ) {
            while(rs.next()){
                System.out.println(rs.getString(1));
            }
            rs.afterLast();
            if (rs.previous()) {
                System.out.println("Najmniej zarabia " +
                        rs.getString(1) + ", zarabia " + rs.getInt(2));
            }

            rs.absolute(2);
            if (rs.next()) {
                System.out.println("Trzeci asystent to " + rs.getString(1) +
                        ", zarabia " + rs.getInt(2));
            }

            rs.absolute(-3);
            if(rs.next()) {
                System.out.println("Przedostatni asystent to " + rs.getString(1) +
                        ", zarabia " + rs.getInt(2));
            }

        } catch (SQLException throwables) {
            throwables.printStackTrace();
        }
    }
}
