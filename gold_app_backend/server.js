const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');
require('dotenv').config();

// Tạo ứng dụng Express
const app = express();

// Middleware
app.use(cors());              // Cho phép Flutter gọi API
app.use(express.json());      // Đọc dữ liệu JSON từ request

// Kết nối MySQL
const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT || 3306,  // Thêm dòng này
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
});

// ============ API ============

// Kiểm tra server hoạt động
app.get('/', (req, res) => {
    res.json({ message: 'API Sổ Vàng đang hoạt động!' });
});

// 1. Lấy tất cả giao dịch (GET /api/transactions)
app.get('/api/transactions', async (req, res) => {
    try {
        const [rows] = await pool.query(
            'SELECT * FROM transactions ORDER BY date DESC'
        );
        res.json(rows);
    } catch (error) {
        console.error('Lỗi GET transactions:', error);
        res.status(500).json({ error: 'Lỗi server khi lấy dữ liệu' });
    }
});

// 2. Thêm giao dịch mới (POST /api/transactions)
app.post('/api/transactions', async (req, res) => {
    try {
        const { quantity, price, type, date } = req.body;
        
        // Kiểm tra dữ liệu đầu vào
        if (!quantity || !price || !type || !date) {
            return res.status(400).json({ error: 'Thiếu thông tin giao dịch' });
        }
        
        const [result] = await pool.query(
            'INSERT INTO transactions (quantity, price, type, date) VALUES (?, ?, ?, ?)',
            [quantity, price, type, date]
        );
        
        res.json({ 
            success: true, 
            id: result.insertId,
            message: 'Thêm giao dịch thành công'
        });
    } catch (error) {
        console.error('Lỗi POST transactions:', error);
        res.status(500).json({ error: 'Lỗi server khi thêm dữ liệu' });
    }
});

// 3. Xóa giao dịch (DELETE /api/transactions/:id)
app.delete('/api/transactions/:id', async (req, res) => {
    try {
        const { id } = req.params;
        
        const [result] = await pool.query(
            'DELETE FROM transactions WHERE id = ?',
            [id]
        );
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Không tìm thấy giao dịch' });
        }
        
        res.json({ success: true, message: 'Xóa thành công' });
    } catch (error) {
        console.error('Lỗi DELETE transactions:', error);
        res.status(500).json({ error: 'Lỗi server khi xóa dữ liệu' });
    }
});

// 4. Lấy tổng kết portfolio (tính tổng số vàng và chi phí)
app.get('/api/portfolio/summary', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT 
                SUM(quantity) as total_quantity,
                SUM(quantity * price) as total_cost
            FROM transactions
        `);
        
        res.json({
            total_quantity: rows[0].total_quantity || 0,
            total_cost: rows[0].total_cost || 0
        });
    } catch (error) {
        console.error('Lỗi GET portfolio summary:', error);
        res.status(500).json({ error: 'Lỗi server' });
    }
});

// Khởi động server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`\n🚀 Server đang chạy tại: http://localhost:${PORT}`);
    console.log(`📋 API danh sách giao dịch: http://localhost:${PORT}/api/transactions`);
    console.log(`💾 Database: ${process.env.DB_NAME}\n`);
});
//Kiểm tra API: http://localhost:3000/