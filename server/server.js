const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');


// Set up Express app
const app = express();
const port = 3000;

// Middleware setup
app.use(cors());  // Allow cross-origin requests
app.use(bodyParser.json());

// Create MySQL connection
const db = mysql.createConnection({
    host: 'localhost',     // MySQL host
    user: 'root',          // MySQL username
    password: '123',       // MySQL password
    database: 'doctor_db'  // Database name
});

// Connect to the database
db.connect((err) => {
    if (err) {
        console.error('Database connection failed:', err);
        return;
    }
    console.log('Connected to MySQL database');
});

// Log Audit function
function logAudit(userId, action, description, resourceType, resourceId) {
    if (!userId) {
        console.error('Audit log requires a valid user ID');
        return;
    }

    console.log(`Logging audit for user ${userId} - Action: ${action} - Resource: ${resourceType} (ID: ${resourceId})`);

    const query = 'INSERT INTO audit_logs (user_id, action, description, resource_type, resource_id) VALUES (?, ?, ?, ?, ?)';
    db.query(query, [userId, action, description, resourceType, resourceId], (err, result) => {
        if (err) {
            console.error("Error logging audit:", err);
        } else {
            console.log("Audit log successfully inserted");
        }
    });
}

// Add a new customer (POST /customers)
app.post('/customers', (req, res) => {
    const { name, email, phone, address, dob, place_of_birth, userId } = req.body;

    if (!userId) {
        return res.status(400).json({ error: 'User ID is required for audit logging' });
    }

    const query = 'INSERT INTO customers (name, email, phone, address, dob, place_of_birth) VALUES (?, ?, ?, ?, ?, ?)';
    db.query(query, [name, email, phone, address, dob, place_of_birth], (err, results) => {
        if (err) {
            return res.status(500).json({ error: 'Error adding customer' });
        }

        logAudit(userId, 'CREATE', `Added customer ${name}`, 'Customer', results.insertId);
        res.status(201).json({ message: 'Customer added successfully', customerId: results.insertId });
    });
});

// Update customer (PUT /customers/:id)
app.put('/customers/:id', (req, res) => {
    const { id } = req.params;
    const { name, email, phone, address, dob, place_of_birth, userId } = req.body;

    const query = 'UPDATE customers SET name = ?, email = ?, phone = ?, address = ?, dob = ?, place_of_birth = ? WHERE id = ?';
    db.query(query, [name, email, phone, address, dob, place_of_birth, id], (err, results) => {
        if (err) {
            return res.status(500).json({ error: 'Error updating customer' });
        }

        logAudit(userId, 'UPDATE', `Updated customer ${name}`, 'Customer', id);
        res.json({ message: 'Customer updated successfully' });
    });
});

// Get all customers (GET /customers)
app.get('/customers/all', (req, res) => {
    db.query('SELECT * FROM customers', (err, results) => {
        if (err) {
            return res.status(500).json({ error: 'Error fetching customers' });
        }
        res.json(results);
    });
});

// Get customer by ID (GET /customers/:id)
app.get('/customers/:id', (req, res) => {
    const { id } = req.params;

    db.query('SELECT * FROM customers WHERE id = ?', [id], (err, results) => {
        if (err) {
            return res.status(500).json({ error: 'Error fetching customer' });
        }
        if (results.length === 0) {
            return res.status(404).json({ error: 'Customer not found' });
        }
        res.json(results[0]);
    });
});

// Delete customer (DELETE /customers/:id)
app.delete('/customers/:id', (req, res) => {
    const { id } = req.params;
    const { userId } = req.query; // Get userId from query parameters

    if (!userId) {
        return res.status(400).json({ error: 'User ID is required for audit logging' });
    }

    const query = 'DELETE FROM customers WHERE id = ?';
    db.query(query, [id], (err, results) => {
        if (err) {
            return res.status(500).json({ error: 'Error deleting customer' });
        }

        if (results.affectedRows > 0) {
            logAudit(userId, 'DELETE', `Deleted customer with ID ${id}`, 'Customer', id);
            res.json({ message: 'Customer deleted successfully' });
        } else {
            res.status(404).json({ error: 'Customer not found' });
        }
    });
});

// Add a new doctor
app.post('/doctors/add', (req, res) => {
    const { name, specialization, email, phoneNumber, rating, password } = req.body;

    // Check if all fields are provided
    if (!name || !specialization || !email || !phoneNumber || !rating || !password) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    const query = `
        INSERT INTO doctors (name, specialization, email, phoneNumber, rating, password)
        VALUES (?, ?, ?, ?, ?, ?)
    `;

    db.query(query, [name, specialization, email, phoneNumber, rating, password], (err, result) => {
        if (err) {
            console.error('Error adding doctor:', err);
            return res.status(500).json({ message: 'Error adding doctor', error: err });
        }

        // Log the action (Make sure userId is defined or passed correctly, for example through session or token)
        const userId = req.body.userId || 'unknown'; // Default user ID if not provided
        logAudit(userId, 'insert', `Added new doctor: ${name}`, 'doctor', result.insertId);

        // Send a single response once the doctor is added and action logged
        res.status(201).json({ message: 'Doctor added successfully' });
    });
});

