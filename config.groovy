import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import com.liferay.portal.kernel.dao.jdbc.DataAccess;

def get_execute(query) {
Connection con = null;
Statement st = null;

def printColumns = true

try {
    con = DataAccess.getUpgradeOptimizedConnection();
    st = con.createStatement();
    ResultSet rs = st.executeQuery(query);
    ResultSetMetaData rsmd = rs.getMetaData();
    int columnCount = rsmd.getColumnCount();

    def columnNames = []
    for (int i = 1; i <= columnCount; i++ ) {
        columnNames << rsmd.getColumnName(i);
    }

    if (printColumns) {
        println(columnNames.join(" | "));
    }

	while (rs.next()) {
        if (printColumns) {
            vals = []
            for (int i = 1; i <= columnCount; i++ ) {
                vals << rs.getString(i)
            }
            println(vals.join(" | "));
        } else {
            for (int i = 1; i <= columnCount; i++ ) {
                println(columnNames[i - 1] + ": " + rs.getString(i));
            }
            println('==================================================');
        }
    }
}

finally {
	DataAccess.cleanUp(con, st);
}
}


def get_config(configurationid) {
    def query = "SELECT * FROM public.configuration_ where configurationid like '%"+configurationid+"%' "
    get_execute(query)
}

def get_update(configurationid ,value) {
    def query = "UPDATE table_name SET dictionary = '"+value+"' WHERE configurationid = '"+configurationid+"'"
    get_execute(query)
}

def get_delete(configurationid) {
    def query = "DELETE FROM public.configuration_ WHERE configurationid ='"+configurationid+"' "
    get_execute(query)
}
def get_add(configurationid ,value) {
    def query = "INSERT INTO public.configuration_(configurationid, dictionary) VALUES ('"+configurationid+"', '"+value+"')"
    get_execute(query)
}



get_config("com.liferay.account.internal.configuration.AccountEntryGroupConfiguration.scoped~6b1433b5-4d80-4c23-91c7-29814a7cb911")
