import { createConnection } from 'mysql2';

const connection = createConnection('mysql://root:louHWjzobPJyuXHQcyCUdFFvuQjYOAOO@mysql.railway.internal:3306/railway');

connection.connect((err) => {
    if (err) {
        console.error('Error connecting to the database:', err.stack);
        return;
    }
    console.log('Connected to the database as id ' + connection.threadId);
});

export default connection;