// Get all doctors
app.get('/doctors', (req, res) => {
    const query = 'SELECT * FROM doctors';

    db.query(query, (err, result) => {
        if (err) {
            console.error('Error fetching doctors:', err);
            return res.status(500).json({ message: 'Error fetching doctors', error: err });
        }
        res.status(200).json(result);
    });
});

// Get a specific doctor by ID
app.get('/doctors/:id', (req, res) => {
    const { id } = req.params;

    const query = 'SELECT * FROM doctors WHERE id = ?';
    db.query(query, [id], (err, result) => {
        if (err) {
            console.error('Error fetching doctor:', err);
            return res.status(500).json({ message: 'Error fetching doctor', error: err });
        }

        if (result.length === 0) {
            return res.status(404).json({ message: 'Doctor not found' });
        }

        // Log the action
        const userId = req.body.userId || 'unknown'; // Default user ID if not provided
        logAudit(userId, 'update', `Viewed doctor: ${result[0].name}`, 'doctor', id);

        res.status(200).json(result[0]);
    });
});

// Update a doctor's details
app.put('/doctors/:id', (req, res) => {
    const doctorId = req.params.id;
    const { name, email, phoneNumber, specialization, rating, password } = req.body;
    const userId = req.body.userId || 'unknown'; // Default user ID if not provided

    // Prepare the SQL query to update the doctor's details
    const query = `
        UPDATE doctors
        SET name = ?, email = ?, phoneNumber = ?, specialization = ?, rating = ?, password = ?
        WHERE id = ?
    `;

    db.query(query, [name, email, phoneNumber, specialization, rating, password, doctorId], (err, result) => {
        if (err) {
            console.error('Error updating doctor:', err);
            return res.status(500).json({ message: 'Error updating doctor', error: err });
        }

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Doctor not found' });
        }

        // Log the action
        logAudit(userId, 'update', `Updated doctor details for ID ${doctorId}`, 'doctor', doctorId);

        res.status(200).json({ message: 'Doctor updated successfully' });
    });
});

// Delete a doctor
app.delete('/doctors/:id', (req, res) => {
    const { id } = req.params;
    const userId = req.body.userId || 'unknown'; // Default user ID if not provided

    const query = `DELETE FROM doctors WHERE id = ?`;

    db.query(query, [id], (err, result) => {
        if (err) {
            console.error('Error deleting doctor:', err);
            return res.status(500).json({ message: 'Error deleting doctor', error: err });
        }

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Doctor not found' });
        }

        // Log the action
        logAudit(userId, 'delete', `Deleted doctor with ID: ${id}`, 'doctor', id);

        res.status(200).json({ message: 'Doctor deleted successfully' });
    });
});

// Add Appointment (POST request)
app.post('/appointments/add', (req, res) => {
    const { doctorId, patientId, appointmentDate, status } = req.body;
    const userId = req.body.userId || 'unknown'; // Default user ID if not provided

    // Parse IDs as integers to prevent type mismatch
    const doctorIdParsed = parseInt(doctorId, 10);
    const patientIdParsed = parseInt(patientId, 10);

    // Validate inputs
    if (isNaN(doctorIdParsed) || isNaN(patientIdParsed)) {
        return res.status(400).json({ message: 'Invalid doctorId or patientId' });
    }

    const query = `INSERT INTO appointments (doctor_id, patient_id, appointment_date, status) VALUES (?, ?, ?, ?)`;


    db.query(query, [doctorIdParsed, patientIdParsed, appointmentDate, status], (err, result) => {
        if (err) {
            return res.status(500).json({
                message: 'Error booking appointment',
                error: err
            });
        }

        // Log the action
        logAudit(userId, 'insert', `Booked appointment with doctor ID: ${doctorIdParsed}`, 'appointment', result.insertId);

        res.status(201).json({ message: 'Appointment booked successfully' });
    });
});

// Endpoint to get all appointments
app.get('/appointments', (req, res) => {
    const query = `
        SELECT 
  appointments.id, 
  doctors.name AS doctor_name, 
  customers.name AS customer_name, 
  appointments.appointment_date, 
  appointments.status
FROM appointments
INNER JOIN doctors ON appointments.doctor_id = doctors.id
INNER JOIN customers ON appointments.patient_id = customers.id;
    `;

    db.query(query, (err, results) => {  // Use db.query here
        if (err) {
            console.error('Error fetching appointments:', err);  // Log the error for debugging
            return res.status(500).json({ message: 'Error fetching appointments', error: err });
        }
        res.json(results); // Return the list of appointments
    });
});


// Endpoint to edit an appointment
app.put('/appointments/:id', (req, res) => {
    const { doctor_id, patient_id, appointment_date, status } = req.body;
    const appointmentId = req.params.id;
    const userId = req.body.userId; // User who performed the action

    const query = `
      UPDATE appointments
      SET doctor_id = ?, patient_id = ?, appointment_date = ?, status = ?
      WHERE id = ?
    `;

    db.query(query, [doctor_id, patient_id, appointment_date, status, appointmentId], (err, results) => {
        if (err) return res.status(500).json({ message: 'Error updating appointment', error: err });

        // Log the audit action
        logAudit(userId, 'insert', `Created new user: ${name}`, 'user', result.insertId);
        res.json({ message: 'Appointment updated successfully' });
    });
});


