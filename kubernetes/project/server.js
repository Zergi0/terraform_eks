// server.js - Main Express.js application
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Database connection
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'password',
  database: process.env.DB_NAME || 'fruit_store'
};

let db;

// Initialize database connection
async function initDatabase() {
  try {
    db = await mysql.createConnection(dbConfig);
    console.log('Connected to MySQL database');
    
    // Create database if it doesn't exist
    await db.execute(`CREATE DATABASE IF NOT EXISTS ${dbConfig.database}`);
    await db.execute(`USE ${dbConfig.database}`);
    
    // Create tables
    await createTables();
    
    // Insert sample data
    await insertSampleData();
    
  } catch (error) {
    console.error('Database connection error:', error);
    process.exit(1);
  }
}

// Create database tables
async function createTables() {
  // Fruits table
  const fruitsTable = `
    CREATE TABLE IF NOT EXISTS fruits (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(100) NOT NULL,
      price DECIMAL(10, 2) NOT NULL,
      stock_quantity INT NOT NULL DEFAULT 0,
      description TEXT,
      category VARCHAR(50),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    )
  `;

  // Sales table
  const salesTable = `
    CREATE TABLE IF NOT EXISTS sales (
      id INT AUTO_INCREMENT PRIMARY KEY,
      customer_name VARCHAR(100) NOT NULL,
      customer_email VARCHAR(100),
      total_amount DECIMAL(10, 2) NOT NULL,
      sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `;

  // Sale items table (for detailed sale records)
  const saleItemsTable = `
    CREATE TABLE IF NOT EXISTS sale_items (
      id INT AUTO_INCREMENT PRIMARY KEY,
      sale_id INT NOT NULL,
      fruit_id INT NOT NULL,
      quantity INT NOT NULL,
      unit_price DECIMAL(10, 2) NOT NULL,
      subtotal DECIMAL(10, 2) NOT NULL,
      FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
      FOREIGN KEY (fruit_id) REFERENCES fruits(id) ON DELETE CASCADE
    )
  `;

  await db.execute(fruitsTable);
  await db.execute(salesTable);
  await db.execute(saleItemsTable);
  
  console.log('Database tables created successfully');
}

// Insert sample data
async function insertSampleData() {
  const checkFruits = await db.execute('SELECT COUNT(*) as count FROM fruits');
  
  if (checkFruits[0][0].count === 0) {
    const sampleFruits = [
      ['Apple', 1.50, 100, 'Fresh red apples', 'Citrus'],
      ['Banana', 0.80, 150, 'Ripe yellow bananas', 'Tropical'],
      ['Orange', 1.20, 80, 'Juicy oranges', 'Citrus'],
      ['Strawberry', 3.50, 60, 'Sweet strawberries', 'Berry'],
      ['Mango', 2.00, 40, 'Tropical mangoes', 'Tropical'],
      ['Grape', 2.80, 70, 'Purple grapes', 'Berry']
    ];

    for (const fruit of sampleFruits) {
      await db.execute(
        'INSERT INTO fruits (name, price, stock_quantity, description, category) VALUES (?, ?, ?, ?, ?)',
        fruit
      );
    }
    console.log('Sample fruit data inserted');
  }
}

// ENDPOINTS

// 1. GET /api/fruits - Get all fruits
app.get('/api/fruits', async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT * FROM fruits ORDER BY name');
    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching fruits',
      error: error.message
    });
  }
});

// 2. GET /api/fruits/:id - Get specific fruit by ID
app.get('/api/fruits/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await db.execute('SELECT * FROM fruits WHERE id = ?', [id]);
    
    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Fruit not found'
      });
    }
    
    res.json({
      success: true,
      data: rows[0]
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching fruit',
      error: error.message
    });
  }
});

// 3. POST /api/fruits - Add new fruit
app.post('/api/fruits', async (req, res) => {
  try {
    const { name, price, stock_quantity, description, category } = req.body;
    
    if (!name || !price || stock_quantity === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Name, price, and stock quantity are required'
      });
    }
    
    const [result] = await db.execute(
      'INSERT INTO fruits (name, price, stock_quantity, description, category) VALUES (?, ?, ?, ?, ?)',
      [name, price, stock_quantity, description || null, category || null]
    );
    
    res.status(201).json({
      success: true,
      message: 'Fruit added successfully',
      data: { id: result.insertId, name, price, stock_quantity, description, category }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error adding fruit',
      error: error.message
    });
  }
});

// 4. PUT /api/fruits/:id - Update fruit
app.put('/api/fruits/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, price, stock_quantity, description, category } = req.body;
    
    // Check if fruit exists
    const [existing] = await db.execute('SELECT * FROM fruits WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Fruit not found'
      });
    }
    
    await db.execute(
      'UPDATE fruits SET name = ?, price = ?, stock_quantity = ?, description = ?, category = ? WHERE id = ?',
      [name, price, stock_quantity, description, category, id]
    );
    
    res.json({
      success: true,
      message: 'Fruit updated successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error updating fruit',
      error: error.message
    });
  }
});