// Endpoint to delete an appointment
// Endpoint to delete an appointment
app.delete('/appointments/:id', (req, res) => {
    const appointmentId = req.params.id;
    const userId = req.body.userId || 'unknown'; // Default user ID if not provided

    const query = `DELETE FROM appointments WHERE id = ?`;

    db.query(query, [appointmentId], (err, result) => {
        if (err) {
            console.error('Error deleting appointment:', err);
            return res.status(500).json({ message: 'Error deleting appointment', error: err });
        }

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Appointment not found' });
        }

        // Log the action
        logAudit(userId, 'delete', `Deleted appointment with ID: ${appointmentId}`, 'appointment', appointmentId);

        res.status(200).json({ message: 'Appointment deleted successfully' });
    });
});

// Create a new user
app.post('/users', (req, res) => {
    const { name, email, phoneNumber, role, password } = req.body;
    const userId = req.body.userId || 'unknown'; // Default user ID if not provided

    const query = `INSERT INTO users (name, email, phoneNumber, role, password) VALUES (?, ?, ?, ?, ?)`;

    db.query(query, [name, email, phoneNumber, role, hashedPassword], (err, result) => {
        if (err) {
            res.status(500).json({ message: 'Error creating user', error: err });
        } else {
            // Log the action
            logAudit(userId, 'insert', `Created new user: ${name}`, 'user', result.insertId);

            res.status(201).json({ message: 'User created successfully', userId: result.insertId });
        }
    });
});


// fetch all users
app.get('/users', (req, res) => {
    // Query the database to fetch all users
    // Replace 'users' with the actual table name in your database

    const query = `select * from users`;
    db.query(query, (err, results) => {
        if (err) {
            res.status(500).json({ message: 'Error fetching users', error: err });
        } else {
            res.status(200).json(results);
        }
    });
});

// Edit (Update) a user
app.put('/users/:id', (req, res) => {
    const userId = req.params.id; // ID of the user to be updated
    const { name, email, phoneNumber, role, password } = req.body;

    const query = `
        UPDATE users 
        SET 
            name = ?, 
            email = ?, 
            phoneNumber = ?, 
            role = ?, 
            password = ?
        WHERE id = ?
    `;

    const values = [name, email, phoneNumber, role, password, userId];

    db.query(query, values, (err, result) => {
        if (err) {
            res.status(500).json({ message: 'Error updating user', error: err });
        } else if (result.affectedRows === 0) {
            res.status(404).json({ message: 'User not found' });
        } else {
            // Log the action
            logAudit(userId, 'update', `Updated user: ${name}`, 'user', userId);

            res.status(200).json({ message: 'User updated successfully', affectedRows: result.affectedRows });
        }
    });
});


// Delete a user
app.delete('/users/:id', (req, res) => {
    const userId = req.params.id;

    const query = `DELETE FROM users WHERE id = ?`;

    db.query(query, [userId], (err, result) => {
        if (err) {
            res.status(500).json({ message: 'Error deleting user', error: err });
        } else {
            // Log the action
            logAudit(userId, 'delete', `Deleted user with ID: ${userId}`, 'user', userId);

            res.status(200).json({ message: 'User deleted successfully', affectedRows: result.affectedRows });
        }
    });
});

// Login endpoint
app.post('/login', (req, res) => {
    const { email, password } = req.body;

    // Query the database to find the user
    const query = `SELECT * FROM users WHERE email = ? AND password = ?`;

    db.query(query, [email, password], (err, results) => {
        if (err) {
            res.status(500).json({ message: 'Server error', error: err });
        } else if (results.length > 0) {
            const user = results[0];
            res.status(200).json({ role: user.role, message: 'Login successful' });
        } else {
            res.status(401).json({ message: 'Invalid email or password' });
        }
    });
});


// Login endpoint
app.post('/login', (req, res) => {
    const { email, password } = req.body;

    // Query the database to find the user
    const query = `SELECT * FROM users WHERE email = ? AND password = ?`;

    db.query(query, [email, password], (err, results) => {
        if (err) {
            res.status(500).json({ message: 'Server error', error: err });
        } else if (results.length > 0) {
            const user = results[0];
            res.status(200).json({ role: user.role, message: 'Login successful' });
        } else {
            res.status(401).json({ message: 'Invalid email or password' });
        }
    });
});
// Recently userAudit logs endpoint
app.get('/audit/recent', (req, res) => {
    db.query('SELECT * FROM audit_logs ORDER BY timestamp DESC LIMIT 50', (err, results) => {
        if (err) {
            console.error('Error fetching recent audits:', err);
            return res.status(500).json({ error: 'Internal server error' });
        }
        res.json(results); ``
    });
});



// Start the server
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