// 5. POST /api/sales - Create a new sale
app.post('/api/sales', async (req, res) => {
  const connection = await mysql.createConnection(dbConfig);
  
  try {
    await connection.beginTransaction();
    
    const { customer_name, customer_email, items } = req.body;
    
    if (!customer_name || !items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Customer name and items array are required'
      });
    }
    
    let total_amount = 0;
    
    // Validate items and calculate total
    for (const item of items) {
      const { fruit_id, quantity } = item;
      
      if (!fruit_id || !quantity || quantity <= 0) {
        await connection.rollback();
        return res.status(400).json({
          success: false,
          message: 'Each item must have valid fruit_id and positive quantity'
        });
      }
      
      // Check fruit availability
      const [fruitRows] = await connection.execute('SELECT * FROM fruits WHERE id = ?', [fruit_id]);
      
      if (fruitRows.length === 0) {
        await connection.rollback();
        return res.status(404).json({
          success: false,
          message: `Fruit with ID ${fruit_id} not found`
        });
      }
      
      const fruit = fruitRows[0];
      
      if (fruit.stock_quantity < quantity) {
        await connection.rollback();
        return res.status(400).json({
          success: false,
          message: `Insufficient stock for ${fruit.name}. Available: ${fruit.stock_quantity}, Requested: ${quantity}`
        });
      }
      
      total_amount += fruit.price * quantity;
    }
    
    // Create sale record
    const [saleResult] = await connection.execute(
      'INSERT INTO sales (customer_name, customer_email, total_amount) VALUES (?, ?, ?)',
      [customer_name, customer_email || null, total_amount]
    );
    
    const sale_id = saleResult.insertId;
    
    // Process each item
    for (const item of items) {
      const { fruit_id, quantity } = item;
      
      // Get current fruit data
      const [fruitRows] = await connection.execute('SELECT * FROM fruits WHERE id = ?', [fruit_id]);
      const fruit = fruitRows[0];
      
      const subtotal = fruit.price * quantity;
      
      // Insert sale item
      await connection.execute(
        'INSERT INTO sale_items (sale_id, fruit_id, quantity, unit_price, subtotal) VALUES (?, ?, ?, ?, ?)',
        [sale_id, fruit_id, quantity, fruit.price, subtotal]
      );
      
      // Update stock
      await connection.execute(
        'UPDATE fruits SET stock_quantity = stock_quantity - ? WHERE id = ?',
        [quantity, fruit_id]
      );
    }
    
    await connection.commit();
    
    res.status(201).json({
      success: true,
      message: 'Sale completed successfully',
      data: {
        sale_id,
        customer_name,
        customer_email,
        total_amount,
        items_count: items.length
      }
    });
    
  } catch (error) {
    await connection.rollback();
    res.status(500).json({
      success: false,
      message: 'Error processing sale',
      error: error.message
    });
  } finally {
    await connection.end();
  }
});

// 6. GET /api/sales - Get all sales with details
app.get('/api/sales', async (req, res) => {
  try {
    const query = `
      SELECT 
        s.id,
        s.customer_name,
        s.customer_email,
        s.total_amount,
        s.sale_date,
        JSON_ARRAYAGG(
          JSON_OBJECT(
            'fruit_name', f.name,
            'quantity', si.quantity,
            'unit_price', si.unit_price,
            'subtotal', si.subtotal
          )
        ) as items
      FROM sales s
      LEFT JOIN sale_items si ON s.id = si.sale_id
      LEFT JOIN fruits f ON si.fruit_id = f.id
      GROUP BY s.id
      ORDER BY s.sale_date DESC
    `;
    
    const [rows] = await db.execute(query);
    
    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching sales',
      error: error.message
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Something went wrong!',
    error: err.message
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found'
  });
});

// Start server
async function startServer() {
  await initDatabase();
  
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`API endpoints available:`);
    console.log(`  GET    /api/fruits     - Get all fruits`);
    console.log(`  GET    /api/fruits/:id - Get fruit by ID`);
    console.log(`  POST   /api/fruits     - Add new fruit`);
    console.log(`  PUT    /api/fruits/:id - Update fruit`);
    console.log(`  POST   /api/sales      - Create new sale`);
    console.log(`  GET    /api/sales      - Get all sales`);
  });
}

// Handle graceful shutdown
process.on('SIGINT', async () => {
  console.log('\nShutting down server...');
  if (db) {
    await db.end();
  }
  process.exit(0);
});

startServer().catch(console.error);